#!/usr/bin/env bash
#
# GNU stow helpers: idempotent (re)stow with conflict backup, dry-run, and
# unstow. Depends on lib/log.sh being sourced first.

[[ -n "${_DOTFILES_STOW_SH:-}" ]] && return 0
_DOTFILES_STOW_SH=1

# Where conflicting real files get moved before stowing, so a fresh machine's
# stock dotfiles are preserved rather than clobbered.
: "${DOTFILES_BACKUP_DIR:=$HOME/.dotfiles-backup}"

###############################################################################
# List the target paths a package would create, relative to $HOME.
# Walks the package dir; every file/symlink maps to $HOME/<relpath>.
#
# @params
#   repo_dir - the dotfiles repo root
#   pkg      - the stow package name
# @output
#   one relative path per line
###############################################################################
stow::package_targets() {
  local repo_dir="$1" pkg="$2"
  local pkg_dir="$repo_dir/$pkg"
  [[ -d "$pkg_dir" ]] || return 0
  # -mindepth 1 so we skip the package dir itself; print paths relative to it.
  (cd "$pkg_dir" && find . \( -type f -o -type l \) -mindepth 1 | sed 's|^\./||')
}

###############################################################################
# Back up any existing REAL (non-symlink) files that a package would overwrite.
# Symlinks are left alone (stow -R handles its own links idempotently).
#
# @params
#   repo_dir  - the dotfiles repo root
#   pkg       - the stow package name
#   dry_run   - "1" to only report, not move
###############################################################################
stow::backup_conflicts() {
  local repo_dir="$1" pkg="$2" dry_run="${3:-}"
  local ts rel target backup_root manifest moved=0
  ts="$(date +%Y%m%d-%H%M%S)"
  backup_root="$DOTFILES_BACKUP_DIR/$ts"
  manifest="$backup_root/manifest.tsv"

  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    target="$HOME/$rel"
    # Only back up real files/dirs that are NOT already our symlinks.
    if [[ -e "$target" && ! -L "$target" ]]; then
      if [[ "$dry_run" == "1" ]]; then
        log::warn "would back up existing $target"
        continue
      fi
      mkdir -p "$backup_root/$(dirname "$rel")"
      mkdir -p "$backup_root"
      printf '%s\t%s\n' "$rel" "$backup_root/$rel" >>"$manifest"
      mv "$target" "$backup_root/$rel"
      log::warn "backed up existing $target -> $backup_root/$rel"
      moved=1
    fi
  done < <(stow::package_targets "$repo_dir" "$pkg")

  [[ "$moved" == "1" ]] && log::info "backups recorded in $manifest"
  return 0
}

###############################################################################
# Stow (or restow) a single package. Idempotent via --restow.
#
# @params
#   repo_dir - the dotfiles repo root
#   pkg      - the stow package name
#   dry_run  - "1" for `stow -n` (simulate only)
#   adopt    - "1" to `stow --adopt` (pull existing home files into repo)
###############################################################################
stow::link() {
  local repo_dir="$1" pkg="$2" dry_run="${3:-}" adopt="${4:-}"
  if [[ ! -d "$repo_dir/$pkg" ]]; then
    log::warn "stow package '$pkg' not found, skipping"
    return 0
  fi

  # --no-folding: create real directories and symlink individual files, rather
  # than folding a whole subtree into one dir-symlink. Critical for a $HOME
  # target: without it, stowing bin/.local/bin/* would fold ~/.local into a
  # symlink pointing at the repo, capturing ~/.local/share etc. inside the repo.
  local args=(--dir="$repo_dir" --target="$HOME" --restow --no-folding --verbose=1)
  [[ "$dry_run" == "1" ]] && args+=(--no)
  [[ "$adopt" == "1" ]] && args+=(--adopt)

  if [[ "$adopt" != "1" ]]; then
    stow::backup_conflicts "$repo_dir" "$pkg" "$dry_run"
  fi

  local label="$pkg"
  [[ "$dry_run" == "1" ]] && label="(dry-run) $pkg"
  log::info "stow $label"
  # In a real run, backup_conflicts has already moved conflicting files, so a
  # nonzero stow exit is a genuine error worth aborting on. In dry-run nothing
  # was moved, so stow may report conflicts it would otherwise resolve — treat
  # that as informational rather than fatal.
  if [[ "$dry_run" == "1" ]]; then
    stow "${args[@]}" "$pkg" || log::warn "(dry-run) '$pkg' has conflicts a real run would back up first"
  else
    stow "${args[@]}" "$pkg"
  fi
}

###############################################################################
# Unstow a single package (remove its symlinks).
###############################################################################
stow::unlink() {
  local repo_dir="$1" pkg="$2"
  [[ -d "$repo_dir/$pkg" ]] || return 0
  log::info "unstow $pkg"
  stow --dir="$repo_dir" --target="$HOME" --delete --verbose=1 "$pkg"
}

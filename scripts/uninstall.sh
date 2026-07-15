#!/usr/bin/env bash
#
# uninstall.sh — remove the symlinks this repo created (stow -D) and, on
# request, restore files that were backed up during install.
#
#   ./scripts/uninstall.sh                 # unstow every known package
#   ./scripts/uninstall.sh --preset dev    # unstow just that preset's packages
#   ./scripts/uninstall.sh --restore-latest # also restore the newest backup snapshot
#   ./scripts/uninstall.sh --dry-run
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/log.sh
source "$REPO_DIR/lib/log.sh"
# shellcheck source=lib/stow.sh
source "$REPO_DIR/lib/stow.sh"
# shellcheck source=lib/modules.sh
source "$REPO_DIR/lib/modules.sh"

PRESET=""
DRY_RUN=0
RESTORE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset | --profile)
      PRESET="$2"
      shift 2
      ;;
    --preset=* | --profile=*)
      PRESET="${1#*=}"
      shift
      ;;
    --restore-latest)
      RESTORE="latest"
      shift
      ;;
    --dry-run | -n)
      DRY_RUN=1
      shift
      ;;
    -h | --help)
      grep '^#' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      log::error "unknown arg: $1"
      exit 2
      ;;
  esac
done

# Which packages to remove: a preset's set, or every package across all modules.
if [[ -n "$PRESET" ]]; then
  if ! modules::is_preset "$PRESET"; then
    log::error "unknown preset: $PRESET"
    exit 2
  fi
  # Intentional word-splitting of the default module list into separate args.
  # shellcheck disable=SC2046,SC2086
  modules_list="$(modules::expand_deps $(modules::default_modules "$PRESET"))"
else
  modules_list="${MODULES_ALL[*]}"
fi
# shellcheck disable=SC2086
packages="$(modules::packages_for_modules $modules_list)"

log::step "unstow packages"
log::info "packages: $packages"
for pkg in $packages; do
  if [[ "$DRY_RUN" == 1 ]]; then
    log::info "(dry-run) would unstow $pkg"
    [[ -d "$REPO_DIR/$pkg" ]] && stow --dir="$REPO_DIR" --target="$HOME" --delete --no --verbose=1 "$pkg" || true
  else
    stow::unlink "$REPO_DIR" "$pkg"
  fi
done

if [[ "$RESTORE" == "latest" ]]; then
  log::step "restore latest backup snapshot"
  latest="$(find "$DOTFILES_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -1)"
  if [[ -z "$latest" || ! -f "$latest/manifest.tsv" ]]; then
    log::warn "no backup manifest found under $DOTFILES_BACKUP_DIR"
  else
    log::info "restoring from $latest"
    while IFS=$'\t' read -r rel saved; do
      [[ -z "$rel" ]] && continue
      if [[ "$DRY_RUN" == 1 ]]; then
        log::info "(dry-run) would restore $saved -> $HOME/$rel"
      else
        mkdir -p "$HOME/$(dirname "$rel")"
        mv "$saved" "$HOME/$rel"
        log::ok "restored $HOME/$rel"
      fi
    done <"$latest/manifest.tsv"
  fi
fi

log::ok "uninstall complete${DRY_RUN:+ (dry-run)}"

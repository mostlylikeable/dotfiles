#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  # Every test gets its own throwaway HOME so nothing touches the real one.
  TEST_HOME="$(mktemp -d)"
  export HOME="$TEST_HOME"
  # Keep backups inside the sandbox HOME (default is $HOME/.dotfiles-backup).
  unset DOTFILES_BACKUP_DIR
  unset XDG_CONFIG_HOME
}

teardown() {
  # Only remove clearly-sandboxed mktemp dirs, never a real HOME.
  if [[ -n "${TEST_HOME:-}" && ( "$TEST_HOME" == /var/* || "$TEST_HOME" == /tmp/* ) ]]; then
    rm -rf "$TEST_HOME"
  fi
  return 0
}

@test "install.sh --dry-run --non-interactive --preset headless exits 0 and creates NO symlinks" {
  run bash "$REPO/install.sh" --dry-run --non-interactive --preset headless
  assert_success
  # No symlinks may have been planted anywhere under the sandbox HOME.
  local links
  links="$(find "$HOME" -type l 2>/dev/null)"
  [[ -z "$links" ]] || {
    echo "unexpected symlinks created:" >&2
    echo "$links" >&2
    return 1
  }
  # dry-run must not persist selection
  [[ ! -f "$HOME/.config/dotfiles/selection" ]]
}

@test "conflict backup: a real \$HOME/.zshenv is moved to a backup dir with a manifest, then symlinked" {
  # Plant a stock (real, non-symlink) .zshenv the installer must not clobber.
  printf 'SENTINEL_ORIGINAL_ZSHENV\n' >"$HOME/.zshenv"
  [[ -f "$HOME/.zshenv" && ! -L "$HOME/.zshenv" ]]

  run bash "$REPO/install.sh" --only stow --non-interactive --preset headless --no-save
  assert_success

  # The installer should have symlinked our repo's .zshenv into place.
  [[ -L "$HOME/.zshenv" ]] || {
    echo ".zshenv is not a symlink after stow" >&2
    ls -la "$HOME" >&2
    return 1
  }

  # And the original real file must be preserved under a timestamped backup dir.
  [[ -d "$HOME/.dotfiles-backup" ]] || {
    echo "no backup dir created" >&2
    return 1
  }
  local backed_up
  backed_up="$(find "$HOME/.dotfiles-backup" -type f -name .zshenv | head -1)"
  [[ -n "$backed_up" ]] || {
    echo "planted .zshenv was not backed up" >&2
    find "$HOME/.dotfiles-backup" >&2
    return 1
  }
  grep -q "SENTINEL_ORIGINAL_ZSHENV" "$backed_up" || {
    echo "backup does not contain original content" >&2
    return 1
  }

  # A manifest.tsv recording the move must exist alongside it.
  local manifest
  manifest="$(find "$HOME/.dotfiles-backup" -type f -name manifest.tsv | head -1)"
  [[ -n "$manifest" ]] || {
    echo "no manifest.tsv recorded" >&2
    return 1
  }
  grep -q $'^\.zshenv\t' "$manifest" || {
    echo "manifest missing .zshenv row" >&2
    cat "$manifest" >&2
    return 1
  }
}

@test "install.sh persists selection and --with merges on re-run (dry-run still skips save)" {
  run bash "$REPO/install.sh" --only stow --non-interactive --preset headless
  assert_success
  [[ -f "$HOME/.config/dotfiles/selection" ]]
  grep -q '^modules=core git$' "$HOME/.config/dotfiles/selection"

  # Re-resolve with --with; dry-run must not overwrite the file, but should log aws.
  run bash "$REPO/install.sh" --dry-run --non-interactive --with aws --only stow
  assert_success
  assert_output --partial "aws"
  grep -q '^modules=core git$' "$HOME/.config/dotfiles/selection"
}

@test "install.sh --fresh ignores saved selection" {
  mkdir -p "$HOME/.config/dotfiles"
  cat >"$HOME/.config/dotfiles/selection" <<'EOF'
preset=dev
gui=1
modules=core git js aws gcp
EOF
  run bash "$REPO/install.sh" --dry-run --non-interactive --fresh --preset headless --no-save
  assert_success
  assert_output --partial "modules: core git"
  refute_output --partial "modules: core git js aws gcp"
}

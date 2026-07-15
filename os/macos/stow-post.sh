#!/usr/bin/env bash
#
# stow-post.sh — place config whose targets live under ~/Library (so they can't
# be plain-stowed into a clean $HOME subtree): VS Code + Cursor user settings
# and the iTerm2 dynamic profile. Idempotent (ln -sfn). GUI installs only.
#
#   bash os/macos/stow-post.sh
set -euo pipefail

[[ "$OSTYPE" == darwin* ]] || {
  echo "not macOS; skipping"
  exit 0
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_SUPPORT="$HOME/Library/Application Support"

link() {
  # link <source-in-repo> <dest>. Symlink so repo edits take effect live.
  local src="$1" dest="$2"
  [[ -f "$src" ]] || {
    echo "skip (missing): $src"
    return 0
  }
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}

echo "==> VS Code + Cursor settings"
for app in "Code" "Cursor"; do
  user_dir="$APP_SUPPORT/$app/User"
  # Only link into editors that are actually installed (their support dir exists).
  if [[ -d "$APP_SUPPORT/$app" ]]; then
    link "$REPO_DIR/os/macos/vscode/settings.json" "$user_dir/settings.json"
    link "$REPO_DIR/os/macos/vscode/keybindings.json" "$user_dir/keybindings.json"
  else
    echo "skip (not installed): $app"
  fi
done

echo "==> iTerm2 dynamic profile"
link "$REPO_DIR/os/macos/iterm2/DynamicProfile.json" \
  "$APP_SUPPORT/iTerm2/DynamicProfiles/dotfiles.json"

echo "app config placement done."

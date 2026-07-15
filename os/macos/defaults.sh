#!/usr/bin/env bash
#
# macOS system defaults. Invoked by install.sh's `macos` phase (GUI installs
# only). Every setting is idempotent — re-running just re-asserts the value.
# Conservative on purpose: sensible developer ergonomics, nothing destructive.
#
# Run directly with:  bash os/macos/defaults.sh
set -euo pipefail

[[ "$OSTYPE" == darwin* ]] || {
  echo "not macOS; skipping"
  exit 0
}

# Ask for the admin password upfront and keep the sudo timestamp alive so the
# handful of sudo settings below don't each prompt.
sudo -v

echo "==> keyboard & input"
# Fast key repeat (great for vim/terminal navigation).
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Full keyboard access: Tab moves between all controls.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Disable press-and-hold in favor of key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Disable "smart" quotes/dashes/auto-capitalize (they mangle code).
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "==> finder"
# Show all filename extensions and the path/status bars.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# Keep folders on top when sorting by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Search the current folder by default (not the whole Mac).
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Avoid creating .DS_Store on network/USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# No warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "==> dock"
# Auto-hide, smaller icons, don't rearrange Spaces by most-recent use.
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 44
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock show-recents -bool false

echo "==> screenshots"
# Save screenshots to ~/Screenshots as PNG without window shadows.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

echo "==> misc"
# Expand save/print panels by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
# Save to disk (not iCloud) by default.
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# Disable the "Are you sure you want to open this application?" dialog.
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "==> restarting affected apps (Finder, Dock, SystemUIServer)"
for app in Finder Dock SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

echo "macOS defaults applied. Some changes require a logout/restart to take full effect."

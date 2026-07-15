#!/usr/bin/env bash
# shellcheck shell=bash
#
# macOS-only shell helpers. Sourced from functions.zsh behind an $OSTYPE guard,
# so a future sh/os/linux.sh can drop in alongside it without touching callers.

[[ -n "${_DOTFILES_OS_MACOS_SH:-}" ]] && return 0
_DOTFILES_OS_MACOS_SH=1

# lock the screen
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

##########################################
# Show hidden files in Finder.
##########################################
finder::show() { defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder; }

##########################################
# Hide hidden files in Finder.
##########################################
finder::hide() { defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder; }

##########################################
# Show desktop icons.
##########################################
desktop::show() { defaults write com.apple.finder CreateDesktop -bool true && killall Finder; }

##########################################
# Hide desktop icons.
##########################################
desktop::hide() { defaults write com.apple.finder CreateDesktop -bool false && killall Finder; }

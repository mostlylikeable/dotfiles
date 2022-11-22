#!/usr/bin/env bash

# lock screen
# https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

##########################################
# Configure Finder to show hidden files
##########################################
finder::show() {
  defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
}

##########################################
# Configure Finder to hide hidden files
##########################################
finder::hide() {
  defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder
}

##########################################
# Show Desktop icons
##########################################
desktop::show() {
  defaults write com.apple.finder CreateDesktop -bool true && killall Finder
}

##########################################
# Hide Desktop icons
##########################################
desktop::hide() {
  defaults write com.apple.finder CreateDesktop -bool false && killall Finder
}

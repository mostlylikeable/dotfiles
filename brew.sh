#!/usr/bin/env bash
#
# Configure Homebrew
# https://github.com/mathiasbynens/dotfiles/blob/main/brew.sh

# Ensure we're up to date
echo "Updating brew"
brew update

# Upgrade formulas
echo "Upgrading formulae"
brew upgrade

# Save homebrew's location
BREW_PREFIX=$(brew --prefix)

# Install GNU core utils (osx utils are outdated)
# https://www.gnu.org/software/coreutils/manual/html_node/index.html
brew install coreutils

# Map GNU sha256sum to sha256sum
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Add GNU utils to path
export PATH=${BREW_PREFIX}/libexec/gnubin:$PATH

# Install more useful utils
# https://joeyh.name/code/moreutils/
brew install moreutils

# Install GNU find utils
# https://www.gnu.org/software/findutils/
brew install findutils

# Install GNU `sed` and overwrite built-in
# https://www.gnu.org/software/sed/
brew install gnu-sed
ln -s "${BREW_PREFIX}/bin/gsed" "${BREW_PREFIX}/bin/sed"

# Install modern bash
brew install bash
brew install bash-completion@2

# Switch to brew bash as default shell
if ! grep -F -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install more recent versions of some osx tools
brew install vim
brew install grep
brew install openssh
brew install screen
brew install php
brew install gmp

# Install other useful tools
brew install ack
brew install git
brew install jq
brew install python3

# 7zip archive formatter
# https://github.com/jinfeihan57/p7zip
brew install p7zip

# parallel gzip
# https://zlib.net/pigz/
brew install pigz

# pipe-viewer
# https://www.ivarch.com/programs/pv.shtml
brew install pv

# Colored directory tree viewer
# https://mama.indstate.edu/users/ice/tree/
brew install tree

##################
# AWS
##################

# https://formulae.brew.sh/formula/awscli
brew install awscli

##################
# Docker
##################

# Dive docker image exploration tool
# https://formulae.brew.sh/formula/dive
brew install dive

##################
# Terraform
##################

brew tap hashicorp/tap
brew install hashicorp/tap/terraform

##################
# React Native
##################

# Facebook tool for watching files
# https://formulae.brew.sh/formula/watchman
brew install watchman

# CocaaPods (for iOS dev)
# https://formulae.brew.sh/formula/cocoapods
brew install cocoapods

# Ruby version manager (for ReactNative)
# https://formulae.brew.sh/formula/rbenv
brew install rbenv ruby-build

# Apple iOS Simulator tools
# https://github.com/wix/AppleSimulatorUtils
brew tap wix/brew
brew install applesimutils

# Remove outdated versions from the cellar
brew cleanup

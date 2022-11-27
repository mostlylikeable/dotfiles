#!/usr/bin/env bash
#
# Inspired by:
#   https://github.com/mathiasbynens/dotfiles/blob/main/.bash_prompt

# export SHELL=bash

# Switch to bash shell
# chsh -s $(which bash)

export EDITOR=vim

# Add home bin to
export PATH="$HOME/bin:$PATH"

# US English and UTF-8
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Highlight section titles (blue) in manual pages
# https://github.com/mathiasbynens/dotfiles/blob/main/.exports
# shellcheck disable=SC2155
export LESS_TERMCAP_md="$(printf '\e[34m')"

# Don’t clear the screen after quitting a manual page
# https://github.com/mathiasbynens/dotfiles/blob/main/.exports
export MANPAGER='less -X'

#!/usr/bin/env bash
# shellcheck shell=bash
#
# Terminal / environment settings.
# Inspired by https://github.com/mathiasbynens/dotfiles/blob/main/.bash_prompt
#
# NOTE: PATH is assembled exactly once in zsh/.zshenv (see AGENTS.md rule 6),
# so this module deliberately does NOT touch PATH.

[[ -n "${_DOTFILES_TERM_SH:-}" ]] && return 0
_DOTFILES_TERM_SH=1

export EDITOR=vim

# US English and UTF-8
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Highlight section titles (blue) in manual pages.
# https://github.com/mathiasbynens/dotfiles/blob/main/.exports
LESS_TERMCAP_md="$(printf '\033[34m')"
export LESS_TERMCAP_md

# Don't clear the screen after quitting a manual page.
export MANPAGER='less -X'

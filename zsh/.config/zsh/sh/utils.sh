#!/usr/bin/env bash
# shellcheck shell=bash
#
# Miscellaneous utility helpers.

[[ -n "${_DOTFILES_UTILS_SH:-}" ]] && return 0
_DOTFILES_UTILS_SH=1

# List pids (pid and name) that match a pattern
alias pids="util::pids"

# Generate a uuid and copy it
alias uuid="util::uuid"

# List processes using a port
alias whoport="util::who_port"

###############################################################################
# List pids and process name that match a pattern.
#
# @params
#   pattern - the pattern
# @output
#   the process and pid that matches the pattern
###############################################################################
util::pids() {
  pgrep -l "$1"
}

###############################################################################
# Generate a random uuid and copy it to the clipboard.
#
# @output
#   the generated uuid (also copied to clipboard)
###############################################################################
util::uuid() {
  uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | pbcopy
  pbpaste
}

###############################################################################
# List processes using a port.
#
# @params
#   port - the port to search for
# @output
#   the list of processes using the port
###############################################################################
util::who_port() {
  lsof -i "tcp:$1"
}

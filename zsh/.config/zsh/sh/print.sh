#!/usr/bin/env bash
# shellcheck shell=bash
#
# Print utilities. Uses printf '\033[' so the first emitted byte is a real ESC
# (0x1b), never a literal backslash-e as a bare `echo` would produce in bash.
#
# "$*" expands to one argument, with all args joined -- appropriate here for
# appending to a message string.

[[ -n "${_DOTFILES_PRINT_SH:-}" ]] && return 0
_DOTFILES_PRINT_SH=1

##########################################
# Prints an error message (bold red) to stderr.
#
# @params
#   * - args to print
##########################################
print::error() {
  printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2
}

##########################################
# Prints an info message (white) to stdout.
#
# @params
#   * - args to print
##########################################
print::info() {
  printf '\033[37m%s\033[0m\n' "$*"
}

##########################################
# Prints a debug message (gray) to stdout.
#
# @params
#   * - args to print
##########################################
print::debug() {
  printf '\033[2;37m%s\033[0m\n' "$*"
}

##########################################
# Prints a success/ok message (bold green) to stdout.
#
# @params
#   * - args to print
##########################################
print::ok() {
  printf '\033[1;32m%s\033[0m\n' "$*"
}

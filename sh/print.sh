#!/usr/bin/env bash
#
# Print utilities
#
# "$*" expands to one argument, with all args joined.
# This is non-standard but appropriate for appending to string.
# Typically, "$@" is the correct choice.

##########################################
# Prints an error message
#
# @params
#   * - args to print
# @output
#   error message to stderr (bold red)
##########################################
print::error() {
  echo "\e[1;31mERROR: $*\e[0m" >&2
}

##########################################
# Prints an info message
#
# @params
#   * - args to print
# @output
#   info message to stdout (white)
##########################################
print::info() {
  echo "\e[37m$*\e[0m"
}

##########################################
# Prints a debug message
#
# @params
#   * - args to print
# @output
#   debug message to stdout (gray)
##########################################
print::debug() {
  echo "\e[2;37m$*\e[0m"
}

##########################################
# Prints a success/ok message
#
# @params
#   * - args to print
# @output
#   success message to stdout (bold green)
##########################################
print::ok() {
  echo "\e[1;32m$*\e[0m"
}

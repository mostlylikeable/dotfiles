#!/usr/bin/env bash
# shellcheck shell=bash
#
# Tint/color a string with ANSI escape codes.
# @refs
#   https://google.github.io/styleguide/shellguide.html
#   https://github.com/fidian/ansi/blob/master/ansi
#   https://github.com/bertvv/dotfiles/blob/main/.bash.d/colors.sh

[[ -n "${_DOTFILES_TINT_SH:-}" ]] && return 0
_DOTFILES_TINT_SH=1

# shellcheck source=./print.sh
source "${ZDOTDIR}/sh/print.sh"

###############################################################################
# Tints or colors a string.
#
# @params
#   $1 - color name
#   $2 - string to apply the color to
# @output
#   the tinted string
# @examples
#   tint green "this text is green"
#   tint GREEN "this text is bold green"
###############################################################################
tint() {
  local color
  color="$(tint::str_to_ansi_color "$1")"
  printf '\033[%s%s\033[0m' "$color" "$2"
}

###############################################################################
# Converts a color name to an ANSI escape code (sans the leading ESC[).
#
# An UPPERCASE color name yields the bold variant.
#
# @params
#   $1 - color name
# @output
#   the ANSI code for the color, e.g. '32m' or '1;32m'
# @examples
#   tint::str_to_ansi_color green ==> '32m'
#   tint::str_to_ansi_color GREEN ==> '1;32m'
###############################################################################
tint::str_to_ansi_color() {
  # $_ is always the last arg to the previous command, and `:` always succeeds,
  # so $_ equals what was passed to `:`. This lets us return that instead of
  # saving to a var in each case.
  # https://github.com/dylanaraps/pure-bash-bible#simpler-case-statement-to-set-variable
  case "$1" in
    'black') : '30m' ;;
    'BLACK') : '1;30m' ;;
    'red') : '31m' ;;
    'RED') : '1;31m' ;;
    'green') : '32m' ;;
    'GREEN') : '1;32m' ;;
    'yellow') : '33m' ;;
    'YELLOW') : '1;33m' ;;
    'blue') : '34m' ;;
    'BLUE') : '1;34m' ;;
    'purple') : '35m' ;;
    'PURPLE') : '1;35m' ;;
    'cyan') : '36m' ;;
    'CYAN') : '1;36m' ;;
    'white') : '37m' ;;
    'WHITE') : '1;37m' ;;
    *)
      print::error "Unknown color: '$1'"
      : '0m' # return reset to noop
      ;;
  esac
  printf '%s' "$_"
}

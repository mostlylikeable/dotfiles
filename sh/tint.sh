#!/usr/bin/env bash

# TODO: make this work with pipe as well
# get stdin. ex: via pipe
# cat < /dev/stdin
#
# random things for inspiration/reference
# https://google.github.io/styleguide/shellguide.html
# https://github.com/fidian/ansi/blob/master/ansi
# https://github.com/bertvv/dotfiles/blob/main/.bash.d/colors.sh

# shellcheck disable=SC1091
source "${DOTFILES_DIR}/bash/print.sh"

###############################################################################
# Tints or colors a string
#
# @params
#   $1 - color
#   $2 = string to apply color to
# @output
#   tinted string
# @examples
#   echo "$(tint green "this text is green")"
#   echo "$(tint GREEN "this text is bold green")"
# @refs
#   https://google.github.io/styleguide/shellguide.html
#   https://github.com/fidian/ansi/blob/master/ansi
#   https://github.com/bertvv/dotfiles/blob/main/.bash.d/colors.sh
###############################################################################
tint() {
  local color
  color="$(tint::str_to_color "$1")"
  printf '%s' "\e[${color}${2}\e[0m"
}

###############################################################################
# Converts a color name to an asci code.
#
# UPPERCASE color name results in bold code.
#
# @params
#   $1 - color name
# @output
#   The ascii escape for the color
# @examples
#   time::str_to_ansi_color green ==> '32m'
#   time::str_to_ansi_color GREEN ==> '32m'
###############################################################################
tint::str_to_ansi_color() {
  # https://github.com/dylanaraps/pure-bash-bible#simpler-case-statement-to-set-variable
  # $_ is always the last arg to previous cmd, and : always succeeds, so $_
  # will equal what was passed to :, and we can return that instead of saving
  # to a var in each case.
  case "$1" in
    'black')
      : '30m'
      ;;
    'BLACK')
      : '1;30m'
      ;;
    'red')
      : '31m'
      ;;
    'RED')
      : '1;31m'
      ;;
    'green')
      : '32m'
      ;;
    'GREEN')
      : '1;32m'
      ;;
    'yellow')
      : '33m'
      ;;
    'YELLOW')
      : '1;33m'
      ;;
    'blue')
      : '34m'
      ;;
    'BLUE')
      : '1;34m'
      ;;
    'purple')
      : '35m'
      ;;
    'PURPLE')
      : '1;35m'
      ;;
    'cyan')
      : '36m'
      ;;
    'CYAN')
      : '1;36m'
      ;;
    'white')
      : '37m'
      ;;
    'WHITE')
      : '1;37m'
      ;;
    *)
      print::error "Unknown color: '$1'"
      : '0m' # return reset to noop
      ;;
  esac
  printf '%s' "$_"
}

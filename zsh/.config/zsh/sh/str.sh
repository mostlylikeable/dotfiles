#!/usr/bin/env bash
# shellcheck shell=bash
#
# String utilities.
# https://github.com/dylanaraps/pure-bash-bible#strings

[[ -n "${_DOTFILES_STR_SH:-}" ]] && return 0
_DOTFILES_STR_SH=1

###############################################################################
# Removes leading and trailing whitespace.
#
# @params
#   str - to trim
# @output
#   str with leading and trailing spaces trimmed
# @examples
#   str::trim "  foo  " ==> "foo"
###############################################################################
str::trim() {
  # rtrim spaces
  : "${1#"${1%%[![:space:]]*}"}"
  # ltrim spaces
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}

###############################################################################
# Lowercase a string.
#
# @params
#   * - args to lowercase (joined by a single space)
# @output
#   lowercased args separated by space
# @examples
#   str::lower FoO BAR ==> "foo bar"
###############################################################################
str::lower() {
  printf '%s\n' "$(tr '[:upper:]' '[:lower:]' <<<"$*")"
}

###############################################################################
# Uppercase a string.
#
# @params
#   * - args to uppercase (joined by a single space)
# @output
#   uppercased args separated by space
# @examples
#   str::upper FoO bar ==> "FOO BAR"
###############################################################################
str::upper() {
  printf '%s\n' "$(tr '[:lower:]' '[:upper:]' <<<"$*")"
}

###############################################################################
# Remove first occurrence of 'term' from 'str'.
#
# @params
#   str  - the string to search
#   term - the term/string to remove
# @output
#   The original string with the first occurrence of 'term' removed, or
#   unchanged if 'term' is not found.
# @examples
#   str::remove "foo bar foo" "foo" ==> " bar foo"
###############################################################################
str::remove() {
  printf '%s\n' "${1/$2/}"
}

###############################################################################
# Remove all occurrences of 'term' from 'str'.
#
# @params
#   str  - the string to search
#   term - the term/string to remove
# @output
#   The original string with all occurrences of 'term' removed, or unchanged
#   if 'term' is not found.
# @examples
#   str::remove_all "foo bar foo" "foo" ==> " bar "
###############################################################################
str::remove_all() {
  printf '%s\n' "${1//$2/}"
}

###############################################################################
# Strip a prefix from a string.
#
# @params
#   str    - the string to strip
#   prefix - the prefix
# @output
#   The original string with 'prefix' stripped, or unchanged if not present.
# @examples
#   str::lstrip "foo bar foo" "foo " ==> "bar foo"
###############################################################################
str::lstrip() {
  printf '%s\n' "${1##"$2"}"
}

###############################################################################
# Strip a suffix from a string.
#
# @params
#   str    - the string to strip
#   suffix - the suffix
# @output
#   The original string with 'suffix' stripped, or unchanged if not present.
# @examples
#   str::rstrip "foo bar foo" " foo" ==> "foo bar"
###############################################################################
str::rstrip() {
  printf '%s\n' "${1%%"$2"}"
}

#!/usr/bin/env bash
#
# String utilities
#
# https://github.com/dylanaraps/pure-bash-bible#strings

# TODO: make these work with piped input

###############################################################################
# Removes leading and trailing whitespace
#
# : built-in always succeeds and $_ returns the arg, so this can be used in
# place of a temp var
#
# @params
#   str - to trim
# @output
#   str with leading and trailing spaces trimmed
# @examples
#   str::trim "  foo "
#     ==> "foo"
###############################################################################
str::trim() {
  # rtrim spaces
  : "${1#"${1%%[![:space:]]*}"}"
  # ltrim spaces
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}

###############################################################################
# Lowercase a string
#
# @params
#   * - args to lowercase
# @output
#   lowercased args separated by space
# @examples
#   str::lower FoO BAR baZ
#     ==> foo bar baz
###############################################################################
str::lower() {
  # printf '%s\n' "${1,,}"
  printf '%s\n' "$(tr '[:upper:]' '[:lower:'] <<< "$@")"
}

###############################################################################
# Uppercase a string
#
# @params
#   * - args to uppercase
# @output
#   uppercased args separated by space
# @examples
#   str::upper FoO BAR baZ
#     ==> FOO BAR BAZ
###############################################################################
str::upper() {
  # printf '%s\n' "${1^^}"
  printf '%s\n' "$(tr '[:lower:]' '[:upper:'] <<< "$@")"
}

###############################################################################
# Remove first occurrence of 'term' from 'str'
#
# @params
#   str - the string to serach
#   term - the term/string to remove
# @output
#   The original string with first occurrence of 'term' removed, or unchanged
#   if 'term' not found.
# @examples
#   str::remove "foo bar foo" "foo"
#     ==> " bar foo"
###############################################################################
str::remove() {
  printf '%s\n' "${1/$2}"
}

###############################################################################
# Remove all occurrences from string
#
# @params
#   str - the string to serach
#   term - the term/string to remove
# @output
#   The original string with all occurrences of 'term' removed, or unchanged
#   if 'term' not found.
# @examples
#   str::remove "foo bar foo" "foo"
#     ==> " bar "
###############################################################################
str::remove_all() {
  printf '%s\n' "${1//$2}"
}

###############################################################################
# Strip prefix from string
#
# @params
#   str - the string to strip
#   prefix - the prefix
# @output
#   The original string with prefix stripped, or unchanged if 'term' not found.
# @examples
#   str::lstrip "foo bar foo" "foo "
#     ==> "bar foo"
###############################################################################
str::lstrip() {
  printf '%s\n' "${1##"$2"}"
}

###############################################################################
# Strip suffix from string
#
# @params
#   str - the string to strip
#   suffix - the suffix
# @output
#   The original string with suffix stripped, or unchanged if 'term' not found.
# @examples
#   str::rstrip "foo bar foo" " foo"
#     ==> "foo bar"
###############################################################################
str::rstrip() {
  printf '%s\n' "${1%%"$2"}"
}

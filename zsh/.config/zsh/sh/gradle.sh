#!/usr/bin/env bash
# shellcheck shell=bash
#
# Gradle helpers.

[[ -n "${_DOTFILES_GRADLE_SH:-}" ]] && return 0
_DOTFILES_GRADLE_SH=1

# shellcheck source=./fs.sh
source "${ZDOTDIR}/sh/fs.sh"

# Run gradle command
alias gr="gradle::run"

# Gradle clean alias
alias grc="gradle::run clean"

# Gradle build alias
alias grb="gradle::run build"

# Gradle build with no build cache
alias grB="gradle::run build --no-build-cache"

# Gradle clean and build
alias grcb="gradle::run clean build"

# Gradle clean and build with no build cache
alias grcB="gradle::run clean build --no-build-cache"

# Configure gradle wrapper for project
alias grap="gradle::wrap"

###############################################################################
# Runs a gradle command, preferring a 'gradlew' if one can be found up the dir
# tree, otherwise executing via 'gradle'.
#
# Allows aliases to work from a subdir of a project with a 'gradlew'.
#
# @params
#   * - args to pass to `gradlew` or `gradle` (if no `gradlew` is found)
###############################################################################
gradle::run() {
  # try to find gradle wrapper in pwd or a dir above
  local wrapper
  wrapper=$(fs::find_up gradlew)
  if [ -z "$wrapper" ]; then
    echo "Gradle wrapper not found. Using 'gradle'"
    gradle "$@"
  else
    "$wrapper" "$@"
  fi
}

###############################################################################
# Configure the gradle wrapper with the provided version.
#
# @params
#   version - the gradle version for the wrapper
###############################################################################
gradle::wrap() {
  gradle wrapper --gradle-version "$1"
}

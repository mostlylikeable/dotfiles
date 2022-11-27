#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${DOTFILES_DIR}/sh/fs.sh"

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
# Runs gradle command, preferring a 'gradlew' if one can be found up the dir
# tree, otherwise executing via 'gradle'.
#
# Allows aliases to work from subdir of project with a 'gradlew'
#
# @params
#   * - args to pass to `gradlew` or `gradle` (if no `gradlew` found)
###############################################################################
gradle::run() {
  # try to find gradle wrapper in pwd or a dir above
  local wrapper
  wrapper=$(upfind gradlew)
  if [ -z "$wrapper" ]; then
    echo "Gradle wrapper not found. Using 'gradle'"
    gradle "$@"
  else
    $wrapper "$@"
  fi
}

###############################################################################
# Configure gradle wrapper with provided version
#
# @params
#   version - the gradle version for the wrapper
###############################################################################
gradle::wrap() {
  gradle wrapper --gradle-version "$1"
}

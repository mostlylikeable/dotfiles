#!/usr/bin/env bash
# dev.sh

################################################################################
# Gradle
################################################################################

alias narc='gradle codenarcMain codenarcTest'

# exec gradle wrapper in current or parents
function gradle() {
  gw="$(upfind gradlew)"
  if [ -z "$gw" ]; then
    echo "Gradle wrapper not found."
  else
    $gw $@
  fi
}

function gwrap() {
  gradle wrapper --gradle-version $1
}

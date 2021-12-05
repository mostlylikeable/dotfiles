#!/usr/bin/env bash
# dev.sh

alias narc='gw codenarcMain codenarcTest'

# exec gradle wrapper in current or parents
function gw {
  local gw="$(upfind gradlew)"
  if [ -z "$gw" ]; then
    echo "Gradle wrapper not found."
    gradle $@
  else
    $gw $@
  fi
}

function gwrap {
  gradle wrapper --gradle-version $1
}

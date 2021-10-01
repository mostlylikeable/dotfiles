#!/usr/bin/env bash
# dev.sh

alias narc='gradle codenarcMain codenarcTest'

# exec gradle wrapper in current or parents
function gradle {
  local gw="$(upfind gradlew)"
  if [ -z "$gw" ]; then
    echo "Gradle wrapper not found."
  else
    $gw $@
  fi
}

function gwrap {
  gradle wrapper --gradle-version $1
}

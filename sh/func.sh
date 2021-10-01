#!/usr/bin/env bash
# func.sh

function status() {
  echo "\033[1m> ${1}\033[0m"
}

function uuid() {
  uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | pbcopy
  pbpaste
}

# list all files in long format, excluding . and ..
function la() {
  ls -lA ${1:-.}
}

# list pids for process matching $1
function pids() {
  ps aux | grep "[${1:0:1}]${1:1}" | awk '{print $2}'
}

# get port for $1
function wport() {
  lsof -iTCP:$1 -sTCP:LISTEN
}

function post() {
  curl -i -X POST -H "Content-Type: application/json" -d $1 $2
}

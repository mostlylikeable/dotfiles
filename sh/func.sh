#!/usr/bin/env bash
# func.sh

function status() {
  echo "\033[1m> ${1}\033[0m"
}

function uuid() {
  uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | pbcopy
  pbpaste
}

# find $1 in current dir, or parents
function upfind() {
  dir=`pwd`
  while [ "$dir" != "/" ]; do
    p=`find "$dir" -maxdepth 1 -name $1`
    if [ ! -z $p ]; then
      echo "$p"
      return
    fi
    dir=`dirname "$dir"`
  done
}

# mkdir -> cd
function mcd() {
  mkdir -p "$1" && cd "$1"
}

# find shorthand
# https://github.com/nicksp/dotfiles/blob/master/shell/shell_functions
function f() {
  find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

# List all files, long format, colorized, permissions in octal
function la() {
   ls -l  "$@" | awk '
    {
      k=0;
      for (i=0;i<=8;i++)
        k+=((substr($1,i+2,1)~/[rwx]/) *2^(8-i));
      if (k)
        printf("%0o ",k);
      printf(" %9s  %3s %2s %5s  %6s  %s %s %s\n", $3, $6, $7, $8, $5, $9,$10, $11);
    }'
}

# https://unix.stackexchange.com/questions/74185/how-can-i-prevent-grep-from-showing-up-in-ps-results
function pids() {
  # ps aux | grep "[o]auth" | awk '{print $2}'
  ps aux | grep "[${1:0:1}]${1:1}" | awk '{print $2}'
}

function wport() {
  lsof -iTCP:$1 -sTCP:LISTEN
}

# override rm to send to trash (timestamped) instead
function rm() {
    local path
    for path in "$@"; do
        # ignore any arguments
        if [[ "$path" = -* ]]; then :
        else
            local dst=${path##*/}
            # append the time if necessary
            while [ -e ~/.Trash/"$dst" ]; do
                dst="$dst $(/bin/date +%H-%M-%S)"
            done
            /bin/mv "$path" ~/.Trash/"$dst"
        fi
    done
}

function post() {
  curl -i -X POST -H "Content-Type: application/json" -d $1 $2
}

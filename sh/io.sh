#!/usr/bin/env bash
# io.sh

function dexists {
  [[ -d $1 ]] && true || false
}

function dempty {
  if ! dexists $1; then
    echo "$1 dir not found" >&2
    exit 2
  fi

  [[ ! "$(ls -A $1)" ]] && true || false
}

# mkdir and cd into it
function mkcd() {
  mkdir -p "$1" && cd "$1"
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

# find shorthand
# https://github.com/nicksp/dotfiles/blob/master/shell/shell_functions
function f() {
  find . -name "$1" 2>&1 | grep -v 'Permission denied'
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

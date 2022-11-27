#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${DOTFILES_DIR}/sh/print.sh"

# cd up 1
alias ..="cd .."

# cd up 2
alias ...="cd ../.."

# cd up 3
alias ....="cd ../../.."

# cd up 4
alias .....="cd ../../../.."

# cd Home
alias ~="cd ~"

# cd Downloads
alias dl="cd ~/Downloads"

# cd Documents
alias docs="cd ~/Documents"

# List long, mark types, size
alias l="ls -lFh"

# >ist long, all but '.', '..', mark types, size
alias la="ls -lAFh"

# List long, ordered, all but '.', '..', mark types, size
alias lo="ls -lAFth"

# List dirs
alias lsd="ls -lF | grep --color=never '^d'"

# Create and enter a dir
alias mkcd="fs::mkdir_enter"

# Find files in pwd by name
alias fname="fs::find"

alias upfind="fs::find_up"

# Send files to Trash
alias trash="fs::trash"

# Override rm to send to trash
# Yes, this is probably terrible, but appeases my anxiety...
alias rm="fs::trash"

###############################################################################
# Create a directory and cd to it
#
# @params
#   dir - dir to create
###############################################################################
fs::mkdir_enter() {
  mkdir -p "$1" && cd "$_" || return;
}

###############################################################################
# Test if a directory exists
#
# @params
#   dir - the directory
###############################################################################
fs::dir_exists() {
  [[ -d $1 ]]
}

###############################################################################
# Test if a directory is empty
#
# @params
#   dir - the directory
###############################################################################
fs::is_dir_empty() {
  fs::dir_exists "$1" && [[ ! "$(ls -A "$1")" ]]
}

###############################################################################
# Find files by name in $PWD
#
# @params
#   pattern - name pattern to look for
# @output
#   the list of matches
###############################################################################
fs::find() {
  find . -name "$1"
}

###############################################################################
# Walk up directory tree from $PWD, looking for file
#
# @params
#   pattern - name pattern to look for
# @output
#   the full path to matches
###############################################################################
fs::find_up() {
  local dir=$PWD
  local found
  while [ "$dir" != "/" ]; do
    echo "checking ${dir} for ${1}"
    found=$(find "$dir" -maxdepth 1 -name "$1")
    if [ -n "$found" ]; then
      realpath "$found"
      return
    fi
    dir=$(dirname "$dir")
  done

  print::error "$1 not found" && false
}

###############################################################################
# Send files to trash (timestamped)
#
# @params
#   * - list of files to send to trash
###############################################################################
fs::trash() {
    local path
    for path in "$@"; do
        if [[ "$path" == -* ]]; then
          # ignore any arguments
          :
        else
            local dst=${path##*/}
            # append the time if necessary, avoiding collisions
            while [ -e ~/.Trash/"$dst" ]; do
                dst="$dst $(/bin/date +%H-%M-%S)"
            done
            /bin/mv "$path" ~/.Trash/"$dst"
        fi
    done
}

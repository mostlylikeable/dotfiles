#!/usr/bin/env bash
# env.sh

export SHELL=/bin/zsh
export EDITOR=vim
export LC_ALL="en_US.UTF-8"

export PATH="/usr/local/sbin:$HOME/bin:$PATH"

: ${DEV_DIR=${HOME}/dev}
export DEV_DIR
alias dev='cd $DEV_DIR'

# make dev repos cd'able from anywhere
if [[ "$(ls -A $DEV_DIR)" ]]; then
  export CDPATH=$DEV_DIR$(ls -dm $DEV_DIR/*/ | tr -d ' ' | tr ',' ':'):$CDPATH
fi
export CDPATH=$DEV_DIR:$CDPATH

# use python3 instead of 2x default in osx
alias python=/usr/bin/python3

alias src='. ~/.zshrc'

# bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

# sdkman
# if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
#   source "$HOME/.sdkman/bin/sdkman-init.sh"
# fi

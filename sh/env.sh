#!/usr/bin/env bash
# env.sh

# default shell
export SHELL=/bin/zsh

# default editor
export EDITOR=vim

# use english + utf-8
export LC_ALL="en_US.UTF-8"

# groovy/grails
# export GVM_HOME=$HOME/.gvm
# export GRAILS_HOME=$GVM_HOME/grails/current
# export GROOVY_HOME=$GVM_HOME/groovy/current

# java
# export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

export PATH="/usr/local/sbin:$HOME/bin:$PATH"

export MY_DEV_DIR=${HOME}/dev/me
alias me='cd $MY_DEV_DIR'
# add personal repos to cd path
# export CDPATH=$(ls -dm $TARGET_DEV_DIR/*/ | tr -d ' ' | tr ',' ':'):$CDPATH
export CDPATH=$MY_DEV_DIR

# bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

alias python=/usr/bin/python3

alias src='. ~/.zshrc'

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
#[[ -s "$HOME/.gvm/bin/gvm-init.sh" && -z $(which gvm-init.sh | grep '/gvm-init.sh') ]] && source "$HOME/.gvm/bin/gvm-init.sh"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" && -z $(which sdkman-init.sh | grep '/sdkman-init.sh') ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
#source "$HOME/.sdkman/bin/sdkman-init.sh"

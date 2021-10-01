#!/usr/bin/env bash
# git.sh

function init-git-aliases() {
  git config --global alias.co checkout
  git config --global alias.cl clone
  git config --global alias.br 'branch'
  git config --global alias.cm commit
  git config --global alias.st status
  git config --global alias.ss 'stash save'
  git config --global alias.sp 'stash pop'
  git config --global alias.sa 'stash apply'
  git config --global alias.sls 'stash list'
  git config --global alias.unstage 'reset HEAD --'
  git config --global alias.last 'log -1 HEAD'
  git config --global alias.ls 'log --oneline --decorate'
  git config --global alias.rau 'remote add upstream'
  git config --global alias.rls 'remote -v'
  git config --global alias.fu 'fetch upstream'

  # squash
  git config --global alias.sq 'rebase -i HEAD~${1:-2}'

  # undo commit
  git config --global alias.undo 'reset --soft HEAD~${1:1}'

  git config --global alias.cu 'checkout -b $1 upstream/$1'
}

function local_branch_exists() {
  if [ ! -z "$(git branch --list $1)" ]; then
    echo "$1 branch exists"
    return 0
  else
    echo "$1 branch does not exist"
    return 1
  fi
}

function remote_branch_exists() {
  if [ ! -z "$(git branch -r --list $1)" ]; then
    echo "$1 remote branch exists"
    return 0
  else
    echo "$1 branch does not exist"
    return 1
  fi
}

function tag_exists() {
  if [ $(git tag -l "$1") ]; then
    echo "$1 tag exists"
    return 0
  else
    echo "$1 tag does not exist"
    return 1
  fi
}

init-git-aliases

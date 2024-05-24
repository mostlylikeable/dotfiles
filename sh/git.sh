#!/usr/bin/env bash

# # Enable zsh command completion
# autoload -U +X compinit && compinit

# shellcheck disable=SC1091
source "${DOTFILES_DIR}/sh/fs.sh"
# shellcheck disable=SC1091
source "${DOTFILES_DIR}/sh/print.sh"

# Alias git and configure zsh for tab completion
alias g="git"
# compdef g=git

# Git clone & cd
alias clone="git::clone_cd"

# Uncomment for bash
# # Enable tab completion for `g` by marking it as an alias for `git`
# # https://github.com/mathiasbynens/dotfiles/blob/main/.bash_profile
# if type _git &> /dev/null; then
# 	complete -o default -o nospace -F _git g;
# fi;

# The git prompt's git commands are read-only and should not interfere with
# other processes. This environment variable is equivalent to running with `git
# --no-optional-locks`, but falls back gracefully for older versions of git.
# See git(1) for and git-status(1) for a description of that flag.
#
# We wrap in a local function instead of exporting the variable directly in
# order to avoid interfering with manually-run git commands by the user.
#
# @see https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh
git::cmd() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

###############################################################################
# Determines if script is running in a git repo
###############################################################################
git::in_a_repo() {
  # check for a .git dir
  git::cmd rev-parse --git-dir &> /dev/null
}

###############################################################################
# Get the short name of HEAD ref
###############################################################################
git::head() {
  local head
  head=$(git::cmd symbolic-ref --short HEAD 2> /dev/null)
  echo "$head"
}

###############################################################################
# Clone a git repo and cd into project dir
#
# @params
#   url - the repo url (ssh or https)
###############################################################################
git::clone_cd() {
  local repo_name
  repo_name="$(git::repo_from_url "$1")"
  if fs::dir_exists "./${repo_name}"; then
    print::error "${repo_name} dir already exists"
    return 0
  fi

  git::cmd clone --recursive "$1" && cd "$repo_name" || return 0
}

###############################################################################
# Get the name of the repo from a url
#
# @params
#   url - the repo's url
# @example
#   git::repo_from_url "https://github.com/mostlylikeable/dotfiles.git"
#     ==> "dotfiles"
#   git::repo_from_url "git@github.com:mostlylikeable/dotfiles.git"
#     ==> "dotfiles"
###############################################################################
git::repo_from_url() {
  local base
  base="$(basename "$1")"
  echo "${base%.*}"
}
###############################################################################
# Get the current branch name
###############################################################################
git::current_branch() {
  local ref
  ref=$(git::cmd symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(git::cmd rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo "${ref#refs/heads/}"
}

# see: https://gist.github.com/eeichinger/1044107a1126901249b1164dac2fce15
git-rpull() {
  local dir;
  for f in */.git/; do
    if [[ -d "$f" && ! -L "$f" ]]; then
      dir=$(dirname $f);
      echo "\e[1;32m...::: Updating: $dir :::...\e[0m";
      echo "\e[1;32mººººººººººººººººº$(printf 'º%.0s' {1..${#dir}})ººººººº\e[0m";
      (pushd $dir >/dev/null; git-pull-main "$@" || exit 2);
      echo ""
    fi
  done
}

git-pull-main() {
  local cmd current_br main_br stash_pre stash_post;

  [[ "$1" = "-d" || "$1" = "--dryrun" ]] && shift && cmd=echo;

  # get current branch
  current_br=$(git rev-parse --abbrev-ref HEAD 2>/dev/null);
  echo "\e[2;37m  Current branch: ${current_br}\e[0m"

  # get current stash head, stash, then get head again to check for stashed changes
  stash_pre=$(git rev-parse -q --verify refs/stash);
  $cmd git stash save -q -u 'before pull';
  stash_post=$(git rev-parse -q --verify refs/stash);

  # pull main
  main_br=$(git branch -l main master --format '%(refname:short)');
  if [ "${current_br}" != "$main_br" ]; then
    echo "\e[2;37m  Switching to ${main_br}\e[0m";
    $cmd git checkout $main_br >/dev/null;
  fi

  echo "\e[2;37m  Syncing `pwd` git:${main_br}\e[0m";
  $cmd git pull --ff-only origin $main_br || exit 2;

  # checkout previous branch
  if [ "${current_br}" != "$main_br" ]; then
    echo "\e[2;37m  Switching back to ${current_br}\e[0m";
    $cmd git checkout "$current_br" >/dev/null;
  fi

  # pop stash if one was pushed
  if [ "$stash_pre" != "$stash_post" ]; then
    echo "\e[2;37m  Restoring stashed changes\e[0m"
    $cmd git stash pop;
  fi
}

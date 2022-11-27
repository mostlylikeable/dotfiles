#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${DOTFILES_DIR}/bash/fs.sh"
source "${DOTFILES_DIR}/bash/print.sh"

alias g="git"
alias clone="git::clone_cd"

# Enable tab completion for `g` by marking it as an alias for `git`
# https://github.com/mathiasbynens/dotfiles/blob/main/.bash_profile
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

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

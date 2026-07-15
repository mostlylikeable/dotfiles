#!/usr/bin/env bash
# shellcheck shell=bash
#
# Git helpers.

[[ -n "${_DOTFILES_GIT_SH:-}" ]] && return 0
_DOTFILES_GIT_SH=1

# shellcheck source=./fs.sh
source "${ZDOTDIR}/sh/fs.sh"
# shellcheck source=./print.sh
source "${ZDOTDIR}/sh/print.sh"

# Alias git
alias g="git"

# Git clone & cd
alias clone="git::clone_cd"

# The git prompt's git commands are read-only and should not interfere with
# other processes. GIT_OPTIONAL_LOCKS=0 is equivalent to `git --no-optional-locks`
# but falls back gracefully for older git.
# @see https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh
git::cmd() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

###############################################################################
# Determines if we are running inside a git repo.
###############################################################################
git::in_a_repo() {
  git::cmd rev-parse --git-dir &>/dev/null
}

###############################################################################
# Get the short name of the HEAD ref.
###############################################################################
git::head() {
  local head
  head=$(git::cmd symbolic-ref --short HEAD 2>/dev/null)
  echo "$head"
}

###############################################################################
# Clone a git repo and cd into the project dir.
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
# Clone all repositories from a GitHub organization into a directory.
#
# @params
#   org - the GitHub organization name
#   dir - (optional) target directory to clone into (defaults to current dir)
# @examples
#   gh::org-clone my-org
#   gh::org-clone my-org ~/projects
###############################################################################
gh::org-clone() {
  local org="${1}"
  local target_dir="${2:-.}"

  if [[ -z "$org" ]]; then
    print::error "usage: gh::org-clone <org> [target-dir]"
    return 1
  fi

  if ! command -v gh &>/dev/null; then
    print::error "gh CLI is not installed"
    return 1
  fi

  local repos
  repos=$(gh repo list "$org" --limit 1000 --json sshUrl --jq '.[].sshUrl') || return 1

  if [[ -z "$repos" ]]; then
    print::error "no repositories found for org: ${org}"
    return 1
  fi

  mkdir -p "$target_dir"

  local repo repo_name
  while IFS= read -r repo; do
    repo_name="$(git::repo_from_url "$repo")"
    if fs::dir_exists "${target_dir}/${repo_name}"; then
      print::info "${repo_name} already exists, skipping"
      continue
    fi
    git::cmd clone --recursive "$repo" "${target_dir}/${repo_name}"
  done <<<"$repos"
}

###############################################################################
# Get the name of the repo from a url.
#
# @params
#   url - the repo's url
# @examples
#   git::repo_from_url "https://github.com/mostlylikeable/dotfiles.git" ==> "dotfiles"
#   git::repo_from_url "git@github.com:mostlylikeable/dotfiles.git"     ==> "dotfiles"
###############################################################################
git::repo_from_url() {
  local base
  base="$(basename "$1")"
  echo "${base%.*}"
}

###############################################################################
# Get the current branch name.
###############################################################################
git::current_branch() {
  local ref ret
  ref=$(git::cmd symbolic-ref --quiet HEAD 2>/dev/null)
  ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return # no git repo.
    ref=$(git::cmd rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo "${ref#refs/heads/}"
}

###############################################################################
# Pull the main/master branch with --ff-only, restoring branch + stash.
#
# @params
#   -d, --dryrun - print the git commands instead of running them
# @see https://gist.github.com/eeichinger/1044107a1126901249b1164dac2fce15
###############################################################################
git-pull-main() {
  # `cmd` is a command prefix: empty (real run) or `echo` (dry run).
  local -a cmd=()
  local current_br main_br stash_pre stash_post

  [[ "$1" == "-d" || "$1" == "--dryrun" ]] && shift && cmd=(echo)

  current_br=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  print::debug "  Current branch: ${current_br}"

  # get current stash head, stash, then get head again to check for changes
  stash_pre=$(git rev-parse -q --verify refs/stash)
  "${cmd[@]}" git stash save -q -u 'before pull'
  stash_post=$(git rev-parse -q --verify refs/stash)

  main_br=$(git branch -l main master --format '%(refname:short)')
  if [ "${current_br}" != "$main_br" ]; then
    print::debug "  Switching to ${main_br}"
    "${cmd[@]}" git checkout "$main_br" >/dev/null
  fi

  print::debug "  Syncing $(pwd) git:${main_br}"
  "${cmd[@]}" git pull --ff-only origin "$main_br" || return 2

  if [ "${current_br}" != "$main_br" ]; then
    print::debug "  Switching back to ${current_br}"
    "${cmd[@]}" git checkout "$current_br" >/dev/null
  fi

  if [ "$stash_pre" != "$stash_post" ]; then
    print::debug "  Restoring stashed changes"
    "${cmd[@]}" git stash pop
  fi
}

###############################################################################
# Run git-pull-main across every immediate subdirectory that is a git repo.
#
# @params
#   * - args forwarded to git-pull-main (e.g. --dryrun)
# @see https://gist.github.com/eeichinger/1044107a1126901249b1164dac2fce15
###############################################################################
git-rpull() {
  local f dir
  for f in */.git/; do
    if [[ -d "$f" && ! -L "$f" ]]; then
      dir=$(dirname "$f")
      print::ok "...::: Updating: ${dir} :::..."
      pushd "$dir" >/dev/null || continue
      git-pull-main "$@"
      popd >/dev/null || return 2
      echo ""
    fi
  done
}

#!/usr/bin/env bash
# git.sh

# clone git repo and cd into project dir
#
# usage:
# clone git@github.com:mostlylikeable/foo-project.git
#
# specify dir:
# clone git@github.com:mostlylikeable/foo-project.git different_dir
function clone() {
  local repo=$1
  local to_dir=${2:-"$(git_url_to_repo $repo)"}
  echo "cloning $repo to $to_dir"

  # echo "git clone $repo $to_dir"
  git clone $repo $to_dir
  cd $to_dir
}

function git_url_to_repo {
  # git@github.com:mostlylikeable/foo-project.git
  local base=$(basename $1) # foo-project.git
  local repo=${base%.*} # foo-project
  echo $repo
}

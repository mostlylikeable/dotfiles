#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  source "$ZDOTDIR/sh/git.sh"
  TMP_NONGIT="$(mktemp -d)"
}

teardown() {
  [[ -n "${TMP_NONGIT:-}" ]] && rm -rf "$TMP_NONGIT"
}

# --- regression: git-pull-main used `exit` inside a sourced function ---------
# Old code did `... || exit 2`, which killed the *host* shell. It now uses
# `return`. We call it INLINE (no `run` subshell) so that an `exit` would tear
# down this very test process; reaching the assertions after proves it did not.
@test "git-pull-main returns (does not exit) on failure in a non-git dir (regression)" {
  cd "$TMP_NONGIT"
  local rc=0
  # Real (non-dry-run) call: git pull fails with no repo, hitting `|| return`.
  git-pull-main >/dev/null 2>&1 || rc=$?
  # If the old `exit` were still there, we'd never get here.
  [[ "$rc" -ne 0 ]] || { echo "expected nonzero return, got $rc" >&2; return 1; }
}

@test "git-pull-main --dryrun does not run real git and survives" {
  cd "$TMP_NONGIT"
  run git-pull-main --dryrun
  # dry-run prefixes git with `echo`, so the pull is only printed, not run.
  assert_output --partial "git pull --ff-only origin"
}

# --- pure helpers ------------------------------------------------------------
@test "git::repo_from_url parses ssh url" {
  run git::repo_from_url "git@github.com:me/dotfiles.git"
  assert_output "dotfiles"
}

@test "git::repo_from_url parses https url" {
  run git::repo_from_url "https://github.com/me/dotfiles.git"
  assert_output "dotfiles"
}

@test "git::in_a_repo is false in a non-git dir" {
  cd "$TMP_NONGIT"
  run git::in_a_repo
  assert_failure
}

@test "git::in_a_repo is true inside the dotfiles repo" {
  cd "$REPO"
  run git::in_a_repo
  assert_success
}

@test "git-rpull and git-pull-main are defined functions" {
  [[ "$(declare -F git-pull-main)" == "git-pull-main" ]]
  [[ "$(declare -F git-rpull)" == "git-rpull" ]]
}

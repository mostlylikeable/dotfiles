#!/usr/bin/env bash
# shellcheck shell=bash
#
# Shared bats setup. Sets REPO + ZDOTDIR and (if vendored) loads
# bats-support / bats-assert / bats-file. Guarded so tests still run under a
# plain `bats` with no helpers vendored.

# Repo root = two levels up from this file (test/test_helper/common.sh).
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO

# The sh modules source siblings via ${ZDOTDIR}/sh/<name>.sh, so this must be
# exported before any module is sourced.
ZDOTDIR="$REPO/zsh/.config/zsh"
export ZDOTDIR

_HELPERS="$REPO/test/test_helper"

common::load_helpers() {
  [[ -f "$_HELPERS/bats-support/load.bash" ]] && load "$_HELPERS/bats-support/load"
  [[ -f "$_HELPERS/bats-assert/load.bash" ]] && load "$_HELPERS/bats-assert/load"
  [[ -f "$_HELPERS/bats-file/load.bash" ]] && load "$_HELPERS/bats-file/load"
  return 0
}

# Fallbacks so .bats files can use assert_* even when helpers aren't vendored.
# $status/$output are set by bats' `run`, not visible to shellcheck here.
# shellcheck disable=SC2154
if [[ ! -f "$_HELPERS/bats-assert/load.bash" ]]; then
  assert_success() { [[ "$status" -eq 0 ]] || {
    echo "expected success, got status=$status: $output" >&2
    return 1
  }; }
  assert_failure() { [[ "$status" -ne 0 ]] || {
    echo "expected failure, got status=0: $output" >&2
    return 1
  }; }
  assert_output() {
    if [[ "$1" == "--partial" ]]; then
      [[ "$output" == *"$2"* ]] || {
        echo "expected output to contain: $2" >&2
        echo "actual: $output" >&2
        return 1
      }
    else
      [[ "$output" == "$1" ]] || {
        echo "expected: $1" >&2
        echo "actual: $output" >&2
        return 1
      }
    fi
  }
  assert_equal() { [[ "$1" == "$2" ]] || {
    echo "expected '$2', got '$1'" >&2
    return 1
  }; }
fi

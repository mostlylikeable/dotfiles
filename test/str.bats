#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  source "$ZDOTDIR/sh/str.sh"
}

# --- regression: misplaced `]` in the tr set broke lower/upper ---------------
@test "str::lower lowercases (regression: tr set)" {
  run str::lower ABCdef
  assert_success
  assert_output "abcdef"
}

@test "str::upper uppercases (regression: tr set)" {
  run str::upper abcDEF
  assert_success
  assert_output "ABCDEF"
}

@test "str::lower on multiple args" {
  run str::lower FoO BAR
  assert_output "foo bar"
}

@test "str::upper on multiple args" {
  run str::upper FoO bar
  assert_output "FOO BAR"
}

# --- other string helpers ----------------------------------------------------
@test "str::trim strips surrounding whitespace" {
  run str::trim "  foo  "
  assert_output "foo"
}

@test "str::remove removes first occurrence" {
  run str::remove "foo bar foo" "foo"
  assert_output " bar foo"
}

@test "str::remove_all removes every occurrence" {
  run str::remove_all "foo bar foo" "foo"
  assert_output " bar "
}

@test "str::lstrip strips prefix" {
  run str::lstrip "foo bar foo" "foo "
  assert_output "bar foo"
}

@test "str::rstrip strips suffix" {
  run str::rstrip "foo bar foo" " foo"
  assert_output "foo bar"
}

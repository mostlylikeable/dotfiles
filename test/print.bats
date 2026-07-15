#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  source "$ZDOTDIR/sh/print.sh"
}

# Regression: print.sh used `echo "\e["` which in bash prints the literal
# text `\e[` (backslash-e) rather than an escape. It now uses printf '\033['.
# We assert the first emitted byte is a real ESC (0x1b), not `\`.

@test "print::ok emits a real ESC byte, not literal backslash-e (regression)" {
  run print::ok hi
  assert_success
  local first; first="$(printf '%s' "$output" | head -c1 | od -An -tx1 | tr -d ' ')"
  assert_equal "$first" "1b"
  # And it must not contain the literal two-char sequence backslash-e.
  [[ "$output" != *'\e'* ]] || { echo "found literal backslash-e in: $output" >&2; return 1; }
}

@test "print::error writes to stderr with bold red + reset" {
  run print::error boom
  assert_success
  local v; v="$(printf '%s' "$output" | cat -v)"
  [[ "$v" == *'^[[1;31m'* ]] || { echo "missing bold red: $v" >&2; return 1; }
  [[ "$v" == *'ERROR: boom'* ]]
  [[ "$v" == *'^[[0m'* ]] || { echo "missing reset: $v" >&2; return 1; }
}

@test "print::info wraps message in white + reset" {
  run print::info hello
  local v; v="$(printf '%s' "$output" | cat -v)"
  [[ "$v" == *'^[[37m'* ]]
  [[ "$v" == *'hello'* ]]
  [[ "$v" == *'^[[0m'* ]]
}

@test "print::error goes to stderr (stdout is empty)" {
  run --separate-stderr print::error boom
  assert_equal "$output" ""
  [[ -n "$stderr" ]] || { echo "expected stderr content" >&2; return 1; }
}

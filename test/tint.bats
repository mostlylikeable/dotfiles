#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  source "$ZDOTDIR/sh/tint.sh"
}

# cat -v renders the ESC byte (0x1b) as `^[`, so a real escape sequence shows
# up as `^[[32m`. On the old (buggy) code tint called an undefined function and
# emitted no color, so these assertions would fail.
_visible() { printf '%s' "$1" | cat -v; }

@test "tint green wraps text in ANSI green + reset (regression)" {
  run tint green foo
  assert_success
  local v; v="$(_visible "$output")"
  [[ "$v" == *'^[[32m'* ]] || { echo "missing green start in: $v" >&2; return 1; }
  [[ "$v" == *'foo'*     ]] || { echo "missing text in: $v" >&2; return 1; }
  [[ "$v" == *'^[[0m'*   ]] || { echo "missing reset in: $v" >&2; return 1; }
}

@test "tint uppercase color name is bold" {
  run tint GREEN foo
  local v; v="$(_visible "$output")"
  [[ "$v" == *'^[[1;32m'* ]] || { echo "missing bold green in: $v" >&2; return 1; }
}

@test "tint::str_to_ansi_color maps names to codes" {
  run tint::str_to_ansi_color red
  assert_output "31m"
  run tint::str_to_ansi_color BLUE
  assert_output "1;34m"
}

@test "tint output starts with a real ESC byte (0x1b), not literal backslash-e" {
  run tint red foo
  # First byte must be 0x1b. \e in printf format => real escape.
  local first; first="$(printf '%s' "$output" | head -c1 | od -An -tx1 | tr -d ' ')"
  assert_equal "$first" "1b"
}

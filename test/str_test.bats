
load ./test_utils.bash
load ./sh/str.sh

@test "str_empty: true if empty" {
  local s=""
  str_empty $s
}

@test "str_empty: true if not set" {
  local s
  str_empty $s
}

@test "str_empty: false if not empty" {
  local s="non-empty"
  ! str_empty $s
}

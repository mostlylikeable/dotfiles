#!/usr/bin/env bats

load ./test_utils.bash
load ./sh/io.sh

@test "dexists: false if no dir" {
  ! dexists /not_found
}

@test "dexists: true if dir exists" {
  dir=$(test_mkdir dexists)
  dexists $dir
}

@test "dempty: fails if dir does not exist" {
  run dempty /not_found
  echo "$status"
  [ "$status" -eq 2 ]
}

@test "dempty: true if dir is empty" {
  dir=$(test_mkdir dempty)
  dempty $dir
}

@test "dempty: false if dir is not empty" {
  dir=$(test_mkdir dempty)
  touch "$dir/test.txt"
  ! dempty $dir
}

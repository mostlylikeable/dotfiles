#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  # shellcheck source=lib/modules.sh
  source "$REPO/lib/modules.sh"
  TEST_HOME="$(mktemp -d)"
  export HOME="$TEST_HOME"
  unset XDG_CONFIG_HOME
}

teardown() {
  if [[ -n "${TEST_HOME:-}" && ( "$TEST_HOME" == /var/* || "$TEST_HOME" == /tmp/* ) ]]; then
    rm -rf "$TEST_HOME"
  fi
  return 0
}

@test "dev / headless presets resolve expected defaults" {
  [[ "$(modules::default_modules dev)" == "core git js" ]]
  [[ "$(modules::default_modules headless)" == "core git" ]]
  modules::default_gui dev
  ! modules::default_gui headless
}

@test "expand_deps auto-enables js and jvm for mobile-rn" {
  run modules::expand_deps mobile-rn
  assert_success
  assert_output --partial "js"
  assert_output --partial "jvm"
  assert_output --partial "mobile-rn"
  # MODULES_ALL order: js before jvm before mobile-rn
  [[ "$output" == "js jvm mobile-rn" ]]
}

@test "auto_enabled reports only pulled-in deps" {
  [[ "$(modules::auto_enabled "mobile-rn" "js jvm mobile-rn")" == "js jvm" ]]
  [[ -z "$(modules::auto_enabled "js jvm mobile-rn" "js jvm mobile-rn")" ]]
}

@test "selection save + load round-trips" {
  modules::selection_save "dev" "1" "core git js aws"
  run modules::selection_load
  assert_success
  [[ "$output" == $'dev\t1\tcore git js aws' ]]
  [[ -f "$(modules::selection_path)" ]]
}

@test "packages_for_modules de-dupes and follows module map" {
  run modules::packages_for_modules core git nvim
  assert_success
  assert_output --partial "zsh"
  assert_output --partial "git"
  assert_output --partial "nvim"
}

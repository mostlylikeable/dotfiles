#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/test_helper/common.sh"
  common::load_helpers
  source "$ZDOTDIR/sh/docker.sh"
}

# Regression: `dlogs` needs to accept an argument (a container), so it must be a
# real function, not an alias (aliases can't take positional args). It is now
# docker::logs, with `dlogs` aliased to it.
@test "docker::logs is defined as a function (regression)" {
  [[ "$(declare -F docker::logs)" == "docker::logs" ]]
}

@test "dlogs alias points at the docker::logs function" {
  run alias dlogs
  assert_output --partial "docker::logs"
}

@test "other docker helpers are functions" {
  [[ "$(declare -F docker::stop)" == "docker::stop" ]]
  [[ "$(declare -F docker::rm_exited)" == "docker::rm_exited" ]]
  [[ "$(declare -F docker::rmi_dangling)" == "docker::rmi_dangling" ]]
}

@test "docker::logs forwards args to 'docker container logs --follow'" {
  # Shadow `docker` with a stub so we can inspect the assembled command line.
  docker() { printf '%s\n' "$*"; }
  run docker::logs mycontainer
  assert_output "container logs --follow mycontainer"
}

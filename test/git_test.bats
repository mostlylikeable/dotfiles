
load ./test_utils.bash
load ./sh/git.sh

@test "git_url_to_repo: repo is parsed from ssh url" {
  local url="git@github.com:mostlylikeable/foo-project.git"
  local repo=$(git_url_to_repo $url)
  [ $repo == "foo-project" ]
}

@test "git_url_to_repo: repo is parsed from http url" {
  local url="https://github.com/mostlylikeable/foo-project.git"
  local repo=$(git_url_to_repo $url)
  [ $repo == "foo-project" ]
}

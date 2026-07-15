# Tests

[bats-core](https://github.com/bats-core/bats-core) test suite for the shell library (`zsh/.config/zsh/sh/*.sh`) and the installer (`install.sh`).

## Layout

```text
test/
  bats/                     # bats-core runner            (git submodule)
  test_helper/
    bats-support/           # bats-support helpers        (git submodule)
    bats-assert/            # bats-assert helpers         (git submodule)
    bats-file/              # bats-file helpers           (git submodule)
    common.sh               # shared setup: sets REPO + ZDOTDIR, loads helpers
  str.bats                  # str::lower/upper/trim/...    (+ tr-set regression)
  tint.bats                 # tint / tint::str_to_ansi_color (undefined-fn regression)
  print.bats                # print::* ANSI helpers        (echo-vs-printf regression)
  git.bats                  # git helpers                  (exit-vs-return regression)
  docker.bats               # docker::* helpers            (alias-vs-function regression)
  install.bats              # install.sh dry-run + conflict-backup
```

The `sh` modules source siblings via `${ZDOTDIR}/sh/<name>.sh`, so `common.sh` exports `ZDOTDIR=<repo>/zsh/.config/zsh` before anything is sourced. The modules are bash-compatible; tests run under bash.

## Running

```sh
# vendored runner (what CI uses)
./test/bats/bin/bats test/

# or a system install
brew install bats-core   # macOS
bats test/
```

`common.sh` guards the helper `load`s with `[[ -f ... ]]`, and provides minimal `assert_*` fallbacks, so the suite still runs under a plain `bats` even if the helper submodules are not vendored.

## Vendoring the bats helpers (on a machine with network)

The runner and helpers are git submodules. To (re)add them:

```sh
git submodule add https://github.com/bats-core/bats-core.git    test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git  test/test_helper/bats-assert
git submodule add https://github.com/bats-core/bats-file.git    test/test_helper/bats-file
```

On a fresh clone, pull them with:

```sh
git submodule update --init --recursive
```

#!/usr/bin/env bash
# shellcheck shell=bash
#
# Sources the shell-function library under ${ZDOTDIR}/sh/ in dependency order.
# Each source is guarded so a missing module never aborts shell startup.

[[ -n "${_DOTFILES_FUNCTIONS_ZSH:-}" ]] && return 0
_DOTFILES_FUNCTIONS_ZSH=1

# Order matters: leaf modules (str, tint, print) come before consumers.
_dotfiles_modules=(
  str
  tint
  print
  term
  utils
  fs
  git
  docker
  gradle
  aliases
)

for _mod in "${_dotfiles_modules[@]}"; do
  # shellcheck disable=SC1090
  [[ -r "${ZDOTDIR}/sh/${_mod}.sh" ]] && source "${ZDOTDIR}/sh/${_mod}.sh"
done
unset _mod _dotfiles_modules

# macOS-only helpers (a future sh/os/linux.sh can drop in alongside).
if [[ "$OSTYPE" == darwin* ]]; then
  # shellcheck disable=SC1091
  [[ -r "${ZDOTDIR}/sh/os/macos.sh" ]] && source "${ZDOTDIR}/sh/os/macos.sh"
fi

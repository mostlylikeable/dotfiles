#!/usr/bin/env bash
#
# Logging helpers for install-time scripts. Plain printf; respects NO_COLOR and
# non-tty output. No external dependencies.

# Guard against double-sourcing.
[[ -n "${_DOTFILES_LOG_SH:-}" ]] && return 0
_DOTFILES_LOG_SH=1

# Respect NO_COLOR (https://no-color.org) and non-tty output.
if [[ -n "${NO_COLOR:-}" || ! -t 1 ]]; then
  _C_RESET='' _C_RED='' _C_GREEN='' _C_YELLOW='' _C_BLUE='' _C_DIM=''
else
  _C_RESET=$'\033[0m' _C_RED=$'\033[1;31m' _C_GREEN=$'\033[1;32m'
  _C_YELLOW=$'\033[1;33m' _C_BLUE=$'\033[1;34m' _C_DIM=$'\033[2;37m'
fi

log::info() { printf '%s==>%s %s\n' "$_C_BLUE" "$_C_RESET" "$*"; }
log::ok() { printf '%s ok%s %s\n' "$_C_GREEN" "$_C_RESET" "$*"; }
log::warn() { printf '%swarn%s %s\n' "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
log::error() { printf '%sERROR%s %s\n' "$_C_RED" "$_C_RESET" "$*" >&2; }
log::debug() {
  [[ -n "${DOTFILES_DEBUG:-}" ]] && printf '%s  · %s%s\n' "$_C_DIM" "$*" "$_C_RESET"
  return 0
}

log::step() { printf '\n%s▸ %s%s\n' "$_C_BLUE" "$*" "$_C_RESET"; }

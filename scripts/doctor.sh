#!/usr/bin/env bash
#
# doctor.sh — read-only health check. Never mutates anything; exits non-zero if
# any REQUIRED check fails (missing optional tools are warnings, not failures).
#
#   ./scripts/doctor.sh
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/log.sh
source "$REPO_DIR/lib/log.sh"

fail=0
ok() { log::ok "$1"; }
warn() { log::warn "$1"; }
bad() {
  log::error "$1"
  fail=1
}

# A symlink under $HOME is "ours" if it resolves into the repo.
points_into_repo() {
  local link="$1" tgt
  [[ -L "$link" ]] || return 1
  tgt="$(cd "$(dirname "$link")" && realpath "$(readlink "$link")" 2>/dev/null)" || return 1
  [[ "$tgt" == "$REPO_DIR"/* ]]
}

log::step "required tooling"
for bin in brew stow git zsh; do
  if command -v "$bin" &>/dev/null; then ok "$bin: $(command -v "$bin")"; else bad "$bin missing"; fi
done

log::step "core CLI tools (warn if absent)"
for bin in starship zoxide direnv mise fzf eza bat rg fd delta; do
  if command -v "$bin" &>/dev/null; then ok "$bin"; else warn "$bin not installed"; fi
done

log::step "symlinks"
for link in "$HOME/.zshenv" "${XDG_CONFIG_HOME:-$HOME/.config}/zsh" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"; do
  if points_into_repo "$link"; then
    ok "$link → repo"
  elif [[ -e "$link" ]]; then
    warn "$link exists but is not a repo symlink"
  else warn "$link not present (package not stowed?)"; fi
done

log::step "PATH"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ok "$HOME/.local/bin on PATH" ;;
  *) warn "$HOME/.local/bin not on PATH (restart shell?)" ;;
esac
if command -v brew &>/dev/null; then
  case ":$PATH:" in *":$(brew --prefix)/bin:"*) ok "homebrew bin on PATH" ;; *) warn "homebrew bin not on PATH" ;; esac
fi

log::step "mise config"
mise_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
if points_into_repo "$mise_cfg"; then
  ok "mise config → repo"
elif [[ -e "$mise_cfg" ]]; then
  warn "mise config present but not a repo symlink"
else warn "mise config not linked (mise phase not run?)"; fi

log::step "backups"
if [[ -d "$HOME/.dotfiles-backup" ]]; then
  log::info "backup snapshots: $(find "$HOME/.dotfiles-backup" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
else
  ok "no backups needed (clean install)"
fi

echo
if [[ "$fail" == 0 ]]; then
  log::ok "doctor: all required checks passed"
else
  log::error "doctor: required checks FAILED"
fi
exit "$fail"

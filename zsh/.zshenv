# ~/.zshenv — sourced for EVERY zsh invocation, before anything else.
# Keep it lean and non-interactive-safe. Its jobs: point zsh at ZDOTDIR and
# assemble PATH + core env exactly once.

# Redirect the rest of zsh's startup files into the XDG-clean config dir.
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

# XDG base directories (used by our configs and many tools).
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Core environment.
export DEV_DIR="${DEV_DIR:-$HOME/dev}"
export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# ---------------------------------------------------------------------------
# PATH — assembled ONCE, here. Nothing else in the config should mutate PATH
# (except .zprofile appending guarded, machine-specific dirs like Android SDK).
# `typeset -U` keeps entries unique (first occurrence wins). Missing dirs are
# harmless; they simply never match.
# ---------------------------------------------------------------------------
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /opt/homebrew/opt/coreutils/libexec/gnubin
  /opt/homebrew/opt/gnu-sed/libexec/gnubin
  /opt/homebrew/opt/grep/libexec/gnubin
  /opt/homebrew/opt/findutils/libexec/gnubin
  $path
)
export PATH

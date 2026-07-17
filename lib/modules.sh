#!/usr/bin/env bash
#
# Preset + module definitions. A *preset* is a named default set of *modules*
# (plus a default GUI flag). A *module* may contribute stow packages, a Brewfile
# fragment, a mise manifest, and later other install hooks. install.sh resolves
# selection here so the TUI and CLI flags share one source of truth.

[[ -n "${_DOTFILES_MODULES_SH:-}" ]] && return 0
_DOTFILES_MODULES_SH=1

# All modules that exist (order = install / conf.d order).
# shellcheck disable=SC2034
MODULES_ALL=(
  core git
  js jvm python ruby go rust
  aws gcp terraform k8s
  docker mobile-rn
  nvim agents
)

# Presets that exist (order = TUI order).
# shellcheck disable=SC2034
MODULES_PRESETS=(dev headless)

###############################################################################
# Default modules for a preset. @params preset @output space-separated modules
###############################################################################
modules::default_modules() {
  case "$1" in
    dev) echo "core git js" ;;
    headless) echo "core git" ;;
    *) echo "" ;;
  esac
}

###############################################################################
# Default GUI flag for a preset. @params preset @return 0 if GUI, 1 if not
###############################################################################
modules::default_gui() { [[ "$1" != "headless" ]]; }

###############################################################################
# Category label for TUI grouping. @params module @output category name
###############################################################################
modules::category() {
  case "$1" in
    core | git) echo "base" ;;
    js | jvm | python | ruby | go | rust) echo "languages" ;;
    aws | gcp | terraform | k8s) echo "cloud" ;;
    docker | mobile-rn) echo "platforms" ;;
    nvim) echo "editors" ;;
    agents) echo "agents" ;;
    *) echo "other" ;;
  esac
}

###############################################################################
# Direct dependencies of a module. @params module @output space-separated deps
###############################################################################
modules::depends_on() {
  case "$1" in
    mobile-rn) echo "js jvm" ;;
    *) echo "" ;;
  esac
}

###############################################################################
# Stow packages for a module. @params module @output space-separated packages
###############################################################################
modules::packages_for_module() {
  case "$1" in
    core) echo "zsh starship bat direnv tmux ghostty bin" ;;
    git) echo "git" ;;
    nvim) echo "nvim" ;;
    agents) echo "agents" ;;
    *) echo "" ;;
  esac
}

###############################################################################
# Brewfile fragment path for a module, if present. @params module, repo
###############################################################################
modules::brewfile_for_module() {
  local f="$2/brew/Brewfile.$1"
  [[ -f "$f" ]] && echo "$f"
  return 0
}

###############################################################################
# mise manifest for a module, if present. @params module, repo
###############################################################################
modules::mise_for_module() {
  local f="$2/mise/$1.toml"
  [[ -f "$f" ]] && echo "$f"
  return 0
}

###############################################################################
# Whether name is a known module. @params name @return 0 if known
###############################################################################
modules::is_module() {
  local m
  for m in "${MODULES_ALL[@]}"; do
    [[ "$m" == "$1" ]] && return 0
  done
  return 1
}

###############################################################################
# Whether name is a known preset. @params name @return 0 if known
###############################################################################
modules::is_preset() {
  local p
  for p in "${MODULES_PRESETS[@]}"; do
    [[ "$p" == "$1" ]] && return 0
  done
  return 1
}

###############################################################################
# True if space-separated list contains token. @params list, token
###############################################################################
modules::_has() { [[ " $1 " == *" $2 "* ]]; }

###############################################################################
# Expand depends_on until fixed point; emit MODULES_ALL order, unique.
# @params modules... @output space-separated modules
###############################################################################
modules::expand_deps() {
  local want=" $* " dep m changed=1
  while [[ "$changed" == 1 ]]; do
    changed=0
    for m in $want; do
      for dep in $(modules::depends_on "$m"); do
        modules::_has "$want" "$dep" && continue
        want+="$dep "
        changed=1
      done
    done
  done
  local out=""
  for m in "${MODULES_ALL[@]}"; do
    modules::_has "$want" "$m" || continue
    out+="$m "
  done
  echo "${out% }"
}

###############################################################################
# Modules in expanded that were not in requested (auto-enabled deps).
# @params requested (space-sep), expanded (space-sep) @output auto-added
###############################################################################
modules::auto_enabled() {
  local requested=" $1 " m out=""
  for m in $2; do
    modules::_has "$requested" "$m" && continue
    out+="$m "
  done
  echo "${out% }"
}

###############################################################################
# Resolve de-duplicated stow packages for modules. @params modules...
###############################################################################
modules::packages_for_modules() {
  local module pkg seen=" " out=""
  for module in "$@"; do
    for pkg in $(modules::packages_for_module "$module"); do
      [[ "$seen" == *" $pkg "* ]] && continue
      seen+="$pkg "
      out+="$pkg "
    done
  done
  echo "${out% }"
}

###############################################################################
# Path to the persisted selection file.
###############################################################################
modules::selection_path() {
  echo "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/selection"
}

###############################################################################
# Load selection file. Prints: preset<TAB>gui<TAB>modules
# @return 0 if loaded, 1 if missing/unreadable
###############################################################################
modules::selection_load() {
  local path line key val preset="" gui="" modules=""
  path="$(modules::selection_path)"
  [[ -f "$path" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    key="${line%%=*}"
    val="${line#*=}"
    case "$key" in
      preset) preset="$val" ;;
      gui) gui="$val" ;;
      modules) modules="$val" ;;
    esac
  done <"$path"
  [[ -n "$modules" ]] || return 1
  printf '%s\t%s\t%s\n' "$preset" "$gui" "$modules"
}

###############################################################################
# Write selection file. @params preset, gui (0|1), modules (space-separated)
###############################################################################
modules::selection_save() {
  local preset="$1" gui="$2" modules="$3"
  local path dir
  path="$(modules::selection_path)"
  dir="$(dirname "$path")"
  mkdir -p "$dir"
  cat >"$path" <<EOF
# dotfiles install selection — written by install.sh
preset=$preset
gui=$gui
modules=$modules
EOF
}

#!/usr/bin/env bash
#
# dotfiles installer. Single entry point for both the interactive (gum) TUI and
# non-interactive flag-driven runs — both resolve the same PRESET + MODULES + GUI
# and run the same phases. Every phase is idempotent and honors --dry-run.
#
# Usage:
#   ./install.sh                                      # interactive menu
#   ./install.sh --preset dev --yes                   # non-interactive
#   ./install.sh --preset headless --yes              # no GUI apps / macOS phases
#   ./install.sh --with aws,gcp,docker                # additive (uses saved selection)
#   ./install.sh --modules core,git,js --no-gui --yes
#   ./install.sh --fresh                              # ignore saved selection
#   ./install.sh --fresh --no-save                    # ignore + don't write selection
#   ./install.sh --dry-run --preset headless          # simulate, mutate nothing
#   ./install.sh --only stow                          # run a single phase
#   ./install.sh --skip macos                         # skip a phase
#   ./install.sh --list                               # show modules / saved selection

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/log.sh
source "$REPO_DIR/lib/log.sh"
# shellcheck source=lib/stow.sh
source "$REPO_DIR/lib/stow.sh"
# shellcheck source=lib/modules.sh
source "$REPO_DIR/lib/modules.sh"

# ---- defaults --------------------------------------------------------------
PRESET=""
MODULES_FLAG="" # absolute --modules set (space-separated once parsed)
WITH_MODULES=""
WITHOUT_MODULES=""
GUI_FLAG="" # empty | 0 | 1 — empty means unset
NONINTERACTIVE=0
DRY_RUN=0
ADOPT=0
FRESH=0
NO_SAVE=0
LIST_ONLY=0
ONLY=""
SKIP=""
ALL_PHASES=(preflight stow brew mise macos app post)

# Resolved by resolve_selection:
MODULES=""
GUI=1

usage() { sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# ---- arg parsing -----------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset | --profile)
      PRESET="$2"
      shift 2
      ;;
    --preset=* | --profile=*)
      PRESET="${1#*=}"
      shift
      ;;
    --modules)
      MODULES_FLAG="${MODULES_FLAG} ${2//,/ }"
      shift 2
      ;;
    --modules=*)
      MODULES_FLAG="${MODULES_FLAG} ${1#*=}"
      MODULES_FLAG="${MODULES_FLAG//,/ }"
      shift
      ;;
    --with)
      WITH_MODULES="$WITH_MODULES ${2//,/ }"
      shift 2
      ;;
    --with=*)
      WITH_MODULES="$WITH_MODULES ${1#*=}"
      WITH_MODULES="${WITH_MODULES//,/ }"
      shift
      ;;
    --without | --no-module | --no-bundle)
      WITHOUT_MODULES="$WITHOUT_MODULES ${2//,/ }"
      shift 2
      ;;
    --without=* | --no-module=* | --no-bundle=*)
      WITHOUT_MODULES="$WITHOUT_MODULES ${1#*=}"
      WITHOUT_MODULES="${WITHOUT_MODULES//,/ }"
      shift
      ;;
    --gui)
      GUI_FLAG=1
      shift
      ;;
    --no-gui)
      GUI_FLAG=0
      shift
      ;;
    --fresh)
      FRESH=1
      shift
      ;;
    --no-save)
      NO_SAVE=1
      shift
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    --yes | --non-interactive | -y)
      NONINTERACTIVE=1
      shift
      ;;
    --dry-run | -n)
      DRY_RUN=1
      shift
      ;;
    --adopt)
      ADOPT=1
      shift
      ;;
    --only)
      ONLY="$2"
      shift 2
      ;;
    --only=*)
      ONLY="${1#*=}"
      shift
      ;;
    --skip)
      SKIP="$SKIP ${2//,/ }"
      shift 2
      ;;
    --skip=*)
      SKIP="$SKIP ${1#*=}"
      SKIP="${SKIP//,/ }"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      log::error "unknown arg: $1"
      usage
      exit 2
      ;;
  esac
done

DRY() { if [[ "$DRY_RUN" == 1 ]]; then log::debug "(dry-run) $*"; else "$@"; fi; }

# ---- helpers ---------------------------------------------------------------
choose_one() {
  local prompt="$1"
  shift
  if command -v gum &>/dev/null; then
    gum choose --header "$prompt" "$@"
  else
    local i=1 opt
    {
      printf '%s\n' "$prompt" >&2
      for opt in "$@"; do
        printf '  %d) %s\n' "$i" "$opt" >&2
        ((i++))
      done
    }
    local reply
    read -r "reply?#? "
    printf '%s\n' "${@:$reply:1}"
  fi
}

normalize_module_list() {
  # Validate tokens and emit MODULES_ALL order (unique).
  local raw=" $* " m out=""
  for m in $raw; do
    [[ -z "$m" ]] && continue
    if ! modules::is_module "$m"; then
      log::error "unknown module: $m"
      exit 2
    fi
  done
  for m in "${MODULES_ALL[@]}"; do
    modules::_has "$raw" "$m" || continue
    out+="$m "
  done
  echo "${out% }"
}

compose_modules() {
  # @params base (space-sep) → apply --with / --without → expand deps → MODULES
  local base="$1" m set requested expanded auto
  set=" $base $WITH_MODULES "
  requested=""
  for m in "${MODULES_ALL[@]}"; do
    modules::_has "$set" "$m" || continue
    modules::_has " $WITHOUT_MODULES " "$m" && continue
    requested+="$m "
  done
  requested="${requested% }"
  # shellcheck disable=SC2086
  expanded="$(modules::expand_deps $requested)"
  auto="$(modules::auto_enabled "$requested" "$expanded")"
  if [[ -n "$auto" ]]; then
    log::info "auto-enabled (depends_on): $auto"
  fi
  MODULES="$expanded"
}

list_modules() {
  local saved_preset="" saved_gui="" saved_modules="" loaded=0
  local line cat prev=""
  if line="$(modules::selection_load)"; then
    loaded=1
    saved_preset="${line%%$'\t'*}"
    line="${line#*$'\t'}"
    saved_gui="${line%%$'\t'*}"
    saved_modules="${line#*$'\t'}"
  fi
  log::step "modules"
  prev=""
  for m in "${MODULES_ALL[@]}"; do
    cat="$(modules::category "$m")"
    if [[ "$cat" != "$prev" ]]; then
      printf '\n[%s]\n' "$cat"
      prev="$cat"
    fi
    if [[ "$loaded" == 1 ]] && modules::_has " $saved_modules " "$m"; then
      printf '  * %s\n' "$m"
    else
      printf '    %s\n' "$m"
    fi
  done
  echo
  if [[ "$loaded" == 1 ]]; then
    log::info "saved: preset=$saved_preset gui=$saved_gui"
    log::info "saved modules: $saved_modules"
    log::info "file: $(modules::selection_path)"
  else
    log::info "no saved selection at $(modules::selection_path)"
  fi
  log::info "presets: ${MODULES_PRESETS[*]}"
}

# ---- interactive selection (gum if available, else read) -------------------
resolve_selection() {
  local base="" saved_preset="" saved_gui="" saved_modules="" line
  local have_saved=0 seed_gui=""

  if [[ "$FRESH" != 1 ]] && line="$(modules::selection_load)"; then
    have_saved=1
    saved_preset="${line%%$'\t'*}"
    line="${line#*$'\t'}"
    saved_gui="${line%%$'\t'*}"
    saved_modules="${line#*$'\t'}"
  fi

  # Absolute --modules wins as the base.
  if [[ -n "${MODULES_FLAG// /}" ]]; then
    base="$(normalize_module_list "$MODULES_FLAG")"
  elif [[ "$have_saved" == 1 ]]; then
    base="$(normalize_module_list "$saved_modules")"
    [[ -z "$PRESET" && -n "$saved_preset" ]] && PRESET="$saved_preset"
    seed_gui="$saved_gui"
  fi

  # Preset: interactive pick, or flag, or default.
  if [[ -z "$PRESET" && "$NONINTERACTIVE" == 0 && -t 0 && -z "${MODULES_FLAG// /}" && "$have_saved" == 0 ]]; then
    PRESET="$(choose_one "Select a preset:" "${MODULES_PRESETS[@]}")"
  fi
  [[ -z "$PRESET" ]] && PRESET="dev"
  if ! modules::is_preset "$PRESET"; then
    log::error "unknown preset: $PRESET (expected ${MODULES_PRESETS[*]})"
    exit 2
  fi

  if [[ -z "$base" ]]; then
    base="$(modules::default_modules "$PRESET")"
  fi

  # Interactive module toggle (gum), seeded from base.
  if [[ "$NONINTERACTIVE" == 0 && -t 0 && -z "${MODULES_FLAG// /}" && -z "$WITH_MODULES" && -z "$WITHOUT_MODULES" ]] &&
    command -v gum &>/dev/null; then
    local chosen
    chosen="$(printf '%s\n' "${MODULES_ALL[@]}" |
      gum choose --no-limit --header "Toggle modules (space=select; deps auto-enabled after):" \
        --selected "$(echo "$base" | tr ' ' ',')")" || true
    if [[ -n "$chosen" ]]; then
      base="$(echo "$chosen" | tr '\n' ' ')"
      base="$(normalize_module_list "$base")"
    fi
  fi

  compose_modules "$base"

  # GUI resolution.
  if [[ -n "$GUI_FLAG" ]]; then
    GUI="$GUI_FLAG"
  elif [[ -n "$seed_gui" ]]; then
    GUI="$seed_gui"
  elif modules::default_gui "$PRESET"; then
    GUI=1
  else
    GUI=0
  fi

  if [[ "$NONINTERACTIVE" == 0 && -t 0 && -z "$GUI_FLAG" && "$have_saved" == 0 ]] &&
    command -v gum &>/dev/null; then
    local gui_pick
    gui_pick="$(gum choose --header "Install GUI apps / macOS defaults?" "yes" "no")" || true
    case "$gui_pick" in
      yes) GUI=1 ;;
      no) GUI=0 ;;
    esac
  fi

  if [[ "$NONINTERACTIVE" == 0 && -t 0 ]] && command -v gum &>/dev/null; then
    local summary="preset=$PRESET  gui=$GUI  modules=$MODULES"
    if ! gum confirm "$summary — proceed?"; then
      log::warn "aborted"
      exit 1
    fi
  fi
}

should_run() {
  local phase="$1"
  [[ -n "$ONLY" && "$ONLY" != "$phase" ]] && return 1
  [[ " $SKIP " == *" $phase "* ]] && return 1
  return 0
}

# ---- phases ----------------------------------------------------------------
phase_preflight() {
  log::step "preflight"
  if [[ "$(uname -m)" != "arm64" ]]; then
    log::warn "expected Apple Silicon (arm64); continuing anyway"
  fi
  if ! xcode-select -p &>/dev/null; then
    log::info "installing Xcode Command Line Tools"
    DRY xcode-select --install || true
  fi
  if ! command -v brew &>/dev/null; then
    log::info "installing Homebrew"
    # Single-quoted on purpose: the inner $(curl ...) must run only when this
    # executes, not during arg expansion — so --dry-run never hits the network.
    # shellcheck disable=SC2016
    DRY bash -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  fi
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  if ! command -v stow &>/dev/null; then
    log::info "installing stow"
    DRY brew install stow
  fi
}

phase_stow() {
  log::step "stow packages"
  local pkgs pkg
  # shellcheck disable=SC2086
  pkgs="$(modules::packages_for_modules $MODULES)"
  log::info "packages: ${pkgs:-<none>}"
  for pkg in $pkgs; do
    stow::link "$REPO_DIR" "$pkg" "$DRY_RUN" "$ADOPT"
  done
}

phase_brew() {
  log::step "brew bundle"
  command -v brew &>/dev/null || {
    log::warn "brew not found; skipping"
    return 0
  }
  local composed module frag
  composed="$(mktemp)"
  if [[ -f "$REPO_DIR/Brewfile" ]]; then cat "$REPO_DIR/Brewfile" >>"$composed"; fi
  for module in $MODULES; do
    frag="$(modules::brewfile_for_module "$module" "$REPO_DIR")"
    if [[ -n "$frag" ]]; then cat "$frag" >>"$composed"; fi
  done
  if [[ "$GUI" == 1 && -f "$REPO_DIR/brew/Brewfile.casks" ]]; then
    cat "$REPO_DIR/brew/Brewfile.casks" >>"$composed"
  fi
  if [[ ! -s "$composed" ]]; then
    log::warn "no Brewfile content for these modules yet; skipping"
    rm -f "$composed"
    return 0
  fi
  if [[ "$DRY_RUN" == 1 ]]; then
    log::debug "(dry-run) brew bundle --file=$composed:"
    cat "$composed"
  else
    brew bundle --file="$composed"
  fi
  rm -f "$composed"
}

phase_mise() {
  log::step "mise tools"
  command -v mise &>/dev/null || {
    log::warn "mise not found; skipping"
    return 0
  }
  local dest="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
  DRY mkdir -p "$dest/conf.d"
  if [[ -f "$REPO_DIR/mise/config.toml" ]]; then
    DRY ln -sfn "$REPO_DIR/mise/config.toml" "$dest/config.toml"
  fi
  local module m
  for module in $MODULES; do
    m="$(modules::mise_for_module "$module" "$REPO_DIR")"
    if [[ -n "$m" ]]; then DRY ln -sfn "$m" "$dest/conf.d/$module.toml"; fi
  done
  DRY mise trust --quiet "$dest/config.toml" || true
  DRY mise install || true
}

phase_macos() {
  log::step "macOS defaults"
  if [[ "$GUI" != 1 ]]; then
    log::info "no-gui: skipping macOS defaults"
    return 0
  fi
  [[ "$OSTYPE" == darwin* ]] || {
    log::warn "not macOS; skipping"
    return 0
  }
  if [[ -f "$REPO_DIR/os/macos/defaults.sh" ]]; then
    DRY bash "$REPO_DIR/os/macos/defaults.sh"
  else
    log::warn "os/macos/defaults.sh not present yet"
  fi
}

phase_app() {
  log::step "app config placement"
  if [[ "$GUI" != 1 ]]; then
    log::info "no-gui: skipping app config"
    return 0
  fi
  if [[ -f "$REPO_DIR/os/macos/stow-post.sh" ]]; then
    DRY bash "$REPO_DIR/os/macos/stow-post.sh"
  else
    log::warn "os/macos/stow-post.sh not present yet"
  fi
}

phase_post() {
  log::step "post"
  command -v bat &>/dev/null && DRY bat cache --build || true
  command -v mise &>/dev/null && DRY mise reshim || true
  log::ok "done — restart your shell (exec zsh) to load the new config"
}

# ---- main ------------------------------------------------------------------
if [[ "$LIST_ONLY" == 1 ]]; then
  list_modules
  exit 0
fi

resolve_selection
log::info "preset: $PRESET"
log::info "gui: $GUI"
log::info "modules: $MODULES"
[[ "$DRY_RUN" == 1 ]] && log::warn "DRY RUN — no changes will be made"

if [[ "$NO_SAVE" != 1 && "$DRY_RUN" != 1 ]]; then
  modules::selection_save "$PRESET" "$GUI" "$MODULES"
  log::info "saved selection → $(modules::selection_path)"
fi

for phase in "${ALL_PHASES[@]}"; do
  should_run "$phase" || {
    log::debug "skipping phase: $phase"
    continue
  }
  "phase_$phase"
done

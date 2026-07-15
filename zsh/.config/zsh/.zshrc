# ~/.config/zsh/.zshrc — interactive shell config.
# Sourced only for interactive shells (after .zshenv, and .zprofile for logins).
# Don't mutate PATH here — it's owned by .zshenv (AGENTS.md rule 6).

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"

setopt share_history          # share history across sessions
setopt hist_ignore_dups       # don't record a line identical to the previous
setopt hist_ignore_all_dups   # remove older duplicate of a re-entered command
setopt hist_ignore_space      # don't record lines that start with a space
setopt hist_reduce_blanks     # trim superfluous blanks before recording
setopt hist_verify            # let me edit a !history expansion before running
setopt inc_append_history     # append as commands run, not just at exit
setopt extended_history       # record timestamp + duration

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
setopt auto_cd                # `cd` by typing a directory name
setopt auto_pushd             # push visited dirs onto the stack
setopt pushd_ignore_dups
setopt interactive_comments   # allow `# comments` at the interactive prompt

# CDPATH: jump straight into a project by name from anywhere.
if [[ -d "${DEV_DIR:-$HOME/dev}" ]]; then
  cdpath=("${DEV_DIR}/me" "${DEV_DIR}/work" "${DEV_DIR}")
fi

# ---------------------------------------------------------------------------
# antidote — plugin manager (clone-or-source), static bundle.
# Plugins load deferred via zsh-defer where sensible (see antidote.txt).
# ---------------------------------------------------------------------------
: "${ANTIDOTE_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/antidote}"

if [[ ! -e "${ANTIDOTE_HOME}/antidote.zsh" ]]; then
  command -v git &>/dev/null &&
    git clone --depth=1 https://github.com/mattmc3/antidote.git "${ANTIDOTE_HOME}" 2>/dev/null
fi

if [[ -e "${ANTIDOTE_HOME}/antidote.zsh" ]]; then
  # shellcheck disable=SC1091
  source "${ANTIDOTE_HOME}/antidote.zsh"

  # Generate a static, sourceable bundle from antidote.txt and cache it. The
  # cache is regenerated only when antidote.txt is newer than the static file.
  zsh_plugins="${ZDOTDIR}/.zsh_plugins.zsh"
  if [[ ! "${zsh_plugins}" -nt "${ZDOTDIR}/antidote.txt" ]]; then
    antidote bundle <"${ZDOTDIR}/antidote.txt" >"${zsh_plugins}"
  fi
  # shellcheck disable=SC1090
  source "${zsh_plugins}"
  unset zsh_plugins
fi

# ---------------------------------------------------------------------------
# Completion — cached compinit (regenerate the dump at most once per day).
# ---------------------------------------------------------------------------
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zcompdump:h}"
# If the dump is <24h old, skip the expensive security check (-C).
if [[ -n "${_zcompdump}"(#qN.mh-24) ]]; then
  compinit -C -d "${_zcompdump}"
else
  compinit -d "${_zcompdump}"
fi
unset _zcompdump

# Alias git → g and mirror its completion.
alias g=git
compdef g=git 2>/dev/null

# ---------------------------------------------------------------------------
# Shell function library (namespace::func helpers).
# ---------------------------------------------------------------------------
if [[ -f "${ZDOTDIR}/functions.zsh" ]]; then
  # shellcheck disable=SC1091
  source "${ZDOTDIR}/functions.zsh"
fi

# ---------------------------------------------------------------------------
# Tool init — each guarded so a missing tool is a no-op.
# ---------------------------------------------------------------------------
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v fzf &>/dev/null; then
  # Newer fzf (>=0.48) ships shell integration via `fzf --zsh`.
  source <(fzf --zsh) 2>/dev/null
fi

# ---------------------------------------------------------------------------
# LAST: secrets, then machine-local overrides (local.zsh wins). Both untracked.
# ---------------------------------------------------------------------------
if [[ -f "${ZDOTDIR}/secrets.zsh" ]]; then
  # shellcheck disable=SC1091
  source "${ZDOTDIR}/secrets.zsh"
fi

if [[ -f "${ZDOTDIR}/local.zsh" ]]; then
  # shellcheck disable=SC1091
  source "${ZDOTDIR}/local.zsh"
fi

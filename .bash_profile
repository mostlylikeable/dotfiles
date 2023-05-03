#!/usr/bin/env bash
#
# Inspired by:
#   https://github.com/mathiasbynens/dotfiles/blob/main/.bash_profile

# Define dotfiles dir if unset or empty
: "${DOTFILES_DIR:=$HOME/.dotfiles}"
export DOTFILES_DIR

# Define dev/project dir if unset or empty
: "${DEV_DIR:=$HOME/dev}"
export DEV_DIR

# If dev dir exists
if [[ -d "${DEV_DIR}" ]]; then
  # cd $HOME/dev
  alias dev='cd ${DEV_DIR}'

  # For separating wip/personal from work projects
  alias mine='cd ${DEV_DIR}/mine'
  alias work='cd ${DEV_DIR}/work'

  # Add "dev" dirs, and project dirs from each "dev" dir to CDPATH
  #
  # Given:
  #   ~/dev/mine/my-project
  #   ~/dev/work/work-project
  #
  # Allows (from anywhere):
  #   cd mine
  #   cd work
  #   cd my-project
  #   cd work-project
  CDPATH=".:${DEV_DIR}:$(find ${DEV_DIR} -type d -maxdepth 1 -mindepth 1 | tr '\n' ':')${CDPATH}"
  export CDPATH
fi

# Some of these are order dependent
FILES="term.sh
aliases.sh
print.sh
docker.sh
fs.sh
git.sh
gradle.sh
osx.sh
str.sh
tint.sh
utils.sh"

# Source shell dotfiles
echo "sourcing dotfiles from $DOTFILES_DIR"
for file in $FILES; do
  # echo "  - $DOTFILES_DIR/sh/$file"
  # shellcheck disable=SC1090
  # source "$(realpath "$DOTFILES_DIR/sh/$file")"
  source $(cd "$(dirname "$DOTFILES_DIR/sh/$file")" && pwd)/$(basename "$DOTFILES_DIR/sh/$file")
done;
unset file
unset FILES

# Source custom dotfiles configuration
if [ -r "$HOME/.dotfiles-custom" ] && [ -f "$HOME/.dotfiles-custom" ]; then
  echo "sourcing $HOME/.dotfiles-custom"
  # shellcheck disable=SC1091
  source "$HOME/.dotfiles-custom"
fi

export PATH="/opt/homebrew/bin:$PATH"
# Configure tab completion for bash
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  # Ensure existing Homebrew v1 completions continue to work
  BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  export BASH_COMPLETION_COMPAT_DIR
  # shellcheck disable=SC1091
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  source /etc/bash_completion
fi

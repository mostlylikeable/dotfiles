
source $HOME/dotfiles/sh/env.sh
source $HOME/dotfiles/sh/functions.sh

source $HOME/dotfiles/sh/osx.sh

#source $HOME/dotfiles/sh/st_env.sh
#source $HOME/dotfiles/sh/st_secret.sh

# set custom dir if not set
if [ -z "${DOTFILES_CUSTOM_DIR}" ]; then
  DOTFILES_DIR="$HOME/.dotfiles-custom"
fi

if [ -n "${DOTFILES_CUSTOM_DIR}" ]; then
  echo "loading custom dotfiles from ${DOTFILES_CUSTOM_DIR}"
  for f in $DOTFILES_CUSTOM_DIR/*.sh; do source $f; done
fi

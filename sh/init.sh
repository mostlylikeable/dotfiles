
source $DOTFILES_DIR/sh/env.sh
source $DOTFILES_DIR/sh/functions.sh

source $DOTFILES_DIR/sh/osx.sh

#source $HOME/dotfiles/sh/st_env.sh
#source $HOME/dotfiles/sh/st_secret.sh

[[ -z "${DOTFILES_CUSTOM_DIR}" ]] && custom_dir="${HOME}/.dotfiles-custom" || custom_dir="${DOTFILES_CUSTOM_DIR}"

if [ -n "${custom_dir}" ]; then
  echo "sourcing ${custom_dir}"
  for f in $custom_dir/*.sh; do
    echo "source ${f}"
    source $f
  done
fi

#!/usr/bin/env bash
# init.sh

export DEBUG_DOTFILES=false

# echo "sourcing dotfiles from $DOTFILES_DIR"
source $DOTFILES_DIR/sh/io.sh

function _df_log_debug {
  if [ "$DEBUG_DOTFILES" = true ]; then
    echo $1
  fi
}

echo "sourcing core files"
for f in $DOTFILES_DIR/sh/*.sh; do
  if [ $f = "$DOTFILES_DIR/sh/init.sh" ] ; then
    _df_log_debug "  - skipping init.sh"
    continue
  fi
  _df_log_debug "  - $f"
  source $f
done

[[ -z "${DOTFILES_CUSTOM_DIR}" ]] && custom_dir="${HOME}/.dotfiles-custom" || custom_dir="${DOTFILES_CUSTOM_DIR}"

if [[ -d $custom_dir ]]; then
  _df_log_debug "sourcing custom files"
  for f in $custom_dir/*.sh; do
    _df_log_debug "  - ${f}"
    source $f
  done
else
  echo "no custom dotfiles to source"
fi

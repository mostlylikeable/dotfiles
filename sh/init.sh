#!/bin/bash

export DEBUG_DOTFILES=true

function _df_log {
  if [ "$DEBUG_DOTFILES" = true ]; then
    echo $1
  fi
}

_df_log "sourcing core files"
for f in $DOTFILES_DIR/sh/*.sh; do
  if [ $f = "$DOTFILES_DIR/sh/init.sh" ] ; then
    _df_log "  - skipping init.sh"
    continue
  fi
  _df_log "  - $f"
  source $f
done

[[ -z "${DOTFILES_CUSTOM_DIR}" ]] && custom_dir="${HOME}/.dotfiles-custom" || custom_dir="${DOTFILES_CUSTOM_DIR}"

if [ -n "${custom_dir}" ]; then
  _df_log "sourcing custom files"
  for f in $custom_dir/*.sh; do
    _df_log "  - ${f}"
    source $f
  done
fi

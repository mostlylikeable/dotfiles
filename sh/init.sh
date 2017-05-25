
echo "sourcing core files"
for f in $DOTFILES_DIR/sh/*.sh; do
  if [ $f = "$DOTFILES_DIR/sh/init.sh" ] ; then
    continue
  fi
done

# for f in $DOTFILES_DIR/sh/*.sh; do
#   echo "source ${f}"
#   source $f
# done

[[ -z "${DOTFILES_CUSTOM_DIR}" ]] && custom_dir="${HOME}/.dotfiles-custom" || custom_dir="${DOTFILES_CUSTOM_DIR}"

if [ -n "${custom_dir}" ]; then
  echo "sourcing custom files"
  for f in $custom_dir/*.sh; do
    echo "source ${f}"
    source $f
  done
fi

#!/bin/zsh
#
# Inspired by:
# https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

cd "$(dirname "${(%):-%x}")"
# cd "$(dirname "${BASH_SOURCE}")"

# update dotfiles
# git pull origin main

bootstrap() {
  # Create .dotfiles symlink in home to this repo
  [ ! -e "$HOME/.dotfiles" ] && ln -s "$PWD" ~/.dotfiles

  # Sync files that should be in home dir to $HOME
  # TODO: remove 'sh'
  rsync \
    --exclude ".git/" \
    --exclude "bash/" \
    --exclude "sh/" \
    --exclude "config/" \
    --exclude "test/" \
		--exclude ".DS_Store" \
		--exclude ".editorconfig" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "brew.sh" \
		--exclude "prompt.sh" \
		--exclude "README.md" \
		--exclude "LICENSE" \
    --archive \
    --verbose \
		--no-perms \
    . ~

  # shellcheck disable=SC1090
  source ~/.zprofile
}

# if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
if [[ "$1" =~ ^(--force|-f)$ ]]; then
	bootstrap
else
  read "reply?This may overwrite existing files in home dir ${HOME}. Proceed? (y/n) "
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    bootstrap
  fi
	# read -p "This may overwrite existing files in home dir ${HOME}. Proceed? (y/n) " -n 1
  # echo ""
	# if [[ $REPLY =~ ^[Yy]$ ]]; then
	# 	boostrap
	# fi
fi
unset boostrap
unset reply

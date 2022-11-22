#!/usr/bin/env bash

alias g="git"

# Enable tab completion for `g` by marking it as an alias for `git`
# https://github.com/mathiasbynens/dotfiles/blob/main/.bash_profile
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

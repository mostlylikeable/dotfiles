#!/usr/bin/env bash
# shellcheck shell=bash
#
# Miscellaneous aliases.

[[ -n "${_DOTFILES_ALIASES_SH:-}" ]] && return 0
_DOTFILES_ALIASES_SH=1

# always colorize grep
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# modern replacements when installed
command -v bat &>/dev/null && alias cat="bat --paging=never"
command -v rg &>/dev/null && alias grep="rg"

# networking
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

# trim newlines and copy to clipboard
alias pb="tr -d '\n' | pbcopy"

# url encode/decode (python3)
alias urlenc='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));"'
alias urldec='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]));"'

# apply a command to each line of stdin: `find . -name x | map dirname`
alias map="xargs -n1"

# print each PATH entry on its own line
alias path='echo "$PATH" | tr ":" "\n"'

# terraform
alias tf="terraform"

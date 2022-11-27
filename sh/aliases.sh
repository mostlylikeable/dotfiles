#!/usr/bin/env bash

# always use colors with grep
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# get my ip
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

# get local ip
alias localip="ipconfig getifaddr en0"

# trim newlines and copy to clipboard
alias pb="tr -d '\n' | pbcopy"

# url encode arg
alias urlenc='python -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));"'

# decode url encoded arg
alias urldec='python -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]));"'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
# https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
alias map="xargs -n1"

# # One of @janmoesen’s ProTip™s
# for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
#   # shellcheck disable=SC2139
# 	alias "${method}"="lwp-request -m '${method}'"
# done

# Print each PATH entry on a separate line
# https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
alias path='echo -e ${PATH//:/\\n}'

# launch chrome
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

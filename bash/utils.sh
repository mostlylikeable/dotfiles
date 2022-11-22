#!/usr/bin/env bash

# List pids (pid and name) that match a pattern
alias pids="util::pids"

# Generate a uuid and copy it
alias uuid="util::uuid"

# List processing using a port
alias whoport="util:who_port"

###############################################################################
# List pids and process name that match pattern
#
# @param
#   pattern - the pattern
# @output
#   the process and pid that matches the pattern
###############################################################################
util::pids() {
  pgrep -l "$1"
}

###############################################################################
# Generate a random uuid, and copy it to clipboard
#
# @output
#   the generated uuid (also copied to clipboard)
###############################################################################
util::uuid() {
  uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | pbcopy
  pbpaste
}

###############################################################################
# List processes using pid
#
# @param
#   pid - the pid to search for
# @output
#   the list of processes using the pid
###############################################################################
util::who_port() {
  lsof -i tcp:*
}

#!/usr/bin/env bash
# shellcheck shell=bash
#
# Docker helpers.

[[ -n "${_DOTFILES_DOCKER_SH:-}" ]] && return 0
_DOTFILES_DOCKER_SH=1

# Start containers (foreground).
alias dcu="docker compose up"
# Start detached, wait until healthy.
alias dcuw="docker compose up --detach --wait"

# Stop and remove containers and networks
alias dcd="docker compose down"

# List running containers
alias dps="docker ps"

# List all containers
alias dpsa="docker ps --all"

# Remove exited containers
alias drm="docker::rm_exited"

# Remove dangling images
alias drmi="docker::rmi_dangling"

# Stop all running containers
alias dstop="docker::stop"

# Follow the logs of a container. A real function (not an alias) so it can take
# a container argument.
alias dlogs=docker::logs

###############################################################################
# Follow the logs of one or more containers.
#
# @params
#   * - container name(s)/id(s) (and any `docker container logs` flags)
###############################################################################
docker::logs() {
  docker container logs --follow "$@"
}

###############################################################################
# Stop all containers.
###############################################################################
docker::stop() {
  docker stop "$(docker ps --all --quiet)"
}

###############################################################################
# Remove 'exited' containers.
###############################################################################
docker::rm_exited() {
  docker rm "$(docker ps --all --quiet --filter status=exited)"
}

###############################################################################
# Remove 'dangling' images.
###############################################################################
docker::rmi_dangling() {
  docker rmi "$(docker images --quiet --filter dangling=true)"
}

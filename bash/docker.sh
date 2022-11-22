#!/usr/bin/env bash

# Create and start containers in background, and wait for healthy
alias dcu="docker-compose up --detach --wait"

# Stop and remove containers and networks
alias dcd="docker-compose down"

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

###############################################################################
# Stop containers
###############################################################################
docker::stop() {
  docker stop "$(docker ps --all --quiet)"
}

###############################################################################
# Remove 'exited' containers
###############################################################################
docker::rm_exited() {
  docker rm "$(docker ps --all --quiet --filter status=exited)"
}

###############################################################################
# Remove 'dangling' images
###############################################################################
docker::rmi_dangling() {
  docker rmi "$(docker images --quiet --filter dangling=true)"
}


function dcu() {
  # echo "docker up"
  status "docker: starting containers"
  docker-compose up -d
}

function drm() {
  status "docker: rm containers"
  docker rm $(docker ps -a -q)
}

function dsa() {
  status "docker: stop containers"
  docker stop $(docker ps -a -q)
}

function is_composable() {
  [ -f 'docker-compose.yml' ]
}

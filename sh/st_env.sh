
# grails
export GRAILS_OPTS="-Xms512M -Xmx4G -XX:PermSize=512M -XX:MaxPermSize=2G -Dfile.encoding=UTF-8"

# use local *-connectivity apps
export ST_ENV=local

# source dirs
export PG_HOME=$HOME/dev/physical-graph
export IOT_HOME=$HOME/dev/gitlab

# aws
export AWS_PROFILE=st-identity
alias awsiot='export AWS_PROFILE=iotdev'
alias awsidentity='export AWS_PROFILE=st-identity'

# cassandra
export DSE_HOME=/usr/local/dse
export CASSANDRA_HOME=$DSE_HOME
export CASSANDRA_BIN=$CASSANDRA_HOME/bin

# run st app. -d will run in debug mode
function str() {
  # determine if we should run in debug-mode
  local is_debug=false
  while getopts d opt; do
    case $opt in
      d) is_debug=true ;;
      *) echo "unknown flag $opt" ;;
    esac
  done
  shift "$((OPTIND-1))" # shift off options and optinal from $@

  # run app/service
  case $1 in
    alliance)
      run_alliance $is_debug ;;
    dm)
      run_dm $is_debug ;;
    oauth)
      run_oauth $is_debug ;;
    *)
      echo "unable to run $1: unknown" ;;
  esac
}

function run_dm() {
  cd $PG_HOME/data-management
  echo "starting data-management"
  echo -n -e "\033]0;data-management\007"
  j7
  if [ "$1" = true ] ; then
    grails-debug run-app
  else
    grails run-app
  fi
}

function run_alliance() {
  cd $IOT_HOME/alliance
  echo "starting alliance"
  echo -n -e "\033]0;alliance\007"
  j8
  docker-compose up -d
  if [ "$1" = true ] ; then
    gradle run --debug-jvm
  else
    gradle run
  fi
}

function run_oauth() {
  cd $PG_HOME/oauth-auth-server
  echo "starting oauth"
  echo -n -e "\033]0;oauth\007"
  j8
  docker-compose up -d
  if [ "$1" = true ] ; then
    ./gradlew oauth-auth-web:bootRun --debug-jvm
  else
    ./gradlew oauth-auth-web:run
  fi
}

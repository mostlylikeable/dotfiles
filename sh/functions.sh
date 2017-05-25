
# set java home to java 8 jvm
function j8() {
  # outputs error if no java 8 jvm installed
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
  java -version
}

# set java home to java 7 jvm
function j7() {
  # outputs error if no java 7 jvm installed
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
  java -version
}

function jver() {
  version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  echo $version
}

function uuid() {
  uuidgen|tr '[:upper:]' '[:lower:]'
}

# exec gradle wrapper in current or parents
function gradle() {
  gw="$(upfind gradlew)"
  if [ -z "$gw" ]; then
    echo "Gradle wrapper not found."
  else
    $gw $@
  fi
}

# find $1 in current dir, or parents
function upfind() {
  dir=`pwd`
  while [ "$dir" != "/" ]; do
    p=`find "$dir" -maxdepth 1 -name $1`
    if [ ! -z $p ]; then
      echo "$p"
      return
    fi
    dir=`dirname "$dir"`
  done
}

function mcd() {
  mkdir -p "$1" && cd "$1"
}

# find shorthand
# https://github.com/nicksp/dotfiles/blob/master/shell/shell_functions
function f() {
  find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

# List all files, long format, colorized, permissions in octal
function la() {
   ls -l  "$@" | awk '
    {
      k=0;
      for (i=0;i<=8;i++)
        k+=((substr($1,i+2,1)~/[rwx]/) *2^(8-i));
      if (k)
        printf("%0o ",k);
      printf(" %9s  %3s %2s %5s  %6s  %s %s %s\n", $3, $6, $7, $8, $5, $9,$10, $11);
    }'
}

# https://unix.stackexchange.com/questions/74185/how-can-i-prevent-grep-from-showing-up-in-ps-results
function pids() {
  # ps aux | grep "[o]auth" | awk '{print $2}'
  ps aux | grep "[${1:0:1}]${1:1}" | awk '{print $2}'
}

# https://gist.github.com/chrisdarroch/7018927
function idea() {
  #  check for where the latest version of IDEA is installed
  IDEA=`ls -1d /Applications/IntelliJ\ * | tail -n1`
  wd=`pwd`

  # were we given a directory?
  if [ -d "$1" ]; then
  #  echo "checking for things in the working dir given"
   wd=`ls -1d "$1" | head -n1`
  fi

  # were we given a file?
  if [ -f "$1" ]; then
  #  echo "opening '$1'"
   open -a "$IDEA" "$1"
  else
     # let's check for stuff in our working directory.
     pushd $wd > /dev/null

     # does our working dir have an .idea directory?
     if [ -d ".idea" ]; then
  #      echo "opening via the .idea dir"
       open -a "$IDEA" .

     # is there an IDEA project file?
     elif [ -f *.ipr ]; then
  #      echo "opening via the project file"
       open -a "$IDEA" `ls -1d *.ipr | head -n1`

     # Is there a pom.xml?
     elif [ -f pom.xml ]; then
  #      echo "importing from pom"
       open -a "$IDEA" "pom.xml"

     # can't do anything smart; just open IDEA
     else
  #      echo 'cbf'
       open "$IDEA"
     fi

     popd > /dev/null
  fi
}

# override rm to send to trash (timestamped) instead
function rm () {
    local path
    for path in "$@"; do
        # ignore any arguments
        if [[ "$path" = -* ]]; then :
        else
            local dst=${path##*/}
            # append the time if necessary
            while [ -e ~/.Trash/"$dst" ]; do
                dst="$dst "$(date +%H-%M-%S)
            done
            mv "$path" ~/.Trash/"$dst"
        fi
    done
}

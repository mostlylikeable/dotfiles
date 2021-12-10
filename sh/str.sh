
# tests whether a string is empty or not.
#   -> true if string is empty.
#
# usage:
# if str_empty $1; then
#   echo "$1 is empty"
# else
#   echo "$1 is not empty"
# fi
function str_empty {
  [[ -z $1 ]] && true || false
}

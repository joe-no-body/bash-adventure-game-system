source utils.bash

declare -gA object_attrs

init-object() {
  func? "$1" || internal_error "init-object expects a function, but got '$1'"
  local -r INITIALIZING_OBJECT="$1"
  object_attrs["$1/_type"]=object
  "$1"
}

set-attr() {
  local object attr val

  if (( "$#" == 2 )); then
    if [[ ! -v INITIALIZING_OBJECT ]]; then
      internal_error "$0 requires three arguments if it's not called from init-object"
    fi
    object="$INITIALIZING_OBJECT"
  elif (( "$#" == 3 )); then
    object="$1"
    shift
  else
    internal_error "$0 expects two or three arguments, but got $#"
  fi

  if [[ ! -v object_attrs["$object/_type"] ]]; then
    internal_error "uninitialized object '$object'"
  fi

  attr="$1"
  val="$2"

  object_attrs["$object/$attr"]="$val"
}

get-attr() {
  local object attr
  object="$1"
  attr="$2"

  echo "${object_attrs["$object/$attr"]}"
}

set-flag() {
  local object flag
  if (( "$#" == 1 )); then
    [[ -v INITIALIZING_OBJECT ]] || internal_error "$0 requires three arguments if it's not called from init-object"
    object="$INITIALIZING_OBJECT"
  elif (( "$#" == 3 )); then
    object="$1"
    shift
  else
    internal_error "$0 expects two or three arguments, but got $#"
  fi


  # TODO
}
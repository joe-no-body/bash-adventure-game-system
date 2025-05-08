# Object handling functions.
source utils.bash

declare -gA OBJECT_ATTRS

#######################################
# Initialize objects by calling functions with appropriate namespace prefixes.
#######################################
init-all-objects() {
  local func
  # XXX: It would probably be better to require the game implementer to call an
  # `objects::define` function explicitly for each object init function they
  # want to declare, but this feels convenient enough I kinda want to stick with
  # it.
  while read -r func; do
    func="${func#declare -f }"
    case "$func" in
      # TODO: Support initializing objects with custom prefixes. Perhaps we
      # could have an array of prefixes or a regex.
      object::*) ;&
      room::*) init-object "$func" ;;
    esac
  done < <(declare -F)
}

#######################################
# Initialize an object from its init function.
# Globals:
#   OBJECT_ATTRS - the object attributes map
#   INITIALIZING_OBJECT - the object ID, to be used as an implicit argument to
#     set-attr, etc.
# Arguments:
#   The ID of the object to init, which should also be the name of its init
#   function.
# Outputs:
#   None.
# Returns:
#   0 on success, non-zero on error.
#######################################
init-object() {
  debug "Initializing object $func"
  func? "$1" || internal_error "init-object expects a function, but got '$1'"
  local -r INITIALIZING_OBJECT="$1"
  OBJECT_ATTRS["$1/_type"]=object
  "$1"
}

#######################################
# Check if an object exists.
# Globals:
#   OBJECT_ATTRS
# Arguments:
#   The ID of the object to check.
#######################################
object?() {
  [[ -v OBJECT_ATTRS["$1/_type"] ]]
}

#######################################
# Set an attribute on an object.
# Globals:
#   OBJECT_ATTRS
#   INITIALIZING_OBJECT - If specified and only two args are provided, will be
#     used as the object ID argument.
# Arguments:
#   $1 - the ID of the object to update (optional)
#   $2 - the name of the attribute to set
#   $3 - the value to set
#   If only two args are given and INITIALIZING_OBJECT is set, $1 and $2 will
#   be used as $2 and $3.
# Outputs:
#   None.
# Returns:
#   0 on success, non-zero on error.
#######################################
set-attr() {
  local object attr val

  if (( "$#" == 2 )); then
    # usage: set-attr ATTR VAL
    if [[ ! -v INITIALIZING_OBJECT ]]; then
      internal_error "${FUNCNAME[0]} requires three arguments if it's not called from init-object"
    fi
    object="$INITIALIZING_OBJECT"
  elif (( "$#" == 3 )); then
    # usage: set-attr OBJECT ATTR VAL
    object="$1"
    shift
  else
    internal_error "${FUNCNAME[0]} expects two or three arguments, but got $#"
  fi

  if ! object? "$object"; then
    internal_error "uninitialized object '$object'"
  fi

  attr="$1"
  val="$2"

  OBJECT_ATTRS["$object/$attr"]="$val"
}

#######################################
# Get the given attribute for the object.
# Globals:
#   OBJECT_ATTRS
# Arguments:
#   $1 - the object ID to query
#   $2 - the name of the attribute to query
# Outputs:
#   The value of the given attribute.
#######################################
get-attr() {
  local object attr
  # TODO: validate args
  object="$1"
  attr="$2"

  object? "$object" || internal_error "${FUNCNAME[0]} can't get attributes on non-existent objects - got $1"

  echo "${OBJECT_ATTRS["$object/$attr"]}"
}

#######################################
# Check if the given object has the named attribute.
# Globals:
#   OBJECT_ATTRS
# Arguments:
#   $1 - the object ID to query
#   $2 - the name of the attribute to query
# Outputs:
#   None.
# Returns:
#   0 if the attribute exists, 1
#######################################
has-attr?() {
  object? "$1" || internal_error "${FUNCNAME[0]} can't check the presence of attributes on non-existent objects - got $1"
  [[ -v OBJECT_ATTRS["$1/$2"] ]]
}

#######################################
# Set the given flag for the object.
#######################################
set-flag() {
  local object flag
  if (( "$#" == 1 )); then
    if [[ ! -v INITIALIZING_OBJECT ]]; then
      internal_error "${FUNCNAME[0]} requires two arguments if it's not called from init-object"
    fi
    object="$INITIALIZING_OBJECT"
  elif (( "$#" == 2 )); then
    object="$1"
    shift
  else
    internal_error "${FUNCNAME[0]} expects one or two arguments, but got $#"
  fi

  object? "$object" || internal_error "${FUNCNAME[0]} can't set flags on non-existent objects - got $1"

  flag="$1"

  OBJECT_ATTRS["$object/flags/$flag"]=1
}

#######################################
# Check if the given flag is set.
#######################################
flag?() {
  object? "$1" || internal_error "${FUNCNAME[0]} can't check the presence of flags on non-existent objects - got $1"
  [[ -v OBJECT_ATTRS["$1/flags/$2"] ]] && [[ "${OBJECT_ATTRS["$1/flags/$2"]}" != '' ]]
}

#######################################
# Clear the given flag for the object.
#######################################
clear-flag() {
  local object flag
  if (( "$#" == 1 )); then
    if [[ ! -v INITIALIZING_OBJECT ]]; then
      internal_error "${FUNCNAME[0]} requires two arguments if it's not called from init-object"
    fi
    object="$INITIALIZING_OBJECT"
  elif (( "$#" == 2 )); then
    object="$1"
    shift
  else
    internal_error "${FUNCNAME[0]} expects one or two arguments, but got $#"
  fi

  object? "$object" || internal_error "${FUNCNAME[0]} can't get flags on non-existent objects - got $1"

  flag="$1"

  OBJECT_ATTRS["$object/flags/$flag"]=
}

#######################################
# Check an object's location.
#######################################
in?() {
  object? "$1" || internal_error "${FUNCNAME[0]} can't check the location of nonexistent object '$1'"
  object? "$2" || internal_error "${FUNCNAME[0]} can't check the location of nonexistent object '$2'"
  [[ "${OBJECT_ATTRS["$1/location"]}" == "$2" ]]
}

#######################################
# Move object to location.
#######################################
move() {
  object? "$1" || internal_error "${FUNCNAME[0]} can't move nonexistent object '$1'"
  object? "$2" || internal_error "${FUNCNAME[0]} can't move to nonexistent object '$2'"

  OBJECT_ATTRS["$1/location"]="$2"
}

#######################################
# Move object to the ether (i.e. it still exists, but is located nowhere and
# cannot be interacted with.)
#######################################
remove() {
  object? "$1" || internal_error "${FUNCNAME[0]} can't remove nonexistent object '$1'"

  OBJECT_ATTRS["$1/location"]=
}

#######################################
# Get the contents of the object.
#######################################
get-contents() {
  # usage: get-contents room::kitchen kitchen_contents
  object? "$1" || internal_error "${FUNCNAME[0]} can't get the contents of nonexistent object '$1'"
  array? "$2" || internal_error "${FUNCNAME[0]} requires the name of an array as its second argument but got '$2' instead - $(declare -p "$2")"

  local -r __contents_of="$1"
  local -n __contents_array="$2"
  __contents_array=()

  for attr in "${!OBJECT_ATTRS[@]}"; do
    if [[ "$attr" == */location ]] && [[ "${OBJECT_ATTRS["$attr"]}" == "$__contents_of" ]]; then
      __contents_array+=("${attr%/location}")
    fi
  done
}
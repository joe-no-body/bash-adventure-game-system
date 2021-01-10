source utils.bash

declare -gA OBJECT_ATTRS

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
      internal_error "$0 requires three arguments if it's not called from init-object"
    fi
    object="$INITIALIZING_OBJECT"
  elif (( "$#" == 3 )); then
    # usage: set-attr OBJECT ATTR VAL
    object="$1"
    shift
  else
    internal_error "$0 expects two or three arguments, but got $#"
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

  object? "$object" || internal_error "$0 can't get attributes on non-existent objects - got $1"

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
  object? "$1" || internal_error "$0 can't check the presence of attributes on non-existent objects - got $1"
  [[ -v OBJECT_ATTRS["$1/$2"] ]]
}

set-flag() {
  local object flag
  if (( "$#" == 1 )); then
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


}
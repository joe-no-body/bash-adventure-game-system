#!/usr/bin/env bash
#
# An assortment of functions for working with arrays.
# TODO: fix usage of locals to avoid conflicts with array names.

#######################################
# Check if the given string names an array.
# Arguments:
#   $1 - the name of a variable to check
# Outputs:
#   None.
# Returns:
#   0 if $1 is the name of an array variable
#   1 if $1 is not an array variable
#   2 if $1 is not a variable
#######################################
array?() {
  [[ -v "$1" ]] || return 2
  case "$(declare -p "$1" 2>/dev/null)" in
    # this pattern only matches if the variable declaration strats approximately
    # like so, where NAME is the array name
    #   declare -a NAME=(
    # however, globs are used around `-a` to support other flags if provided
    "declare -"*"a"*" $1=("*) return 0 ;;
  esac
  return 1
}

#######################################
# Get the length of the array.
# Arguments:
#   $1 - the name of the array variable
# Outputs:
#   The length of the array on stdout (or nothing if it's not an array).
# Returns:
#   0 if successful.
#   1 if unsuccessful.
#   2 if $1 does not name a valid array variable.
#######################################
alen() {
  array? "$1" || return 2
  local -n arrayref="$1"
  printf '%s' "${#arrayref[*]}"
}

#######################################
# Check if two arrays are equal.
# Arguments:
#   $1 - the name of an array
#   $2 - the name of another array
# Outputs:
#   None.
# Returns:
#   0 if the named arrays are equal.
#   1 if the named arrays are not equal.
#   2 if either $1 or $2 does not name a valid array variable.
#######################################
aequal() {
  local len len2
  len="$(alen "$1")" || return 2
  len2="$(alen "$2")" || return 2
  [[ "$len" == "$len2" ]] || {
    return 1
  }

  local -n a="$1" b="$2"
  local i
  for ((i = 0; i < len; i++)); do
    [[ "${a["$i"]}" == "${b["$i"]}" ]] || {
      return 1
    }
  done
}

#######################################
# Remove the first element of the named array (just like `shift` does with
# positional parameters).
# Arguments:
#   $1 - the name of an array
# Outputs:
#   None.
# Returns:
#   0 if successful.
#   1 if unsuccessful.
#   2 if $1 does not name a valid array variable.
#######################################
ashift() {
  array? "$1" || return 2
  local -n array="$1"
  array=("${array[@]:1}")
}
if [[ ! -v ARRAYOPS_BASH_ ]]; then
ARRAYOPS_BASH_=1

# arrayops.bash --- hide some of the nasty syntax for manipulating bash arrays
# via https://github.com/bminor/bash/blob/master/examples/functions/arrayops.bash
# Author: Noah Friedman <friedman@splode.com>
# Extended by joe-no-body.
# Created: 2016-07-08
# Public domain

# $Id: arrayops.bash,v 1.3 2016/07/28 15:38:55 friedman Exp $

# Commentary:

# These functions try to tame the syntactic nightmare that is bash array
# syntax, which makes perl's almost look reasonable.
#
# For example the apush function below lets you write:
#
#	apush arrayvar newval
#
# instead of
#
#	${arrayvar[${#arrayvar[@]}]}=newval
#
# Because seriously, you've got to be kidding me.

# These functions avoid the use of local variables as much as possible
# (especially wherever modification occurs) because those variable names
# might shadow the array name passed in.  Dynamic scope!

# Code:

#:docstring apush:
# Usage: apush arrayname val1 {val2 {...}}
#
# Appends VAL1 and any remaining arguments to the end of the array
# ARRAYNAME as new elements.
#:end docstring:
apush()
{
    eval "$1=(\"\${$1[@]}\" \"\${@:2}\")"
}

#:docstring apop:
# Usage: apop arrayname {n}
#
# Removes the last element from ARRAYNAME.
# Optional argument N means remove the last N elements.
#:end docstring:
apop()
{
    eval "$1=(\"\${$1[@]:0:\${#$1[@]}-${2-1}}\")"
}

#:docstring aunshift:
# Usage: aunshift arrayname val1 {val2 {...}}
#
# Prepends VAL1 and any remaining arguments to the beginning of the array
# ARRAYNAME as new elements.  The new elements will appear in the same order
# as given to this function, rather than inserting them one at a time.
#
# For example:
#
#	foo=(a b c)
#	aunshift foo 1 2 3
#       => foo is now (1 2 3 a b c)
# but
#
#	foo=(a b c)
#	aunshift foo 1
#       aunshift foo 2
#       aunshift foo 3
#       => foo is now (3 2 1 a b c)
#
#:end docstring:
aunshift()
{
    eval "$1=(\"\${@:2}\" \"\${$1[@]}\")"
}

#:docstring ashift:
# Usage: ashift arrayname {n}
#
# Removes the first element from ARRAYNAME.
# Optional argument N means remove the first N elements.
#:end docstring:
ashift()
{
    eval "$1=(\"\${$1[@]: -\${#$1[@]}+${2-1}}\")"
}

#:docstring aset:
# Usage: aset arrayname idx newval
#
# Assigns ARRAYNAME[IDX]=NEWVAL
#:end docstring:
aset()
{
    eval "$1[\$2]=${@:3}"
}

#:docstring aref:
# Usage: aref arrayname idx {idx2 {...}}
#
# Echoes the value of ARRAYNAME at index IDX to stdout.
# If more than one IDX is specified, each one is echoed.
#
# Unfortunately bash functions cannot return arbitrary values in the usual way.
#:end docstring:
aref()
{
    eval local "v=(\"\${$1[@]}\")"
    local x
    for x in "${@:2}" ; do echo "${v[$x]}"; done
}

#:docstring aref:
# Usage: alen arrayname
#
# Echoes the length of the number of elements in ARRAYNAME.
#
# It also returns number as a numeric value, but return values are limited
# by a maximum of 255 so don't rely on this unless you know your arrays are
# relatively small.
#:end docstring:
alen()
{
    eval echo   "\${#$1[@]}"
    eval return "\${#$1[@]}"
}

#:docstring anreverse:
# Usage: anreverse arrayname
#
# Reverse the order of the elements in ARRAYNAME.
# The array variable is altered by this operation.
#:end docstring:
anreverse()
{
    eval set "$1" "\"\${$1[@]}\""
    eval unset "$1"
    while [ $# -gt 1 ]; do
        eval "$1=(\"$2\" \"\${$1[@]}\")"
        set "$1" "${@:3}"
    done
}

# end of original arrayops.bash source

#######################################
# Extensions by joe-no-body          #
#######################################


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
  case "$(declare -p "$1" 2>/dev/null)" in
    # this pattern only matches if the variable declaration strats approximately
    # like so, where NAME is the array name
    #   declare -a NAME=(
    # however, globs are used around `-a` to support other flags if provided
    "declare -"*"a"*" $1"*) return 0 ;;
    "declare -"*"a"*" $1") return 0 ;;
  esac
  [[ -v "$1" ]] || return 2
  return 1
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
aequal?() {
  array? "$1" || return 2
  array? "$2" || return 2
  local -n __array_utils__array1="$1" __array_utils__array2="$2"
  local len len2
  len="$(alen "$1")"
  len2="$(alen "$2")"
  if [[ "$len" != "$len2" ]]; then
    return 1
  fi

  local i
  for ((i = 0; i < len; i++)); do
    [[ "${__array_utils__array1["$i"]}" == "${__array_utils__array2["$i"]}" ]] \
      || return 1
  done
}

#######################################
# Check if array contains the given value.
# Arguments:
#   $1 - the name of the array
#   $2 - the value to search for
# Outputs:
#   None.
# Returns:
#   0 if the element is in the array.
#   1 if the element is not in the array.
#   2 if $1 doesn't name an array.
#######################################
acontains?() {
  array? "$1" || return 2
  local -n __array_utils__acontains_array="$1"
  local -r __array_utils__acontains_element="$2"
  for __array_utils__acontains_i in "${__array_utils__acontains_array[@]}"; do
    if [[ "$__array_utils__acontains_i" == "$__array_utils__acontains_element" ]]; then
      return
    fi
  done
  return 1
}

fi
#!/usr/bin/env bash

debug() {
  echo "$@" >&2
}

array?() {
  [[ -v "$1" ]] || return 2
  case "$(declare -p "$1" 2>/dev/null)" in
    "declare -"*"a"*" $1=("*) return 0 ;;
  esac
  return 1
}

alen() {
  array? "$1" || return 2
  local -n a="$1"
  echo "${#a[*]}"
}

aequal() {
  local len len2
  len="$(alen "$1")" || return 2
  len2="$(alen "$2")" || return 2
  [[ "$len" == "$(alen "$2")" ]] || {
    debug "array lengths don't match"
    return 1
  }
  debug "array lengths = $len"

  local -n a="$1" b="$2"
  local i
  for ((i = 0; i < len; i++)); do
    debug "a[$i] = ${a["$i"]}, b[$i] = ${b["$i"]}"
    [[ "${a["$i"]}" == "${b["$i"]}" ]] || {
      debug "a[$i] != b[$i] - failure"
      return 1
    }
  done
}

ashift() {
  array? "$1" || return 2
  local -n array="$1"
  array=("${array[@]:1}")
}
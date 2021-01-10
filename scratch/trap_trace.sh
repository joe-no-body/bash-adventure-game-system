#!/usr/bin/env bash
# Via https://github.com/dylanaraps/pure-bash-bible
# See LICENSE for terms.
trim_string() {
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s' "$_"
}

trace() {
  local line_num func file i
  local -a line
  i="${1:-1}"
  while true; do
    caller $i || break
    ((i++))
  done | while read -r line_num func file; do
    mapfile -t -s "$((line_num - 1))" -n 1 line <"$file"
    echo -e "$file, line $line_num: $(trim_string "$line")"
  done
}

err_trap() {
  status=$?
  (( "$status" == 0 )) && return
  echo "trapped an error - failed with status $status"
  trace
}

set -eEuo pipefail
trap err_trap ERR

foo3() {
  local i
  echo foo3
  # this doesn't really work for undefined vars, but bash throws an already
  # useful error there anyway

  # echo "$undefined"
  return 99
}

foo2() {
  # echo foo2
  # caller
  foo3
  echo after foo3
}

foo1() {
  # echo foo1
  # caller
  foo2 x y z
}

foo1 a b c

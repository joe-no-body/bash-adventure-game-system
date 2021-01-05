# Via https://github.com/dylanaraps/pure-bash-bible
# See LICENSE for terms.
trim_string() {
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s' "$_"
}

trace() {
  local line_num func file
  local -a line
  for ((i=1;;i++)); do
    caller $i || break
  done | while read -r line_num func file; do
    mapfile -t -s "$((line_num - 1))" -n 1 line <"$file"
    echo -e "File '$file', line $line_num:\n    $(trim_string "$line")"
  done
}

err_trap() {
  status=$?
  echo "trapped an error - failed with status $status"
  trace
}

set -eEuo pipefail
trap err_trap ERR

foo3() {
  local i
  echo foo3
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

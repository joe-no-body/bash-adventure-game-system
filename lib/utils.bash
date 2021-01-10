readonly STATUS_INTERNAL_ERROR=2

func?() {
  declare -F "$1" &>/dev/null
}

#######################################
# Trim leadingand trailing spaces from a string.
# Via https://github.com/dylanaraps/pure-bash-bible
# See LICENSE for terms.
# Arguments:
#   $1 - the string to trim
# Output:
#   The string with whitespace removed.
#######################################
trim_string() {
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s' "$_"
}

#######################################
# Produce a stack trace.
# Arguments:
#   $1 (optional) - Number of stack frames to skip in the output.
# Output:
#   A stack trace listing each frame's file name, line number, and the line of
#   code at that line in that file.
#######################################
trace() {
  local line_num func file
  local -a line
  local i="${1:-0}"
  ((i++))  # Always skip the frame for this function.
  while caller "$i"; do
    ((i++))
  done | while read -r line_num func file; do
    mapfile -t -s "$((line_num - 1))" -n 1 line <"$file"
    echo -e "$file, line $line_num: $(trim_string "$line")"
  done
}

internal_error() {
  echo "internal error: $*"
  trace 1
  exit "$STATUS_INTERNAL_ERROR"
} >&2

debug() {
  if [[ "$BAGS_DEBUG_MODE" ]]; then
    echo "debug: $*"
  fi
} >&2
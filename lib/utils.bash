if [[ ! -v UTILS_BASH_ ]]; then
UTILS_BASH_=
readonly STATUS_INTERNAL_ERROR=2

#######################################
# Return 0 if $1 is a function or non-zero if it isn't.
#######################################
func?() {
  declare -F "$1" &>/dev/null
}

#######################################
# Trim leading and trailing spaces from a string.
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
# Print a stack trace.
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
  echo "Traceback (most recent call last):"
  ((i++))  # Always skip the frame for this function.
  while caller "$i"; do
    ((i++))
  done | while read -r line_num func file; do
    mapfile -t -s "$((line_num - 1))" -n 1 line <"$file"
    printf '  %s, line %s, in %s:\n    %s\n' "$file" "$line_num" "$func" "$(trim_string "${line[0]}")"
  done
}

#######################################
# Print an error message and stack trace on stderr, then exit.
#######################################
internal_error() {
  echo "internal error: $*"
  trace 1
  exit "$STATUS_INTERNAL_ERROR"
} >&2

#######################################
# Print a debug message on stderr.
# Globals:
#   BAGS_DEBUG_MODE - if non-empty, the message will be printed
#######################################
debug() {
  if [[ "${BAGS_DEBUG_MODE:-}" ]]; then
    printf '%s, line %s, in %s: %s\n' "${BASH_SOURCE[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[1]}" "$*"
  fi
} >&2

fi
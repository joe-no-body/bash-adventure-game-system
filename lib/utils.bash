[[ -v UTILS_BASH_ ]] && return
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
# Read a specific line number from a file.
# Arguments:
#   $1 - the file to read from
#   $2 - the line number to read
#######################################
read_file_line() {
  local file="$1"
  local line_num="$2"
  local -a line
  mapfile -t -s "$((line_num - 1))" -n 1 line <"$file"
  printf '%s' "${line[0]}"
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
  local line_num func file line
  local i="${1:-1}"
  echo "Traceback (most recent call last):"

  # For some reason, `caller` returns the first line of the first file in the
  # traceback, so we try to use information set by the ERR trap configured in
  # bags.bash.
  if (( i == 1 )) && [[ "${ERR_FILE-}" ]]; then
    file="$ERR_FILE"
    func="$ERR_FUNCNAME"
    line_num="$ERR_LINENO"
    line="$(read_file_line "$file" "$line_num")"
    printf '  %s, line %s, in %s:\n    %s\n' "$file" "$line_num" "$func" "$(trim_string "${line}")"
    ((i++)) # Skip to the next stack frame.
  fi

  while read -r line_num func file < <(caller "$i" || true); do
    ((i++))
    if ! [[ "$line_num" || "$func" || "$file" ]]; then
      return
    fi
    line="$(read_file_line "$file" "$line_num")"
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
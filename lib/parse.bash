err() {
  echo "$*" >&2
}

parse() {
  if [[ "$1" == "the" ]]; then
    return 1
  fi

  verb="$1"
  shift

  if [[ "$1" == "the" ]]; then
    shift
  fi

  dobject="$1"
  shift

  if [[ "$1" == "with" ]]; then
    shift
  fi

  iobject="$1"
}

parse::main() {
  local verb= dobject= iobject=

  if ! parse "$@"; then
    err "parse error"
    return 1
  fi

  echo verb="$verb"
  echo dobject="$dobject"
  echo iobject="$iobject"
}

# Allow running directly for simplified testing.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  parse::main "$@"
  exit $?
fi
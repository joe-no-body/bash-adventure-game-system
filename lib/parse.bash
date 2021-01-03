parse() {
  verb="$1"
  shift

  if test "$1" == "the"; then
    shift
  fi

  dobject="$1"

  shift
  iobject="$1"
}

parse::main() {
  local verb= dobject= iobject=

  parse "$@"

  echo verb="$verb"
  echo dobject="$dobject"
  echo iobject="$iobject"
}

# Allow running directly for simplified testing.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  parse::main "$@"
fi
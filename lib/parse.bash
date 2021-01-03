parse() {
  verb="$1"
  dobject="$2"
  iobject="$3"
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
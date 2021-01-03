parse::main() {
  echo verb="$1"
}

# Allow running directly for simplified testing.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  parse::main "$@"
fi
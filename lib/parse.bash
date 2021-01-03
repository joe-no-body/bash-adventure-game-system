parse::main() {
  echo hi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  parse::main "$@"
fi
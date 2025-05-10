#!/usr/bin/env bash

PROGDIR="$(dirname "${BASH_SOURCE[0]}")"
LIBDIR="$PROGDIR/../lib"
PATH="$LIBDIR"
# shellcheck source=../lib/parse.bash
source "$LIBDIR/parse.bash"

main() {
  # setup
  syntax adorn OBJ with OBJ = verb::adorn
  syntax put OBJ in OBJ = verb::put-in

  nouns::define object::ruby-slippers -t the -a ruby -s slippers
  nouns::define object::ruby -t the -s ruby

  echo "=== syntax_tree ==="
  declare -p syntax_tree

  echo

  echo "=== nouns ==="
  declare -p nouns

  echo

  # examples
  echo "=== adorn the ruby slippers with the ruby ==="
  parse::main adorn the ruby slippers with the ruby || true

  echo

  echo "=== put the ruby in the ruby slippers ==="
  parse::main put the ruby in the ruby slippers || true
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
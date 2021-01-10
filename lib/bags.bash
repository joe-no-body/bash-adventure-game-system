#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o noglob

BAGS_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

# ensure namespace isn't polluted
# passing the lib directory here allows us to source using relative paths
\export PATH="$BAGS_LIB_DIR"
\unalias -a
hash -r

# safer IFS, though it shouldn't matter if we're safe
IFS=$' \t\n'

source arrayops.bash
source parse.bash
source perform.bash
source utils.bash
source objects.bash

bags::main() {
  init-all-objects

  if [[ "${BAGS_DEBUG_MODE:-}" ]]; then
    debug "Declared object attributes: $(declare -p OBJECT_ATTRS)"
  fi

  local verb= dobject= iobject= error=
  local -a response

  while true; do
    if ! read -rep "> " -a response; then
      echo "error"
      exit 1
    fi

    if [[ "${response[0]}" == "quit" ]]; then
      break
    fi

    error=
    if ! parse "${response[@]}" || [[ "$error" ]]; then
      echo "$error"
      echo "Why don't you try that again?"
      continue
    fi

    perform "$verb" "$dobject" "$iobject"
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  bags::main "$@"
fi
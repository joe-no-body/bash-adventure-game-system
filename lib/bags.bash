#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o noglob

# ensure namespace isn't polluted
\export PATH=''
\unalias -a
hash -r

# safer IFS, though it shouldn't matter if we're safe
IFS=$' \t\n'

# FIXME: use BASH_SOURCE here
source lib/parse.bash
source lib/perform.bash
source lib/utils.bash

bags::main() {
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
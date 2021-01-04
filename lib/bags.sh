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

source lib/parse.bash   # FIXME: use BASH_SOURCE here

func?() {
  declare -F "$1" &>/dev/null
}

perform() {
  local verb="$1" dobject="$2" iobject="$3"
  echo verb="$verb"
  echo dobject="$dobject"
  echo iobject="$iobject"


}

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
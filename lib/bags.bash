#!/usr/bin/env bash

### start preamble

# set stricter error handling
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

# set a safer IFS, though it shouldn't matter if we're digilent with quotes
IFS=$' \t\n'

# enable function names with special characters like `?` and prevent globbing
# when variables are unquoted.
set -o noglob

if [[ ! -v BAGS_LIB_DIR ]]; then
  BAGS_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
fi

# ensure the namespace is unpolluted
\export PATH="$BAGS_LIB_DIR"  # purge the path of everything but the BAGS source
\unalias -a                   # clear any aliases the user might have set
hash -r                       # purge the command hash table

### end preamble

## error handling
source utils.bash

bags::_errtrace() {
  local err_status=$?
  if (( err_status == 0 )) || [[ ! "${ERR_FILE-}" ]]; then
    return
  fi

  echo "=== Fatal error $err_status (${ERR_FILE-}:${ERR_LINENO-}:${ERR_FUNCNAME-}) ==="
  trace 1
}

declare -g ERR_LINENO ERR_FUNCNAME ERR_FILE

trap 'ERR_LINENO=${LINENO-} ERR_FUNCNAME=${FUNCNAME-} ERR_FILE=${BASH_SOURCE-}' ERR
trap bags::_errtrace EXIT

# now we load all of our libraries
source arrayops.bash
source parse.bash
source perform.bash
source objects.bash
source nouns.bash

bags::main() {
  init-all-objects

  if [[ "${BAGS_DEBUG_MODE:-}" ]]; then
    debug "Declared object attributes: $(declare -p OBJECT_ATTRS)"
  fi

  # init shared variables
  # shellcheck disable=SC2034
  local rawverb=
  local verb=
  local dobject=
  local iobject=
  local error=
  local -a response

  # If player_prompt isn't already defined, we initialize it here.
  : "${player_prompt:=> }"

  # main loop
  while true; do
    if ! read -rep "$player_prompt" -a response; then
      echo "error reading input"
      return
    fi

    case "${response[*]}" in
      '') continue ;;
      quit|exit) break ;;
    esac

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
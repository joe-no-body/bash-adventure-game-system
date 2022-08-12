#!/usr/bin/env bash

# start preamble

# set stricter error handling
set -o errexit
set -o nounset
set -o pipefail

# set a safer IFS, though it shouldn't matter if we're digilent with quotes
IFS=$' \t\n'

# enable function names with special characters like `?`
set -o noglob

if [[ ! -v BAGS_LIB_DIR ]]; then
  BAGS_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
fi

# ensure the namespace is unpolluted
\export PATH="$BAGS_LIB_DIR"  # purge the path of everything but the BAGS source
\unalias -a                   # clear any aliases the user might have set
hash -r                       # purge the command hash table

# end preamble

# now we load all of our libraries
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

  # init shared variables
  local verb=
  local dobject=
  local iobject=
  local error=
  local -a response

  # main loop
  while true; do
    if ! read -rep "> " -a response; then
      echo "error reading input"
      exit 1
    fi

    if [[ "${response[*]}" == "" ]]; then
      continue
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
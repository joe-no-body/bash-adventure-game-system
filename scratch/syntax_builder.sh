#!/usr/bin/env bash
set -euo pipefail

export PATH=''

declare -A tree=()

syntax() {
  local w
  local verb
  local -a structure=()

  while (( "$#" )); do
    w="$1"
    shift

    if [[ "$w" == "=" ]]; then
      break
    fi

    structure+=("$w")
  done

  # TODO: handle too few arguments, missing =, etc.

  verb="$1"

  local -a prefix=()
  local prefix_=
  for w in "${structure[@]}"; do
    prefix+=("$w")
    prefix_="${prefix[*]}"
    if [[ ! -v tree["$prefix_"] ]]; then
      tree["$prefix_"]=''
    fi
  done
  tree["$prefix_"]="$verb"
}

syntax look = verb::look
syntax look OBJ = verb::look
syntax look at OBJ = verb::look
syntax look in OBJ = verb::look-inside
syntax go OBJ = verb::go
syntax take OBJ = verb::take

for key in "${!tree[@]}"; do
  val="${tree["$key"]}"
  echo "$key = $val"
done
#!/usr/bin/env bash

declare -A MYMAP

MYMAP=(
  [foo]=1
  [bar]=
)

member?() {
  if [[ -v MYMAP["$1"] ]]; then
    echo "$1 is a member of MYMAP"
  else
    echo "$1 is not in MYMAP"
  fi
}

member? foo
member? bar
member? baz
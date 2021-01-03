#!/usr/bin/env bash

declare -A MYMAP

MYMAP=(
  [foo]=1
)

declare -p MYMAP

declare -n ref='MYMAP[foo]'
echo "$ref"
ref='set by nameref'

declare -p MYMAP
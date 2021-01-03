#!/usr/bin/env bash

declare -A data

for i in {1..100}; do
  data["xyz$i"]=blah
done

for ch in {a..z}; do
  data["$ch""xxx"]=bleh
done

data[foo_bar]=123
data[foo_baz]=456

run_test() {
  local i=0
  for i in {1..100}; do
    for key in "${!data[@]}"; do
      if [[ "$key" == foo_* ]]; then
        (( i++ ))
      fi
    done
  done
}

time run_test
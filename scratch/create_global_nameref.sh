#!/usr/bin/env bash

declare -A DATA=(
  [special var]='unset'
)

create_nameref() {
  declare -gn SPECIAL_VAR='DATA[special var]'
}

create_nameref

echo "$SPECIAL_VAR"
SPECIAL_VAR=test
declare -p DATA
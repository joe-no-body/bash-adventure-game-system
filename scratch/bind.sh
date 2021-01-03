#!/usr/bin/env bash

set -e

declare -A DATA

DATA=(
  [object::foo/testvar]='foo-specific value'
  [object::bar/testvar]='bar-specific value'
  # TODO: handle nested values
  [object::bar/nested/xyz]='nested value'
)

bind_vars() {
  # TODO: make the data source an argument here
  # TODO: add unique prefixes to the local names so they don't get overridden
  local prefix key varname
  prefix="$1"

  for key in "${!DATA[@]}"; do
    # match prefix
    if [[ "$key" != "$prefix/"* ]]; then
      continue
    fi

    # strip the prefix to get the variable name
    varname="${key#*/}"

    # ignore nested values
    if [[ "$varname" == */* ]]; then
      continue
    fi

    local -n "$varname"="DATA[$key]"
  done

  "$@"
}

object::foo() {
  echo "object::foo - testvar=$testvar"
  testvar='updated by foo'
}

object::bar() {
  echo "object::bar - testvar=$testvar"
  testvar='updated by bar'
}

bind_vars object::foo
bind_vars object::bar

echo "Once again"

bind_vars object::foo
bind_vars object::bar
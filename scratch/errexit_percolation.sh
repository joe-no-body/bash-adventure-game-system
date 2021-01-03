#!/usr/bin/env bash

set -x
set -e

bar() {
  return 1
}

foo() {
  bar
}

main1() {
  foo
}

main() {
  if ! foo; then
    echo "foo failed"
  fi
}
main "$@"
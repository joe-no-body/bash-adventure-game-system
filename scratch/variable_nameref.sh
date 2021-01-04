#!/usr/bin/env bash

foo='value of foo'
bar='value of bar'
baz='value of baz'

declare -n ref=foo
echo "ref=foo, foo=$ref"

# This sets foo=bar
ref=bar
echo "ref=bar, foo=$ref"
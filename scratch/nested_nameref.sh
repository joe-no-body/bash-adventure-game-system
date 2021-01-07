#!/usr/bin/env bash


var=123
declare -n ref1=var
declare -n ref2=ref1

echo "ref2 = $ref2"

declare -A arr=(
  [key]=val
)
declare -n ref1=arr
declare -n ref2=ref1[key]

echo "ref2 = $ref2"
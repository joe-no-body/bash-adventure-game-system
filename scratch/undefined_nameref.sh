#!/usr/bin/env bash

declare -A DATA=()

declare -n ref='DATA[foo]'

echo "DATA[foo]=$ref"
ref=123
declare -p DATA


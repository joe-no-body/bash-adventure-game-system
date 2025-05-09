#!/usr/bin/env bash

PROGDIR="$(dirname "${BASH_SOURCE[0]}")"
LIBDIR="$PROGDIR/../lib"
PATH="$LIBDIR"
# shellcheck source=../lib/parse.bash
source "$LIBDIR/parse.bash"

syntax yell = verb::yell

syntax look = verb::look
syntax look OBJ = verb::look
syntax look in OBJ = verb::look-inside
syntax look at OBJ = verb::look

syntax go OBJ = verb::go

syntax take OBJ = verb::take

syntax attack OBJ with OBJ = verb::attack

nouns::define object::box -s box
nouns::define object::north -s north
nouns::define object::stick -t the -s stick
nouns::define object::troll -t the -a angry -s troll
nouns::define object::sword -t the -s sword


# main

set -x
parse::main attack the ugly troll with the sword
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

BENCHMARK_COUNT=1000
benchmark_parse() {
  local bench_iters
  echo "** parsing '$*' $BENCHMARK_COUNT times"
  time (
    for ((bench_iters=0; bench_iters < BENCHMARK_COUNT; bench_iters++)); do
      parse::main "$@" >/dev/null
    done
  )
}

benchmark_parse go north

benchmark_parse take the stick

benchmark_parse attack troll with sword
benchmark_parse attack the troll with the sword
benchmark_parse attack the angry troll with the sword

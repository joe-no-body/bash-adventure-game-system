load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

# Initial test setup. We do this outside a setup() function because it's slow to
# rerun before every test.
PATH="lib/:$PATH"
source lib/parse.bash

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

# Mark key globals readonly just to make sure we don't inadvertently mutate them
# during the tests.
readonly PATH
readonly syntax_tree
readonly nouns

@test "parse standalone verb 'look'" {
  run parse::main look
  assert_success
  assert_output --partial "verb=verb::look"
  assert_output --partial "dobject="
  assert_output --partial "iobject="
}

@test "parse 'look in box'" {
  run parse::main look in box
  assert_success
  assert_output --partial "verb=verb::look-inside"
  assert_output --partial "dobject=object::box"
  assert_output --partial "iobject="
}

@test "parse standalone verb 'yell'" {
  run parse::main yell
  assert_success
  assert_output --partial "verb=verb::yell"
  assert_output --partial "dobject="
  assert_output --partial "iobject="
}

@test "parse 'go north'" {
  run parse::main go north
  assert_success
  assert_output --partial "verb=verb::go"
  assert_output --partial "dobject=object::north"
  assert_output --partial "iobject="
}

@test "parse 'take stick'" {
  run parse::main take stick
  assert_success
  assert_output --partial "verb=verb::take"
  assert_output --partial "dobject=object::stick"
  assert_output --partial "iobject="
}

@test "parse 'take the stick'" {
  run parse::main take the stick
  assert_success
  assert_output --partial "verb=verb::take"
  assert_output --partial "dobject=object::stick"
  assert_output --partial "iobject="
}

@test "parse 'attack troll with sword'" {
  run parse::main attack troll with sword
  assert_success
  assert_output --partial "verb=verb::attack"
  assert_output --partial "dobject=object::troll"
  assert_output --partial "iobject=object::sword"
}

@test "parse 'attack the troll with the sword'" {
  run parse::main attack the troll with the sword
  assert_success
  assert_output --partial "verb=verb::attack"
  assert_output --partial "dobject=object::troll"
  assert_output --partial "iobject=object::sword"
}

@test "parse 'attack the angry troll with the sword'" {
  run parse::main attack the angry troll with the sword
  assert_success
  assert_output --partial "verb=verb::attack"
  assert_output --partial "dobject=object::troll"
  assert_output --partial "iobject=object::sword"
}

@test "report a useful error on an invalid noun - 'attack the ugly troll with the sword'" {
  run parse::main attack the ugly troll with the sword
  assert_failure

  assert_output --partial "syntax error"
  assert_output --partial "ugly"
  # The error should be specific to the noun.
  refute_output --partial "seems to end before it's meant to be finished"
}

@test "throw parse error if first word isn't a verb" {
  run parse::main the
  assert_failure
  assert_output --partial "syntax error"
}

@test "throw a useful error if input terminates unexpectedly" {
  run parse::main attack
  assert_failure
  assert_output --partial "syntax error"
}
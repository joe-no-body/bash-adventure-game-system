load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test "parse standalone verb 'look'" {
  run bash scratch/syntax_tree.sh look
  assert_success
  assert_output --partial "verb=verb::look"
  assert_output --partial "dobject="
  assert_output --partial "iobject="
}

@test "parse standalone verb 'yell'" {
  run bash scratch/syntax_tree.sh yell
  assert_success
  assert_output --partial "verb=verb::yell"
  assert_output --partial "dobject="
  assert_output --partial "iobject="
}

@test "parse 'go north'" {
  run bash scratch/syntax_tree.sh go north
  assert_success
  assert_output --partial "verb=verb::go"
  assert_output --partial "dobject=north"
  assert_output --partial "iobject="
}

@test "parse 'take stick'" {
  run bash scratch/syntax_tree.sh take stick
  assert_success
  assert_output --partial "verb=verb::take"
  assert_output --partial "dobject=stick"
  assert_output --partial "iobject="
}

@test "parse 'take the stick'" {
  run bash scratch/syntax_tree.sh take the stick
  assert_success
  assert_output --partial "verb=verb::take"
  assert_output --partial "dobject=stick"
  assert_output --partial "iobject="
}

@test "parse 'attack troll with sword'" {
  run bash scratch/syntax_tree.sh attack troll with sword
  assert_success
  assert_output --partial "verb=verb::attack"
  assert_output --partial "dobject=troll"
  assert_output --partial "iobject=sword"
}

@test "throw parse error if first word isn't a verb" {
  run bash scratch/syntax_tree.sh the
  assert_failure
  assert_output --partial "syntax error"
}

@test "throw a useful error if input terminates unexpectedly" {
  run bash scratch/syntax_tree.sh attack
  assert_failure
  assert_output --partial "syntax error"
  assert_output --partial "unexpected end of input"
}
load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test "syntax - foo" {
  source lib/parse.bash
  syntax foo = verb::foo

  assert [ "${tree[foo]}" == verb::foo ]
}

@test "syntax - foo OBJ" {
  source lib/parse.bash
  syntax foo OBJ = verb::foo

  assert [ "${tree[foo]}" == '' ]
  assert [ "${tree[foo OBJ]}" == 'verb::foo' ]
}

@test "syntax - foo OBJ bar OBJ" {
  source lib/parse.bash
  syntax foo OBJ bar OBJ = verb::foo-bar

  assert [ "${tree[foo]}" == '' ]
  assert [ "${tree[foo OBJ]}" == '' ]
  assert [ "${tree[foo OBJ bar]}" == '' ]
  assert [ "${tree[foo OBJ bar OBJ]}" == 'verb::foo-bar' ]
}

@test "syntax - overlapping syntaxes" {
  source lib/parse.bash
  syntax foo OBJ bar OBJ = verb::foo-bar
  syntax foo OBJ = verb::foo
  syntax foo = verb::foo-nothing

  assert [ "${tree[foo]}" == 'verb::foo-nothing' ]
  assert [ "${tree[foo OBJ]}" == 'verb::foo' ]
  assert [ "${tree[foo OBJ bar]}" == '' ]
  assert [ "${tree[foo OBJ bar OBJ]}" == 'verb::foo-bar' ]
}
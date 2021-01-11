load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  PATH="lib/:$PATH"
  source lib/parse.bash
}

@test "syntax - foo" {
  syntax foo = verb::foo

  assert [ "${syntax_tree[foo]}" == verb::foo ]
}

@test "syntax - foo OBJ" {
  syntax foo OBJ = verb::foo

  assert [ "${syntax_tree[foo]}" == '' ]
  assert [ "${syntax_tree[foo OBJ]}" == 'verb::foo' ]
}

@test "syntax - foo OBJ bar OBJ" {
  syntax foo OBJ bar OBJ = verb::foo-bar

  assert [ "${syntax_tree[foo]}" == '' ]
  assert [ "${syntax_tree[foo OBJ]}" == '' ]
  assert [ "${syntax_tree[foo OBJ bar]}" == '' ]
  assert [ "${syntax_tree[foo OBJ bar OBJ]}" == 'verb::foo-bar' ]
}

@test "syntax - overlapping syntaxes" {
  syntax foo OBJ bar OBJ = verb::foo-bar
  syntax foo OBJ = verb::foo
  syntax foo = verb::foo-nothing

  assert [ "${syntax_tree[foo]}" == 'verb::foo-nothing' ]
  assert [ "${syntax_tree[foo OBJ]}" == 'verb::foo' ]
  assert [ "${syntax_tree[foo OBJ bar]}" == '' ]
  assert [ "${syntax_tree[foo OBJ bar OBJ]}" == 'verb::foo-bar' ]
}
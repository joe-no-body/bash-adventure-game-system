load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  PATH="lib/:$PATH"
  source lib/parse.bash
  source lib/nouns.bash

  syntax look at OBJ = verb::look
  nouns::define object::cake -s cake
}

@test "look at cake" {
  run parse::main look at cake
  assert_success
  assert_output --partial "verb=verb::look"
  assert_output --partial "dobject=object::cake"
  assert_output --partial "iobject="
}

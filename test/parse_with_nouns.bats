load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  PATH="lib/:$PATH"
  source lib/parse.bash

  syntax adorn OBJ with OBJ = verb::adorn
  syntax put OBJ in OBJ = verb::put-in

  nouns::define object::ruby-slippers -t the -a ruby -s slippers
  nouns::define object::ruby -t the -s ruby
}

@test "adorn the ruby slippers with the ruby" {
  run parse::main adorn the ruby slippers with the ruby
  assert_success
  assert_output --partial "verb=verb::adorn"
  assert_output --partial "dobject=object::ruby-slippers"
  assert_output --partial "iobject=object::ruby"
}

@test "put the ruby in the ruby slippers" {
  run parse::main put the ruby in the ruby slippers
  assert_success
  assert_output --partial "verb=verb::put-in"
  assert_output --partial "dobject=object::ruby"
  assert_output --partial "iobject=object::ruby-slippers"
}
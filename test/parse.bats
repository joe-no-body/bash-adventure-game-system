load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test "parse handles standalone verb 'look'" {
  run bash lib/parse.bash look
  assert_success
  assert_output --partial "verb=look"
}

@test "parse handles standalone verb 'yell'" {
  run bash lib/parse.bash yell
  assert_success
  assert_output --partial "verb=yell"
}
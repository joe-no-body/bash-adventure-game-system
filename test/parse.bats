load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test "parse standalone verb 'look'" {
  run bash lib/parse.bash look
  assert_success
  assert_output --partial "verb=look"
  assert_output --partial "dobject="
  assert_output --partial "iobject="
}

@test "parse standalone verb 'yell'" {
  run bash lib/parse.bash yell
  assert_success
  assert_output --partial "verb=yell"
  assert_output --partial "dobject="
  assert_output --partial "iobject="
}

@test "parse 'go north'" {
  run bash lib/parse.bash go north
  assert_success
  assert_output --partial "verb=go"
  assert_output --partial "dobject=north"
  assert_output --partial "iobject="
}

@test "parse 'take stick'" {
  run bash lib/parse.bash take stick
  assert_success
  assert_output --partial "verb=take"
  assert_output --partial "dobject=stick"
  assert_output --partial "iobject="
}

@test "parse 'take the stick'" {
  run bash lib/parse.bash take the stick
  assert_success
  assert_output --partial "verb=take"
  assert_output --partial "dobject=stick"
  assert_output --partial "iobject="
}
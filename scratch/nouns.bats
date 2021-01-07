load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  source scratch/nouns.sh
}

@test "parsing undefined word fails" {
  run nouns::parse notanoun
  assert_failure 1
}

@test "parse one word" {
  nouns=(
    [foo]=object::foo
  )
  run nouns::parse foo
  assert_success
  assert_output "object::foo"
}

@test "define a noun" {
  nouns::define object::bar -s bar
  run nouns::parse bar
  assert_success
  assert_output "object::bar"
}

@test "parse nouns with articles" {
  nouns=(
    [the]=
    [the foo]=object::foo
    [foo]=object::foo
  )
  run nouns::parse the foo
  assert_success
  assert_output "object::foo"
}

@test "define nouns with articles" {
  nouns::define object::bar -t your -s bar
  assert [ "${nouns[your]}" = "" ]
  assert [ "${nouns[your bar]}" = "object::bar" ]
  run nouns::parse bar
  assert_success
  assert_output "object::bar"

  run nouns::parse your bar
  assert_success
  assert_output "object::bar"
}

@test "define and parse nouns with adjectives" {
  nouns::define object::red-foo -t the -a red -s foo
  assert [ "${nouns[the red foo]}" = "object::red-foo" ]
  assert [ "${nouns[the foo]}" = "object::red-foo" ]
  assert [ "${nouns[foo]}" = "object::red-foo" ]

  run nouns::parse the foo
  assert_success
  assert_output "object::red-foo"

  run nouns::parse the red foo
  assert_success
  assert_output "object::red-foo"
}

@test "handle multi-word nouns" {
  nouns::define location::living-room -t the -s "living room"

  run nouns::parse living room
  assert_success
  assert_output "location::living-room"

  run nouns::parse the living room
  assert_success
  assert_output "location::living-room"
}

@test "handle homonymous nouns" {
  nouns::define object::red-foo -t the -a red -s foo
  nouns::define object::blue-foo -t the -a blue -s foo
  assert [ "${nouns[the red foo]}" = "object::red-foo" ]
  assert [ "${nouns[the blue foo]}" = "object::blue-foo" ]
  assert [ "${nouns[red foo]}" = "object::red-foo" ]
  assert [ "${nouns[blue foo]}" = "object::blue-foo" ]
  assert [ "${nouns[the foo]}" = "object::red-foo object::blue-foo" ]
  assert [ "${nouns[foo]}" = "object::red-foo object::blue-foo" ]

  run nouns::parse the foo
  assert_success
  assert_output --partial "object::red-foo"
  assert_output --partial "object::blue-foo"

  run nouns::parse the red foo
  assert_success
  assert_output --partial "object::red-foo"

  run nouns::parse the blue foo
  assert_success
  assert_output --partial "object::blue-foo"
}
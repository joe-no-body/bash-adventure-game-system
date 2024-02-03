load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  PATH="lib/:$PATH"
  source lib/nouns.bash
}

@test "parsing undefined word fails" {
  run nouns::test_parse notanoun
  assert_failure 1
}

@test "parse one word" {
  nouns=(
    [foo]=object::foo
  )
  run nouns::test_parse foo
  assert_success
  assert_output "word_count=1 object_id=object::foo"
}

@test "define a noun" {
  nouns::define object::bar -s bar

  run nouns::test_parse bar
  assert_success
  assert_output "word_count=1 object_id=object::bar"
}

@test "parse nouns with articles" {
  nouns=(
    [the]=
    [the foo]=object::foo
    [foo]=object::foo
  )

  run nouns::test_parse the foo
  assert_success
  assert_output "word_count=2 object_id=object::foo"
}

@test "define nouns with articles" {
  nouns::define object::bar -t your -s bar
  assert [ "${nouns[your]}" = "" ]
  assert [ "${nouns[your bar]}" = "object::bar" ]
  run nouns::test_parse bar
  assert_success
  assert_output "word_count=1 object_id=object::bar"

  run nouns::test_parse your bar
  assert_success
  assert_output "word_count=2 object_id=object::bar"
}

@test "define and parse nouns with adjectives" {
  nouns::define object::red-foo -t the -a red -s foo
  assert [ "${nouns[the red foo]}" = "object::red-foo" ]
  assert [ "${nouns[the foo]}" = "object::red-foo" ]
  assert [ "${nouns[foo]}" = "object::red-foo" ]

  run nouns::test_parse the foo
  assert_success
  assert_output "word_count=2 object_id=object::red-foo"

  run nouns::test_parse the red foo
  assert_success
  assert_output "word_count=3 object_id=object::red-foo"
}

@test "handle multi-word nouns" {
  nouns::define location::living-room -t the -s "living room"

  run nouns::test_parse living room
  assert_success
  assert_output "word_count=2 object_id=location::living-room"

  run nouns::test_parse the living room
  assert_success
  assert_output "word_count=3 object_id=location::living-room"
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

  run nouns::test_parse the foo
  assert_success
  assert_output --partial "2"
  assert_output --partial "object::red-foo"
  assert_output --partial "object::blue-foo"

  run nouns::test_parse the red foo
  assert_success
  assert_output "word_count=3 object_id=object::red-foo"

  run nouns::test_parse the blue foo
  assert_success
  assert_output "word_count=3 object_id=object::blue-foo"
}
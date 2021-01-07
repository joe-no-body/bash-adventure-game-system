load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  source scratch/nouns.sh
  nouns=(
    [foo]=object::foo
  )
}

@test "parsing undefined word fails" {
  run nouns::parse notanoun
  assert_failure 1
}

@test "parse one word" {
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
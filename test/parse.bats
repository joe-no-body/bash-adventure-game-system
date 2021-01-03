load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test "parse.bash runs" {
  run bash lib/parse.bash
  assert_success
  assert_output "hi"
}
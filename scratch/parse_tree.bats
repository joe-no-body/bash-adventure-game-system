load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test 'parse "look"' {
  run bash scratch/parse_tree.sh look
  assert_success
}
load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  PATH="lib/:$PATH"
  source lib/objects.bash
}

@test "objects::init-object initializes an object and its attributes"  {
  object::red-pen() {
    set-attr display_name 'red pen'
    set-attr location 'room::kitchen'
  }
  init-object object::red-pen

  run get-attr object::red-pen display_name
  assert_success
  assert_output 'red pen'

  run get-attr object::red-pen location
  assert_success
  assert_output 'room::kitchen'
}
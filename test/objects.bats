load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  PATH="lib/:$PATH"
  source lib/objects.bash

  object::red-pen() {
    set-attr display_name 'red pen'
    set-attr location 'room::kitchen'
    # set-flag takeable
  }
  init-object object::red-pen
}

assert_internal_error() {
  assert_output --partial 'internal error'
  assert_failure "$STATUS_INTERNAL_ERROR"
}


### objects::init-object

@test "objects::init-object sets up object sentinel value" {
  assert [ "${object_attrs[object::red-pen/_type]}" == 'object' ]
}

@test "objects::init-object produces an error if given a non-function" {
  run init-object object::does-not-exist
  assert_internal_error
  assert [ ! -v object_attrs[object::does-not-exist] ]
}


### objects::get-attr

@test "objects::get-attr gets an object's attributes"  {
  run get-attr object::red-pen display_name
  assert_success
  assert_output 'red pen'

  run get-attr object::red-pen location
  assert_success
  assert_output 'room::kitchen'
}


### objects::set-attr

@test "objects::set-attr sets attributes" {
  set-attr object::red-pen foo 'value of foo'

  assert [ -v object_attrs[object::red-pen/foo] ]
  assert [ "${object_attrs[object::red-pen/foo]}" == "value of foo" ]

  run get-attr object::red-pen foo
  assert_success
  assert_output 'value of foo'
}

@test "objects::set-attr produces an error if too few args are given" {
  run set-attr
  assert_internal_error
}

@test "objects::set-attr produces an error if given a non-existent object" {
  run set-attr object::nonexistent foo 'value of foo'
  assert_internal_error
}
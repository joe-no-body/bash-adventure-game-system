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


### init-object

@test "init-object sets up object sentinel value" {
  assert [ "${OBJECT_ATTRS[object::red-pen/_type]}" == 'object' ]
}

@test "init-object produces an error if given a non-function" {
  run init-object object::does-not-exist
  assert_internal_error
  assert [ ! -v OBJECT_ATTRS[object::does-not-exist] ]
}


### get-attr

@test "get-attr gets an object's attributes"  {
  run get-attr object::red-pen display_name
  assert_success
  assert_output 'red pen'

  run get-attr object::red-pen location
  assert_success
  assert_output 'room::kitchen'
}


### has-attr?

@test "has-attr? validates an attribute's presence" {
  run has-attr? object::red-pen display_name
  assert_success

  run has-attr? object::red-pen foobar
  assert_failure
}


### set-attr

@test "set-attr sets attributes" {
  set-attr object::red-pen foo 'value of foo'

  assert [ -v OBJECT_ATTRS[object::red-pen/foo] ]
  assert [ "${OBJECT_ATTRS[object::red-pen/foo]}" == "value of foo" ]

  run get-attr object::red-pen foo
  assert_success
  assert_output 'value of foo'
}

@test "set-attr produces an error if too few args are given" {
  run set-attr
  assert_internal_error
}

@test "set-attr produces an error if given a non-existent object" {
  run set-attr object::nonexistent foo 'value of foo'
  assert_internal_error
}
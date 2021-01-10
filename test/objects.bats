load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'
load '../lib/arrayops.bash'

setup() {
  PATH="lib/:$PATH"
  source lib/objects.bash

  object::red-pen() {
    set-attr display_name 'red pen'
    set-attr location 'room::kitchen'
  }
  init-object object::red-pen

  object::small-box() {
    set-attr display_name 'small box'
    set-attr location 'room::kitchen'
  }
  init-object object::small-box

  room::kitchen() {
    set-attr display_name 'kitchen'
  }
  init-object room::kitchen
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


### object?

@test "object? checks if an object is defined" {
  assert object? object::red-pen
  refute object? object::nonexistent
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

@test "get-attr produces an error if given a non-existent object" {
  run get-attr object::nonexistent foo
  assert_internal_error
}


### has-attr?

@test "has-attr? validates an attribute's presence" {
  run has-attr? object::red-pen display_name
  assert_success

  run has-attr? object::red-pen foobar
  assert_failure
}

@test "has-attr? produces an error if given a non-existent object" {
  run has-attr? object::nonexistent foo
  assert_internal_error
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


### flags

@test "set-flag sets flags, clear-flags clears flags, and flag? checks them" {
  # flag? returns false if flag was never set
  refute flag? object::red-pen takeable

  # flag? returns true once a flag has been set
  set-flag object::red-pen takeable

  assert flag? object::red-pen takeable
  assert [ "${OBJECT_ATTRS[object::red-pen/flags/takeable]}" == 1 ]

  # flag? once more returns false if a flag has been cleared
  clear-flag object::red-pen takeable

  assert [ "${OBJECT_ATTRS[object::red-pen/flags/takeable]}" == '' ]
  refute flag? object::red-pen takeable
}

@test "set-flag produces an error if given a non-existent object" {
  run set-flag object::nonexistent takeable
  assert_internal_error
}

@test "flag? produces an error if given a non-existent object" {
  run flag? object::nonexistent takeable
  assert_internal_error
}

@test "clear-flag produces an error if given a non-existent object" {
  run clear-flag object::nonexistent takeable
  assert_internal_error
}


### containment

## in?

@test "in? checks an object's location" {
  assert in? object::red-pen room::kitchen
  refute in? object::red-pen object::small-box
}

@test "in? errors on a non-existent object" {
  run in? object::red-pen object::nonexistent
  assert_internal_error

  run in? object::nonexistent room::kitchen
  assert_internal_error
}

## move

@test "move moves an object to a new location" {
  move object::red-pen object::small-box
  assert in? object::red-pen object::small-box
  refute in? object::red-pen room::kitchen

  local -a box_contents
  get-contents object::small-box box_contents
  assert [ "$(alen box_contents)" == 1 ]
  assert [ "$(aref box_contents 0)" == object::red-pen ]

  local -a kitchen_contents
  get-contents room::kitchen kitchen_contents
  assert [ "$(alen kitchen_contents)" == 1 ]
  assert [ "$(aref kitchen_contents 0)" == object::small-box ]
}

@test "remove moves an object to the ether" {
  remove object::red-pen
  refute in? object::red-pen object::small-box
  refute in? object::red-pen room::kitchen
  assert [ "${OBJECT_ATTRS[object::red-pen/location]}" == '' ]
}

## get-contents

@test "get-contents gets the contents of an object" {
  local -a kitchen_contents
  get-contents room::kitchen kitchen_contents

  assert [ "$(alen kitchen_contents)" == 2 ]
  assert acontains? kitchen_contents object::red-pen
  assert acontains? kitchen_contents object::small-box
}
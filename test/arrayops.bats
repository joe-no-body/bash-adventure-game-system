load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
  source 'lib/arrayops.bash'
}

@test "array? checks if the named var is an array" {
  str='a b c'
  num=123
  array=(a b c)
  declare -A map=([a]=1 [b]=2 [c]=3)

  run array? not_an_array
  assert_failure

  run array? num
  assert_failure

  run array? array
  assert_success

  run array? map
  assert_failure

  run array? 123
  assert_failure 2

  run array? "a b c"
  assert_failure 2
}

@test "array? handles arrays with extra flags" {
  declare -i iarray=(1 2 3)
  declare -l larray=(a b c)
  declare -r rarray=(a b c)
  declare -t tarray=(a b c)
  declare -u uarray=(a b c)
  declare -x xarray=(a b c)
  declare -a narray

  run array? iarray
  assert_success
  run array? larray
  assert_success
  run array? rarray
  assert_success
  run array? tarray
  assert_success
  run array? uarray
  assert_success
  run array? xarray
  assert_success
  run array? narray
  assert_success
}

@test "aequal? tests array equality" {
  str='a'
  int=1
  arr1=(1 2 3)
  arr1_=(1 2 3)
  arr2=(2 3 4 5)

  # array equals itself
  run aequal? arr1 arr1
  assert_success

  # array equals an identical array
  run aequal? arr1 arr1_
  assert_success

  # array does not equal a different array
  run aequal? arr1 arr2
  assert_failure 1

  # non-arrays aren't compared and return 2
  run aequal? arr1 int
  assert_failure 2
  run aequal? arr1 str
  assert_failure 2
  run aequal? str int
  assert_failure 2
}

@test "ashift shifts an array" {
  local my_array=(1 2 3)
  local expected=(2 3)
  ashift my_array
  assert aequal? my_array expected
}

@test "acontains? checks if an element is in an array" {
  array=(1 2 3)
  assert acontains? array 1
  assert acontains? array 2
  assert acontains? array 3

  refute acontains? array 4
}
source lib/utils.bash

foo3() {
  local i
  echo foo3
  internal_error "foo3 failed"
}

foo2() {
  # echo foo2
  # caller
  foo3
}

foo1() {
  # echo foo1
  # caller
  foo2 x y z
}

foo1 a b c
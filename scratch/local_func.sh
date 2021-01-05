declare_funcs() {
  foo() {
    echo foo
  }
  declare -l foo

  bar() {
    echo bar
  }
}

# doesn't work
declare_funcs
foo
bar
declare -A DATA

info() {
  : echo "# $*" >&2
}

DATA=(
  [object::foo/testvar]='foo-specific value'
  [object::bar/testvar]='bar-specific value'
  # TODO: handle nested values
  #[object::bar/nested/xyz]='nested value'
)

bind_vars() {
  # TODO: make the data source an argument here
  # TODO: add unique prefixes to the local names so they don't get overridden
  local prefix key varname value
  prefix="$1"

  for key in "${!DATA[@]}"; do
    info "Checking key $key"

    # match prefix
    if [[ "$key" != "$prefix/"* ]]; then
      info "Key $key doesn't match prefix $prefix/"
      continue
    fi

    # strip the prefix to get the variable name
    varname="${key#*/}"

    value="${DATA["$key"]}"
    info "Assigning $varname=$value"

    local "$varname"="$value"
  done

  info "Executing cmd $*"
  "$@"
}

object::foo() {
  echo "object::foo - testvar=$testvar"
}

object::bar() {
  echo "object::bar - testvar=$testvar"
}

bind_vars object::foo
bind_vars object::bar
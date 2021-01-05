set -euo pipefail
# My second attempt at a rudimentary syntax tree-type thing in Bash.

# The tree is represented as an associative array of valid prefixes, with full
# valid sentences being denoted by a period at the end.
declare -A tree=(
  [yell]=
  [yell .]=@verb::yell

  [look]=
  [look .]=@verb::look

  [look OBJ]=
  [look OBJ .]=@verb::look

  [look in]=
  [look in OBJ]=
  [look in OBJ .]=@verb::look-inside

  [look at]=
  [look at OBJ]=
  [look at OBJ .]=@verb::look

  [look at OBJ with]=
  [look at OBJ with OBJ]=
  [look at OBJ with OBJ .]=@verb::look-with
)

syntax_error() {
  echo "syntax error: $*" >&2
  return 1
}

parse() {
  # for each word in the input:
  #   if the prefix + word is in the tree, continue
  #   if the prefix + "OBJ" is in the tree, parse an object and continue
  #   error
  # if prefix + . is not in the tree, error
  # otherwise, return successfully
  verb= dobject= iobject=
  # -l ensures that word will always be converted to lower case for consistency
  local -l word
  word="$1"

  prefix="$word"
  raw_prefix="$1"
  shift

  if [[ ! -v tree["$prefix"] ]]; then
    syntax_error "invalid sentence start '$prefix'"
  fi

  for word; do
    raw_prefix="$raw_prefix $word"
    # try matching a literal
    if [[ -v tree["$prefix $word"] ]]; then
      prefix="$prefix $word"
      continue
    fi

    # try matching an object
    if [[ -v tree["$prefix OBJ"] ]]; then
      if [[ "$dobject" == "" ]]; then
        dobject="$word"
        prefix="$prefix OBJ"
        continue
      elif [[ "$iobject" == "" ]]; then
        iobject="$word"
        prefix="$prefix OBJ"
        continue
      else
        syntax_error "unexpected object in pattern '$prefix OBJ'"
      fi
    fi

    # failed to match a literal or an object -> error
    syntax_error "I can't make sense of '$word' at the end of '$raw_prefix'"
  done

  if [[ ! -v tree["$prefix ."] ]] || [[ "${tree["$prefix ."]}" == "" ]]; then
    syntax_error "Your sentence seems to end before it's meant to be finished."
  fi

  # set verb
  verb="${tree["$prefix ."]}"
}

main() {
  verb= dobject= iobject=
  parse "$@"
  echo "verb='$verb' dobject='$dobject' iobject='$iobject'"
}

main "$@"
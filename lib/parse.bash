# My second attempt at a rudimentary syntax tree-type thing in Bash.

# The tree is represented as an associative array of valid prefixes, with full
# valid sentences structures being denoted by a value referencing a
# corresponding verb function.
declare -A tree=(
  # [yell]=verb::yell

  # [go]=
  #   [go OBJ]=verb::go

  # [take]=
  #   [take OBJ]=verb::take
  #   [take the]=
  #     [take the OBJ]=verb::take

  # [look]=verb::look
  #   [look OBJ]=verb::look
  #   [look in]=
  #     [look in OBJ]=verb::look-inside
  #   [look at]=
  #     [look at OBJ]=verb::look
  #       [look at OBJ with]=
  #         [look at OBJ with OBJ]=verb::look-with

  # [attack]=
  #   [attack OBJ]=
  #     [attack OBJ with]=
  #       [attack OBJ with OBJ]=verb::attack
)

# syntax attack OBJ with OBJ = verb::attack
syntax() {
  local -a syntax
  local word verb_func

  while (( "$#" )); do
    word="$1"
    shift
    if [[ "$word" == '=' ]]; then
      break
    fi
    syntax+=("$word")
  done

  verb_func="$1"

  local -a prefix
  local prefix_str
  for word in "${syntax[@]}"; do
    prefix+=("$word")
    prefix_str="${prefix[*]}"
    if [[ "${tree["$prefix_str"]+exists}" == '' ]]; then
      tree["$prefix_str"]=''
    fi
  done
  tree["$prefix_str"]="$verb_func"
}

grammatical?() {
  [[ -v tree["$1"] ]]
}

complete?() {
  [[ -v tree["$1"] ]] && [[ "${tree["$1"]}" != "" ]]
}

get-verb() {
  local prefix
  prefix="$1"

  if ! complete? "$prefix"; then
    internal_error "get-verb got an incomplete sentence: '$prefix'"
  fi

  echo "${tree["$prefix"]}"
}

syntax_error() {
  error="$*"
  return 1
}

internal_error() {
  echo "internal error: $*" >&2
  exit 1
}

parse() {
  # for each word in the input:
  #   if the prefix + word is in the tree, continue
  #   if the prefix + "OBJ" is in the tree, parse an object and continue
  #   error
  # if tree[prefix] is null, error
  # otherwise, return successfully
  verb= dobject= iobject=
  # -l ensures that word will always be converted to lower case for consistency
  local -l word
  word="$1"

  prefix="$word"
  raw_prefix="$1"
  shift

  if ! grammatical? "$prefix"; then
    syntax_error "invalid sentence start '$prefix'"
    return 1
  fi

  for word; do
    raw_prefix="$raw_prefix $word"
    # try matching a literal
    if grammatical? "$prefix $word"; then
      prefix="$prefix $word"
      continue
    fi

    # try matching an object
    if grammatical? "$prefix OBJ"; then
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
        return 1
      fi
    fi

    # failed to match a literal or an object -> error
    syntax_error "I can't make sense of '$word' at the end of '$raw_prefix'"
    return 1
  done

  if ! complete? "$prefix"; then
    syntax_error "Your sentence seems to end before it's meant to be finished."
    return 1
  fi

  verb="$(get-verb "$prefix")"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  error=
  set -euo pipefail
  syntax yell = verb::yell

  syntax look = verb::look
  syntax look OBJ = verb::look
  syntax look in OBJ = verb::look-inside
  syntax look at OBJ = verb::look

  syntax go OBJ = verb::go

  syntax take OBJ = verb::take
  syntax take the OBJ = verb::take

  syntax attack OBJ with OBJ = verb::attack

  verb= dobject= iobject=
  if ! parse "$@" || [[ "$error" ]]; then
    echo "syntax error: $error" >&2
    exit 1
  fi
  echo "verb=$verb dobject=$dobject iobject=$iobject"
fi
#!/usr/bin/env bash
# Logic for defining nouns.
# TODO: actually use this, as it's currently not used.

set -euo pipefail

# nouns is an associative array that defines valid noun phrases. As with
# `syntax_tree`, `nouns` contains a set of valid prefixes and full noun phrases
# which are used during parsing to identify syntax errors.
declare -gA nouns=(
  # Example noun prefix tree:

  # [west]="object::west"
  # [north]="object::north"
  # [east]="object::east"
  # [south]="object::south"

  # [the]=""
    # ["the angry"]=""
      # ["the angry troll"]="object::troll"
    # ["the sword"]="object::sword"

  # ["the troll"]="object::troll"

  # [angry]=""
    # ["angry troll"]="object::troll"

  # [troll]="object::troll"

  # [sword]="object::sword"
)


# nouns::ensure checks whether the given noun phrase or prefix is defined in the
# map. This includes partial prefixes.
#
# usage: nouns::ensure ...NOUNPHRASE
nouns::ensure() {
  [[ -v nouns["$*"] ]] || nouns["$*"]=''
}

# nouns::is-complete takes a noun phrase and checks that it's complete (rather
# than being a valid but incomplete prefix).
nouns::is-complete() {
  [[ -v nouns["$*"] && "${nouns["$*"]}" ]]
}

# nouns::add adds a given noun phrase to the `nouns` map. It takes an object
# identifier followed by one or more arguments defining the phrase. It splits
# the given phrase on spaces (potentially re-splitting if multiple arguments are
# provided) and validates that each successive prefix of the phrase is in the
# map.
#
# usage: nouns::add OBJECT ...NOUNPHRASE
nouns::add() {
  local -a prefix=()
  local object_id="$1"
  shift

  local arg

  # Ensure each substring is defined as a valid prefix.
  # XXX: Wait... how do partial noun phrases actually get added to `nouns`??
  #
  # We actually want to split on spaces here, so we use $* unquoted on purpose.
  #
  # shellcheck disable=SC2048
  for arg in $*; do
    prefix+=("$arg")
    nouns::ensure "${prefix[@]}" || internal_error "The prefix '${prefix[*]}' is missing from the nouns map. (Error encountered in nouns:add while attempting to define object_id='$object_id' with noun phrase '$*'.)"
  done

  # Map the complete phrase to an object id. If there is already an object id
  # mapped for this key, append the new id delimited by a space. (TODO: use this
  # elsewhere.)
  if [[ "${nouns["$*"]}" ]]; then
    nouns["$*"]="${nouns["$*"]} $object_id"
  else
    nouns["$*"]="$object_id"
  fi
}

# nouns::define takes an object id and an article (optional), adjective
# (optional), and name by which the object may be called. It adds noun phrases
# corresponding to this object to the global `nouns` map.
#
# Usage: nouns::define OBJECT-ID [-t ARTICLE] [-a ADJECTIVE] [-s NAME]
nouns::define() {
  local object_id="$1"
  shift
  local article=  # TODO: default to 'the'
  local synonym=   # TODO: support multiple
  local adjective=

  while (( "$#" )); do
    case "$1" in
      -t)
        article="$2"
        shift
        ;;
      -s)
        synonym="$2"
        shift
        ;;
      -a)
        adjective="$2"
        shift
        ;;
      *)
        echo "internal error: invalid option $1 for nouns::define" >&2
        exit 1
        ;;
    esac
    shift
  done

  # foo
  nouns::add "$object_id" "$synonym"

  # red foo
  if [[ "$adjective" ]]; then
    nouns::add "$object_id" "$adjective $synonym"
  fi

  # the foo
  if [[ "$article" ]]; then
    nouns::add "$object_id" "$article $synonym"
  fi

  # the red foo
  if [[ "$article" ]] && [[ "$adjective" ]]; then
    nouns::add "$object_id" "$article $adjective $synonym"
  fi
}

# nouns::parse parses a noun phrase and sets the shared variables `object_id`
# and `word_count` based on the result. This is expected to be called from the
# `parse` function.
nouns::parse() {
  local -a noun_prefix=()
  local noun_prefix_str=

  local -a args=("$@")
  local idx
  local word

  # shared variables for return value
  object_id=
  word_count=0

  for (( idx=0; idx<"$#"; idx++ )); do
    word="${args[idx]}"

    noun_prefix+=("$word")
    noun_prefix_str="${noun_prefix[*]}"
    ((word_count++))

    # XXX I think this checks if we've matched a full object name.
    # That might be trouble if we have objects that have overlapping prefixes.
    # (ex. "the ruby" and "the ruby slippers")
    # TODO: use nouns::is-complete here!
    if [[ -v nouns["${noun_prefix_str}"] && "${nouns["$noun_prefix_str"]}" ]]; then
      object_id="${nouns["$noun_prefix_str"]}"
      break
    fi
  done

  # TODO: handle ambiguity when multiple objects are matched

  if [[ "$object_id" == "" ]]; then
    # TODO: report errors properly
    syntax_error "'$*' doesn't seem to be a complete name I recognize"
    return 1
  fi
}

nouns::test_parse() {
  set -euo pipefail

  error=
  word_count=
  object_id=
  if ! nouns::parse "$@" || [[ "$error" ]]; then
    echo "noun syntax error: $error" >&2
    exit 1
  fi
  echo "word_count=$word_count object_id=$object_id"
}

nouns::main() {
  # nouns::parse "$@"
  # nouns::define object::bar -t your -s bar
  # declare -p nouns

  nouns::define object::red-foo -t the -a red -s foo
  nouns::define object::blue-foo -t the -a blue -s foo
  nouns::test_parse the foo
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  nouns::main "$@"
fi
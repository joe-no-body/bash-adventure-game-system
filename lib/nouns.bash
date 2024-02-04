#!/usr/bin/env bash
# Logic for defining nouns.
# TODO: actually use this, as it's currently not used.

set -euo pipefail

declare -gA nouns=()

# usage: nouns::ensure ...STR
# Ensure the given key is set in the map.
nouns::ensure() {
  [[ -v nouns["$*"] ]] || nouns["$*"]=''
}

# usage: nouns::add OBJECT ...STR
nouns::add() {
  local -a prefix=()
  local object_id="$1"
  shift

  # ensure each substring is defined as a valid prefix
  # we actually want to split on spaces here, so we use $* unquoted on purpose
  # shellcheck disable=SC2048
  for arg in $*; do
    prefix+=("$arg")
    nouns::ensure "${prefix[@]}"
  done

  # ensure the whole thing is defined and mapped to the object
  # TODO: append so we handle homonyms
  if [[ "${nouns["$*"]}" ]]; then
    nouns["$*"]="${nouns["$*"]} $object_id"
  else
    nouns["$*"]="$object_id"
  fi
}

# Usage: nouns::define OBJECT-ID [-t ARTICLE] [-a ADJECTIVES...] [-s SYNONYMS...]
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

# nouns::parse parses a noun and sets object_id and word_count based on the
# result.
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
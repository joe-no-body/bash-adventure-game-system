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

# nouns::parse parses a noun and emits the number of words parsed as well as the
# unique object identifier of the noun.
nouns::parse() {
  local object_id=
  local -a prefix=()
  local prefix_str=
  local word_count="$#"

  while (( "$#" )); do
    prefix+=("$1")
    prefix_str="${prefix[*]}"
    shift
    if [[ -v nouns["${prefix_str}"] ]] && [[ "${nouns["$prefix_str"]}" ]]; then
      object_id="${nouns["$prefix_str"]}"
      break
    fi
  done

  # TODO: handle ambiguity when multiple objects are matched

  if [[ "$object_id" == "" ]]; then
    # TODO: report errors properly
    echo "'$*' doesn't seem to be a complete name I recognize"
    return 1
  fi

  # XXX use shared variables to return results instead of printing the result here
  printf '%s %s' "$word_count" "$object_id"
}

nouns::main() {
  # nouns::parse "$@"
  nouns::define object::bar -t your -s bar
  declare -p nouns
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  nouns::main "$@"
fi
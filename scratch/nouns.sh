#!/usr/bin/env bash
set -euo pipefail

declare -gA nouns=()

# Usage: nouns::define OBJECT-ID [-t ARTICLE] [-a ADJECTIVES...] [-s SYNONYMS...]
nouns::define() {
  local object_id="$1"
  shift
  local article=  # TODO: default to 'the'
  local synonym=   # TODO: support multiple

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
      *)
        echo "internal error: invalid option $1 for nouns::define" >&2
        exit 1
        ;;
    esac
    shift
  done

  nouns["$synonym"]="$object_id"
  if [[ "$article" ]]; then
    [[ ! -v nouns["$article"] ]] && nouns["$article"]=""
    # TODO: handle homonyms
    nouns["$article $synonym"]="$object_id"
  fi
}

nouns::parse() {
  local object_id=
  local -a prefix=()
  local prefix_str=

  while (( "$#" )); do
    prefix+=("$1")
    prefix_str="${prefix[*]}"
    shift
    if [[ -v nouns["${prefix_str}"] ]] && [[ "${nouns["$prefix_str"]}" ]]; then
      object_id="${nouns["$prefix_str"]}"
      break
    fi
  done

  # TODO: handle homonyms

  if [[ "$object_id" == "" ]]; then
    echo "'$*' doesn't seem to be a complete name I recognize"
    return 1
  fi

  printf '%s' "$object_id"
}

nouns::main() {
  nouns::parse "$@"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  nouns::main "$@"
fi
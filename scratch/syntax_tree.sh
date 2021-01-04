#!/usr/bin/env bash
# A proof of concept syntax tree-thing implemented in pure motherfucking Bash.

# Gotta stay safe out there.
set -euo pipefail

# We don't need binaries where we're going. Out here, it's just us and the
# shell.
export PATH=""

# Behold, the syntax tree itself.
# Each key in this associative array represents a valid input prefix. The
# corresponding value can be of two possible types (or three, depending on how
# you want to count):
#   1. a space-delimited list of valid tokens following the prefix
#   2. an empty string if the prefix constitutes one whole valid input and
#      should not have any tokens after it
#   3. if the prefix ends with 'TERM', the name of a function, prefixed with
#      '@', specifying the action handler for the verb
# Token lists may consist of the following:
#   - literal strings, consisting of single, all-lowercase words
#   - 'OBJ', representing a noun that should be taken as an object of the
#     sentence. the first OBJ is the direct object, the second (if provided) is
#     the indirect object, and more than two is an error
#   - 'TERM', which can only appear in the key of the array and is appended to
#     the prefix after parsing the full input to denote that it is complete.
declare -A tree=(
  [look]='at in inside OBJ'
  [look TERM]='@verb::look'
  [look OBJ]=''
  [look OBJ TERM]='@verb::look'
  [look at]='OBJ'
  [look at OBJ]=''
  [look at OBJ TERM]='@verb::look'
  [look in]='OBJ'
  [look in OBJ]='@verb::look-inside'
  [look in OBJ TERM]='@verb::look-inside'
  [yell]=''
  [yell TERM]='@verb::yell'
  [go]='OBJ'
  [go OBJ]=''
  [go OBJ TERM]='@verb::go'
  # TODO: fix this
  # I added 'the' as a valid token here to make my other parser's tests pass,
  # but that should obviously be handled differently
  [take]='the OBJ'
  [take the]='OBJ'
  [take the OBJ]=''
  [take the OBJ TERM]='@verb::take'
  [take OBJ]=''
  [take OBJ TERM]='@verb::take'
  [attack]='OBJ'
  [attack OBJ]='with'
  [attack OBJ with]='OBJ'
  [attack OBJ with OBJ]=''
  [attack OBJ with OBJ TERM]='@verb::attack'
)

debug() {
  if [[ "${DEBUG:-}" == 1 ]]; then
    echo "$@" >&2
  fi
}

parse() {
  verb= dobj= iobj=

  debug "parsing the phrase '$*'"

  prefix="$1"
  shift

  # bail out if the first word isn't matched
  if [[ ! -v tree["$prefix"] ]]; then
    echo "syntax error - invalid token '$prefix'"
    exit 1
  fi

  # find the first word in the lookup table
  possible_tokens="${tree["$prefix"]}"

  debug "initial state - prefix='$prefix' possible_tokens='$possible_tokens'"

  # now, for each word after the first, we're going to check if it's a valid
  # token for the current prefix, handle it as a noun if it's an object (TODO),
  # and append to the prefix as appropriate
  while (( "$#" )); do
    # input word is the word we just got
    input_word="$1"
    shift

    debug "parsing word '$input_word' - prefix='$prefix' possible_tokens='$possible_tokens'"

    # postfix is the term that will be appended to the prefix. if postfix is
    # null (empty) after the for loop below, that's means it wasn't matched and
    # is a syntax error
    postfix=

    # the lack of quotes here is deliberate. we unfortunately have to rely on
    # word splitting for this to work
    for token in $possible_tokens; do
      postfix=
      case "$token" in
        OBJ) # TODO
          debug "matched '$input_word' as an object"
          if [[ ! "$dobj" ]]; then
            debug "assigning '$input_word' to dobj"
            dobj="$input_word"
          elif [[ ! "$iobj" ]]; then
            debug "assigning '$input_word' to iobj"
            iobj="$input_word"
          else
            echo "internal error - prefix '$prefix' supports an object, but we" \
                 "already got both a direct and indirect object!" >&2
            return 1
          fi

          # we need to append OBJ since that's what's in the prefix string
          postfix="OBJ"
          break
          ;;
        "$input_word")
          debug "matched '$input_word' as a literal"
          postfix="$token"
          break
          ;;
      esac
    done

    if [[ "$postfix" == "" ]]; then
      echo "syntax error - unexpected token '$input_word' after '$prefix'." \
           "valid options: $possible_tokens" >&2
      return 1
    fi

    # now we update the prefix with the postfix
    prefix="$prefix $postfix"

    # bail out if the new prefix is invalid
    if [[ ! -v tree["$prefix"] ]]; then
      echo "syntax error - prefix '$prefix' doesn't match a known prefix"
      exit 1
    fi

    # find the word in the lookup table
    possible_tokens="${tree["$prefix"]}"
  done


  terminal_prefix="$prefix TERM"
  debug "done matching tokens. our terminal prefix is now '$terminal_prefix'"

  if [[ ! -v tree["$terminal_prefix"] ]]; then
    echo "syntax error - unexpected end of input - no terminal prefix matches this string"
    return 1
  fi

  verb_="${tree["$terminal_prefix"]}"

  if [[ "$verb_" == "" ]]; then
    echo "internal error - unexpectedly empty tree value for '$terminal_prefix'" >&2
    return 1
  fi

  if [[ "${verb_:0:1}" != "@" ]]; then
    echo "internal error - the value for '$terminal_prefix', '$verb_', does not start with @ as expected" >&2
    return 1
  fi


  verb="${verb_:1}"
  debug "matched terminal prefix to verb $verb"
}

main() {
  parse "$@"
  echo "verb=$verb dobject=$dobj iobject=$iobj"
}
main "$@"
set -euo pipefail

export PATH=""

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
)

debug() {
  : echo "$@" >&2
}

in?() {
  local needle="$1"
  shift
  for arg; do
    if [[ "$needle" == "$arg" ]]; then
      return
    fi
  done
  return 1
}

parse() {
  verb= dobj= iobj=

  debug "parsing the phrase '$*'"

  prefix="$1"
  shift

  # find the first word in the lookup table
  possible_tokens="${tree["$prefix"]}"

  debug "initial state - prefix='$prefix' possible_tokens='$possible_tokens'"

  # bail out if the first word isn't matched
  if [[ "$possible_tokens" == "" ]]; then
    echo "syntax error - invalid token $1"
    exit 1
  fi

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
  done


  terminal_prefix="$prefix TERM"
  debug "done matching tokens. our terminal prefix is now '$terminal_prefix'"
  verb_="${tree["$terminal_prefix"]}"

  if [[ "${verb_:0:1}" == "" ]]; then
    echo "syntax error - input terminated unexpectedly after '$prefix'" >&2
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
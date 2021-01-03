set -euo pipefail

readonly FALSE=1
readonly UNKNOWN_WORD=2

declare -A POS
POS=(
  [the]=article

  [from]=preposition
  [to]=preposition
  [with]=preposition

  [look]=verb
  [yell]=verb
  [attack]=verb
  [take]=verb
  [go]=verb

  [sword]=noun
  [troll]=noun
  [bag]=noun
  [leaflet]=noun
  [mailbox]=noun
  [stick]=noun
  [north]=noun
)

# returns the part of speech for $1 or failure if the word is unknown
pos() {
  if (( "$#" != 1 )); then
    fatal "pos requires exactly one argument" >&2
  fi

  if [[ ! -v POS["$1"] ]]; then
    return "$UNKNOWN_WORD"
  fi

  echo "${POS["$1"]}"
}

# Determines if $1 is a known word
word?() {
  if (( "$#" != 1 )); then
    fatal "word? requires exactly one argument" >&2
  fi
  if [[ ! -v POS["$1"] ]];then
    return "$UNKNOWN_WORD"
  fi
}

# determines if $1's part of speech is $2
# returns 0 if $1's part of speech is $2
# retursn 1 if $1's part of speech is not $2
# returns 2 if the word is unknown
pos-is?() {
  if (( "$#" != 2 )); then
    fatal "pos-is? must be invoked as 'pos-is? WORD POS'"
  fi

  local word expected_pos pos
  word="$1"
  expected_pos="$2"

  if ! pos="$(pos "$1")"; then
    return "$UNKNOWN_WORD"
  fi

  if [[ "$pos" != "$expected_pos" ]]; then
    return "$FALSE"
  fi
}

verb?() {
  if (( "$#" != 1 )); then
    fatal "verb? requires exactly one argument" >&2
  fi
  pos-is? "$1" verb
}

article?() {
  if (( "$#" != 1 )); then
    fatal "article? requires exactly one argument" >&2
  fi
  pos-is? "$1" article
}

noun?() {
  if (( "$#" != 1 )); then
    fatal "noun? requires exactly one argument" >&2
  fi
  pos-is? "$1" noun
}

preposition?() {
  if (( "$#" != 1 )); then
    fatal "preposition? requires exactly one argument" >&2
  fi
  pos-is? "$1" preposition
}

fatal() {
  echo "fatal internal error: $*" >&2
  exit 1
}

err() {
  echo "$*" >&2
}

# Returns a parse error.
# Note that this only works if errexit is set.
parse_err() {
  error="$1"
  return 1
}

parse() {
  local pos
  verb=
  dobject=
  iobject=

  verb? "$1" || parse_err "expected a verb but got $1"

  verb="$1"
  shift

  # VERB only
  if [[ ! "${1-}" ]]; then
    return
  fi

  # VERB followed by 'the'
  if article? "$1"; then
    shift
    # if we got an article, then we need a noun after it
    if [[ ! "${1-}" ]]; then
      parse_err "input ended unexpectedly after article"
    fi
  fi

  # VERB [the] NOUN
  if ! noun? "$1"; then
    parse_err "expected a noun after the verb but got $1"
  fi
  dobject="$1"
  shift

  # input stops after direct object
  # VERB [the[ NOUN only
  if [[ ! "${1-}" ]]; then
    return
  fi

  # VERB [the] NOUN PREP
  if ! preposition? "$1"; then
    parse_err "expected a preposition after the direct object but got $1"
  fi
  shift

  if [[ ! "${1-}" ]]; then
    parse_err "input ended unexpectedly after preposition"
  fi

  # VERB [the] NOUN PREP [the]
  if article? "${1-}"; then
    shift

    if [[ ! "${1-}" ]]; then
      parse_err "input ended unexpectedly after article in indirect object phrase"
    fi
  fi

  # VERB [the] NOUN PREP [the] VERB
  if ! noun? "${1-}"; then
    parse_err "expected a noun after the preposition but got $1"
  fi

  iobject="$1"
}

parse::main() {
  local verb= dobject= iobject= error=

  if ! parse "$@" || [[ "$error" ]]; then
    if [[ "$error" ]]; then
      error="parse error: $error"
    else
      error="parse error"
    fi
    err "$error"
    return 1
  fi

  echo verb="$verb"
  echo dobject="$dobject"
  echo iobject="$iobject"
}

# Allow running directly for simplified testing.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  parse::main "$@"
  exit $?
fi
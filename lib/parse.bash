# A basic parser for English commands.
source utils.bash
source nouns.bash

# Each key of syntax_tree represents a valid prefix or, if it has a non-null
# value, a full valid command. When the value is non-null, it should contain the
# name of the verb function used to execute the command.
declare -gA syntax_tree=(
  # The comments below illustrate an example syntax tree.

  # [yell]=verb::yell

  # [go]=
  #   [go OBJ]=verb::go

  # [take]=
  #   [take OBJ]=verb::take

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

# syntax defines a new command syntax by updating syntax_tree.
#
# example usage:
#   syntax attack OBJ with OBJ = verb::attack
syntax() {
  local -a syntax
  local word verb_func nobjs=0

  while (( "$#" )); do
    word="$1"
    shift
    if [[ "$word" == '=' ]]; then
      break
    fi
    if [[ "$word" == OBJ ]]; then
      if (( ++nobjs > 2 )); then
        internal_error "syntax '${syntax[*]} $word $*' includes more than two"\
                       "OBJ placeholders - a maximum of two is permitted"
      fi
    fi
    syntax+=("$word")
  done

  verb_func="$1"

  local -a prefix
  local prefix_str
  for word in "${syntax[@]}"; do
    prefix+=("$word")
    prefix_str="${prefix[*]}"
    if [[ "${syntax_tree["$prefix_str"]+exists}" == '' ]]; then
      syntax_tree["$prefix_str"]=''
    fi
  done
  syntax_tree["$prefix_str"]="$verb_func"
}

# grammatical? tests if the given string is in syntax_tree.
grammatical?() {
  [[ -v syntax_tree["$1"] ]]
}

# complete? tests if the given string is in syntax_tree and refers to a verb.
complete?() {
  [[ -v syntax_tree["$1"] ]] && [[ "${syntax_tree["$1"]}" != "" ]]
}

# article? tests if the given string is an article. currently only "the" is
# supported
article?() {
  # TODO support other articles

  # XXX there's no way this can be this simple
  [[ "$1" == the ]]
}

# get-verb returns the verb specified by the syntax_tree
get-verb() {
  local prefix
  prefix="$1"

  if ! complete? "$prefix"; then
    internal_error "get-verb got an incomplete sentence: '$prefix'"
  fi

  echo "${syntax_tree["$prefix"]}"
}

# syntax_error sets the error status and returns
syntax_error() {
  error="$*"
  return 1
}

# parse attempts to parse the given command using the syntax_tree and populates
# the global variables verb, dobject, and iobject with the result of the parse.
# See test/parse.bats for examples.
parse() {
  # for each word in the input:
  #   - if "$prefix $word" is in the syntax_tree, set prefix="$prefix $word" and
  #     continue
  #   - if "$prefix OBJ" is in the syntax_tree, set prefix="$prefix OBJ", parse
  #     a noun phrase, set dobject or iobject to the parsed object's id, and
  #     continue
  #   - otherwise, report a parsing error
  #
  # finally:
  #   - if syntax_tree[$prefix] is null, return an error - the input appears
  #     incomplete
  #   - if it's not null, set verb=syntax_tree[prefix] and return - we've
  #     successfully parsed the input!

  # initialize the output globals we'll use to report the results of parsing.
  verb=
  dobject=
  iobject=

  local -a words=("$@")
  local nwords="$#"

  # `word` stores the current word being parsed and is updated in each iteration
  # of the loop below. The -l flag converts `word` to lowercase for ease of
  # parsing.
  local -l word
  word="$1"

  # Validate that the first word is a valid prefix in syntax_tree.
  if ! grammatical? "$word"; then
    syntax_error "I don't know how to $word"
    return 1
  fi

  # We store the exact verb provided by the player in `rawverb` for cases where
  # we want to handle aliases or synonyms in special ways.
  #
  # shellcheck disable=SC2034
  rawverb="$1"

  # `prefix` contains the parsed prefix of the user's command in canonical form
  # (i.e. the form we expect to see in `syntax_tree`). For example, after
  # parsing "attack the troll with the sword", we would have prefix="attack OBJ
  # with OBJ".
  #
  # (XXX: "prefix" is kind of a misnomer here, because it's no longer
  # a prefix at the last iteration of the loop. The point is that we want to
  # successively match entries in syntax_tree that represent prefixes of a valid
  # command until we finally match a full valid command.)
  prefix="$word"

  # `raw_prefix` contains the parsed prefix of the user's command in the
  # verbatim form that they entered it.
  raw_prefix="$1"  # store the original form for error reporting

  # Declare loop local variables.
  local -i idx  # current word index
  local object_id  # temp var for the object identifier returned by nouns::parse
  local -i word_count  # number of words encountered when parsing a noun

  # Note here that we've already parsed the first word of the command.

  # We use a C-style for loop so we can easily skip forward or backward in the
  # array of input words.
  for (( idx=1; idx < nwords; idx++ )); do
    word="${words[idx]}"
    raw_prefix="$raw_prefix $word"

    # At each point during parsing, we expect to either match a literal word
    # or a noun phrase, represented by the placeholder "OBJ".

    # Try matching a literal word from the syntax_tree. For example, in the
    # first iteration of parsing "look in the box", we'd have prefix="look" and
    # word="in", so we check if "look in" is in the syntax_tree.
    if grammatical? "$prefix $word"; then
      prefix="$prefix $word"
      continue
    fi

    # Check if we're expecting a noun phrase here
    if ! grammatical? "$prefix OBJ"; then
      # failed to match a literal or an object -> error
      syntax_error "I can't make sense of '$word' at the end of '$raw_prefix'"
      return 1
    fi

    # "$prefix OBJ" is grammatical, so now we try parsing a noun phrase.

    # Parse the direct object from the noun phrase if we don't have one yet.
    if [[ ! "$dobject" ]]; then
      object_id=
      word_count=
      if ! nouns::parse "${words[@]:idx}"; then
        return 1
      fi
      dobject="$object_id"
      prefix="$prefix OBJ"
      (( idx += word_count - 1 ))
      continue
    fi

    # Parse the indirect object from the noun phrase if we already have a direct
    # object.
    if [[ ! "$iobject" ]]; then
      object_id=
      word_count=
      if ! nouns::parse "${words[@]:idx}"; then
        return 1
      fi
      iobject="$object_id"
      prefix="$prefix OBJ"
      (( idx += word_count - 1 ))
      continue
    fi

    # If we have both a direct and indirect object already, the defined syntax
    # has too many OBJ placeholders.
    internal_error "the syntax '$prefix OBJ' has too many objects defined or the parser state has gotten borked. dobject and iobject are already defined, but the defined syntax wants another object. (dobject='$dobject', iobject='$iobject')"
    return 1
  done

  # Ensure we have parsed a complete valid command.
  if ! complete? "$prefix"; then
    syntax_error "Your sentence seems to end before it's meant to be finished ('$prefix'; '$raw_prefix')"
    return 1
  fi

  # Get the verb corresponding to this command from syntax_tree.
  verb="$(get-verb "$prefix")"
}

parse::main() {
  error=
  set -euo pipefail

  verb=
  dobject=
  iobject=
  if ! parse "$@" || [[ "$error" ]]; then
    echo "syntax error: $error" >&2
    return 1
  fi
  echo "verb=$verb dobject=$dobject iobject=$iobject"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  parse::main "$@"
fi
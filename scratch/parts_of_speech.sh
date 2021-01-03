set -euo pipefail

declare -A POS
POS=(
  [the]=article

  [from]=preposition
  [to]=preposition
  [with]=preposition

  [look]=verb
  [sword]=noun
  [troll]=noun
  [bag]=noun
  [leaflet]=noun
  [mailbox]=noun
  [north]=noun
)

word="$1"
if [[ -v POS["$word"] ]]; then
  echo "${POS[$word]}"
else
  echo "unknown word: $word"
fi

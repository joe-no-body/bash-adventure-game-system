set -euo pipefail

declare -A map=()

varname=foo

if [[ ! -v map[$varname] ]]; then
  echo $varname is not present
else
  echo $varname is present
fi
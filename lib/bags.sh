#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o noglob

# ensure namespace isn't polluted
\export PATH=''
\unalias -a
hash -r

# safer IFS, though it shouldn't matter if we're safe
IFS=$' \t\n'


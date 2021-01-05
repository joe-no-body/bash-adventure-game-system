#!/usr/bin/env bash

set -euo pipefail

# This doesn't work
foo="$1" || { echo "an argument is required"; exit 1; }

echo "You said: $foo"
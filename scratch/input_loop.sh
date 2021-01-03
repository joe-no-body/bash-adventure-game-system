#!/usr/bin/env bash

while true; do
  if ! read -rep "> " action args; then
    echo "error"
    exit 1
  fi
  if [[ "$action" == "quit" ]]; then
    break
  fi
  echo "Action: $action"
  echo "Input: $args"
done
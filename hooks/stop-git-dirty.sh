#!/usr/bin/env bash
# stop-git-dirty.sh — warn about uncommitted changes
#
# Called by stop.sh. Reads JSON input from $1 (file path).
# Outputs JSON to stdout if there are uncommitted changes.
# Non-blocking: informs Claude but does not prevent stopping.

input_file="$1"
stop_hook_active=$(jq -r '.stop_hook_active // false' < "$input_file")

[[ "$stop_hook_active" == "true" ]] && exit 0

if git rev-parse --git-dir &>/dev/null; then
  dirty=$(git status --porcelain 2>/dev/null)
  if [[ -n "$dirty" ]]; then
    jq -n --arg dirty "$dirty" '{
      "reason": "Note: there are uncommitted changes in the working tree:\n\($dirty)\nRemind the user if relevant."
    }'
  fi
fi

exit 0

#!/usr/bin/env bash
# Stop hook — router
#
# Delegates to subscripts:
#   stop-git-dirty.sh    — warn about uncommitted changes (non-blocking)
#   stop-quality-gate.sh — project-specific linter/checks
#
# Input: JSON from stdin (standard Claude Code hook format)
# Output: JSON from first subscript that produces output

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')

# log raw input
log_file="/tmp/${session_id}.jsonl"
echo "$input" >> "$log_file"

# write input to temp file for subscripts
input_file=$(mktemp)
echo "$input" > "$input_file"
trap 'rm -f "$input_file"' EXIT

# --- subscripts ---

output=$("$HOOK_DIR/stop-git-dirty.sh" "$input_file" 2>/dev/null || true)
[[ -n "$output" ]] && echo "$output"

"$HOOK_DIR/stop-quality-gate.sh" "$input_file" 2>/dev/null || true

# --- skogparse last assistant line ---

if [[ "$stop_hook_active" != "true" ]]; then
  transcript=$(echo "$input" | jq -r '.transcript_path')
  if [[ -n "$transcript" && -f "$transcript" ]]; then
    last_line=$(tac "$transcript" | grep -m1 '"type":"assistant"' | jq -r '.message.content[-1].text' 2>/dev/null | tail -1)
    [[ -n "$last_line" ]] && echo "$last_line" | skogparse 2>/dev/null
  fi
fi

exit 0

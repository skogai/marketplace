#!/usr/bin/env bash
# UserPromptSubmit hook - runs when user submits a prompt
#
# Source: plugins/claude-docs/references/hooks.md
#
# Input JSON structure:
# {
#   "session_id": "abc123",
#   "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
#   "cwd": "/Users/...",
#   "permission_mode": "default",
#   "hook_event_name": "UserPromptSubmit",
#   "prompt": "Write a function to calculate the factorial of a number"
# }
#
# Output options:
# 1. Plain text stdout (exit 0): Simplest - any non-JSON text added as context
# 2. JSON with additionalContext (exit 0): More structured control
# {
#   "decision": "block" | undefined,  # "block" prevents prompt processing, erases it
#   "reason": "string",  # Shown to user (not Claude) when blocking
#   "hookSpecificOutput": {
#     "hookEventName": "UserPromptSubmit",
#     "additionalContext": "string"  # Added to context
#   }
# }
#
# Exit codes:
# - 0: Success. Plain stdout OR JSON parsed. Stdout added to context.
# - 2: Blocks prompt processing, erases prompt, shows stderr to user only
# - Other: Non-blocking error, stderr shown to user in verbose mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKOGPARSE="$HOME/.local/bin/skogparse"

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
log_file="/tmp/${session_id}.jsonl"
echo "$input" >>"$log_file"

prompt=$(echo "$input" | jq -r '.prompt // ""')
additional_context=""

# --- 0. User context script ---
user_context_script="$SCRIPT_DIR/../scripts/user-context.sh"
if [[ -x "$user_context_script" ]]; then
  user_ctx=$("$user_context_script" 2>/dev/null || true)
  if [[ -n "$user_ctx" ]]; then
    additional_context="$user_ctx"
  fi
fi

# --- 1. Skogparse: parse $refs and @actions ---
last_line=$(echo "$prompt" | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ -n "$last_line" ]] && [[ -x "$SKOGPARSE" ]]; then
  if echo "$last_line" | grep -qE '(\$[a-zA-Z_][a-zA-Z0-9_.]*|\[@[a-zA-Z])'; then
    parsed=""
    if parsed=$("$SKOGPARSE" "$last_line" 2>&1); then
      if echo "$parsed" | grep -qE '^(SRef|SAction|SCommand|Error:)'; then
        additional_context="original message: ${last_line}\nparsed message: ${parsed}"
      fi
    fi
  fi
fi

# --- 2. Lesson matching: keyword match against prompt ---
lesson_context=$(python3 "$SCRIPT_DIR/lesson_matcher.py" --mode prompt --text "$prompt" --tool "user-prompt-submit" 2>/dev/null || true)

if [[ -n "$lesson_context" ]]; then
  if [[ -n "$additional_context" ]]; then
    additional_context="${additional_context}\n${lesson_context}"
  else
    additional_context="$lesson_context"
  fi
fi

# --- 3. Output merged context ---
if [[ -n "$additional_context" ]]; then
  jq -n \
    --arg context "$additional_context" \
    '{
        "hookSpecificOutput": {
          "hookEventName": "UserPromptSubmit",
          "additionalContext": $context
        }
      }'
fi

exit 0

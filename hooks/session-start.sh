#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook - runs when Claude Code starts a new session or resumes
#
# Source: plugins/claude-docs/references/hooks.md
#
# Input JSON structure:
# {
#   "session_id": "abc123",
#   "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
#   "permission_mode": "default",
#   "hook_event_name": "SessionStart",
#   "source": "startup"
# }
#
# Output JSON structure (optional):
# {
#   "hookSpecificOutput": {
#     "hookEventName": "SessionStart",
#     "additionalContext": "string"  # Added to context at session start
#   }
# }
#
# Exit codes:
# - 0: Success. JSON output in stdout is parsed for hookSpecificOutput
# - 2: N/A (SessionStart cannot block)
# - Other: Non-blocking error, stderr shown to user in verbose mode

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
log_file="/tmp/${session_id}.jsonl"
echo "$input" >>"$log_file"

# [@todo:skogix:"a better solution to tag on example hooks like these"]
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/workflow-memory.sh"

if ! skogai_workflow_init 2>/dev/null; then
  echo "session-start: workflow bootstrap failed" >&2
fi

# Session context script
session_context=""
session_context_script="$SCRIPT_DIR/../scripts/session-context.sh"
if [[ -x "$session_context_script" ]]; then
  session_ctx=$("$session_context_script" 2>/dev/null || true)
  if [[ -n "$session_ctx" ]]; then
    session_context="$session_ctx"
  fi
fi

# Inject always_apply lessons as session-start guardrails
lesson_context=$(python3 "$SCRIPT_DIR/lesson_matcher.py" --mode session-start 2>/dev/null || true)

combined_context=""
[[ -n "$session_context" ]] && combined_context="$session_context"
[[ -n "$lesson_context" ]] && combined_context="${combined_context:+$combined_context\n}$lesson_context"

if [[ -n "$combined_context" ]]; then
  jq -n \
    --arg context "$combined_context" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": $context
      }
    }'
fi

exit 0

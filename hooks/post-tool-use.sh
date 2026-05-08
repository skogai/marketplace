#!/usr/bin/env bash
# PostToolUse hook - runs after tool calls complete
#
# Input: {session_id, hook_event_name, tool_name, tool_input, tool_response, tool_use_id}
# Output: Optional {decision, reason, hookSpecificOutput}
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"
source "$SCRIPT_DIR/../scripts/workflow-memory.sh"

tool_name=$(skogai_jq_field ".tool_name" "")
tool_use_id=$(skogai_jq_field ".tool_use_id" "")

if ! skogai_workflow_init 2>/dev/null; then
  echo "post-tool-use: workflow bootstrap failed" >&2
fi

if ! skogai_workflow_append_progress "$tool_name" "$tool_use_id" 2>/dev/null; then
  echo "post-tool-use: workflow progress append failed" >&2
fi

skogai_jq_log "Tool completed: $tool_name"

exit 0

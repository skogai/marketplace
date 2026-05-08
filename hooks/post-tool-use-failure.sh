#!/usr/bin/env bash
# PostToolUseFailure hook - runs after a tool call fails
#
# Input: {session_id, hook_event_name, tool_name, tool_input, error}
# Output: None (cannot block, tool already failed)
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

tool_name=$(skogai_jq_field ".tool_name" "unknown")
skogai_jq_log "Tool failed: $tool_name"

exit 0

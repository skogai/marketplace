#!/usr/bin/env bash
# PermissionRequest hook - runs when a permission dialog is about to appear
#
# Input: {session_id, hook_event_name, tool_name, tool_input, permission_type}
# Output: Optional {decision: "allow"|"deny", reason}
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

tool_name=$(skogai_jq_field ".tool_name" "unknown")
permission_type=$(skogai_jq_field ".permission_type" "unknown")
skogai_jq_log "Permission requested for $tool_name, type: $permission_type"

exit 0

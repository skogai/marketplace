#!/usr/bin/env bash
# SubagentStop hook - runs when subagent tasks complete
#
# Input: {session_id, hook_event_name, stop_hook_active}
# Output: Optional {decision, reason}
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

stop_hook_active=$(skogai_jq_field ".stop_hook_active" "false")
skogai_jq_log "Subagent stopped, stop_hook_active: $stop_hook_active"

exit 0

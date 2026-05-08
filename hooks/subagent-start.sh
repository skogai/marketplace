#!/usr/bin/env bash
# SubagentStart hook - runs when a subagent is spawned
#
# Input: {session_id, hook_event_name, subagent_type}
# Output: Optional {decision, reason}
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

subagent_type=$(skogai_jq_field ".subagent_type" "unknown")
skogai_jq_log "Subagent started, type: $subagent_type"

exit 0

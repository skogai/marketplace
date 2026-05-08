#!/usr/bin/env bash
# TeammateIdle hook - runs when an agent team member is about to go idle
#
# Input: {session_id, hook_event_name, teammate_name}
# Output: Optional {decision: "block", reason}
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

teammate=$(skogai_jq_field ".teammate_name" "unknown")
skogai_jq_log "Teammate going idle: $teammate"

exit 0

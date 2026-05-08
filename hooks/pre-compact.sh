#!/usr/bin/env bash
# PreCompact hook - runs before Claude Code compacts conversation
#
# Input: {session_id, hook_event_name, trigger, custom_instructions}
# Output: None (cannot block compaction)
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

trigger=$(skogai_jq_field ".trigger" "unknown")
skogai_jq_log "Pre-compact triggered, trigger: $trigger"

exit 0

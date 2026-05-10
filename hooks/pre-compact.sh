#!/usr/bin/env bash
# PreCompact hook - runs before context compaction.
#
# Input: {session_id, hook_event_name, trigger, custom_instructions}
# Output: none
# Exit: 0 always

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

trigger=$(skogai_jq_field ".trigger" "unknown")
skogai_jq_log "PreCompact trigger: $trigger"

exit 0

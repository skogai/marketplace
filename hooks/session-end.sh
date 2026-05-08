#!/usr/bin/env bash
# SessionEnd hook - runs when Claude Code session ends
#
# Input: {session_id, transcript_path, cwd, permission_mode, hook_event_name, reason}
# Output: None (cannot block session termination)
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

reason=$(skogai_jq_field ".reason" "unknown")
skogai_jq_log "Session ended, reason: $reason"

exit 0

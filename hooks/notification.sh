#!/usr/bin/env bash
# Notification hook - runs when Claude Code sends notifications
#
# Input: {session_id, hook_event_name, message, notification_type}
# Output: None
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

notification_type=$(skogai_jq_field ".notification_type" "unknown")
skogai_jq_log "Notification received, type: $notification_type"

exit 0

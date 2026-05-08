#!/usr/bin/env bash
# ConfigChange hook - runs when a Claude Code config file changes during a session
#
# Input: {session_id, hook_event_name, config_file}
# Output: None (cannot block config changes)
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

config_file=$(skogai_jq_field ".config_file" "unknown")
skogai_jq_log "Config changed: $config_file"

exit 0

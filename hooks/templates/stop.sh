#!/usr/bin/env bash
# Stop — runs when Claude finishes a turn.
# Output a reason JSON to continue the turn (exit 0 + JSON). Otherwise exit 0 silently.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_STOP_HOOK_ACTIVE=$(skogai_jq_field ".stop_hook_active" "false")
HOOK_TRANSCRIPT=$(skogai_jq_field ".transcript_path" "EMPTY_TRANSCRIPT")

skogai_jq_log "Stop: stop_hook_active=$HOOK_STOP_HOOK_ACTIVE"

exit 0

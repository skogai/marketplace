#!/usr/bin/env bash
# SessionStart — runs when a session starts or resumes.
# Cannot block. Output additionalContext to inject into session.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_SOURCE=$(skogai_jq_field ".source" "unknown")
HOOK_TRANSCRIPT=$(skogai_jq_field ".transcript_path" "EMPTY_TRANSCRIPT")
HOOK_PERMISSION_MODE=$(skogai_jq_field ".permission_mode" "unknown")

skogai_jq_log "SessionStart: source=$HOOK_SOURCE permission_mode=$HOOK_PERMISSION_MODE"

exit 0

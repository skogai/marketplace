#!/usr/bin/env bash
# PreToolUse — runs before every tool call.
# Exit 0: allow. Exit 2: block (shows stderr to Claude).
# Output permissionDecision JSON to allow/deny/ask.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_TOOL_NAME=$(skogai_jq_field ".tool_name" "UNKNOWN_TOOL")
HOOK_TOOL_USE_ID=$(skogai_jq_field ".tool_use_id" "UNKNOWN_ID")

skogai_jq_log "PreToolUse: tool=$HOOK_TOOL_NAME id=$HOOK_TOOL_USE_ID"

exit 0

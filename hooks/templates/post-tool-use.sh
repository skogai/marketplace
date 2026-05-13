#!/usr/bin/env bash
# PostToolUse — runs after every tool call completes.
# Cannot block. Output additionalContext to inject after tool result.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_TOOL_NAME=$(skogai_jq_field ".tool_name" "UNKNOWN_TOOL")
HOOK_TOOL_USE_ID=$(skogai_jq_field ".tool_use_id" "UNKNOWN_ID")

skogai_jq_log "PostToolUse: tool=$HOOK_TOOL_NAME id=$HOOK_TOOL_USE_ID"

exit 0

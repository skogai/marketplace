#!/usr/bin/env bash
# PreCompact — runs before context compaction.
# Cannot block. Output additionalContext to inject into compaction summary.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_TRIGGER=$(skogai_jq_field ".trigger" "unknown")
HOOK_CUSTOM_INSTRUCTIONS=$(skogai_jq_field ".custom_instructions" "")

skogai_jq_log "PreCompact: trigger=$HOOK_TRIGGER"

exit 0

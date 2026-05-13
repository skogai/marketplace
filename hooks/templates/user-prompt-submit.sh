#!/usr/bin/env bash
# UserPromptSubmit — runs when user submits a prompt.
# Exit 0: allow. Exit 2: block (erases prompt, shows stderr to user).
# Output additionalContext JSON to inject into Claude's context.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_CWD=$(skogai_jq_field ".cwd" "UNKNOWN_CWD")
HOOK_PERMISSION_MODE=$(skogai_jq_field ".permission_mode" "unknown")

skogai_jq_log "UserPromptSubmit: cwd=$HOOK_CWD permission_mode=$HOOK_PERMISSION_MODE prompt_len=${#HOOK_PROMPT}"

exit 0

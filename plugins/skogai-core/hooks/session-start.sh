#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook — bootstrap the repo environment, mirroring .envrc.
#
# Runs: git submodule update --init
# Injects: LESSON_DIRS into session context so agents know where lessons live.
#
# Exit codes:
# - 0: success; JSON output parsed for hookSpecificOutput
# - other: non-blocking error, stderr shown in verbose mode

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

# --- Schema ---
HOOK_CWD=$(skogai_jq_field ".cwd" "UNKNOWN_CWD")
HOOK_SOURCE=$(skogai_jq_field ".source" "unknown")

skogai_jq_log "SessionStart: source=$HOOK_SOURCE cwd=$HOOK_CWD"

# Bootstrap: initialise submodules (idempotent, safe to re-run)
bootstrap_output=""
if [[ "$HOOK_CWD" != "UNKNOWN_CWD" ]]; then
    bootstrap_output=$(git -C "$HOOK_CWD" submodule update --init 2>&1 || true)
fi

# Surface LESSON_DIRS so skills can locate lessons without relying on direnv
lesson_dirs="${HOOK_CWD}/tests/lessons"
bin_dir="${HOOK_CWD}/.skogai/tmp/bin"

context="Bootstrap complete.
LESSON_DIRS=${lesson_dirs}
PATH includes ${bin_dir}"

[[ -n "$bootstrap_output" ]] && context="${context}
submodule: ${bootstrap_output}"

skogai_jq_context "SessionStart" "$context"

exit 0

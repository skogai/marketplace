#!/usr/bin/env bash
# Setup hook — runs on `claude --init-only` or `--init`/`--maintenance` with -p.
# Does NOT fire on normal session startup. Use SessionStart for per-session init.
#
# Trigger values: "init" (first install) | "maintenance" (scheduled cleanup)
#
# Cannot block. Exit 2 shows stderr to user; other non-zero shows only with --verbose.
# Plain stdout goes to debug log only — output additionalContext via JSON instead.
# Has access to $CLAUDE_ENV_FILE (write exports here to persist into session env).
#
# Key env vars available:
#   $CLAUDE_PLUGIN_ROOT  — this plugin's install dir (changes on update, treat as read-only)
#   $CLAUDE_PLUGIN_DATA  — persistent data dir that survives updates (~/.claude/plugins/data/<id>/)
#   $CLAUDE_PROJECT_DIR  — project root
#   $CLAUDE_ENV_FILE     — write "export KEY=val" lines here to persist env vars
#
# Plugin update detection pattern (for deps that need reinstall on update):
#   diff -q "$CLAUDE_PLUGIN_ROOT/manifest" "$CLAUDE_PLUGIN_DATA/manifest" >/dev/null 2>&1 \
#     || { run_install && cp "$CLAUDE_PLUGIN_ROOT/manifest" "$CLAUDE_PLUGIN_DATA/manifest"; }
#   The diff fails when stored copy is missing (first install) or differs (plugin updated).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

# --- skogai-jq transform dir (for direct jq -f usage) ---
JQ_DIR="$SCRIPT_DIR/../skills/skogai-jq"

# --- Schema ---
HOOK_TRIGGER=$(skogai_jq_field ".trigger" "UNKNOWN_TRIGGER")
HOOK_CWD=$(skogai_jq_field ".cwd" "UNKNOWN_CWD")

skogai_jq_log "Setup: trigger=$HOOK_TRIGGER cwd=$HOOK_CWD"

# --- Validate input using skogai-jq ---
# has-field: check a nested path exists in $HOOK_INPUT
# crud-get:  extract a value with a default
# Example (uncomment to use):
# trigger_exists=$(echo "$HOOK_INPUT" | jq -f "$JQ_DIR/has-field/transform.jq" --arg path "trigger")
# cwd_value=$(echo "$HOOK_INPUT" | jq -f "$JQ_DIR/crud-get/transform.jq" --arg path "cwd" --arg default "unknown")

report=""

# --- init: first install ---
if [[ "$HOOK_TRIGGER" == "init" ]]; then
    report="skogai-core initialised."
fi

# --- maintenance: scheduled cleanup / update ---
if [[ "$HOOK_TRIGGER" == "maintenance" ]]; then
    report="skogai-core maintenance run."
fi

# --- Output context if we have anything to say ---
if [[ -n "$report" ]]; then
    skogai_jq_context "Setup" "$report"
fi

exit 0

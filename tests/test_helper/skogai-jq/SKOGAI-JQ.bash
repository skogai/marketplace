#!/usr/bash
# skogai-jq.sh — Shared hook library for JSON I/O, debug logging, and output helpers.
#
# Usage: source this at the top of any hook script:
#   SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#   source "$SCRIPT_DIR/../scripts/skogai-jq.sh"
#
# After sourcing, these are available:
#   $HOOK_INPUT       — raw JSON from stdin
#   $HOOK_SESSION_ID  — extracted session_id
#   $HOOK_EVENT       — extracted hook_event_name
#   $HOOK_PROMPT      — extracted hook_prompt
#   $HOOK_LOG         — log file path (/tmp/${session_id}.jsonl)
#
# Functions:
#   skogai_jq_field ".path" ["default"]  — extract field from input
#   skogai_jq_log "summary"             — append structured JSONL debug entry
#   skogai_jq_context "event" "text"    — output hookSpecificOutput JSON
#   skogai_jq_decision "decision" "reason" — output decision JSON
#   skogai_jq_codex_*                   — Codex-specific hook output helpers

set -euo pipefail

SKOGAI_JQ_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKOGAI_JQ_TRANSFORM_DIR="${SKOGAI_JQ_SCRIPT_DIR}/../skogai-jq"

# --- Init: read stdin, extract common fields ---
HOOK_INPUT_FILE="$1"
HOOK_INPUT=$(cat "$HOOK_INPUT_FILE")
HOOK_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"')
HOOK_PROMPT=$(echo "$HOOK_INPUT" | jq -r '.prompt // "EMPTY_PROMPT"')
HOOK_EVENT=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // "Unknown"')
HOOK_LOG="/tmp/${HOOK_SESSION_ID}.jsonl"

# --- Field extraction ---
# Usage: val=$(skogai_jq_field ".tool_name" "default_value")
skogai_jq_field() {
    local path="$1"
    local default="${2:-}"
    if [[ -n "$default" ]]; then
        echo "$HOOK_INPUT" | jq -r "${path} // \"${default}\""
    else
        echo "$HOOK_INPUT" | jq -r "${path} // empty"
    fi
}

# --- Structured debug logging ---
# Appends a JSONL entry: {ts, event, session_id, summary, input}
# Usage: skogai_jq_log "Logged session end, reason: exit"
skogai_jq_log() {
    local summary="${1:-}"
    jq -c -n \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg event "$HOOK_EVENT" \
        --arg sid "$HOOK_SESSION_ID" \
        --arg summary "$summary" \
        --argjson input "$HOOK_INPUT" \
        '{ts: $ts, event: $event, session_id: $sid, summary: $summary, input: $input}' \
        >>"$HOOK_LOG"
}

# --- Output: context injection ---
# Usage: skogai_jq_context "SessionStart" "context text here"
skogai_jq_context() {
    local event_name="$1"
    local context="$2"
    jq -n \
        --arg event "$event_name" \
        --arg ctx "$context" \
        '{hookSpecificOutput: {hookEventName: $event, additionalContext: $ctx}}'
}

# --- Output: decision ---
# Usage: skogai_jq_decision "block" "uncommitted changes found"
skogai_jq_decision() {
    local decision="$1"
    local reason="$2"
    jq -n \
        --arg d "$decision" \
        --arg r "$reason" \
        '{decision: $d, reason: $r}'
}

# --- Codex outputs ---
# Codex and Claude share several event names, but not every output field has
# the same behavior. Keep Codex helpers explicit so hook scripts show intent.

# Usage: skogai_jq_codex_context "SessionStart|UserPromptSubmit|PostToolUse" "context text"
skogai_jq_codex_context() {
    local event_name="$1"
    local context="$2"
    skogai_jq_context "$event_name" "$context"
}

# Usage: skogai_jq_codex_pre_tool_deny "blocking reason"
skogai_jq_codex_pre_tool_deny() {
    local reason="$1"
    jq -n \
        --arg reason "$reason" \
        '{
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "deny",
                permissionDecisionReason: $reason
            }
        }'
}

# Usage: skogai_jq_codex_permission_request "allow|deny" ["message"]
skogai_jq_codex_permission_request() {
    local behavior="$1"
    local message="${2:-}"

    case "$behavior" in
    allow | deny) ;;
    *)
        echo "unsupported Codex PermissionRequest behavior: $behavior" >&2
        return 64
        ;;
    esac

    jq -n \
        --arg behavior "$behavior" \
        --arg message "$message" \
        '{
            hookSpecificOutput: {
                hookEventName: "PermissionRequest",
                decision: ({behavior: $behavior} + (if $message == "" then {} else {message: $message} end))
            }
        }'
}

# Usage: skogai_jq_codex_block "UserPromptSubmit|PostToolUse|PreToolUse" "reason"
skogai_jq_codex_block() {
    local event_name="$1"
    local reason="$2"

    case "$event_name" in
    PreToolUse | PostToolUse | UserPromptSubmit | Stop) ;;
    *)
        echo "unsupported Codex block event: $event_name" >&2
        return 64
        ;;
    esac

    skogai_jq_decision "block" "$reason"
}

# Usage: skogai_jq_codex_continue_turn "next prompt text"
skogai_jq_codex_continue_turn() {
    local reason="$1"
    skogai_jq_codex_block "Stop" "$reason"
}

# Usage: skogai_jq_codex_stop "stop reason"
skogai_jq_codex_stop() {
    local reason="$1"
    jq -n \
        --arg reason "$reason" \
        '{continue: false, stopReason: $reason}'
}

# --- Output: bool ---
# Usage: skogai_jq_bool "is-empty-string|is-timestamp" "2025-01-01"
skogai_jq_bool() {
    local predicate="$1"
    local value="$2"
    local transform_file="${SKOGAI_JQ_TRANSFORM_DIR}/${predicate}/transform.jq"

    jq -n --arg value "$value" '{value: $value}' |
        jq --arg path "value" -f "$transform_file"
}

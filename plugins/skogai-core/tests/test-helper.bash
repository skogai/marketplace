#!/bin/bash

# portable test helpers for bats tests
# source this in your test files: load test-helper

# get the project root directory
# export PROJECT_ROOT="$(./scripts/find-agent-root.sh)"
# export PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
# export SCRIPTS_DIR="${SCRIPTS_DIR:-$PROJECT_ROOT/scripts}"
# echo $PROJECT_ROOT
# echo $SCRIPTS_DIR

# create a temporary directory for test files
setup_test_dir() {
    export TEST_DIR="$(mktemp -d -t test.XXXXXX)"
    cd "$TEST_DIR" || exit 1
}

# clean up test directory
teardown_test_dir() {
    if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# source a script without executing its main code
# usage: source_script "script-name.sh"
source_script() {
    local script="$1"
    SOURCING_FOR_TESTS=1 source "$SCRIPTS_DIR/$script" "test-mode" 2>/dev/null || true
}

# create a mock git repository
setup_git_repo() {
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    # Disable commit signing for throwaway test repos so tests pass in
    # environments that enforce signed commits (e.g. CI with custom gpg programs).
    git config commit.gpgsign false
    echo "test" >test.txt
    git add test.txt
    git commit -m "Initial commit" --quiet
}

SKOGAI_JQ_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKOGAI_JQ_TRANSFORM_DIR="${SKOGAI_JQ_SCRIPT_DIR}/../skogai-jq"
JQ_DIR="${SKOGAI_JQ_TRANSFORM_DIR}"

# --- Init: read stdin, extract common fields ---
HOOK_INPUT=$(cat)
HOOK_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"')
HOOK_PROMPT=$(echo "$HOOK_INPUT" | jq -r '.prompt // "EMPTY_PROMPT"')
HOOK_EVENT=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // "Unknown"')
HOOK_LOG="/tmp/${HOOK_SESSION_ID}.jsonl"

# --- Claude env vars (set by Claude Code when running inside a plugin) ---
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
CLAUDE_PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-}"
CLAUDE_ENV_FILE="${CLAUDE_ENV_FILE:-}"

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
# Appends a JSONL entry: {ts, event, session_id, summary, env, input}
# env includes available Claude env vars (empty string if not set by Claude Code)
# Usage: skogai_jq_log "summary text"
skogai_jq_log() {
    local summary="${1:-}"
    jq -c -n \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg event "$HOOK_EVENT" \
        --arg sid "$HOOK_SESSION_ID" \
        --arg summary "$summary" \
        --arg plugin_root "$CLAUDE_PLUGIN_ROOT" \
        --arg plugin_data "$CLAUDE_PLUGIN_DATA" \
        --arg project_dir "$CLAUDE_PROJECT_DIR" \
        --arg env_file "$CLAUDE_ENV_FILE" \
        --argjson input "$HOOK_INPUT" \
        '{ts: $ts, event: $event, session_id: $sid, summary: $summary,
          env: {plugin_root: $plugin_root, plugin_data: $plugin_data,
                project_dir: $project_dir, env_file: $env_file},
          input: $input}' \
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

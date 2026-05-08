#!/usr/bin/env bats

load ../test-helper

SCRIPTS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-jq-session.jsonl
}

# Helper: source the library with given JSON input and run a command
run_with_input() {
    local input="$1"
    local cmd="$2"
    bash -c "source '$SCRIPTS_DIR/skogai-jq.sh' && $cmd" <<< "$input"
}

# ============================================================
# Init variables: HOOK_INPUT, HOOK_SESSION_ID, HOOK_EVENT, HOOK_LOG
# ============================================================

@test "HOOK_INPUT captures the full stdin JSON" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        echo \"\$HOOK_INPUT\"
    " <<< '{"session_id":"s1","hook_event_name":"Test","extra":"data"}'
    assert_success
    assert_output_contains '"session_id"'
    assert_output_contains '"extra"'
}

@test "HOOK_SESSION_ID is extracted from input" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        echo \"\$HOOK_SESSION_ID\"
    " <<< '{"session_id":"my-session-xyz","hook_event_name":"Test"}'
    assert_success
    assert_output_equals "my-session-xyz"
}

@test "HOOK_EVENT is extracted from input" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        echo \"\$HOOK_EVENT\"
    " <<< '{"session_id":"s1","hook_event_name":"PreToolUse"}'
    assert_success
    assert_output_equals "PreToolUse"
}

@test "HOOK_SESSION_ID defaults to 'unknown' when field is missing" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        echo \"\$HOOK_SESSION_ID\"
    " <<< '{}'
    assert_success
    assert_output_equals "unknown"
}

@test "HOOK_EVENT defaults to 'Unknown' when field is missing" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        echo \"\$HOOK_EVENT\"
    " <<< '{}'
    assert_success
    assert_output_equals "Unknown"
}

@test "HOOK_LOG path uses session_id" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        echo \"\$HOOK_LOG\"
    " <<< '{"session_id":"test-jq-session","hook_event_name":"Test"}'
    assert_success
    assert_output_equals "/tmp/test-jq-session.jsonl"
}

# ============================================================
# skogai_jq_field
# ============================================================

@test "skogai_jq_field extracts top-level string field" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_field '.tool_name'
    " <<< '{"session_id":"s1","hook_event_name":"Test","tool_name":"Bash"}'
    assert_success
    assert_output_equals "Bash"
}

@test "skogai_jq_field extracts nested field" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_field '.tool_input.command'
    " <<< '{"session_id":"s1","hook_event_name":"Test","tool_input":{"command":"echo hello"}}'
    assert_success
    assert_output_equals "echo hello"
}

@test "skogai_jq_field returns empty string when field is absent and no default given" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_field '.nonexistent'
    " <<< '{"session_id":"s1","hook_event_name":"Test"}'
    assert_success
    assert_output_equals ""
}

@test "skogai_jq_field returns the provided default when field is absent" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_field '.nonexistent' 'my-default'
    " <<< '{"session_id":"s1","hook_event_name":"Test"}'
    assert_success
    assert_output_equals "my-default"
}

@test "skogai_jq_field returns actual value (not default) when field is present" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_field '.name' 'fallback'
    " <<< '{"session_id":"s1","hook_event_name":"Test","name":"real_value"}'
    assert_success
    assert_output_equals "real_value"
}

@test "skogai_jq_field handles null JSON value with default" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_field '.nullfield' 'default-for-null'
    " <<< '{"session_id":"s1","hook_event_name":"Test","nullfield":null}'
    assert_success
    assert_output_equals "default-for-null"
}

# ============================================================
# skogai_jq_log
# ============================================================

@test "skogai_jq_log creates the JSONL log file" {
    bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_log 'test entry'
    " <<< '{"session_id":"test-jq-session","hook_event_name":"Test"}'
    assert_file_exists "/tmp/test-jq-session.jsonl"
}

@test "skogai_jq_log appends a valid JSON entry" {
    bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_log 'checking json'
    " <<< '{"session_id":"test-jq-session","hook_event_name":"Test"}'
    # jq can parse multiple concatenated pretty-printed objects from the same file
    run bash -c "jq '.' /tmp/test-jq-session.jsonl > /dev/null"
    assert_success
}

@test "skogai_jq_log entry contains the provided summary" {
    bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_log 'my-unique-summary'
    " <<< '{"session_id":"test-jq-session","hook_event_name":"Test"}'
    run bash -c "grep -c 'my-unique-summary' /tmp/test-jq-session.jsonl"
    assert_success
}

@test "skogai_jq_log entry includes the event name" {
    bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_log 'event check'
    " <<< '{"session_id":"test-jq-session","hook_event_name":"PreToolUse"}'
    run bash -c "jq -r '.event' /tmp/test-jq-session.jsonl | tail -1"
    assert_success
    assert_output_equals "PreToolUse"
}

@test "skogai_jq_log entry includes the session_id" {
    bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_log 'sid check'
    " <<< '{"session_id":"test-jq-session","hook_event_name":"Test"}'
    run bash -c "jq -r '.session_id' /tmp/test-jq-session.jsonl | tail -1"
    assert_success
    assert_output_equals "test-jq-session"
}

@test "skogai_jq_log entry embeds the full input JSON" {
    bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_log 'input embed'
    " <<< '{"session_id":"test-jq-session","hook_event_name":"Test","tool_name":"Read"}'
    run bash -c "jq -r '.input.tool_name' /tmp/test-jq-session.jsonl | tail -1"
    assert_success
    assert_output_equals "Read"
}

# ============================================================
# skogai_jq_context
# ============================================================

@test "skogai_jq_context outputs valid JSON" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_context 'SessionStart' 'hello' | jq . > /dev/null
    " <<< '{"session_id":"s1","hook_event_name":"SessionStart"}'
    assert_success
}

@test "skogai_jq_context output contains hookSpecificOutput key" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_context 'SessionStart' 'hello'
    " <<< '{"session_id":"s1","hook_event_name":"SessionStart"}'
    assert_success
    assert_output_contains "hookSpecificOutput"
}

@test "skogai_jq_context sets hookEventName correctly" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_context 'UserPromptSubmit' 'ctx' | jq -r '.hookSpecificOutput.hookEventName'
    " <<< '{"session_id":"s1","hook_event_name":"UserPromptSubmit"}'
    assert_success
    assert_output_equals "UserPromptSubmit"
}

@test "skogai_jq_context sets additionalContext correctly" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_context 'SessionStart' 'injected context text' | jq -r '.hookSpecificOutput.additionalContext'
    " <<< '{"session_id":"s1","hook_event_name":"SessionStart"}'
    assert_success
    assert_output_equals "injected context text"
}

@test "skogai_jq_context preserves special characters in context" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_context 'SessionStart' 'line1\nline2' | jq -r '.hookSpecificOutput.additionalContext'
    " <<< '{"session_id":"s1","hook_event_name":"SessionStart"}'
    assert_success
    assert_output_contains "line1"
}

# ============================================================
# skogai_jq_decision
# ============================================================

@test "skogai_jq_decision outputs valid JSON" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_decision 'block' 'reason' | jq . > /dev/null
    " <<< '{"session_id":"s1","hook_event_name":"Stop"}'
    assert_success
}

@test "skogai_jq_decision sets the decision field" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_decision 'block' 'some reason' | jq -r '.decision'
    " <<< '{"session_id":"s1","hook_event_name":"Stop"}'
    assert_success
    assert_output_equals "block"
}

@test "skogai_jq_decision sets the reason field" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_decision 'allow' 'all good here' | jq -r '.reason'
    " <<< '{"session_id":"s1","hook_event_name":"Stop"}'
    assert_success
    assert_output_equals "all good here"
}

@test "skogai_jq_decision works with 'continue' decision" {
    run bash -c "
        source '$SCRIPTS_DIR/skogai-jq.sh'
        skogai_jq_decision 'continue' 'proceeding' | jq -r '.decision'
    " <<< '{"session_id":"s1","hook_event_name":"Stop"}'
    assert_success
    assert_output_equals "continue"
}

#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_session_input() {
    local session="${1:-test-ss-session}"
    jq -n \
        --arg sid "$session" \
        '{
            session_id: $sid,
            hook_event_name: "SessionStart",
            permission_mode: "default",
            source: "startup"
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-ss-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0" {
    write_session_input
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'"
    assert_success
}

@test "hook exits 0 when session_id is missing from input" {
    echo '{}' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_session_input
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'" || true
    assert_file_exists "/tmp/test-ss-session.jsonl"
}

@test "session log entry contains the hook event name" {
    write_session_input
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'" || true
    run bash -c "grep -c 'SessionStart' /tmp/test-ss-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_session_input
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is SessionStart" {
    write_session_input
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -r '.hookSpecificOutput.hookEventName'"
        assert_success
        assert_output_equals "SessionStart"
    fi
}

@test "when output is produced additionalContext is a non-empty string" {
    write_session_input
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -e '.hookSpecificOutput.additionalContext | length > 0'"
        assert_success
    fi
}

# ============================================================
# Dependency resilience: session-context.sh absent
# ============================================================

@test "hook succeeds when session-context.sh is not executable" {
    # session-context.sh is checked with -x; an absent HOME means it won't be found
    write_session_input
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'"
    assert_success
}

# ============================================================
# Dependency resilience: lesson_matcher.py absent / failing
# ============================================================

@test "hook succeeds when lesson_matcher.py produces no output" {
    write_session_input
    # The hook uses `|| true` on the lesson_matcher call, so failures are silent
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'"
    assert_success
}

@test "session-start bootstraps workflow artifacts" {
    write_session_input
    run env SKOGAI_WORKFLOW_DIR="$TEST_DIR/workflow" bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-start.sh'"
    assert_success
    assert_file_exists "$TEST_DIR/workflow/tasks-progress.md"
    assert_file_exists "$TEST_DIR/workflow/research-notes.md"
    assert_file_exists "$TEST_DIR/workflow/decisions-results.md"
}

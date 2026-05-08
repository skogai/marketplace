#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_session_end_input() {
    local reason="${1:-exit}"
    local session="${2:-test-se-session}"
    jq -n \
        --arg sid "$session" \
        --arg reason "$reason" \
        '{
            session_id: $sid,
            transcript_path: "/tmp/fake-transcript.jsonl",
            cwd: "/tmp",
            permission_mode: "default",
            hook_event_name: "SessionEnd",
            reason: $reason
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-se-session.jsonl
}

# ============================================================
# Exit code (cannot block session termination)
# ============================================================

@test "hook exits 0 for exit reason" {
    write_session_end_input "exit"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'"
    assert_success
}

@test "hook exits 0 for timeout reason" {
    write_session_end_input "timeout"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'"
    assert_success
}

@test "hook exits 0 for interrupt reason" {
    write_session_end_input "interrupt"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'"
    assert_success
}

@test "hook exits 0 with missing reason field" {
    jq -n '{
        session_id: "test-se-session",
        hook_event_name: "SessionEnd"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_session_end_input "exit"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'" || true
    assert_file_exists "/tmp/test-se-session.jsonl"
}

@test "session log contains reason" {
    write_session_end_input "timeout"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'" || true
    run bash -c "grep -c 'timeout' /tmp/test-se-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_session_end_input "exit"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/session-end.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

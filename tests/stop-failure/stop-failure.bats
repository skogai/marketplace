#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_stop_failure_input() {
    local stop_hook_active="${1:-true}"
    local session="${2:-test-sf-session}"
    jq -n \
        --arg sid "$session" \
        --argjson active "$stop_hook_active" \
        '{
            session_id: $sid,
            hook_event_name: "StopFailure",
            stop_hook_active: $active
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-sf-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 when stop_hook_active is true" {
    write_stop_failure_input true
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/stop-failure.sh'"
    assert_success
}

@test "hook exits 0 when stop_hook_active is false" {
    write_stop_failure_input false
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/stop-failure.sh'"
    assert_success
}

@test "hook exits 0 with missing stop_hook_active" {
    jq -n '{session_id: "test-sf-session", hook_event_name: "StopFailure"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/stop-failure.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_stop_failure_input true
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/stop-failure.sh'" || true
    assert_file_exists "/tmp/test-sf-session.jsonl"
}

@test "session log contains StopFailure event" {
    write_stop_failure_input true
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/stop-failure.sh'" || true
    run bash -c "grep -c 'StopFailure' /tmp/test-sf-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_stop_failure_input true
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/stop-failure.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

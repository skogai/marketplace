#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_notification_input() {
    local type="${1:-info}"
    local message="${2:-Test notification}"
    local session="${3:-test-notif-session}"
    jq -n \
        --arg sid "$session" \
        --arg type "$type" \
        --arg msg "$message" \
        '{
            session_id: $sid,
            hook_event_name: "Notification",
            notification_type: $type,
            message: $msg
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-notif-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for info notification" {
    write_notification_input "info" "Hello"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/notification.sh'"
    assert_success
}

@test "hook exits 0 for error notification" {
    write_notification_input "error" "Something went wrong"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/notification.sh'"
    assert_success
}

@test "hook exits 0 with missing notification_type" {
    jq -n '{session_id: "test-notif-session", hook_event_name: "Notification", message: "bare msg"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/notification.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_notification_input "info" "logged"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/notification.sh'" || true
    assert_file_exists "/tmp/test-notif-session.jsonl"
}

@test "session log contains notification_type" {
    write_notification_input "warning" "disk low"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/notification.sh'" || true
    run bash -c "grep -c 'warning' /tmp/test-notif-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_notification_input "info" "test"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/notification.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

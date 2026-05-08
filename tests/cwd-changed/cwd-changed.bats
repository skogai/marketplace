#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_cwd_changed_input() {
    local old_cwd="${1:-/home/user/project}"
    local new_cwd="${2:-/home/user/project/src}"
    local session="${3:-test-cwd-session}"
    jq -n \
        --arg sid "$session" \
        --arg old "$old_cwd" \
        --arg new "$new_cwd" \
        '{
            session_id: $sid,
            hook_event_name: "CwdChanged",
            old_cwd: $old,
            new_cwd: $new
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-cwd-session.jsonl
}

# ============================================================
# Exit code (cannot block cwd changes)
# ============================================================

@test "hook exits 0 for a directory change" {
    write_cwd_changed_input "/tmp" "/tmp/sub"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/cwd-changed.sh'"
    assert_success
}

@test "hook exits 0 when changing to root" {
    write_cwd_changed_input "/home/user" "/"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/cwd-changed.sh'"
    assert_success
}

@test "hook exits 0 with missing old_cwd" {
    jq -n '{
        session_id: "test-cwd-session",
        hook_event_name: "CwdChanged",
        new_cwd: "/tmp"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/cwd-changed.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_cwd_changed_input "/tmp" "/tmp/sub"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/cwd-changed.sh'" || true
    assert_file_exists "/tmp/test-cwd-session.jsonl"
}

@test "session log contains new_cwd" {
    write_cwd_changed_input "/home/user" "/home/user/project"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/cwd-changed.sh'" || true
    run bash -c "grep -c 'project' /tmp/test-cwd-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_cwd_changed_input "/tmp" "/tmp/sub"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/cwd-changed.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

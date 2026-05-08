#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_setup_input() {
    local trigger="${1:-init}"
    local session="${2:-test-setup-session}"
    jq -n \
        --arg sid "$session" \
        --arg trigger "$trigger" \
        '{
            session_id: $sid,
            transcript_path: "/tmp/fake-transcript.jsonl",
            cwd: "/tmp",
            hook_event_name: "Setup",
            trigger: $trigger
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-setup-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "setup hook exits 0 for init trigger" {
    write_setup_input "init"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'"
    assert_success
}

@test "setup hook exits 0 for maintenance trigger" {
    write_setup_input "maintenance"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'"
    assert_success
}

@test "setup hook exits 0 with missing trigger field" {
    jq -n '{session_id:"test-setup-session",hook_event_name:"Setup"}' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "setup hook writes input to session JSONL log" {
    write_setup_input "init"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'" || true
    assert_file_exists "/tmp/test-setup-session.jsonl"
}

@test "session log contains the hook event name" {
    write_setup_input "init"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'" || true
    run bash -c "grep -c 'Setup' /tmp/test-setup-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_setup_input "init"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is Setup" {
    write_setup_input "init"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/setup.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -r '.hookSpecificOutput.hookEventName'"
        assert_success
        assert_output_equals "Setup"
    fi
}

#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_subagent_stop_input() {
    local stop_hook_active="${1:-false}"
    local session="${2:-test-sast-session}"
    jq -n \
        --arg sid "$session" \
        --argjson active "$stop_hook_active" \
        '{
            session_id: $sid,
            hook_event_name: "SubagentStop",
            stop_hook_active: $active
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-sast-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 when stop_hook_active is false" {
    write_subagent_stop_input false
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'"
    assert_success
}

@test "hook exits 0 when stop_hook_active is true" {
    write_subagent_stop_input true
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'"
    assert_success
}

@test "hook exits 0 with missing stop_hook_active" {
    jq -n '{session_id: "test-sast-session", hook_event_name: "SubagentStop"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_subagent_stop_input false
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'" || true
    assert_file_exists "/tmp/test-sast-session.jsonl"
}

@test "session log contains SubagentStop event" {
    write_subagent_stop_input false
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'" || true
    run bash -c "grep -c 'SubagentStop' /tmp/test-sast-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional decision)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_subagent_stop_input false
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when decision is present it is block or allow" {
    write_subagent_stop_input false
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-stop.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        decision=$(echo "$output" | jq -r '.decision // empty')
        if [[ -n "$decision" ]]; then
            [[ "$decision" == "block" || "$decision" == "allow" ]]
        fi
    fi
}

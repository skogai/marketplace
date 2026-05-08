#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_teammate_idle_input() {
    local name="${1:-agent-worker}"
    local session="${2:-test-ti-session}"
    jq -n \
        --arg sid "$session" \
        --arg name "$name" \
        '{
            session_id: $sid,
            hook_event_name: "TeammateIdle",
            teammate_name: $name
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-ti-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for an idle teammate" {
    write_teammate_idle_input "agent-worker"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/teammate-idle.sh'"
    assert_success
}

@test "hook exits 0 with missing teammate_name" {
    jq -n '{session_id: "test-ti-session", hook_event_name: "TeammateIdle"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/teammate-idle.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_teammate_idle_input "agent-worker"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/teammate-idle.sh'" || true
    assert_file_exists "/tmp/test-ti-session.jsonl"
}

@test "session log contains teammate_name" {
    write_teammate_idle_input "code-reviewer"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/teammate-idle.sh'" || true
    run bash -c "grep -c 'code-reviewer' /tmp/test-ti-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional block decision)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_teammate_idle_input "agent-worker"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/teammate-idle.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when decision is present it is block" {
    write_teammate_idle_input "agent-worker"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/teammate-idle.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        decision=$(echo "$output" | jq -r '.decision // empty')
        if [[ -n "$decision" ]]; then
            [[ "$decision" == "block" ]]
        fi
    fi
}

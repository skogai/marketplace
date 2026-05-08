#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_subagent_start_input() {
    local type="${1:-general-purpose}"
    local session="${2:-test-sas-session}"
    jq -n \
        --arg sid "$session" \
        --arg type "$type" \
        '{
            session_id: $sid,
            hook_event_name: "SubagentStart",
            subagent_type: $type
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-sas-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for general-purpose subagent" {
    write_subagent_start_input "general-purpose"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'"
    assert_success
}

@test "hook exits 0 for Explore subagent" {
    write_subagent_start_input "Explore"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'"
    assert_success
}

@test "hook exits 0 with missing subagent_type" {
    jq -n '{session_id: "test-sas-session", hook_event_name: "SubagentStart"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_subagent_start_input "general-purpose"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'" || true
    assert_file_exists "/tmp/test-sas-session.jsonl"
}

@test "session log contains subagent_type" {
    write_subagent_start_input "Explore"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'" || true
    run bash -c "grep -c 'Explore' /tmp/test-sas-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional decision)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_subagent_start_input "general-purpose"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when decision is present it is block or allow" {
    write_subagent_start_input "general-purpose"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/subagent-start.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        decision=$(echo "$output" | jq -r '.decision // empty')
        if [[ -n "$decision" ]]; then
            [[ "$decision" == "block" || "$decision" == "allow" ]]
        fi
    fi
}

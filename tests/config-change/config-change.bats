#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_config_change_input() {
    local config_file="${1:-.claude/settings.json}"
    local session="${2:-test-cc-session}"
    jq -n \
        --arg sid "$session" \
        --arg file "$config_file" \
        '{
            session_id: $sid,
            hook_event_name: "ConfigChange",
            config_file: $file
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-cc-session.jsonl
}

# ============================================================
# Exit code (cannot block config changes)
# ============================================================

@test "hook exits 0 for settings.json change" {
    write_config_change_input ".claude/settings.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/config-change.sh'"
    assert_success
}

@test "hook exits 0 for CLAUDE.md change" {
    write_config_change_input "CLAUDE.md"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/config-change.sh'"
    assert_success
}

@test "hook exits 0 with missing config_file" {
    jq -n '{session_id: "test-cc-session", hook_event_name: "ConfigChange"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/config-change.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_config_change_input ".claude/settings.json"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/config-change.sh'" || true
    assert_file_exists "/tmp/test-cc-session.jsonl"
}

@test "session log contains config_file path" {
    write_config_change_input "CLAUDE.md"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/config-change.sh'" || true
    run bash -c "grep -c 'CLAUDE.md' /tmp/test-cc-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_config_change_input ".claude/settings.json"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/config-change.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

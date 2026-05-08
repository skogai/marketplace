#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_instructions_loaded_input() {
    local source="${1:-project}"
    local path="${2:-CLAUDE.md}"
    local session="${3:-test-il-session}"
    jq -n \
        --arg sid "$session" \
        --arg source "$source" \
        --arg path "$path" \
        '{
            session_id: $sid,
            hook_event_name: "InstructionsLoaded",
            instructions_source: $source,
            instructions_path: $path
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-il-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for project CLAUDE.md" {
    write_instructions_loaded_input "project" "CLAUDE.md"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'"
    assert_success
}

@test "hook exits 0 for global instructions" {
    write_instructions_loaded_input "global" "/home/user/.claude/CLAUDE.md"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'"
    assert_success
}

@test "hook exits 0 for plugin instructions" {
    write_instructions_loaded_input "plugin" ".claude-plugin/instructions.md"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'"
    assert_success
}

@test "hook exits 0 with missing instructions_path" {
    jq -n '{
        session_id: "test-il-session",
        hook_event_name: "InstructionsLoaded",
        instructions_source: "project"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_instructions_loaded_input "project" "CLAUDE.md"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'" || true
    assert_file_exists "/tmp/test-il-session.jsonl"
}

@test "session log contains instructions_source" {
    write_instructions_loaded_input "plugin" ".claude-plugin/instructions.md"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'" || true
    run bash -c "grep -c 'plugin' /tmp/test-il-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_instructions_loaded_input "project" "CLAUDE.md"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/instructions-loaded.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

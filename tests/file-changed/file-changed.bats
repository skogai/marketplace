#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_file_changed_input() {
    local file_path="${1:-src/main.ts}"
    local change_type="${2:-modified}"
    local session="${3:-test-fc-session}"
    jq -n \
        --arg sid "$session" \
        --arg path "$file_path" \
        --arg type "$change_type" \
        '{
            session_id: $sid,
            hook_event_name: "FileChanged",
            file_path: $path,
            change_type: $type
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-fc-session.jsonl
}

# ============================================================
# Exit code (cannot block file changes)
# ============================================================

@test "hook exits 0 for a modified file" {
    write_file_changed_input "src/main.ts" "modified"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'"
    assert_success
}

@test "hook exits 0 for a created file" {
    write_file_changed_input "src/new-module.ts" "created"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'"
    assert_success
}

@test "hook exits 0 for a deleted file" {
    write_file_changed_input "src/old-module.ts" "deleted"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'"
    assert_success
}

@test "hook exits 0 with missing change_type" {
    jq -n '{
        session_id: "test-fc-session",
        hook_event_name: "FileChanged",
        file_path: "README.md"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_file_changed_input "src/main.ts" "modified"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'" || true
    assert_file_exists "/tmp/test-fc-session.jsonl"
}

@test "session log contains file_path" {
    write_file_changed_input "hooks/pre-tool-use.sh" "modified"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'" || true
    run bash -c "grep -c 'pre-tool-use' /tmp/test-fc-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_file_changed_input "src/main.ts" "modified"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/file-changed.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

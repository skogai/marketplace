#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_failure_input() {
    local tool="${1:-Bash}"
    local session="${2:-test-ptuf-session}"
    jq -n \
        --arg sid "$session" \
        --arg tool "$tool" \
        '{
            session_id: $sid,
            transcript_path: "/tmp/fake-transcript.jsonl",
            cwd: "/tmp",
            hook_event_name: "PostToolUseFailure",
            tool_name: $tool,
            tool_use_id: "toolu_fail_001",
            tool_input: {command: "nonexistent-command"},
            error: "command not found: nonexistent-command"
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-ptuf-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a failed Bash tool" {
    write_failure_input "Bash"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use-failure.sh'"
    assert_success
}

@test "hook exits 0 for a failed Write tool" {
    jq -n '{
        session_id: "test-ptuf-session",
        hook_event_name: "PostToolUseFailure",
        tool_name: "Write",
        tool_use_id: "toolu_fail_002",
        tool_input: {file_path: "/no/permission/file.txt", content: "data"},
        error: "Permission denied"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use-failure.sh'"
    assert_success
}

@test "hook exits 0 with missing error field" {
    jq -n '{
        session_id: "test-ptuf-session",
        hook_event_name: "PostToolUseFailure",
        tool_name: "Bash",
        tool_use_id: "toolu_fail_003",
        tool_input: {command: "false"}
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use-failure.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_failure_input "Bash"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use-failure.sh'" || true
    assert_file_exists "/tmp/test-ptuf-session.jsonl"
}

@test "session log records the tool name" {
    write_failure_input "Bash"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use-failure.sh'" || true
    run bash -c "grep -c 'Bash' /tmp/test-ptuf-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_failure_input "Bash"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use-failure.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

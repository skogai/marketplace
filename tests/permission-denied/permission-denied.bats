#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_denied_input() {
    local tool="${1:-Bash}"
    local command="${2:-rm -rf /}"
    local session="${3:-test-pd-session}"
    jq -n \
        --arg sid "$session" \
        --arg tool "$tool" \
        --arg cmd "$command" \
        '{
            session_id: $sid,
            transcript_path: "/tmp/fake-transcript.jsonl",
            cwd: "/tmp",
            permission_mode: "auto",
            hook_event_name: "PermissionDenied",
            tool_name: $tool,
            tool_use_id: "toolu_denied_001",
            tool_input: {command: $cmd},
            deny_reason: "Command not permitted in auto mode"
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-pd-session.jsonl
}

# ============================================================
# Exit code (PermissionDenied cannot block — exit codes ignored)
# ============================================================

@test "hook exits 0 for a denied Bash command" {
    write_denied_input "Bash" "rm -rf /"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'"
    assert_success
}

@test "hook exits 0 for a denied Write tool" {
    jq -n '{
        session_id: "test-pd-session",
        hook_event_name: "PermissionDenied",
        permission_mode: "auto",
        tool_name: "Write",
        tool_use_id: "toolu_denied_002",
        tool_input: {file_path: "/etc/passwd", content: "evil"},
        deny_reason: "Write to system file denied"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'"
    assert_success
}

@test "hook exits 0 with missing deny_reason" {
    jq -n '{
        session_id: "test-pd-session",
        hook_event_name: "PermissionDenied",
        permission_mode: "auto",
        tool_name: "Bash",
        tool_use_id: "toolu_denied_003",
        tool_input: {command: "ls"}
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_denied_input "Bash" "rm -rf /"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'" || true
    assert_file_exists "/tmp/test-pd-session.jsonl"
}

@test "session log contains the tool name" {
    write_denied_input "Bash" "rm -rf /"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'" || true
    run bash -c "grep -c 'Bash' /tmp/test-pd-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional retry signal)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_denied_input "Bash" "ls"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when retry is signalled it is a boolean true" {
    write_denied_input "Bash" "ls"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-denied.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        retry=$(echo "$output" | jq -r '.hookSpecificOutput.retry // empty')
        if [[ -n "$retry" ]]; then
            run bash -c "echo '$output' | jq -e '.hookSpecificOutput.retry == true'"
            assert_success
        fi
    fi
}

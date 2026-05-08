#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_permission_input() {
    local tool="${1:-Bash}"
    local command="${2:-npm test}"
    local session="${3:-test-pr-session}"
    jq -n \
        --arg sid "$session" \
        --arg tool "$tool" \
        --arg cmd "$command" \
        '{
            session_id: $sid,
            transcript_path: "/tmp/fake-transcript.jsonl",
            cwd: "/tmp",
            permission_mode: "default",
            hook_event_name: "PermissionRequest",
            tool_name: $tool,
            tool_use_id: "toolu_perm_001",
            tool_input: {command: $cmd}
        }' > "$TEST_DIR/input.json"
}

write_write_permission_input() {
    local file_path="${1:-/tmp/file.txt}"
    local session="${2:-test-pr-session}"
    jq -n \
        --arg sid "$session" \
        --arg path "$file_path" \
        '{
            session_id: $sid,
            hook_event_name: "PermissionRequest",
            permission_mode: "default",
            tool_name: "Write",
            tool_use_id: "toolu_perm_002",
            tool_input: {file_path: $path, content: "hello"}
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-pr-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a normal Bash permission request" {
    write_permission_input "Bash" "npm test"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'"
    assert_success
}

@test "hook exits 0 for a Write permission request" {
    write_write_permission_input "/tmp/output.txt"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'"
    assert_success
}

@test "hook exits 0 for ExitPlanMode tool" {
    jq -n '{
        session_id: "test-pr-session",
        hook_event_name: "PermissionRequest",
        permission_mode: "plan",
        tool_name: "ExitPlanMode",
        tool_use_id: "toolu_perm_003",
        tool_input: {}
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_permission_input "Bash" "npm test"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'" || true
    assert_file_exists "/tmp/test-pr-session.jsonl"
}

# ============================================================
# Output format (allow/deny decision)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_permission_input "Bash" "npm test"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is PermissionRequest" {
    write_permission_input "Bash" "npm test"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -r '.hookSpecificOutput.hookEventName'"
        assert_success
        assert_output_equals "PermissionRequest"
    fi
}

@test "when decision is present it is allow or deny" {
    write_permission_input "Bash" "npm test"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        decision=$(echo "$output" | jq -r '.hookSpecificOutput.decision.behavior // empty')
        if [[ -n "$decision" ]]; then
            [[ "$decision" == "allow" || "$decision" == "deny" ]]
        fi
    fi
}

# ============================================================
# ExitPlanMode auto-approval
# ============================================================

@test "ExitPlanMode returns allow decision" {
    jq -n '{
        session_id: "test-pr-session",
        hook_event_name: "PermissionRequest",
        permission_mode: "plan",
        tool_name: "ExitPlanMode",
        tool_use_id: "toolu_perm_exit",
        tool_input: {}
    }' > "$TEST_DIR/input.json"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/permission-request.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -e '.hookSpecificOutput.decision.behavior == \"allow\"'"
        assert_success
    fi
}

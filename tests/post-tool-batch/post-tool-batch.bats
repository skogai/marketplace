#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_tool_batch_input() {
    local session="${1:-test-ptb-session}"
    jq -n \
        --arg sid "$session" \
        '{
            session_id: $sid,
            hook_event_name: "PostToolBatch",
            permission_mode: "default",
            tool_uses: [
                {
                    tool_name: "Bash",
                    tool_use_id: "toolu_001",
                    tool_input: {command: "git status"},
                    tool_result: {output: "nothing to commit", exit_code: 0}
                },
                {
                    tool_name: "Read",
                    tool_use_id: "toolu_002",
                    tool_input: {file_path: "README.md"},
                    tool_result: {content: "# Project"}
                }
            ]
        }' > "$TEST_DIR/input.json"
}

write_single_tool_batch_input() {
    local tool="${1:-Bash}"
    local session="${2:-test-ptb-session}"
    jq -n \
        --arg sid "$session" \
        --arg tool "$tool" \
        '{
            session_id: $sid,
            hook_event_name: "PostToolBatch",
            permission_mode: "default",
            tool_uses: [{
                tool_name: $tool,
                tool_use_id: "toolu_single",
                tool_input: {command: "echo hi"},
                tool_result: {output: "hi", exit_code: 0}
            }]
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-ptb-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a normal tool batch" {
    write_tool_batch_input
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'"
    assert_success
}

@test "hook exits 0 for a single-tool batch" {
    write_single_tool_batch_input "Bash"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'"
    assert_success
}

@test "hook exits 0 or 2 — never other codes" {
    write_tool_batch_input
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'"
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

@test "hook exits 0 with empty tool_uses array" {
    jq -n '{
        session_id: "test-ptb-session",
        hook_event_name: "PostToolBatch",
        permission_mode: "default",
        tool_uses: []
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_tool_batch_input
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'" || true
    assert_file_exists "/tmp/test-ptb-session.jsonl"
}

@test "session log contains PostToolBatch event" {
    write_tool_batch_input
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'" || true
    run bash -c "grep -c 'PostToolBatch' /tmp/test-ptb-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional block to stop agentic loop)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_tool_batch_input
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when decision block is present reason field exists" {
    write_tool_batch_input
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-batch.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        decision=$(echo "$output" | jq -r '.decision // empty')
        if [[ "$decision" == "block" ]]; then
            run bash -c "echo '$output' | jq -e '.reason != null'"
            assert_success
        fi
    fi
}

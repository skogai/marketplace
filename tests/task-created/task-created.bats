#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_task_created_input() {
    local task_id="${1:-task-001}"
    local subject="${2:-Implement feature X}"
    local session="${3:-test-tc-session}"
    jq -n \
        --arg sid "$session" \
        --arg id "$task_id" \
        --arg subj "$subject" \
        '{
            session_id: $sid,
            hook_event_name: "TaskCreated",
            task_id: $id,
            task_subject: $subj
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-tc-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a normal task" {
    write_task_created_input "task-001" "Write tests"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'"
    assert_success
}

@test "hook exits 0 with missing task_subject" {
    jq -n '{session_id: "test-tc-session", hook_event_name: "TaskCreated", task_id: "task-002"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'"
    assert_success
}

@test "hook exits 0 or 2 — never other codes" {
    write_task_created_input "task-003" "Deploy to prod"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'"
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_task_created_input "task-001" "Write tests"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'" || true
    assert_file_exists "/tmp/test-tc-session.jsonl"
}

@test "session log contains task_id" {
    write_task_created_input "task-001" "Write tests"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'" || true
    run bash -c "grep -c 'task-001' /tmp/test-tc-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional block decision)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_task_created_input "task-001" "Write tests"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when decision block is present reason field exists" {
    write_task_created_input "task-001" "Write tests"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/task-created.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        decision=$(echo "$output" | jq -r '.decision // empty')
        if [[ "$decision" == "block" ]]; then
            run bash -c "echo '$output' | jq -e '.reason != null'"
            assert_success
        fi
    fi
}

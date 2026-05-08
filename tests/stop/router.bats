#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

setup() {
    setup_test_dir
    setup_git_repo

    export INPUT_FILE="$TEST_DIR/input.json"
    cat > "$INPUT_FILE" <<'EOF'
{
  "session_id": "test-session-123",
  "transcript_path": "/tmp/fake-transcript.jsonl",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": false
}
EOF
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-session-123.jsonl
}

@test "dirty repo passes through git-dirty output" {
    echo "dirty" > untracked.txt
    run bash -c "cat '$INPUT_FILE' | '$HOOKS_DIR/stop.sh'"
    assert_success
    assert_output_contains "uncommitted changes"
}

@test "logs input to session jsonl" {
    run bash -c "cat '$INPUT_FILE' | '$HOOKS_DIR/stop.sh'"
    assert_success
    assert_file_exists "/tmp/test-session-123.jsonl"
}

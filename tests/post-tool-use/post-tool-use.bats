#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_post_tool_input() {
  local tool_name="${1:-Bash}"
  local tool_use_id="${2:-toolu_123}"
  jq -n \
    --arg sid "test-post-tool-session" \
    --arg tool "$tool_name" \
    --arg tuid "$tool_use_id" \
    '{
      session_id: $sid,
      hook_event_name: "PostToolUse",
      tool_name: $tool,
      tool_use_id: $tuid
    }' > "$TEST_DIR/input.json"
}

setup() {
  setup_test_dir
}

teardown() {
  teardown_test_dir
  rm -f /tmp/test-post-tool-session.jsonl
}

@test "post-tool-use appends durable progress entry" {
  write_post_tool_input "Read" "toolu_abc"
  run env SKOGAI_WORKFLOW_DIR="$TEST_DIR/workflow" bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use.sh'"
  assert_success

  assert_file_exists "$TEST_DIR/workflow/tasks-progress.md"

  run bash -c "grep -q 'tool=Read' '$TEST_DIR/workflow/tasks-progress.md'"
  assert_success

  run bash -c "grep -q 'tool_use_id=toolu_abc' '$TEST_DIR/workflow/tasks-progress.md'"
  assert_success
}

@test "missing tool_use_id still appends valid progress line" {
  jq -n '{session_id:"test-post-tool-session",hook_event_name:"PostToolUse",tool_name:"Bash"}' > "$TEST_DIR/input.json"

  run env SKOGAI_WORKFLOW_DIR="$TEST_DIR/workflow" bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-tool-use.sh'"
  assert_success

  run bash -c "grep -q 'tool=Bash' '$TEST_DIR/workflow/tasks-progress.md'"
  assert_success

  run bash -c "grep -q 'tool_use_id=none' '$TEST_DIR/workflow/tasks-progress.md'"
  assert_success
}

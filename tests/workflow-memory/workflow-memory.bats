#!/usr/bin/env bats

load ../test-helper

SCRIPTS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"

setup() {
  setup_test_dir
}

teardown() {
  teardown_test_dir
}

@test "workflow init creates all required artifacts" {
  run bash -c "
    export SKOGAI_WORKFLOW_DIR='$TEST_DIR/workflow'
    source '$SCRIPTS_DIR/workflow-memory.sh'
    skogai_workflow_init
    test -f \"$TEST_DIR/workflow/tasks-progress.md\"
    test -f \"$TEST_DIR/workflow/research-notes.md\"
    test -f \"$TEST_DIR/workflow/decisions-results.md\"
  "
  assert_success
}

@test "tasks-progress includes required workflow labels" {
  run bash -c "
    export SKOGAI_WORKFLOW_DIR='$TEST_DIR/workflow'
    source '$SCRIPTS_DIR/workflow-memory.sh'
    skogai_workflow_init
    grep -q 'Current Step:' '$TEST_DIR/workflow/tasks-progress.md'
    grep -q 'Remaining Steps:' '$TEST_DIR/workflow/tasks-progress.md'
    grep -q 'Completion Target:' '$TEST_DIR/workflow/tasks-progress.md'
  "
  assert_success
}

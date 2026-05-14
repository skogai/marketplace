#!/usr/bin/env bats

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)/setup.sh"
F="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
TEST_HELPER="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../../tests/test_helper" && pwd)"
LOG="/tmp/test-setup-session.jsonl"

setup() {
    load "$TEST_HELPER/bats-support/load"
    load "$TEST_HELPER/bats-file/load"
    load "$TEST_HELPER/bats-assert/load"
    rm -f "$LOG"
}

teardown() { rm -f "$LOG"; }

@test "trigger init outputs setup context" {
    run bash "$HOOK" <"$F/init.json"
    assert_success
    assert_output --partial "skogai-core initialised."
}

@test "trigger maintenance outputs setup context" {
    run bash "$HOOK" <"$F/maintenance.json"
    assert_success
    assert_output --partial "skogai-core maintenance run."
}

@test "unknown trigger produces no output" {
    run bash -c "jq -n '{session_id: \"test-setup-session\", hook_event_name: \"Setup\", cwd: \"/tmp/test-project\", trigger: \"unknown\"}' | bash '$HOOK'"
    assert_success
    assert_output ""
}

@test "trigger init writes log entry" {
    bash "$HOOK" <"$F/init.json"
    assert_file_exist "$LOG"
}

@test "trigger init log summary contains trigger value" {
    bash "$HOOK" <"$F/init.json"
    summary=$(tail -1 "$LOG" | jq -r '.summary')
    assert_equal "$summary" "Setup: trigger=init cwd=/tmp/test-project"
}

@test "trigger init log entry contains env block" {
    bash "$HOOK" <"$F/init.json"
    env_type=$(tail -1 "$LOG" | jq -r '.env | type')
    assert_equal "$env_type" "object"
}

#!/usr/bin/env bats

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hooks" && pwd)/debug.sh"
F="$(cd "$(dirname "$BATS_TEST_FILENAME")/debug" && pwd)"

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-file/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/skogai-jq/load'
}

teardown() { rm -f "$HOOK_LOG"; }

@test "empty input: session_id defaults to 'unknown'" {
    assert_equal "$HOOK_SESSION_ID" "unknown"
}

@test "empty input: running debug.sh creates log file" {
    run bash "$HOOK" <"$F/empty.json"
    assert_success
    assert_file_exist "$HOOK_LOG"
}

@test "empty input: log entry has session_id 'unknown'" {
    bash "$HOOK" <"$F/empty.json"
    session_id=$(tail -1 "$HOOK_LOG" | jq -r '.session_id')
    assert_equal "$session_id" "unknown"
}

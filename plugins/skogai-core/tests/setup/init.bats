#!/bin/bash

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load '../scripts/skogai-jq.sh'
    skogai_jq_log "mytest"
}

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hooks" && pwd)/debug.sh"
F="$(cd "$(dirname "$BATS_TEST_FILENAME")/debug" && pwd)"

teardown() { rm -f /tmp/${HOOK_LOG}.jsonl; }

@test "empty input" {
    # load "../scripts/skogai-jq.sh"
    # run bash "$HOOK" <"$F/empty.json"
    # assert_success
    # session_id=$(tail -1 /tmp/unknown.jsonl | jq -r '.session_id')
    run bash "$HOOK"
    assert_equal "$HOOK_INPUT" "{}"
}

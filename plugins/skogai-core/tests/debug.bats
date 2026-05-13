#!/bin/bash

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-file/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/skogai-jq/load'
}

@test "test" {
    run echo test
    assert_output "test"
}
@test "empty input writes session_id 'unknown' to log" {
    [ "$HOOK_SESSION_ID" = "unknown" ]
}

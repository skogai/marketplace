#!/bin/bash

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-file/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/skogai-jq/load'
}

@test "test" {

    assert_equal "$HOOK_SESSION_ID" "unknown"
}

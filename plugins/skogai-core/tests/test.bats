#!/bin/bash

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-file/load'
    load 'test_helper/bats-assert/load'
}

@test "test" {
    run echo test
    assert_output "test"
}

@test "fail" {
    fail "lol"
}

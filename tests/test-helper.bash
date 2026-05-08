#!/bin/bash

# portable test helpers for bats tests
# source this in your test files: load ../testing-framework/test-helper

# get the project root directory
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS_DIR="${SCRIPTS_DIR:-$PROJECT_ROOT/scripts}"

# create a temporary directory for test files
setup_test_dir() {
    export TEST_DIR="$(mktemp -d -t test.XXXXXX)"
    cd "$TEST_DIR" || exit 1
}

# clean up test directory
teardown_test_dir() {
    if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# source a script without executing its main code
# usage: source_script "script-name.sh"
source_script() {
    local script="$1"
    SOURCING_FOR_TESTS=1 source "$SCRIPTS_DIR/$script" "test-mode" 2>/dev/null || true
}

# create a mock git repository
setup_git_repo() {
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    # Disable commit signing for throwaway test repos so tests pass in
    # environments that enforce signed commits (e.g. CI with custom gpg programs).
    git config commit.gpgsign false
    echo "test" > test.txt
    git add test.txt
    git commit -m "Initial commit" --quiet
}

# assert that a command succeeds
assert_success() {
    if [[ "$status" -ne 0 ]]; then
        echo "Command failed with status $status"
        echo "Output: $output"
        return 1
    fi
}

# assert that a command fails
assert_failure() {
    if [[ "$status" -eq 0 ]]; then
        echo "Command succeeded but should have failed"
        echo "Output: $output"
        return 1
    fi
}

# assert output contains a string
assert_output_contains() {
    local expected="$1"
    if [[ "$output" != *"$expected"* ]]; then
        echo "Output does not contain expected string"
        echo "Expected: $expected"
        echo "Actual: $output"
        return 1
    fi
}

# assert output does not contain a string
assert_output_not_contains() {
    local unexpected="$1"
    if [[ "$output" == *"$unexpected"* ]]; then
        echo "Output contains unexpected string"
        echo "Unexpected: $unexpected"
        echo "Actual: $output"
        return 1
    fi
}

# assert output equals expected string
assert_output_equals() {
    local expected="$1"
    if [[ "$output" != "$expected" ]]; then
        echo "Output does not match expected"
        echo "Expected: $expected"
        echo "Actual: $output"
        return 1
    fi
}

# assert file exists
assert_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "File does not exist: $file"
        return 1
    fi
}

# assert directory exists
assert_dir_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir"
        return 1
    fi
}

# skip test if command not available
skip_if_missing() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        skip "$cmd is not installed"
    fi
}

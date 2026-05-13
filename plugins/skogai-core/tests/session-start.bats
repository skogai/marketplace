#!/usr/bin/env bats

load test-helper

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hooks" && pwd)/session-start.sh"
F="$(cd "$(dirname "$BATS_TEST_FILENAME")/session-start" && pwd)"

setup()    { setup_test_dir; }
teardown() { teardown_test_dir; rm -f /tmp/test-ss-session.jsonl; }

@test "source startup injects Bootstrap complete" {
    run bash -c "cat '$F/source-startup-injects-ootstrap-complete.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"Bootstrap complete."* ]]
}

@test "source resume injects Bootstrap complete" {
    run bash -c "cat '$F/source-resume-injects-ootstrap-complete.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"Bootstrap complete."* ]]
}

@test "source compact injects Bootstrap complete" {
    run bash -c "cat '$F/source-compact-injects-ootstrap-complete.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"Bootstrap complete."* ]]
}

@test "cwd is injected into LESSON_DIRS" {
    run bash -c "cat '$F/cwd-is-injected-into-.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"LESSON_DIRS=/tmp/test-project/tests/lessons"* ]]
}

@test "cwd is injected into PATH includes" {
    run bash -c "cat '$F/cwd-is-injected-into--includes.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"PATH includes /tmp/test-project/.skogai/tmp/bin"* ]]
}

@test "missing cwd uses UNKNOWN_CWD sentinel in LESSON_DIRS" {
    run bash -c "cat '$F/missing-cwd-uses--sentinel-in-.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"LESSON_DIRS=UNKNOWN_CWD/tests/lessons"* ]]
}

@test "missing cwd uses UNKNOWN_CWD sentinel in PATH" {
    run bash -c "cat '$F/missing-cwd-uses--sentinel-in-.json' | bash '$HOOK' 2>/dev/null"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"PATH includes UNKNOWN_CWD/.skogai/tmp/bin"* ]]
}

@test "log entry is written to session log file" {
    bash -c "cat '$F/log-entry-is-written-to-session-log-file.json' | bash '$HOOK' 2>/dev/null" >/dev/null
    [ -f /tmp/test-ss-session.jsonl ]
}

@test "log entry contains env block" {
    bash -c "cat '$F/log-entry-contains-env-block.json' | bash '$HOOK' 2>/dev/null" >/dev/null
    env_block=$(tail -1 /tmp/test-ss-session.jsonl | jq '.env')
    [ "$env_block" != "null" ]
}

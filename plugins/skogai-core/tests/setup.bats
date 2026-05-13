#!/usr/bin/env bats

load test-helper

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hooks" && pwd)/setup.sh"

write_input() {
    local trigger="$1"
    jq -n --arg trigger "$trigger" '{
        session_id:      "test-setup-session",
        hook_event_name: "Setup",
        cwd:             "/tmp/test-project",
        trigger:         $trigger
    }' > "$TEST_DIR/input.json"
}

setup()    { setup_test_dir; }
teardown() { teardown_test_dir; rm -f /tmp/test-setup-session.jsonl; }

# --- trigger: init ---

@test "trigger init outputs hookEventName Setup" {
    write_input "init"
    run bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.hookEventName')
    [ "$ctx" = "Setup" ]
}

@test "trigger init outputs additionalContext containing 'initialised'" {
    write_input "init"
    run bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"initialised"* ]]
}

# --- trigger: maintenance ---

@test "trigger maintenance outputs hookEventName Setup" {
    write_input "maintenance"
    run bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.hookEventName')
    [ "$ctx" = "Setup" ]
}

@test "trigger maintenance outputs additionalContext containing 'maintenance'" {
    write_input "maintenance"
    run bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"maintenance"* ]]
}

# --- debug log ---

@test "trigger init writes a log entry to /tmp/<session_id>.jsonl" {
    write_input "init"
    run bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'"
    [ -f /tmp/test-setup-session.jsonl ]
}

@test "log entry records the trigger value" {
    write_input "init"
    bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'" >/dev/null
    summary=$(tail -1 /tmp/test-setup-session.jsonl | jq -r '.summary')
    [[ "$summary" == *"trigger=init"* ]]
}

@test "log entry contains env block" {
    write_input "init"
    bash -c "cat '$TEST_DIR/input.json' | bash '$HOOK'" >/dev/null
    env_block=$(tail -1 /tmp/test-setup-session.jsonl | jq '.env')
    [ "$env_block" != "null" ]
}

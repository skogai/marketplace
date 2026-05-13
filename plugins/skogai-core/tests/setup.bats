#!/usr/bin/env bats

load test-helper

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hooks" && pwd)/setup.sh"
F="$(cd "$(dirname "$BATS_TEST_FILENAME")/setup" && pwd)"

setup()    { setup_test_dir; }
teardown() { teardown_test_dir; rm -f /tmp/test-setup-session.jsonl; }

@test "trigger init outputs additionalContext containing initialised" {
    run bash -c "cat '$F/trigger-init-outputs-additionalontext-containing-initialised.json' | bash '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"initialised"* ]]
}

@test "trigger maintenance outputs additionalContext containing maintenance" {
    run bash -c "cat '$F/trigger-maintenance-outputs-additionalontext-containing-maintenance.json' | bash '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"maintenance"* ]]
}

@test "unknown trigger produces no output" {
    run bash -c "cat '$F/unknown-trigger-produces-no-output.json' | bash '$HOOK'"
    [ -z "$output" ]
}

@test "trigger init writes log entry" {
    bash -c "cat '$F/trigger-init-writes-log-entry.json' | bash '$HOOK'" >/dev/null
    [ -f /tmp/test-setup-session.jsonl ]
}

@test "trigger init log summary contains trigger value" {
    bash -c "cat '$F/trigger-init-log-summary-contains-trigger-value.json' | bash '$HOOK'" >/dev/null
    summary=$(tail -1 /tmp/test-setup-session.jsonl | jq -r '.summary')
    [[ "$summary" == *"trigger=init"* ]]
}

@test "trigger init log entry contains env block" {
    bash -c "cat '$F/trigger-init-log-entry-contains-env-block.json' | bash '$HOOK'" >/dev/null
    env_block=$(tail -1 /tmp/test-setup-session.jsonl | jq '.env')
    [ "$env_block" != "null" ]
}

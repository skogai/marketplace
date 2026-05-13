#!/usr/bin/env bats

load test-helper

HOOK="$SKOGAI_HOOK_DIR/debug.sh"
F="$(cd "$(dirname "$BATS_TEST_FILENAME")/debug" && pwd)"

teardown() { teardown_logs; }

@test "empty input writes session_id 'unknown' to log" {
    run bash "$HOOK" <"$F/empty.json"
    session_id=$(tail -1 "$HOOK_LOG" | jq -r '.session_id')
    [ "$session_id" = "unknown" ]
}

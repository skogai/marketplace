#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_elicitation_result_input() {
    local request_id="${1:-elicit-001}"
    local result="${2:-production}"
    local session="${3:-test-elicitr-session}"
    jq -n \
        --arg sid "$session" \
        --arg rid "$request_id" \
        --arg result "$result" \
        '{
            session_id: $sid,
            hook_event_name: "ElicitationResult",
            request_id: $rid,
            result: $result
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-elicitr-session.jsonl
}

# ============================================================
# Exit code (cannot modify result after-the-fact)
# ============================================================

@test "hook exits 0 for a normal result" {
    write_elicitation_result_input "elicit-001" "production"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation-result.sh'"
    assert_success
}

@test "hook exits 0 for an empty result" {
    write_elicitation_result_input "elicit-002" ""
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation-result.sh'"
    assert_success
}

@test "hook exits 0 with missing result field" {
    jq -n '{
        session_id: "test-elicitr-session",
        hook_event_name: "ElicitationResult",
        request_id: "elicit-003"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation-result.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_elicitation_result_input "elicit-001" "production"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation-result.sh'" || true
    assert_file_exists "/tmp/test-elicitr-session.jsonl"
}

@test "session log contains request_id" {
    write_elicitation_result_input "elicit-999" "staging"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation-result.sh'" || true
    run bash -c "grep -c 'elicit-999' /tmp/test-elicitr-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_elicitation_result_input "elicit-001" "production"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation-result.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

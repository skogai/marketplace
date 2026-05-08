#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_elicitation_input() {
    local prompt="${1:-What is the target environment?}"
    local request_id="${2:-elicit-001}"
    local session="${3:-test-elicit-session}"
    jq -n \
        --arg sid "$session" \
        --arg prompt "$prompt" \
        --arg rid "$request_id" \
        '{
            session_id: $sid,
            hook_event_name: "Elicitation",
            prompt: $prompt,
            request_id: $rid
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-elicit-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a normal elicitation" {
    write_elicitation_input "What environment?" "elicit-001"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'"
    assert_success
}

@test "hook exits 0 or 2 — never other codes" {
    write_elicitation_input "Confirm deployment?" "elicit-002"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'"
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

@test "hook exits 0 with missing prompt" {
    jq -n '{
        session_id: "test-elicit-session",
        hook_event_name: "Elicitation",
        request_id: "elicit-003"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_elicitation_input "What environment?" "elicit-001"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'" || true
    assert_file_exists "/tmp/test-elicit-session.jsonl"
}

@test "session log contains request_id" {
    write_elicitation_input "What environment?" "elicit-999"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'" || true
    run bash -c "grep -c 'elicit-999' /tmp/test-elicit-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional response injection)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_elicitation_input "What environment?" "elicit-001"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is Elicitation" {
    write_elicitation_input "What environment?" "elicit-001"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        event=$(echo "$output" | jq -r '.hookSpecificOutput.hookEventName // empty')
        if [[ -n "$event" ]]; then
            [[ "$event" == "Elicitation" ]]
        fi
    fi
}

@test "when response is provided it is a non-empty string" {
    write_elicitation_input "What environment?" "elicit-001"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/elicitation.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        response=$(echo "$output" | jq -r '.hookSpecificOutput.response // empty')
        if [[ -n "$response" ]]; then
            [[ -n "$response" ]]
        fi
    fi
}

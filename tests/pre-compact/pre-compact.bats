#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_pre_compact_input() {
    local trigger="${1:-manual}"
    local session="${2:-test-precomp-session}"
    jq -n \
        --arg sid "$session" \
        --arg trigger "$trigger" \
        '{
            session_id: $sid,
            hook_event_name: "PreCompact",
            trigger: $trigger,
            custom_instructions: ""
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-precomp-session.jsonl
}

# ============================================================
# Exit code (cannot block compaction)
# ============================================================

@test "hook exits 0 for manual trigger" {
    write_pre_compact_input "manual"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'"
    assert_success
}

@test "hook exits 0 for auto trigger" {
    write_pre_compact_input "auto"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'"
    assert_success
}

@test "hook exits 0 with missing trigger" {
    jq -n '{session_id: "test-precomp-session", hook_event_name: "PreCompact"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_pre_compact_input "manual"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'" || true
    assert_file_exists "/tmp/test-precomp-session.jsonl"
}

@test "session log contains trigger value" {
    write_pre_compact_input "auto"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'" || true
    run bash -c "grep -c 'auto' /tmp/test-precomp-session.jsonl"
    assert_success
}

# ============================================================
# Output format (optional context injection)
# ============================================================

@test "when output is produced it is valid JSON" {
    write_pre_compact_input "manual"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is PreCompact" {
    write_pre_compact_input "manual"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/pre-compact.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        event=$(echo "$output" | jq -r '.hookSpecificOutput.hookEventName // empty')
        if [[ -n "$event" ]]; then
            [[ "$event" == "PreCompact" ]]
        fi
    fi
}

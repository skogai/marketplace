#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_post_compact_input() {
    local trigger="${1:-manual}"
    local session="${2:-test-postcomp-session}"
    jq -n \
        --arg sid "$session" \
        --arg trigger "$trigger" \
        '{
            session_id: $sid,
            hook_event_name: "PostCompact",
            trigger: $trigger,
            summary: "Compacted 42 messages into 3 summary blocks"
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-postcomp-session.jsonl
}

# ============================================================
# Exit code (cannot block after-the-fact)
# ============================================================

@test "hook exits 0 for manual trigger" {
    write_post_compact_input "manual"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-compact.sh'"
    assert_success
}

@test "hook exits 0 for auto trigger" {
    write_post_compact_input "auto"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-compact.sh'"
    assert_success
}

@test "hook exits 0 with missing trigger" {
    jq -n '{session_id: "test-postcomp-session", hook_event_name: "PostCompact"}' \
        > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-compact.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_post_compact_input "manual"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-compact.sh'" || true
    assert_file_exists "/tmp/test-postcomp-session.jsonl"
}

@test "session log contains PostCompact event" {
    write_post_compact_input "manual"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-compact.sh'" || true
    run bash -c "grep -c 'PostCompact' /tmp/test-postcomp-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_post_compact_input "manual"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/post-compact.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

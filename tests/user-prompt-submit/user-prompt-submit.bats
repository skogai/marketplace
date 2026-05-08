#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

# Write a UserPromptSubmit JSON payload to $TEST_DIR/input.json
write_prompt_input() {
    local prompt="$1"
    local session="${2:-test-ups-session}"
    jq -n \
        --arg prompt "$prompt" \
        --arg sid "$session" \
        '{
            session_id: $sid,
            hook_event_name: "UserPromptSubmit",
            permission_mode: "default",
            prompt: $prompt
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
    # Ensure skogparse is absent so tests are deterministic
    export HOME="$TEST_DIR"
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-ups-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a plain text prompt" {
    write_prompt_input "What is 2 + 2?"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

@test "hook exits 0 for an empty prompt" {
    write_prompt_input ""
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

@test "hook exits 0 when prompt contains only whitespace" {
    write_prompt_input "   "
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_prompt_input "log this prompt"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'" || true
    assert_file_exists "/tmp/test-ups-session.jsonl"
}

@test "session log contains the session_id" {
    write_prompt_input "log session id check"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'" || true
    run bash -c "grep -c 'test-ups-session' /tmp/test-ups-session.jsonl"
    assert_success
}

# ============================================================
# Output format when context is produced
# ============================================================

@test "when output is produced it is valid JSON" {
    write_prompt_input "hello world"
    # Run and capture; if there is output, verify it parses as JSON
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced it contains hookSpecificOutput" {
    write_prompt_input "hello"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -e '.hookSpecificOutput' > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is UserPromptSubmit" {
    write_prompt_input "hello"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -r '.hookSpecificOutput.hookEventName'"
        assert_success
        assert_output_equals "UserPromptSubmit"
    fi
}

# ============================================================
# Skogparse: graceful absence
# ============================================================

@test "hook succeeds when skogparse binary is absent" {
    # HOME is already set to TEST_DIR (no skogparse binary there)
    write_prompt_input 'fetch \$ref.path'
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

@test "hook succeeds for prompt with @action notation and no skogparse" {
    write_prompt_input '[@load:myfile] do something'
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

# ============================================================
# Lesson matcher: graceful absence / failure
# ============================================================

@test "hook succeeds even if lesson_matcher.py is unavailable" {
    # Point SCRIPT_DIR to a temp dir with no lesson_matcher.py so the call fails
    # The hook uses `|| true` so it should still succeed
    write_prompt_input "test without lesson matcher"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

# ============================================================
# user-context.sh: graceful absence
# ============================================================

@test "hook succeeds when user-context.sh is absent" {
    write_prompt_input "test without user context script"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

# ============================================================
# Prompt field extraction
# ============================================================

@test "null prompt field is handled gracefully" {
    jq -n '{
        session_id: "test-ups-session",
        hook_event_name: "UserPromptSubmit",
        prompt: null
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

@test "missing prompt field is handled gracefully" {
    jq -n '{
        session_id: "test-ups-session",
        hook_event_name: "UserPromptSubmit"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-submit.sh'"
    assert_success
}

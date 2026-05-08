#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

write_expansion_input() {
    local command_name="${1:-my-skill}"
    local command_args="${2:-}"
    local session="${3:-test-upe-session}"
    jq -n \
        --arg sid "$session" \
        --arg cmd "$command_name" \
        --arg args "$command_args" \
        --arg prompt "/$command_name $command_args" \
        '{
            session_id: $sid,
            transcript_path: "/tmp/fake-transcript.jsonl",
            cwd: "/tmp",
            permission_mode: "default",
            hook_event_name: "UserPromptExpansion",
            expansion_type: "slash_command",
            command_name: $cmd,
            command_args: $args,
            command_source: "plugin",
            prompt: $prompt
        }' > "$TEST_DIR/input.json"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-upe-session.jsonl
}

# ============================================================
# Exit code
# ============================================================

@test "hook exits 0 for a plain skill expansion" {
    write_expansion_input "my-skill" "some-arg"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'"
    assert_success
}

@test "hook exits 0 with empty command args" {
    write_expansion_input "my-skill" ""
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'"
    assert_success
}

@test "hook exits 0 for mcp_prompt expansion type" {
    jq -n '{
        session_id: "test-upe-session",
        hook_event_name: "UserPromptExpansion",
        expansion_type: "mcp_prompt",
        command_name: "my-mcp-prompt",
        command_args: "",
        command_source: "mcp",
        prompt: "/my-mcp-prompt"
    }' > "$TEST_DIR/input.json"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'"
    assert_success
}

# ============================================================
# Session logging
# ============================================================

@test "hook writes input to session JSONL log" {
    write_expansion_input "my-skill"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'" || true
    assert_file_exists "/tmp/test-upe-session.jsonl"
}

@test "session log contains command_name" {
    write_expansion_input "my-skill"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'" || true
    run bash -c "grep -c 'my-skill' /tmp/test-upe-session.jsonl"
    assert_success
}

# ============================================================
# Output format
# ============================================================

@test "when output is produced it is valid JSON" {
    write_expansion_input "my-skill"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq . > /dev/null"
        assert_success
    fi
}

@test "when output is produced hookEventName is UserPromptExpansion" {
    write_expansion_input "my-skill"
    output=$(bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
        run bash -c "echo '$output' | jq -r '.hookSpecificOutput.hookEventName'"
        assert_success
        assert_output_equals "UserPromptExpansion"
    fi
}

# ============================================================
# Blocking
# ============================================================

@test "hook can block an expansion with exit 2" {
    # Hook may choose to block; when blocked stderr is shown to user
    write_expansion_input "blocked-skill"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOKS_DIR/user-prompt-expansion.sh'"
    # Either allowed (0) or blocked (2) is valid; anything else is a bug
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

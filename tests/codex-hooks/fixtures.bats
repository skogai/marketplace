#!/usr/bin/env bats

load ../test-helper

FIXTURES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures/codex-hooks" && pwd)"

@test "Codex hook fixtures are valid JSON" {
    run bash -c "jq -e . '$FIXTURES_DIR'/*.json >/dev/null"
    assert_success
}

@test "Codex hook fixtures cover every documented event" {
    run bash -c "jq -r '.hook_event_name' '$FIXTURES_DIR'/*.json | sort | paste -sd ',' -"
    assert_success
    assert_output_equals "PermissionRequest,PostCompact,PostToolUse,PreCompact,PreToolUse,SessionStart,Stop,UserPromptSubmit"
}

@test "Codex hook fixtures include shared required context fields" {
    run bash -c "for file in '$FIXTURES_DIR'/*.json; do jq -e '.session_id and .cwd and .hook_event_name and .model and .permission_mode and .transcript_path' \"\$file\" >/dev/null || exit 1; done"
    assert_success
}

@test "Codex tool fixtures include tool names and tool inputs" {
    run bash -c "jq -e '.tool_name and .tool_input' '$FIXTURES_DIR'/pre-tool-use.json '$FIXTURES_DIR'/permission-request.json '$FIXTURES_DIR'/post-tool-use.json >/dev/null"
    assert_success
}

@test "Codex compact fixtures distinguish pre and post compact payloads" {
    run bash -c "jq -e '.custom_instructions == \"\"' '$FIXTURES_DIR'/pre-compact.json >/dev/null && jq -e '.compact_summary | length > 0' '$FIXTURES_DIR'/post-compact.json >/dev/null"
    assert_success
}

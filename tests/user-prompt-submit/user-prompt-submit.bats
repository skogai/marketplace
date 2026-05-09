#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"
HOOK="$HOOKS_DIR/user-prompt-submit.sh"

write_prompt_input() {
    local prompt="$1"
    jq -n --arg prompt "$prompt" '{
        session_id: "test-ups-session",
        hook_event_name: "UserPromptSubmit",
        transcript_path: "/tmp/test-ups-session.jsonl",
        prompt: $prompt,
        cwd: "/tmp",
        permission_mode: "default"
    }' > "$TEST_DIR/input.json"
}

setup_lesson_dir() {
    local dir="$TEST_DIR/lessons"
    mkdir -p "$dir"

    cat > "$dir/git-workflow.md" <<'EOF'
---
match:
  keywords: [git, commit, workflow]
version: 1
status: active
---
# git workflow best practices

## Rule
Stage and commit only the files that belong to the current change.
EOF

    cat > "$dir/docker.md" <<'EOF'
---
match:
  keywords: [docker, container, image]
version: 1
status: active
---
# docker best practices

## Rule
Never run containers as root.
EOF

    cat > "$dir/deprecated-git.md" <<'EOF'
---
match:
  keywords: [git, commit]
status: deprecated
---
# Old Git Lesson

## Rule
This should never appear in output.
EOF

    export LESSON_DIRS="$dir"
}

setup() {
    setup_test_dir
    unset LESSON_DIRS
}

teardown() {
    teardown_test_dir
    rm -f /tmp/test-ups-session.jsonl
    unset LESSON_DIRS
}

# ============================================================
# Content selection: right lesson body reaches the output
# ============================================================

@test "prompt 'build a docker container image' injects docker lesson body" {
    setup_lesson_dir
    write_prompt_input "build a docker container image"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"Never run containers as root"* ]]
}

@test "prompt 'build a docker container image' does not inject git lesson body" {
    setup_lesson_dir
    write_prompt_input "build a docker container image"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" != *"Stage and commit only the files"* ]]
}

# ============================================================
# Filtering: deprecated lessons never reach the output
# ============================================================

@test "prompt matching deprecated lesson keywords produces no deprecated content" {
    setup_lesson_dir
    write_prompt_input "git commit my changes"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" != *"This should never appear in output"* ]]
}

# ============================================================
# Multi-lesson output: both bodies present, separated
# ============================================================

@test "prompt matching two lessons includes both bodies and a separator" {
    local dir="$TEST_DIR/multi"
    mkdir -p "$dir"
    cat > "$dir/alpha.md" <<'EOF'
---
match:
  keywords: [alpha]
status: active
---
# Alpha

## Rule
Alpha rule body.
EOF
    cat > "$dir/beta.md" <<'EOF'
---
match:
  keywords: [alpha, beta]
status: active
---
# Beta

## Rule
Beta rule body.
EOF
    export LESSON_DIRS="$dir"
    write_prompt_input "alpha beta"
    run bash -c "cat '$TEST_DIR/input.json' | '$HOOK'"
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"Alpha rule body"* ]]
    [[ "$ctx" == *"Beta rule body"* ]]
    [[ "$ctx" == *"---"* ]]
}

# ============================================================
# Session log: full input including transcript_path is persisted
# ============================================================

@test "session log contains transcript_path from input" {
    write_prompt_input "hello"
    bash -c "cat '$TEST_DIR/input.json' | '$HOOK'" || true
    logged=$(jq -r '.transcript_path' /tmp/test-ups-session.jsonl)
    [ "$logged" = "/tmp/test-ups-session.jsonl" ]
}

#!/usr/bin/env bats

load ../test-helper

HOOKS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../hooks" && pwd)"

setup() {
    setup_test_dir
    setup_git_repo
}

teardown() {
    # Remove any worktrees created by tests before deleting TEST_DIR
    git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}' | while read -r wt; do
        if [[ "$wt" != "$(git rev-parse --show-toplevel 2>/dev/null)" ]]; then
            git worktree remove "$wt" --force 2>/dev/null || true
        fi
    done
    teardown_test_dir
    rm -f /tmp/unknown.jsonl
}

# ============================================================
# worktree-create.sh
# ============================================================

@test "worktree-create exits 0 when creating a new branch worktree" {
    local wt_path="$TEST_DIR/wt-feature"
    jq -n \
        --arg path "$wt_path" \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeCreate",
            worktree_path: $path,
            branch: "feature/test-branch"
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-create.sh'"
    assert_success
}

@test "worktree-create creates the worktree directory" {
    local wt_path="$TEST_DIR/wt-new"
    jq -n \
        --arg path "$wt_path" \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeCreate",
            worktree_path: $path,
            branch: "feature/new-branch"
        }' | bash -c "cat | '$HOOKS_DIR/worktree-create.sh'"
    assert_dir_exists "$wt_path"
}

@test "worktree-create exits 0 with empty worktree_path (no-op)" {
    jq -n \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeCreate",
            worktree_path: "",
            branch: ""
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-create.sh'"
    assert_success
}

@test "worktree-create exits 0 when worktree_path is missing from input" {
    jq -n \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeCreate"
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-create.sh'"
    assert_success
}

@test "worktree-create logs to session JSONL file" {
    local wt_path="$TEST_DIR/wt-log"
    jq -n \
        --arg path "$wt_path" \
        '{
            session_id: "test-wt-log-session",
            hook_event_name: "WorktreeCreate",
            worktree_path: $path,
            branch: "feature/log-branch"
        }' | bash -c "cat | '$HOOKS_DIR/worktree-create.sh'" || true
    assert_file_exists "/tmp/test-wt-log-session.jsonl"
}

# ============================================================
# worktree-remove.sh
# ============================================================

@test "worktree-remove exits 0 for an existing worktree" {
    local wt_path="$TEST_DIR/wt-to-remove"
    # Create the worktree first
    git worktree add "$wt_path" -b "branch-to-remove" 2>/dev/null
    jq -n \
        --arg path "$wt_path" \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeRemove",
            worktree_path: $path
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-remove.sh'"
    assert_success
}

@test "worktree-remove removes the worktree directory" {
    local wt_path="$TEST_DIR/wt-remove-check"
    git worktree add "$wt_path" -b "branch-remove-check" 2>/dev/null
    jq -n \
        --arg path "$wt_path" \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeRemove",
            worktree_path: $path
        }' | bash -c "cat | '$HOOKS_DIR/worktree-remove.sh'"
    run bash -c "[[ ! -d '$wt_path' ]]"
    assert_success
}

@test "worktree-remove exits 0 for a non-existent worktree path (no-op)" {
    jq -n \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeRemove",
            worktree_path: "/nonexistent/path/that/does/not/exist"
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-remove.sh'"
    assert_success
}

@test "worktree-remove exits 0 with empty worktree_path" {
    jq -n \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeRemove",
            worktree_path: ""
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-remove.sh'"
    assert_success
}

@test "worktree-remove exits 0 when worktree_path is missing from input" {
    jq -n \
        '{
            session_id: "test-wt-session",
            hook_event_name: "WorktreeRemove"
        }' | run bash -c "cat | '$HOOKS_DIR/worktree-remove.sh'"
    assert_success
}

@test "worktree-remove logs to session JSONL file" {
    jq -n \
        '{
            session_id: "test-wt-rm-log",
            hook_event_name: "WorktreeRemove",
            worktree_path: "/some/path"
        }' | bash -c "cat | '$HOOKS_DIR/worktree-remove.sh'" || true
    assert_file_exists "/tmp/test-wt-rm-log.jsonl"
}

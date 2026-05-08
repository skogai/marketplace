#!/usr/bin/env bash
# WorktreeCreate hook - runs when a git worktree is being created
#
# IMPORTANT: Replaces default git worktree creation behavior entirely.
#
# Input: {session_id, hook_event_name, worktree_path, branch}
# Exit: 0 success, 2 failure

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

worktree_path=$(skogai_jq_field ".worktree_path")
branch=$(skogai_jq_field ".branch")
skogai_jq_log "Creating worktree: $worktree_path on branch: $branch"

if [[ -n "$worktree_path" && -n "$branch" ]]; then
  git worktree add "$worktree_path" -b "$branch" 2>/dev/null || \
  git worktree add "$worktree_path" "$branch"
fi

exit 0

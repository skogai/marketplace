#!/usr/bin/env bash
# WorktreeRemove hook - runs when a git worktree is being removed
#
# IMPORTANT: Replaces default git worktree removal behavior entirely.
#
# Input: {session_id, hook_event_name, worktree_path}
# Exit: 0 success, 2 failure

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

worktree_path=$(skogai_jq_field ".worktree_path")
skogai_jq_log "Removing worktree: $worktree_path"

if [[ -n "$worktree_path" ]]; then
  git worktree remove "$worktree_path" --force 2>/dev/null || true
fi

exit 0

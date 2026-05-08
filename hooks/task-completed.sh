#!/usr/bin/env bash
# TaskCompleted hook - runs when a task is being marked as completed
#
# Input: {session_id, hook_event_name, task_id, task_subject}
# Output: Optional {decision: "block", reason}
# Exit: 0 always

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

task_id=$(skogai_jq_field ".task_id" "unknown")
task_subject=$(skogai_jq_field ".task_subject" "unknown")
skogai_jq_log "Task completed: [$task_id] $task_subject"

exit 0

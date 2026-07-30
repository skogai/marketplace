---
name: hook-debugger
description: >
  Beginner-friendly guide for Claude Code hooks. Use this skill proactively
  whenever the user asks about hooks, debugging hooks, why a hook isn't working,
  how to add debugging to a hook, what input a hook receives, hook exit codes,
  how to read hook log files, or wants to understand what any hook event does.
  Also use when the user mentions PreToolUse, PostToolUse, SessionStart,
  UserPromptSubmit, Stop, SubagentStop, PreCompact, SessionEnd, Notification,
  PermissionRequest, PostToolUseFailure, SubagentStart, TeammateIdle,
  TaskCompleted, ConfigChange, WorktreeCreate, or WorktreeRemove.
---

# Hook Debugger

Hooks are shell scripts (or HTTP endpoints) that Claude Code calls automatically
at specific points in a session. Think of them as "event listeners" — you write
a script, tell Claude Code when to run it, and it passes you a JSON blob with
context. You can log it, modify it, or block things from happening.

---

## The one debugging trick you need

Every hook in the core plugin logs its input like this:

```bash
input=$(cat)                                          # read JSON from stdin
session_id=$(echo "$input" | jq -r '.session_id')    # extract session ID
log_file="/tmp/${session_id}-session-start.json"      # name the log file
echo "$input" > "$log_file"                           # write it to disk
```

After a session, inspect it:

```bash
cat /tmp/<session-id>-session-start.json | jq .
```

You can find your session ID in the log filename — list `/tmp/` and look for files
starting with a UUID. To add this to ANY hook, just put those 4 lines at the top
after `input=$(cat)`.

---

## Exit codes — the most important thing to understand

| Exit code | Meaning |
|-----------|---------|
| `0` | Success — hook ran fine |
| `2` | **Block** — stderr is shown to Claude (or the user, depending on hook). Tool/prompt is stopped. |
| anything else | Non-blocking error — stderr shown to user in verbose mode only |

**The key rule:** `exit 2` stops things. `exit 0` lets them proceed.

---

## All 18 hook events

### 1. SessionStart
**When:** Session begins or resumes.
**Can block:** No.
**Can inject context:** Yes — return `additionalContext` and it appears at session start.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "source": "startup"
}
```

Output (optional):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Today is Monday. User prefers bun over npm."
  }
}
```

**Core hook:** `plugins/core/hooks/session-start.sh` — injects lessons as context.

---

### 2. UserPromptSubmit
**When:** User sends a message, before Claude processes it.
**Can block:** Yes — `exit 2` or return `"decision": "block"` with a reason.
**Can inject context:** Yes — `additionalContext` added alongside the prompt.

```json
{
  "session_id": "abc123",
  "transcript_path": "...",
  "cwd": "/home/user/myproject",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to delete all files"
}
```

To block (exit 2 shows stderr to user, erases the prompt):
```bash
echo "That prompt is not allowed here" >&2
exit 2
```

To inject context without blocking:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "User is working in a Docker container. No sudo available."
  }
}
```

**Core hook:** `plugins/core/hooks/user-prompt-submit.sh` — runs skogparse and injects lessons.

---

### 3. PreToolUse
**When:** Before any tool call (Bash, Write, Edit, Read, etc).
**Can block:** Yes — this is the most powerful hook for safety rules.
**Can modify input:** Yes — return `updatedInput` to change what the tool receives.

```json
{
  "session_id": "abc123",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/build",
    "description": "Clean build directory"
  },
  "tool_use_id": "toolu_01ABC123"
}
```

To block:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive commands are blocked"
  }
}
```

Permission decisions:
- `"allow"` — run it, skip Claude's own permission check
- `"deny"` — block it, show reason to Claude
- `"ask"` — ask the user (default behavior)

**Core hook:** `plugins/core/hooks/pre-tool-use.sh` — blocks dangerous bash commands, injects lessons.

---

### 4. PermissionRequest
**When:** A permission dialog is about to appear to the user.
**Can block:** Yes — can auto-approve or auto-deny without showing the dialog.

```json
{
  "session_id": "abc123",
  "hook_event_name": "PermissionRequest",
  "tool_name": "Bash",
  "tool_input": { "command": "npm install" },
  "permission_type": "tool_use"
}
```

Return `"decision": "allow"` to silently approve, `"deny"` to silently reject.

**Core hook:** `plugins/core/hooks/permission-request.sh` — logs only.

---

### 5. PostToolUse
**When:** After a tool call completes successfully.
**Can block:** No (tool already ran). Can send feedback to Claude via `additionalContext`.

```json
{
  "session_id": "abc123",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": { "file_path": "/path/to/file.txt", "content": "..." },
  "tool_response": { "filePath": "/path/to/file.txt", "success": true },
  "tool_use_id": "toolu_01ABC123"
}
```

**Core hook:** `plugins/core/hooks/post-tool-use.sh` — logs only (no output).

---

### 6. PostToolUseFailure
**When:** After a tool call fails.
**Can block:** No. Use for logging failures or injecting recovery context.

```json
{
  "session_id": "abc123",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": { "command": "npm test" },
  "error": "Command exited with code 1"
}
```

**Core hook:** `plugins/core/hooks/post-tool-use-failure.sh` — logs by tool name.

---

### 7. Notification
**When:** Claude Code sends a notification (permission prompts, idle, auth events).
**Can block:** No. Good for desktop notifications or logging.

```json
{
  "session_id": "abc123",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission to use Bash",
  "notification_type": "permission_prompt"
}
```

Notification types: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.

**Core hook:** `plugins/core/hooks/notification.sh` — logs by type.

---

### 8. SubagentStart
**When:** A subagent is spawned.
**Can block:** Yes — can prevent subagent from starting.

```json
{
  "session_id": "abc123",
  "hook_event_name": "SubagentStart",
  "subagent_type": "general-purpose"
}
```

**Core hook:** `plugins/core/hooks/subagent-start.sh` — logs by subagent type.

---

### 9. SubagentStop
**When:** A subagent finishes.
**Can block:** Yes — same pattern as Stop hook, check `stop_hook_active`.

```json
{
  "session_id": "abc123",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false
}
```

**Core hook:** `plugins/core/hooks/subagent-stop.sh` — logs only.

---

### 10. Stop
**When:** Claude finishes responding (end of turn).
**Can block:** Yes — return `"decision": "block"` with a `"reason"` to make Claude continue.
**Loop prevention:** Always check `stop_hook_active` — when true, Claude is already
continuing because of a stop hook. Don't block again or you'll loop forever.

```json
{
  "session_id": "abc123",
  "hook_event_name": "Stop",
  "stop_hook_active": false,
  "transcript_path": "..."
}
```

To force Claude to keep going:
```json
{ "decision": "block", "reason": "You forgot to run the tests. Run them now." }
```

**Core hook:** `plugins/core/hooks/stop.sh` — logs, runs quality checks, skogparse.

---

### 11. TeammateIdle
**When:** An agent team member is about to go idle.
**Can block:** Yes — can give the teammate more work instead of letting it idle.

```json
{
  "session_id": "abc123",
  "hook_event_name": "TeammateIdle",
  "teammate_name": "researcher"
}
```

---

### 12. TaskCompleted
**When:** A task is being marked as completed.
**Can block:** Yes — can prevent premature task completion.

---

### 13. ConfigChange
**When:** A Claude Code config file changes during a session.

```json
{
  "session_id": "abc123",
  "hook_event_name": "ConfigChange",
  "config_file": ".claude/settings.json"
}
```

---

### 14. WorktreeCreate
**When:** A git worktree is being created (via `--worktree` or `isolation: "worktree"`).
**Special:** If this hook exists, it **replaces** the default git worktree behavior entirely.

```json
{
  "session_id": "abc123",
  "hook_event_name": "WorktreeCreate",
  "worktree_path": "/path/to/new/worktree",
  "branch": "feature/my-branch"
}
```

---

### 15. WorktreeRemove
**When:** A git worktree is being removed (at session exit or when a subagent finishes).
**Special:** If this hook exists, it **replaces** the default removal behavior.

```json
{
  "session_id": "abc123",
  "hook_event_name": "WorktreeRemove",
  "worktree_path": "/path/to/worktree"
}
```

---

### 16. PreCompact
**When:** Before Claude compacts (summarizes) the conversation.
**Can block:** No. Good for archiving the full transcript before it's compressed.

```json
{
  "session_id": "abc123",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
```

Triggers: `"manual"` (via `/compact`) or `"auto"` (automatic).

**Core hook:** `plugins/core/hooks/pre-compact.sh` — logs with trigger type in filename.

---

### 18. SessionEnd
**When:** Session terminates.
**Can block:** No.
**Note:** By the time this runs, the session is already ending. Use for cleanup or async sync.

```json
{
  "session_id": "abc123",
  "hook_event_name": "SessionEnd",
  "reason": "exit"
}
```

Reasons: `"exit"`, `"clear"`, `"logout"`, `"prompt_input_exit"`, `"other"`.

**Core hook:** `plugins/core/hooks/session-end.sh` — logs only.

---


## Minimal hook template

Copy this to start any new hook:

```bash
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
hook_name="my-hook"  # change this
log_file="/tmp/${session_id}-${hook_name}.json"
echo "$input" > "$log_file"

# Your logic here
# - Read fields: tool_name=$(echo "$input" | jq -r '.tool_name')
# - Block (exit 2 + stderr): echo "blocked!" >&2 && exit 2
# - Inject context: output JSON with hookSpecificOutput

exit 0
```

## How to register a new hook in marketplace.json

```json
{
  "name": "core",
  "hooks": {
    "PostToolUseFailure": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/post-tool-use-failure.sh"
      }]
    }]
  }
}
```

The `matcher` field filters by tool name (e.g., `"Bash"`) or is empty to match all.

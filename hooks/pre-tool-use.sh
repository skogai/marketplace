#!/usr/bin/env bash
# PreToolUse hook - runs before tool calls (can block them)
#
# Source: plugins/claude-docs/references/hooks.md
#
# Input JSON structure (example for Bash tool):
# {
#   "session_id": "abc123",
#   "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
#   "cwd": "/Users/...",
#   "permission_mode": "default",
#   "hook_event_name": "PreToolUse",
#   "tool_name": "Bash",  # or "Write", "Edit", "Read", etc.
#   "tool_input": {
#     "command": "psql -c 'SELECT * FROM users'",
#     "description": "Query the users table",
#     "timeout": 120000
#   },
#   "tool_use_id": "toolu_01ABC123..."
# }
#
# Output JSON structure (optional):
# {
#   "hookSpecificOutput": {
#     "hookEventName": "PreToolUse",
#     "permissionDecision": "allow" | "deny" | "ask",  # Controls tool execution
#     "permissionDecisionReason": "string",  # Explanation (shown to Claude for deny, user for allow/ask)
#     "updatedInput": {}  # Optional: modify tool input before execution
#   }
# }
#
# Exit codes:
# - 0: Success. JSON output parsed for hookSpecificOutput
# - 2: Blocks the tool call, shows stderr to Claude
# - Other: Non-blocking error, stderr shown to user in verbose mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
tool_name=$(echo "$input" | jq -r '.tool_name')
log_file="/tmp/${session_id}.jsonl"
echo "$input" >> "$log_file"

# =============================================================================
# Block Dangerous Bash Commands
# =============================================================================

COMMAND=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ -n "$COMMAND" ]]; then
  # rm -rf with dangerous paths
  if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive\s+--force|-rf|-fr)\s+(/|~|\.\.|\$HOME|\$\{HOME\})'; then
    echo "BLOCKED: Destructive rm command targeting root, home, or parent directory" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # rm -rf /* or rm -rf ~/*
  if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive\s+--force|-rf|-fr)\s+(/\*|~/\*|/home)'; then
    echo "BLOCKED: Destructive rm command with wildcard on sensitive path" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # Force push to main/master
  if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f|--force)\s+.*(main|master|production|release)'; then
    echo "BLOCKED: Force push to protected branch" >&2
    echo "Command: $COMMAND" >&2
    echo "Tip: Create a PR instead of force pushing to main/master" >&2
    exit 2
  fi

  # chmod 777 (world-writable)
  if echo "$COMMAND" | grep -qE 'chmod\s+(777|a\+rwx)'; then
    echo "BLOCKED: Setting world-writable permissions (777)" >&2
    echo "Command: $COMMAND" >&2
    echo "Tip: Use 755 for directories, 644 for files" >&2
    exit 2
  fi

  # Piping curl directly to shell
  if echo "$COMMAND" | grep -qE 'curl\s+.*\|\s*(ba)?sh'; then
    echo "BLOCKED: Piping curl output directly to shell" >&2
    echo "Command: $COMMAND" >&2
    echo "Tip: Download script first, review it, then execute" >&2
    exit 2
  fi

  # wget piped to shell
  if echo "$COMMAND" | grep -qE 'wget\s+.*\|\s*(ba)?sh'; then
    echo "BLOCKED: Piping wget output directly to shell" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # dd writing to disk devices
  if echo "$COMMAND" | grep -qE 'dd\s+.*of=/dev/(sd|hd|nvme|disk)'; then
    echo "BLOCKED: dd command writing directly to disk device" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # mkfs (format disk)
  if echo "$COMMAND" | grep -qE 'mkfs'; then
    echo "BLOCKED: mkfs command (disk formatting)" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # Commands that could exfiltrate data
  if echo "$COMMAND" | grep -qE '(curl|wget|nc|netcat)\s+.*\.(env|pem|key|secret)'; then
    echo "BLOCKED: Command appears to exfiltrate sensitive files" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # Reading .env files via cat/less/head/tail
  if echo "$COMMAND" | grep -qE '(cat|less|head|tail|more|bat)\s+.*\.env'; then
    echo "BLOCKED: Reading .env file via $COMMAND" >&2
    echo "Tip: Use environment variables instead of reading .env directly" >&2
    exit 2
  fi
fi

# =============================================================================
# Lesson injection: match lessons relevant to this tool
# =============================================================================

lesson_context=$(python3 "$SCRIPT_DIR/lesson_matcher.py" --mode tool --tool "$tool_name" 2>/dev/null || true)

if [[ -n "$lesson_context" ]]; then
  jq -n \
    --arg context "$lesson_context" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "additionalContext": $context
      }
    }'
fi

exit 0

# hooks/

Reference implementations and templates for Claude Code hooks, built on `scripts/skogai-jq.sh`.

## Adding a new hook — the workflow

1. Copy the matching template from `hooks/templates/` into the appropriate plugin's `hooks/` dir (or into `hooks/` here for the repo-level hooks).
2. Source the plugin-local `scripts/skogai-jq.sh` (plugins vendor their own copy — never reference the repo-root one from inside a plugin).
3. Declare the schema — every field the hook reads, with a sentinel.
4. Call `skogai_jq_log` first. This is your debug output.
5. Add business logic. Output via `skogai_jq_context` or `skogai_jq_decision`.
6. Test with `cat hooks/example-inputs/<event>.json | bash hooks/my-hook.sh`.

## Anatomy of a hook

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"   # reads stdin → $HOOK_INPUT + helpers

# --- Schema ---
# Every field this hook consumes, with a sentinel for the missing case.
# This declaration IS the contract.
HOOK_TOOL_NAME=$(skogai_jq_field ".tool_name" "UNKNOWN_TOOL")
HOOK_CWD=$(skogai_jq_field ".cwd" "UNKNOWN_CWD")

# --- Debug log (always first) ---
skogai_jq_log "PreToolUse: tool=$HOOK_TOOL_NAME"

# --- Business logic ---
# if [[ "$HOOK_TOOL_NAME" == "Bash" ]]; then ...

exit 0
```

Key rules:
- `skogai-jq.sh` reads stdin on source. Never call `cat` after sourcing.
- Use `skogai_jq_field` for every field. No inline `jq -r` after the schema block.
- Sentinels must be ALL_CAPS strings that can never appear as real values.
- Log before any conditional logic so every invocation is visible in `/tmp/<session_id>.jsonl`.

## skogai-jq.sh — what you get after sourcing

### Auto-populated variables

| Variable | Content |
|---|---|
| `$HOOK_INPUT` | Raw JSON from stdin |
| `$HOOK_SESSION_ID` | `.session_id` |
| `$HOOK_EVENT` | `.hook_event_name` |
| `$HOOK_PROMPT` | `.prompt` (empty string if absent) |
| `$HOOK_LOG` | `/tmp/${HOOK_SESSION_ID}.jsonl` |

### Functions

```bash
# Extract a field. Second arg is the sentinel for null/missing.
val=$(skogai_jq_field ".tool_name" "UNKNOWN_TOOL")

# Append a structured JSONL debug entry to $HOOK_LOG.
skogai_jq_log "summary text"

# Output hookSpecificOutput JSON (context injection).
skogai_jq_context "EventName" "text injected into Claude context"

# Output decision JSON (block/allow with reason).
skogai_jq_decision "block" "reason shown to user"

# Test a value against a skogai-jq transform predicate.
result=$(skogai_jq_bool "is-empty-string" "$val")   # "true" or "false"
result=$(skogai_jq_bool "is-timestamp" "$val")
```

Codex-specific helpers (`skogai_jq_codex_*`) are documented in `docs/hook-compatibility.md`.

## Event reference

Each event has a template in `hooks/templates/` and an example input in `hooks/example-inputs/`.

### SessionStart

- **When:** Session starts or resumes.
- **Cannot block.**
- **Output:** `skogai_jq_context "SessionStart" "..."` to inject text into session.

Input fields:
```
session_id, hook_event_name, transcript_path, permission_mode, source
```

### UserPromptSubmit

- **When:** User submits a prompt.
- **Exit 0:** allow. **Exit 2:** block (erases prompt, shows stderr to user).
- **Output:** `skogai_jq_context "UserPromptSubmit" "..."` to inject into Claude's context.

Input fields:
```
session_id, hook_event_name, transcript_path, cwd, permission_mode, prompt
```

### PreToolUse

- **When:** Before any tool call.
- **Exit 0:** allow. **Exit 2:** block (shows stderr to Claude).
- **Output:** Permission JSON to allow/deny/ask, or context injection.

Input fields:
```
session_id, hook_event_name, transcript_path, cwd, permission_mode,
tool_name, tool_input (object), tool_use_id
```

Output shapes:
```bash
# Allow with context
skogai_jq_context "PreToolUse" "note injected before tool runs"

# Deny
jq -n --arg r "reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'

# Ask user
jq -n --arg r "reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'
```

Common `tool_input` fields by tool:
| Tool | Key fields in `.tool_input` |
|---|---|
| `Bash` | `.command`, `.description`, `.timeout` |
| `Write` | `.file_path`, `.content` |
| `Edit` | `.file_path`, `.old_string`, `.new_string` |
| `Read` | `.file_path` |
| `mcp__*` | varies per server |

### PostToolUse

- **When:** After a tool call completes.
- **Cannot block the tool** (already ran). Exit 2 feeds stderr back to Claude as feedback.
- **Output:** `skogai_jq_context "PostToolUse" "..."` or leave empty.

Input fields (superset of PreToolUse):
```
... all PreToolUse fields ...
tool_response (string or object, varies by tool)
```

### Stop

- **When:** Claude finishes a turn and considers stopping.
- **Exit 0 + empty stdout:** allow stop.
- **Exit 0 + JSON `reason`:** continue the turn (Claude re-runs with reason as context).

Input fields:
```
session_id, hook_event_name, transcript_path, cwd, stop_hook_active
```

`stop_hook_active` is `true` when Stop is itself being re-run to prevent infinite loops — always check it and exit 0 early.

Output to continue the turn:
```bash
jq -n --arg r "reason text" '{reason: $r}'
```

### PreCompact

- **When:** Before context compaction.
- **Cannot block** (compaction proceeds regardless).
- **Output:** `skogai_jq_context "PreCompact" "..."` to inject text preserved in the compact summary.

Input fields:
```
session_id, hook_event_name, transcript_path, trigger, custom_instructions
```

`trigger` values: `"manual"`, `"auto"`.

## Testing any hook

```bash
# Quick smoke test — verify exit code and output shape
cat hooks/example-inputs/pre-tool-use.json | bash hooks/pre-tool-use.sh

# See what was logged
cat /tmp/abc123.jsonl | jq .

# Pipe custom input inline
echo '{"session_id":"test","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"rm -rf /"},"tool_use_id":"t1"}' \
  | bash hooks/pre-tool-use.sh

# Run all bats tests
bats tests/**/*.bats
```

## Naming conventions

For repos that will have many hooks (100+), use this naming scheme:

```
hooks/
  <event>-<domain>-<action>.sh

Examples:
  pre-tool-use-bash-safety.sh
  pre-tool-use-write-secrets.sh
  post-tool-use-bash-logger.sh
  stop-test-gate.sh
  stop-git-dirty.sh
  user-prompt-submit-context.sh
  session-start-project-context.sh
```

Rules:
- Always start with the event name so `ls hooks/` groups by event.
- `<domain>` is the tool name (for tool hooks) or the thing being checked.
- `<action>` is what the hook does: `safety`, `logger`, `gate`, `context`, `block`.
- Router hooks (like `stop.sh`) delegate to named sub-hooks via `$HOOK_DIR/<sub>.sh`.

## Router pattern for Stop

Stop often needs multiple independent checks. Use a router:

```bash
# stop.sh — router
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$HOOK_DIR/../scripts/skogai-jq.sh"

[[ "$HOOK_STOP_HOOK_ACTIVE" == "true" ]] && exit 0   # anti-loop guard

input_file=$(mktemp); echo "$HOOK_INPUT" > "$input_file"; trap 'rm -f "$input_file"' EXIT

output=$("$HOOK_DIR/stop-git-dirty.sh" "$input_file" 2>/dev/null || true)
[[ -n "$output" ]] && echo "$output" && exit 0

"$HOOK_DIR/stop-quality-gate.sh" "$input_file" 2>/dev/null || true
exit 0
```

Sub-hooks read from `$1` (file path) rather than stdin, since stdin is consumed by the router.

## Output rules summary

| Event | Can block? | Context injection | Decision JSON |
|---|---|---|---|
| SessionStart | no | `skogai_jq_context "SessionStart" "..."` | — |
| UserPromptSubmit | yes (exit 2) | `skogai_jq_context "UserPromptSubmit" "..."` | `decision:"block"` |
| PreToolUse | yes (exit 2) | `skogai_jq_context "PreToolUse" "..."` | `permissionDecision:"deny"` |
| PostToolUse | no (already ran) | `skogai_jq_context "PostToolUse" "..."` | — |
| Stop | yes (return reason) | — | `{reason:"..."}` |
| PreCompact | no | `skogai_jq_context "PreCompact" "..."` | — |

## skogai-jq transform directory

`skogai-jq.sh` expects transforms at `$SKOGAI_JQ_TRANSFORM_DIR` (defaults to `../skogai-jq/` relative to `scripts/`). In this repo the symlink `skogai-jq/ → plugins/skogai-jq/skills/skogai-jq/` satisfies that. Plugins vendor transforms alongside their own `skogai-jq.sh` copy.

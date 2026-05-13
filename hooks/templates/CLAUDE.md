# hooks/templates/

Minimal correct starting point for each Claude Code hook event. Copy, rename, wire up.

## Usage

```bash
# 1. Copy to your plugin's hooks/ directory
cp hooks/templates/pre-tool-use.sh plugins/my-plugin/hooks/pre-tool-use-bash-safety.sh

# 2. Update the source path to the plugin-local skogai-jq.sh
#    templates/ is two levels deep; plugins/my-plugin/hooks/ is one level deep
#    so change: source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"
#    to:        source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

# 3. Extend the schema with any fields your logic needs
# 4. Add your logic between the schema and exit 0
# 5. Test: cat hooks/example-inputs/<event>.json | bash plugins/my-plugin/hooks/my-hook.sh
```

## Templates

| File | Event | Blocking? |
|---|---|---|
| `session-start.sh` | SessionStart | no |
| `user-prompt-submit.sh` | UserPromptSubmit | yes (exit 2) |
| `pre-tool-use.sh` | PreToolUse | yes (exit 2) |
| `post-tool-use.sh` | PostToolUse | no |
| `stop.sh` | Stop | yes (return reason JSON) |
| `pre-compact.sh` | PreCompact | no |

Each template:
- Sources `skogai-jq.sh` (adjust path for plugin depth)
- Declares the schema for that event's fields
- Calls `skogai_jq_log` so every invocation is visible in `/tmp/<session_id>.jsonl`
- Exits 0 cleanly — add your logic above `exit 0`

## Source path by location

| Hook lives in | Source line |
|---|---|
| `hooks/` (repo root) | `source "$SCRIPT_DIR/../scripts/skogai-jq.sh"` |
| `hooks/templates/` | `source "$SCRIPT_DIR/../../scripts/skogai-jq.sh"` |
| `plugins/<name>/hooks/` | `source "$SCRIPT_DIR/../scripts/skogai-jq.sh"` |

Each plugin vendors its own `scripts/skogai-jq.sh`. Never cross-reference between plugins.

## Extending a template

Add fields to the schema block using `skogai_jq_field`:

```bash
# Fields auto-populated by skogai-jq.sh (already available):
# $HOOK_INPUT, $HOOK_SESSION_ID, $HOOK_EVENT, $HOOK_PROMPT, $HOOK_LOG

# --- Schema --- (add what your hook needs)
HOOK_TOOL_NAME=$(skogai_jq_field ".tool_name" "UNKNOWN_TOOL")
HOOK_COMMAND=$(skogai_jq_field ".tool_input.command" "EMPTY_COMMAND")
HOOK_FILE_PATH=$(skogai_jq_field ".tool_input.file_path" "EMPTY_PATH")
```

Sentinel values must be ALL_CAPS strings that can never appear as real values. They make missing fields immediately visible in logs and conditions.

## Output cheatsheet

```bash
# Inject text into Claude's context (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PreCompact)
skogai_jq_context "EventName" "text"

# Block a UserPromptSubmit (exit 2 to erase prompt and show stderr to user)
echo "reason" >&2; exit 2

# Deny a tool call (PreToolUse)
jq -n --arg r "reason" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'

# Continue a Stop turn (output JSON reason, exit 0)
jq -n --arg r "reason" '{reason: $r}'

# Debug log (appends to /tmp/<session_id>.jsonl, no stdout)
skogai_jq_log "summary"
```

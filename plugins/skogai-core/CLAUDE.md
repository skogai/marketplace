# skogai-core

Always-active base plugin. Present in every skogai session.

## Structure

```
plugins/skogai-core/
├── hooks/
│   └── session-start.sh      ← runs on every session start
├── scripts/
│   └── skogai-jq.sh          ← vendored hook library (source this in every hook)
└── skills/
    ├── skogai-jq/            ← symlink → skogai-jq transform library — READ skills/skogai-jq/SKILL.md
    └── skogai-routing/
```

## Hooks

Every hook in this plugin follows the same pattern:

```bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"   # reads stdin; exposes vars + helpers

# --- Schema ---
HOOK_CWD=$(skogai_jq_field ".cwd" "UNKNOWN_CWD")

skogai_jq_log "EventName: key=$VALUE"           # always log first

# ... logic ...
skogai_jq_context "EventName" "text"            # output context injection
exit 0
```

After sourcing `skogai-jq.sh`:
- `$HOOK_INPUT` — raw stdin JSON
- `$HOOK_SESSION_ID`, `$HOOK_EVENT`, `$HOOK_PROMPT`, `$HOOK_LOG`
- `skogai_jq_field ".path" "SENTINEL"` — extract field with typed sentinel
- `skogai_jq_log "summary"` — append to `/tmp/<session_id>.jsonl`
- `skogai_jq_context "Event" "text"` — output `hookSpecificOutput` JSON
- `skogai_jq_decision "block" "reason"` — output decision JSON

Test a hook:
```bash
cat hooks/example-inputs/session-start.json | bash plugins/skogai-core/hooks/session-start.sh
```

## skogai-jq skill

`skills/skogai-jq/` symlinks to the full transform library (60+ transforms). Use it for any JSON work inside hooks instead of writing raw jq.

```bash
# From inside a hook script:
JQ_DIR="$SCRIPT_DIR/../skills/skogai-jq"
result=$(echo "$HOOK_INPUT" | jq -f "$JQ_DIR/crud-get/transform.jq" --arg path "tool_input.command")
```

Read `skills/skogai-jq/SKILL.md` to discover which transform to use. Reference `skills/skogai-jq/references/CHEAT_SHEET.md` for the full index.

## Adding a hook

1. Create `hooks/<event>-<domain>-<action>.sh`
2. Source `"$SCRIPT_DIR/../scripts/skogai-jq.sh"`
3. Declare schema — one `skogai_jq_field` per input field you use, with a SENTINEL default
4. `skogai_jq_log` immediately after schema
5. Business logic using skogai-jq transforms where applicable
6. Output via `skogai_jq_context` or `skogai_jq_decision`
7. `exit 0`

Test: `cat hooks/example-inputs/<event>.json | bash plugins/skogai-core/hooks/<your-hook>.sh`

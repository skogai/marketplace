# hooks/

Claude Code hooks for this repo. Each hook sources `skogai-jq.sh` and follows the schema-first pattern.

## Hook structure

Every hook starts by sourcing the helper, which reads stdin and exposes typed env vars:

```bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"
```

After sourcing, declare the schema — every input field the hook consumes, with a sentinel for the missing case:

```bash
# --- Schema ---
HOOK_PROMPT=$(skogai_jq_field ".prompt" "EMPTY_PROMPT")
HOOK_CWD=$(skogai_jq_field ".cwd" "UNKNOWN_CWD")
```

This declaration IS the contract. A field is either a typed string with a known sentinel, or it does not exist. No null checks, no silent failures downstream.

## Output

Use the library functions — never hand-roll jq output:

```bash
skogai_jq_context "UserPromptSubmit" "$additional_context"   # inject context
skogai_jq_decision "block" "reason shown to user"            # block a prompt
```

## What belongs in a hook

- Schema declaration (input fields)
- Validation/guard logic using skogai-jq transforms
- Business logic (lesson matching, skogparse, etc.)
- Output via `skogai_jq_context` or `skogai_jq_decision`

Keep hooks thin. Logic that can live in a transform or a helper script should.

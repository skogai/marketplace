# Plan: skogai-core first hook (setup.sh)

## Goal

Add a single working hook to `skogai-core` that demonstrates the full hook pattern for the plugin: vendor `skogai-jq.sh` into the plugin, source it in the hook, and log the raw hook input to `/tmp/<session-id>.log`. This becomes the reference implementation that future `skogai-core` hooks are built on.

## Why this first

- Proves the pattern works end-to-end inside a plugin (not just in the repo-local `hooks/`).
- Gives a working file to copy when adding real hooks later.
- The log output makes it easy to inspect what Claude Code sends to hooks during development.

## Target structure

```
plugins/skogai-core/
├── scripts/
│   └── skogai-jq.sh    ← vendored copy of repo scripts/skogai-jq.sh
└── hooks/
    └── setup.sh        ← logs raw input; exit 0 always
```

## Hook behavior

`setup.sh` should:

1. Source `scripts/skogai-jq.sh` (which reads stdin into `$HOOK_INPUT` and sets `$HOOK_SESSION_ID`, `$HOOK_EVENT`, `$HOOK_LOG`).
2. Append a structured JSONL entry via `skogai_jq_log "setup: received $HOOK_EVENT"`.
3. Produce no stdout output (no context injection, no decision — pure observer).
4. Exit 0 always.

The log lands at `/tmp/<session-id>.jsonl` (the default `$HOOK_LOG` path set by `skogai-jq.sh`).

## Steps

1. Create `plugins/skogai-core/scripts/` and copy `scripts/skogai-jq.sh` there (vendored).
2. Create `plugins/skogai-core/hooks/setup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

skogai_jq_log "setup: received $HOOK_EVENT"
exit 0
```

3. `chmod +x plugins/skogai-core/hooks/setup.sh`.
4. Reload plugins (`/reload-plugins`) and trigger a hook event (e.g. submit a prompt).
5. Confirm `/tmp/<session-id>.jsonl` contains a valid JSONL entry with the expected fields.

## What "vendored skogai-jq.sh" means

Each plugin carries its own copy of `skogai-jq.sh` under `plugins/<name>/scripts/`. This avoids cross-plugin path dependencies and keeps each plugin self-contained. When `skogai-jq.sh` changes in the repo root `scripts/`, the updated copy must be propagated to each plugin manually (or via a future sync script). This is intentional — stability over convenience at this stage.

## After it works

This hook is the seed. Next real hooks to consider for `skogai-core`:

- A `session-start.sh` that injects repo context (CLAUDE.md summary, git branch, etc.).
- A `stop.sh` that warns on uncommitted changes (port of `hooks/stop-git-dirty.sh`).
- A `pre-tool-use.sh` that enforces the repo's allow/block rules (port of `hooks/pre-tool-use.sh`).

# skogai/marketplace

Claude Code plugin marketplace — catalog and hooks for skogai personal plugins.

## What this repo is

- `.claude-plugin/marketplace.json` — Claude Code catalog (source of truth); `metadata.pluginRoot = "./plugins"`
- `.agents/plugins/marketplace.json` — Codex marketplace catalog
- `.codex/config.toml` — repo-local Codex baseline config
- `plugins/` — all installable plugins (see below)
- `hooks/` — reference hook implementations showing the pattern; not wired up. `skogai-core` will be the first plugin to implement real hooks.
- `tests/` — bats test suites for the hooks; run with `bats tests/**/*.bats`
- `docs/claude-code/` and `docs/codex/` — gitignored docs snapshots; refresh both with `scripts/fetch-hook-docs.sh`
- `PLAN.md` — current direction and near-term tasks; read this before starting work
- `.plans/` — per-task implementation specs linked from `PLAN.md`

## Plugins

| Plugin | Always loaded | Purpose |
|---|---|---|
| `skogai-core` | yes | Trusted baseline — always present. Code agents (`code-explorer`, `code-architect`, `code-reviewer`, `code-simplifier`) and workflow commands (`feature-dev`, `revise-docs`). Will house the first real hook implementations. |
| `skogai-plugin` | no | Load when developing plugins. Skills, agents, and commands for building Claude Code plugins. |
| `skogai-tests` | no | Load when working with tests. Currently focused on bats for shell script TDD. |
| `skogai-jq` | no | JSON transform and hook I/O framework — a tooling layer, not just a skill. Distribution model TBD. |
| `skogai-lessons` | no | _(planned)_ Contextual lesson injection via session hooks. `hooks/lesson_matcher.py` and `concepts/` are the prototype. |

## Plugin management

- `argc marketplace update` — pull the latest catalog from remote; run after pushing catalog changes

## Symlinks (from `.skogai/` submodule)

`agents`, `bin`, `commands`, `skills`, `.claude` → `.skogai/` (skogai/core). Edit in core, not here.

`.agents/` and `.codex/` are repo-local Codex directories, not symlinks.

## Testing workflow

- **Tests first.** Write tests before implementing. Tests are the spec — implementation must satisfy them.
- **Tests catch Claude, not bash.** The unreliable variable is the AI making edits, not the language. Test things Claude could accidentally break.
- **No conditional assertions.** `if [[ -n "$output" ]]; then assert...` lets output disappear silently. If a hook should produce output, assert it unconditionally.
- **Don't test constants.** Testing that the hook echoes back its own input field is not a test.
- **What to test:** exit codes, file system side effects, output content that could be accidentally removed, both allow and block paths.
- **Pattern:** define expected behavior → write failing test → implement → tests pass → future edits can't silently regress.

## Hook pattern

All hooks source a plugin-local `scripts/skogai-jq.sh`. Each plugin vendors its own copy — do not reference the repo-root `scripts/skogai-jq.sh` from inside a plugin. Sourcing it reads stdin and exposes `$HOOK_INPUT`, `$HOOK_SESSION_ID`, `$HOOK_EVENT`, `$HOOK_LOG`. Each hook then declares its own schema — typed env vars with sentinels for missing values. That declaration is both documentation and the implementation contract. See `hooks/CLAUDE.md` for the reference pattern.

Tests validate content regressions using the same skogai-jq transforms. See `tests/CLAUDE.md`.

Codex-specific hook output helpers use the `skogai_jq_codex_*` prefix. See `docs/hook-compatibility.md` before reusing Claude-shaped hook decisions for Codex.

The Codex marketplace smoke test uses `plugins/codex-hooks` and asserts that Codex can expose its `codex-hooks-smoke` skill once the plugin is present in the Codex plugin cache.

## Key conventions

- `CLAUDE.md` → `AGENTS.md` (same file, symlinked so both agents and Claude Code pick it up)
- See `FILESTRUCTURE.md` for a full map of where things live

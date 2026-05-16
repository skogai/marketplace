# Contributing

This repository is the SkogAI plugin marketplace and hook development workspace. It carries Claude Code marketplace metadata, Codex marketplace metadata, reference hook implementations, plugin payloads, and Bats tests for hook behavior.

## Setup

1. Install the local toolchain: `bash`, `jq`, `bats`, `git`, `gh`, `codex`, `claude`, `argc`, `gita`, and `wt`.
2. Initialize the SkogAI core submodule: `git submodule update --init`.
3. Load `.envrc` with `direnv allow` if you use direnv. It initializes submodules and adds `.skogai/tmp/bin` to `PATH`.
4. Work from the repository root so hook tests resolve `hooks/`, `scripts/`, `tests/`, `.agents/`, and `.claude-plugin/` consistently.

## Commands

<!-- AUTO-GENERATED: commands:start -->
Generated from: `package.json`, `Argcfile.sh`, `.envrc`, `docs/codex-marketplace.md`, `hooks/CLAUDE.md`, `tests/CLAUDE.md`, and `scripts/`.

| Command | Description |
| --- | --- |
| `git submodule update --init` | Initialize the `.skogai/` submodule used by root symlinks and local PATH setup. |
| `bats tests/**/*.bats` | Run the repository hook test suite. |
| `bats tests/codex-plugin/codex-plugin.bats` | Smoke-test Codex marketplace registration and plugin skill visibility. |
| `bats tests/skogai-jq/skogai-jq.bats` | Run the shared `skogai-jq` helper tests. |
| `jq -e . .agents/plugins/marketplace.json .claude-plugin/marketplace.json` | Validate the Codex and Claude marketplace catalogs. |
| `jq -e . plugins/skogai-core/hooks/hooks.json` | Validate the current `skogai-core` Claude hook manifest. |
| `codex mcp list` | Confirm Codex loads the repo-local `.codex/config.toml` baseline. |
| `env HOME=/tmp/codex-marketplace-test-home codex plugin marketplace add "$PWD"` | Register this checkout as a temporary local Codex marketplace. |
| `env HOME=/tmp/codex-marketplace-test-home codex debug prompt-input "Run the Codex hooks plugin smoke test."` | Confirm Codex can expose the `codex-hooks-smoke` skill after test setup. |
| `bash scripts/fetch-claude-code-docs.sh` | Refresh the gitignored Claude Code docs snapshot in `docs/claude-code/`. |
| `bash scripts/fetch-codex-hook-docs.sh` | Refresh the gitignored Codex hook docs/schema snapshot in `docs/codex/`. |
| `bash scripts/fetch-hook-docs.sh` | Refresh both Claude Code and Codex docs snapshots. |
| `cat hooks/example-inputs/pre-tool-use.json \| bash hooks/pre-tool-use.sh` | Manually smoke-test a hook against a checked-in example payload. |
| `claude plugin marketplace update "$SKOGAI_MARKETPLACE_NAME"` | Update the installed Claude Code marketplace entry directly. |
| `codex plugin marketplace add "$SKOGAI_MARKETPLACE_SOURCE"` | Add the SkogAI marketplace to Codex directly. |
| `codex plugin marketplace upgrade "$SKOGAI_MARKETPLACE_NAME"` | Upgrade the installed Codex marketplace entry directly. |
| `codex plugin marketplace remove "$SKOGAI_MARKETPLACE_NAME"` | Remove the installed Codex marketplace entry directly. |
| `argc tools claude list` | Source-declared wrapper for listing Claude Code plugins and marketplaces; currently blocked by the wrapper caveat below. |
| `argc tools claude validate [path]` | Source-declared wrapper for Claude Code plugin/marketplace validation; currently blocked by the wrapper caveat below. |
| `argc tools claude update` | Source-declared wrapper around `claude plugin marketplace update`; currently blocked by the wrapper caveat below. |
| `argc tools codex add` | Source-declared wrapper around `codex plugin marketplace add`; currently blocked by the wrapper caveat below. |
| `argc tools codex upgrade` | Source-declared wrapper around `codex plugin marketplace upgrade`; currently blocked by the wrapper caveat below. |
| `argc tools codex remove` | Source-declared wrapper around `codex plugin marketplace remove`; currently blocked by the wrapper caveat below. |

Current wrapper caveat: `bash Argcfile.sh --help`, `bash Argcfile.sh tools ...`, and `argc --argc-export Argcfile.sh` fail until `marketplace::plugin::update` has a declared `marketplace::plugin` parent command.
<!-- AUTO-GENERATED: commands:end -->

## Environment

<!-- AUTO-GENERATED: env:start -->
Generated from: `.envrc`, `Argcfile.sh`, `scripts/skogai-jq.sh`, `hooks/CLAUDE.md`, and `plugins/skogai-core/hooks/setup.sh`.

| Variable | Required | Description | Example |
| --- | --- | --- | --- |
| `DEV_BASE_DIR` | No | Base directory used by repo wrapper commands. | `/home/skogix/.local/src/` |
| `WORKTREE_DIR` | No | Worktree directory name used by wrapper conventions. | `/home/skogix/dev` |
| `GITA_GROUP` | No | `gita` group name for active repositories. | `src` |
| `SKOGAI_MARKETPLACE_NAME` | No | Marketplace name passed to Claude/Codex plugin CLIs. | `skogai` |
| `SKOGAI_MARKETPLACE_SOURCE` | No | Marketplace source passed to `codex plugin marketplace add`. | `SkogAI/marketplace` |
| `SKOGAI_MARKETPLACE_REPO_DIR` | No | Local Claude marketplace checkout used by wrapper defaults. | `/home/skogix/.claude/plugins/marketplaces/skogai` |
| `SKOGAI_CLAUDE_PLUGIN_ROOT` | No | Claude Code plugin root. | `/home/skogix/.claude/plugins` |
| `SKOGAI_CLAUDE_PLUGIN_MARKETPLACES_DIR` | No | Claude Code marketplace checkout root. | `/home/skogix/.claude/plugins/marketplaces` |
| `SKOGAI_CLAUDE_PLUGIN_CACHE_DIR` | No | Claude Code plugin cache root. | `/home/skogix/.claude/plugins/cache` |
| `SKOGAI_CODEX_PLUGIN_ROOT` | No | Codex plugin root. | `/home/skogix/.codex/plugins` |
| `SKOGAI_CODEX_PLUGIN_MARKETPLACES_DIR` | No | Codex marketplace checkout root. | `/home/skogix/.codex/plugins/marketplaces` |
| `SKOGAI_CODEX_PLUGIN_CACHE_DIR` | No | Codex plugin cache root. | `/home/skogix/.codex/plugins/cache` |
| `LESSON_DIRS` | No | Local lesson fixture directories loaded by `.envrc`. | `./tests/lessons/` |
| `HOOK_LOG` | Runtime | Hook helper log path derived from `.session_id`. | `/tmp/<session_id>.jsonl` |
| `CLAUDE_PLUGIN_ROOT` | Runtime | Claude plugin install directory available to plugin hooks. | `/home/skogix/.claude/plugins/cache/...` |
| `CLAUDE_PLUGIN_DATA` | Runtime | Claude plugin persistent data directory. | `/home/skogix/.claude/plugins/data/<id>/` |
| `CLAUDE_PROJECT_DIR` | Runtime | Project root provided to Claude plugin hooks. | `/mnt/sda1/src/marketplace` |
| `CLAUDE_ENV_FILE` | Runtime | File where setup hooks can write exported session environment. | `/tmp/claude-env` |

The checked-in `.env*` files are currently empty, and there is no `.env.example`, `.env.template`, or `.env.sample` in this checkout. Do not document private `.env` values directly.
<!-- AUTO-GENERATED: env:end -->

## Testing

Write tests before changing hook behavior. The repository convention is to test behavior that agents can silently regress: exit codes, file effects, selected output content, allow/block paths, and hook log content. Avoid conditional assertions and avoid tests that only prove constants were echoed back.

Use `tests/CLAUDE.md` for Bats assertion style and `hooks/CLAUDE.md` for the hook input/output contract. Plugin hooks must source their plugin-local `scripts/skogai-jq.sh`; do not source the repo-root helper from inside an installable plugin.

## Code Style

Shell hooks should use `set -euo pipefail`, derive paths from `BASH_SOURCE` or the hook script directory, declare every consumed JSON field with a sentinel, and log before conditional logic. JSON and TOML config changes should be validated with `jq -e` or a TOML parser before publishing.

## PR Checklist

1. Re-read `PLAN.md`, `FILESTRUCTURE.md`, and the relevant plugin docs before editing.
2. Keep catalog, plugin, hook, and test changes narrowly scoped.
3. Validate changed JSON manifests with `jq -e`.
4. Run the smallest relevant Bats suite, then broaden to `bats tests/**/*.bats` for shared hook behavior.
5. Review `git diff` for accidental edits to symlinks, submodule content, generated docs snapshots, or empty package-manager files.
6. Update docs in generated sections only when the source-of-truth files changed.

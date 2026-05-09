# skogai/marketplace

Claude Code plugin marketplace — catalog and hooks for skogai personal plugins.

## What this repo is

- `.claude-plugin/marketplace.json` — catalog (source of truth); `metadata.pluginRoot = "./plugins"`
- `plugins/` — local plugin home (currently empty; plugins are added here or as external sources)
- `hooks/` — Claude Code hooks that run during development in this repo
- `tests/` — bats test suites for the hooks; run with `bats tests/**/*.bats`
- `docs/claude-code/` — gitignored; refresh with `scripts/fetch-claude-code-docs.sh`

## Symlinks (from `.skogai/` submodule)

`agents`, `bin`, `commands`, `skills`, `.claude` → `.skogai/` (skogai/core). Edit in core, not here.

## Key conventions

- `CLAUDE.md` → `AGENTS.md` (same file, symlinked so both agents and Claude Code pick it up)
- See `FILESTRUCTURE.md` for a full map of where things live

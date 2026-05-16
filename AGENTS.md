# skogai/marketplace

Plugin catalog and development workspace for skogai plugins.

## routes

- @PLAN.md -- current direction and near-term tasks; read this first
- .claude-plugin/marketplace.json -- Claude Code catalog (source of truth); pluginRoot = ./plugins
- .agents/plugins/marketplace.json -- Codex catalog

## contents

- @plugins/ -- installable plugins
- @hooks/ -- reference hook implementations (not wired up); pattern → hooks/CLAUDE.md
- @tests/ -- bats test suites; run with `bats tests/**/*.bats`; rules → tests/CLAUDE.md
- @docs/claude-code/ -- docs snapshots (gitignored); refresh with scripts/fetch-hook-docs.sh
- .plans/ -- per-task implementation specs linked from PLAN.md
- .codex/config.toml -- repo-local Codex baseline config

## conventions

- @CLAUDE.md → @AGENTS.md (symlinked — same file, both agents pick it up)
- symlinks: agents, bin, commands, skills, .claude → @.skogai/ submodule; edit in core not here
- .agents/ and .codex/ are repo-local Codex dirs, not symlinks
- full file map → @FILESTRUCTURE.md

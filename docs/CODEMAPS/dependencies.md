<!-- Generated: 2026-05-16 | Files scanned: 2806 | Token estimate: ~720 -->
# Dependencies Codemap

## Runtime Toolchain
- Bash/sh: hook scripts, installers, bats suites, doc fetch scripts.
- Node.js: `plugins/skogai-core/scripts/hooks/*.js` and `scripts/lib/*.js` hook/runtime logic.
- Python 3: lesson matcher, harness installer, dashboard runtime/prototype learning scripts.
- jq: hook JSON extraction/output and skogai-jq transform tests.
- Bats: hook regression suites (`tests/**/*.bats`, `plugins/skogai-core/tests/*.bats`).
- Git/Codex/Claude CLIs: marketplace install/smoke workflows.

## External Services / Integrations
- Claude Code plugin marketplace (`.claude-plugin/marketplace.json`).
- Codex plugin marketplace (`.agents/plugins/marketplace.json`, `.codex/config.toml`).
- MCP health/config support in core scripts (`mcp-health-check.js`, `mcp-config.js`).
- Desktop notifications, tmux/worktree orchestration, package-manager/formatter detection in core plugin.
- GitHub Actions workflows: `.github/workflows/claude.yml`, `.github/workflows/claude-code-review.yml`.

## Shared Libraries In-Repo
```
scripts/skogai-jq.sh                  -> root reference hooks
plugins/skogai-core/scripts/skogai-jq.sh -> plugin-local vendored copy
plugins/skogai-core/scripts/lib/*     -> JS runtime utilities
plugins/skogai-jq/skills/skogai-jq/*  -> jq transform library + docs/tests
```

## Dependency Detection Notes
- No `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, or lockfiles detected.
- Dependencies are implicit system tools rather than package-manager-resolved modules.
- Network-fetch scripts update ignored official docs snapshots under `docs/claude-code/` and `docs/codex/`.

## Test Commands
- `bats tests/**/*.bats`: root hook/Codex suites.
- `bats plugins/skogai-core/tests/*.bats`: core plugin hook/setup suites.
- `python -m pytest hooks/test_lesson_matcher.py plugins/skogai-core/scripts/test_lesson_matcher.py`: lesson matcher suites if pytest is installed.

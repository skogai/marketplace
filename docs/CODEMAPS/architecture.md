<!-- Generated: 2026-05-16 | Files scanned: 2806 | Token estimate: ~650 -->
# System Architecture Codemap

## Project Type
Claude Code/Codex plugin marketplace monorepo: catalogs + installable plugins + hook reference implementations + bats suites.

## Source Boundaries
```
.claude-plugin/marketplace.json ─┐
.agents/plugins/marketplace.json ├─> marketplace catalogs -> plugins/*
.codex/config.toml              ┘

hooks/*.sh + scripts/skogai-jq.sh -> reference Claude hook pattern -> tests/*
plugins/skogai-core/             -> always-loaded plugin; real hook/runtime payload
plugins/skogai-jq/               -> jq transform skill/library
plugins/skogai-plugin/           -> plugin authoring agents/commands/skills
plugins/skogai-learning/         -> continuous-learning hooks/prototypes
plugins/codex-hooks/             -> Codex marketplace smoke plugin
plugins/skogai-harness/          -> external harness installer/docs/media
```

## Entry Points
- Claude catalog: `.claude-plugin/marketplace.json` (`metadata.pluginRoot=./plugins`).
- Codex catalog: `.agents/plugins/marketplace.json` (`codex-hooks` installed by default).
- Root hook examples: `hooks/session-start.sh`, `hooks/pre-tool-use.sh`, `hooks/post-tool-use.sh`, `hooks/pre-compact.sh`, `hooks/stop.sh`, `hooks/user-prompt-submit.sh`.
- Core plugin hooks: `plugins/skogai-core/hooks/hooks.json` -> `plugins/skogai-core/scripts/hooks/*.js` via `plugin-hook-bootstrap.js` / `run-with-flags.js`.
- Shared hook I/O: `scripts/skogai-jq.sh`; plugin-vendored copy: `plugins/skogai-core/scripts/skogai-jq.sh`.
- Lesson matcher CLI/module: `hooks/lesson_matcher.py` and `plugins/skogai-core/scripts/lesson_matcher.py`.

## Data Flow
```
Agent runtime -> marketplace catalog -> plugin install/cache
Agent hook JSON stdin -> hook script -> skogai-jq helpers -> JSON stdout + /tmp/<session>.jsonl
User prompt/tool event -> lesson_matcher.py -> additionalContext injection
Bats fixtures -> hook scripts/manifests -> regression assertions
```

## Key Files
- `AGENTS.md` / `PLAN.md`: repo operating model and current direction.
- `FILESTRUCTURE.md`: curated tree map.
- `docs/hook-compatibility.md`: Claude/Codex hook output compatibility notes.
- `.plans/*.md`: implementation specs for hook, lessons, workflow tracks.

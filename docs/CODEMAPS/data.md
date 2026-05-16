<!-- Generated: 2026-05-16 | Files scanned: 2806 | Token estimate: ~610 -->
# Data / Persistence Codemap

## Stores
No database, ORM, migrations, or durable service datastore detected. Persistence is file/catalog based.

## Catalog Data
```
.claude-plugin/marketplace.json
  name/owner/metadata.pluginRoot/plugins[] -> Claude Code plugin catalog
.agents/plugins/marketplace.json
  plugins[] -> Codex local marketplace entries
plugins/*/.codex-plugin/plugin.json
  Codex plugin interface metadata, skills path, capabilities
plugins/*/hooks.json
  Hook event matcher -> command route definitions
```

## Runtime Files
- Hook input/fixtures: `hooks/example-inputs/*.json`, `tests/fixtures/codex-hooks/*.json`.
- Hook logs: `/tmp/<session_id>.jsonl` via `skogai_jq_log`.
- Continuous learning config: `plugins/skogai-learning/continuous-learning*/config.json`.
- Learned skills target: `~/.claude/skills/learned/` (configured, not auto-approved by default).
- Codex test cache: `$HOME/.codex/plugins/cache/skogai/codex-hooks/local`.

## Transform Library Data
- `plugins/skogai-jq/skills/skogai-jq/*/transform.jq`: reusable jq transforms.
- Matching `schema.json`, `test-input-*.json`, and `test.sh` files define examples/regression data for each transform.
- Root `skogai-jq/` symlink points at plugin transform library for script lookup.

## Relationships
```
marketplace plugin.source -> plugins/<name>
hooks.json command paths -> plugin-local scripts/hooks/*.js or hooks/*.sh
bats test -> fixture JSON -> hook script -> expected JSON/exit behavior
lesson markdown frontmatter -> lesson_matcher.py -> ranked context snippets
```

## Migration History
No schema migrations. Versioning is per marketplace/plugin JSON (`version` fields) plus git history.

<!-- Generated: 2026-05-16 | Files scanned: 2806 | Token estimate: ~420 -->
# Frontend / User-Facing Surface Codemap

## UI Type
No web frontend or routed pages. User-facing surfaces are marketplace metadata, plugin skills, commands, agents, markdown docs, and hook messages rendered by agent runtimes.

## Marketplace Presentation
```
Claude Code UI/catalog -> .claude-plugin/marketplace.json -> plugins/* descriptions
Codex plugin UI        -> .agents/plugins/marketplace.json -> plugins/codex-hooks/.codex-plugin/plugin.json interface
```

## Skill / Command Tree
- `plugins/codex-hooks/skills/codex-hooks-smoke/SKILL.md`: Codex smoke-test skill exposed by local plugin cache.
- `plugins/skogai-core/skills/skogai-routing/SKILL.md`: routing guidance for core sessions.
- `plugins/skogai-plugin/skills/*/SKILL.md`: plugin, skill, command, hook, MCP, and settings authoring guidance.
- `plugins/skogai-plugin/agents/*.md`: plugin validator, skill reviewer, agent creator.
- `plugins/skogai-plugin/commands/create-plugin.md`: plugin creation command.
- `plugins/skogai-jq/skills/skogai-jq/*.md`: jq transform skill docs, cheat sheet, examples, backlog.

## Hook Message Flow
```
Hook stdout JSON -> hookSpecificOutput.additionalContext / permissionDecisionReason
Hook stderr      -> user/agent-visible warnings depending on runtime + exit code
Markdown rules   -> agent context (rules/common, rules/<language>, rules/web, rules/zh)
```

## Static Assets
- `plugins/skogai-harness/clips/*`: screenshots/video referenced by harness docs.
- No bundled CSS/JS app shell, component hierarchy, or client state manager detected.

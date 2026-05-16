<!-- Generated: 2026-05-16 | Files scanned: 2806 | Token estimate: ~760 -->
# Backend / Hook Runtime Codemap

## API Surface
No HTTP backend. Runtime integration is hook/event driven through Claude Code and Codex plugin manifests.

## Hook Routes
```
SessionStart       -> hooks/session-start.sh        -> skogai_jq_context
UserPromptSubmit   -> hooks/user-prompt-submit.sh   -> lesson_matcher.py -> additionalContext
PreToolUse         -> hooks/pre-tool-use.sh         -> allow/block dangerous tool calls
PostToolUse        -> hooks/post-tool-use.sh        -> workflow progress + log append
PreCompact         -> hooks/pre-compact.sh         -> compact-trigger log
Stop               -> hooks/stop.sh                -> stop-git-dirty.sh + stop-quality-gate.sh
```

## Core Plugin Dispatch
```
plugins/skogai-core/hooks/hooks.json
  PreToolUse Bash       -> scripts/hooks/pre-bash-dispatcher.js
  Write/Edit guards     -> run-with-flags.js -> doc/config/console/design checks
  PostToolUse Bash/Edit -> post-bash-dispatcher.js / edit accumulators / format/typecheck
  Session/Stop hooks    -> session-start.js, session-end.js, suggest-compact.js
```

## Libraries
- `scripts/skogai-jq.sh`: reads stdin once; exports `HOOK_INPUT`, `HOOK_SESSION_ID`, `HOOK_EVENT`, `HOOK_LOG`; emits Claude/Codex-shaped JSON helpers.
- `plugins/skogai-core/scripts/lib/*.js`: package-manager, formatter resolution, project detection, session/alias/orchestration, install lifecycle/state/manifests, MCP config/health support.
- `plugins/skogai-core/scripts/lib/*.d.ts`: lightweight type declarations for package manager and session helpers.
- `hooks/lesson_matcher.py`: YAML-ish frontmatter parser, lesson discovery, scoring by keywords/tools, formatted context output.

## Tests
- Root bats suites validate hook behavior and Codex fixtures/marketplace smoke.
- `plugins/skogai-core/tests/*.bats` validate core hook manifest/setup/debug behavior.
- Python lesson matcher tests live beside implementations in root and core plugin.

## Side Effects
- `/tmp/<session_id>.jsonl`: hook debug log.
- Codex smoke cache: `$HOME/.codex/plugins/cache/skogai/codex-hooks/local` in tests.
- Learning plugin paths: `~/.claude/skills/learned/` for extracted patterns (disabled/approval-gated by config).

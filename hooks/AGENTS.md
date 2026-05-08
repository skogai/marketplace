# AGENTS.md - dot-core hooks

## OVERVIEW
Event-driven shell routers for context injection, guardrails, permission logging, tool logging, and stop-time checks. Shared Python matcher handles lesson selection.

## STRUCTURE (KEY FILES)
```
hooks/
├── session-start.sh       # Session context and lesson injection
├── user-prompt-submit.sh  # Prompt context and lesson injection
├── pre-tool-use.sh        # Guardrail and tool lesson lookup
├── stop.sh                # Router to stop sub-hooks
├── stop-git-dirty.sh      # Dirty worktree warning
├── stop-quality-gate.sh   # End-of-turn checks
├── lesson_matcher.py      # Shared lesson matcher
└── test_lesson_matcher.py # Pytest coverage
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Event wiring | `../hooks.json` | Current source of mapped events |
| JSON helpers | `../scripts/skogai-jq.sh` | Field/log/context output helpers |
| Session context | `session-start.sh` | Loads session context and lessons |
| Prompt context | `user-prompt-submit.sh` | Loads prompt-scoped lessons |
| Guardrails | `pre-tool-use.sh` | Blocks dangerous commands |
| Stop checks | `stop.sh` | Fans out to stop sub-hooks |
| Lesson matching | `lesson_matcher.py` | YAML frontmatter search |

## CONVENTIONS
- Hook scripts receive JSON on stdin and should emit valid hook JSON when responding.
- Source `../scripts/skogai-jq.sh` for repeated field extraction, logging, and response helpers.
- Context injection is fail-open; optional lesson/context failures must not block the user turn.
- `lesson_matcher.py` skips `README.md`, `TEMPLATE.md`, root `YYYY-MM-DD-*.md` notes, and `status: deprecated` or `status: archived` lessons.
- Matcher result caps are intentional: session 3, prompt 3, tool 2.
- Tests use pytest for `lesson_matcher.py` and Bats under `../tests/` for shell hook behavior.

## ANTI-PATTERNS
- Do not add non-schema event names to `hooks.json`; Codex currently exposes `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, and `Stop`.
- Do not add empty catch blocks or silent failure paths that hide broken mandatory behavior.
- Do not parse hook JSON ad hoc when `skogai-jq.sh` already provides the helper.
- Do not make optional context lookup fail closed.

## COMMANDS
```bash
# From plugins/dot-core

# Manual hook run
bash hooks/session-start.sh < input.json

# Python matcher tests
uvx pytest hooks/test_lesson_matcher.py -v

# Related Bats suites
bats tests/session-start/session-start.bats
bats tests/pre-tool-use/pre-tool-use.bats
bats tests/stop/router.bats
```

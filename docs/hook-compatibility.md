# Claude Code vs Codex Hook Compatibility

Date: 2026-05-10

This matrix is based on the checked-in local docs snapshots:

- `docs/codex/hooks.md`
- `docs/codex/hooks/schema/generated/*.json`
- `docs/claude-code/hooks.md`
- `docs/claude-code/hooks-guide.md`

`scripts/skogai-jq.sh` should stay the shared JSON I/O layer. Output helpers that rely on event semantics should be platform-specific when Codex and Claude use the same field names differently.

## Common Ground

| Area | Status | Notes |
| --- | --- | --- |
| Input transport | shared | Hook scripts receive JSON on stdin. |
| Common input fields | mostly shared | Both include `session_id`, `cwd`, `hook_event_name`, and transcript context. Codex generated schemas make more fields required. |
| Logging | shared | `skogai_jq_log` is platform-neutral JSONL logging. |
| Field extraction | shared | `skogai_jq_field` is platform-neutral. |
| Context output | shared shape | `hookSpecificOutput.hookEventName` plus `additionalContext` works for supported context-injection events. |

## Event Matrix

| Event | Shared Inputs | Claude-Specific Notes | Codex-Specific Notes | Recommended Helper |
| --- | --- | --- | --- | --- |
| `SessionStart` | `session_id`, `cwd`, `hook_event_name`, `source`, transcript path | `source` may include `compact`; supports context injection. | Generated schema requires `model`, `permission_mode`, `source`, `transcript_path`; docs list `startup` and `resume`. | `skogai_jq_codex_context` or existing `skogai_jq_context` when platform-neutral. |
| `UserPromptSubmit` | `session_id`, `cwd`, `hook_event_name`, `prompt`, transcript path | Can inject context or block prompt. | `matcher` ignored; `decision:"block"` blocks prompt; common `continue:false` is supported. | `skogai_jq_codex_context`, `skogai_jq_codex_block`, `skogai_jq_codex_stop`. |
| `PreToolUse` | `tool_name`, `tool_input`, `tool_use_id`, permission mode | `permissionDecision` supports `allow`, `deny`, `ask`; `deny` blocks the tool. | Only `permissionDecision:"deny"` is supported today; `allow`, `ask`, `updatedInput`, `additionalContext`, and `continue:false` fail open. Legacy `decision:"block"` is accepted. | `skogai_jq_codex_pre_tool_deny`; use `skogai_jq_codex_block` only for legacy shape. |
| `PermissionRequest` | `tool_name`, `tool_input`, permission mode | Decision is `hookSpecificOutput.decision.behavior` with `allow` or `deny`. | Same shape, but `updatedInput`, `updatedPermissions`, and `interrupt` fail closed today. | `skogai_jq_codex_permission_request`. |
| `PostToolUse` | `tool_name`, `tool_input`, `tool_response`, `tool_use_id` | `decision:"block"` feeds feedback to Claude after the tool has run; may support tool output rewriting. | `decision:"block"` replaces the tool result with feedback and continues; `continue:false` stops normal processing of the original result. `updatedMCPToolOutput` fails open. | `skogai_jq_codex_block`, `skogai_jq_codex_context`, `skogai_jq_codex_stop`. |
| `Stop` | `stop_hook_active`, `last_assistant_message` | `decision:"block"` prevents Claude from stopping and asks it to continue. | Same top-level shape, but plain text stdout is invalid; `continue:false` takes precedence over continuation. | `skogai_jq_codex_continue_turn`, `skogai_jq_codex_stop`. |
| `PreCompact` | `trigger` | Can block compaction with exit 2 or JSON `decision:"block"`; includes `custom_instructions`. | Generated schema exists; output schema only has common fields. | Add hook-specific wrappers only when implementing Codex compact hooks. |
| `PostCompact` | `trigger` | Observational; includes `compact_summary`; cannot affect result. | Generated schema exists; output schema only has common fields. | Shared logging helpers are enough for now. |

## Current Setup Decision

Keep these shared:

- `skogai_jq_field`
- `skogai_jq_log`
- `skogai_jq_bool`
- `skogai_jq_context` for platform-neutral context injection
- `skogai_jq_decision` for existing legacy hook scripts

Use these Codex-explicit helpers for new Codex hook wiring:

- `skogai_jq_codex_context`
- `skogai_jq_codex_pre_tool_deny`
- `skogai_jq_codex_permission_request`
- `skogai_jq_codex_block`
- `skogai_jq_codex_continue_turn`
- `skogai_jq_codex_stop`

Do not use generic `skogai_jq_decision "block"` in new Codex `Stop` hooks without naming the intent. In Codex, `decision:"block"` on `Stop` means "continue the turn", not "reject output".

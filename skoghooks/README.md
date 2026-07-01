# skoghooks

Lifecycle hooks for logging, context loading, and validation across Claude Code sessions.

## Overview

`skoghooks` wires a script into every Claude Code lifecycle event (session start/end, prompt submit, tool use, permission requests, notifications, stop, subagent start/stop, and pre-compact) to provide consistent logging and context handling across sessions.

## Installation

```bash
/plugin install ./skoghooks
```

Or from the SkogAI Market marketplace:

```bash
/plugin marketplace add skogai-market/marketplace
/plugin install skoghooks
```

## Components

### Hooks

`hooks/hooks.json` registers a script for each lifecycle event:

- `SessionStart` — `scripts/session_start.py --load-context`
- `SessionEnd` — `scripts/session_end.py`
- `Setup` — `scripts/setup.py`
- `UserPromptSubmit` — `scripts/user_prompt_submit.py --log-only --store-last-prompt --name-agent`
- `PreToolUse` — `scripts/pre_tool_use.py`
- `PostToolUse` — `scripts/post_tool_use.py`
- `PostToolUseFailure` — `scripts/post_tool_use_failure.py`
- `PermissionRequest` — `scripts/permission_request.py --log-only`
- `Notification` — `scripts/notification.py`
- `Stop` — `scripts/stop.py --chat`
- `SubagentStart` — `scripts/subagent_start.py`
- `SubagentStop` — `scripts/subagent_stop.py --chat`
- `PreCompact` — `scripts/pre_compact.py --backup`

Each script is a standalone `uv run` script with its own inline dependencies.

### Hook Events

| Event | Fires | Key payload fields |
| --- | --- | --- |
| `UserPromptSubmit` | immediately when the user submits a prompt, before Claude processes it | `prompt`, `session_id` |
| `PreToolUse` | before any tool execution | `tool_name`, `tool_input` |
| `PostToolUse` | after successful tool completion | `tool_name`, `tool_input`, `tool_response` |
| `PostToolUseFailure` | when a tool execution fails | `tool_name`, `tool_input`, `tool_use_id`, `error` |
| `PermissionRequest` | when the user is shown a permission dialog | `tool_name`, `tool_input`, `tool_use_id` |
| `Notification` | when Claude Code sends a notification (e.g. waiting for input) | `message` |
| `Stop` | when Claude Code finishes responding | `stop_hook_active`, `transcript_path` |
| `SubagentStart` | when a subagent (Task tool) spawns | `agent_id`, `agent_type` |
| `SubagentStop` | when a subagent finishes responding | `stop_hook_active` |
| `PreCompact` | before a compaction operation | `trigger` (`manual`/`auto`), `custom_instructions` |
| `SessionStart` | on new session or resume | `source` (`startup`/`resume`/`clear`) |
| `SessionEnd` | on session exit, sigint, or error | `session_id`, `transcript_path`, `cwd`, `reason` |
| `Setup` | on repo init or periodic maintenance | `trigger` (`init`/`maintenance`), `cwd` |

Note: `session_start.py` also supports an unwired `--announce` flag that speaks a message via `utils/tts/pyttsx3_tts.py`; TTS utilities exist under `utils/tts/` but aren't invoked by any hook wired in `hooks.json` by default.

### Validators

`scripts/validators/` contains additional checks (`ruff_validator.py`, `ty_validator.py`, `validate_new_file.py`, `validate_file_contains.py`) usable from the hooks above.

## Hook Pattern

Every hook script follows this shape:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
import json, sys

input_data = json.load(sys.stdin)
# ... hook-specific logic ...
# log to <runtime_dir>/{name}.json via append_log(), see get_runtime_dir()
sys.exit(0)                          # never exit non-zero unless blocking
```

- **Block a tool call**: print reason to stderr, `sys.exit(2)`.
- **Output context**: print `{"hookSpecificOutput": {"additionalContext": "..."}}` then exit 0.
- **Never crash**: hooks catch exceptions and exit 0 rather than propagate.

Test a hook locally, e.g.:

```bash
echo '{"session_id":"test","hook_event_name":"SessionStart"}' | uv run scripts/session_start.py --load-context
```

## Available Script Flags

| Script                | Active flags (wired in `hooks.json`)          | Other supported flags |
| ---------------------- | --------------------------------------------- | ---------------------- |
| session_start.py       | `--load-context`                              | `--announce`            |
| session_end.py         | —                                             | `--cleanup`             |
| setup.py               | —                                             | `--install-deps` `--verbose` |
| user_prompt_submit.py  | `--log-only --store-last-prompt --name-agent` | `--validate`            |
| pre_tool_use.py        | —                                             | —                      |
| post_tool_use.py       | —                                             | —                      |
| post_tool_use_failure.py | —                                            | —                      |
| permission_request.py  | `--log-only`                                  | `--auto-allow`          |
| notification.py        | —                                             | —                      |
| stop.py                | `--chat`                                      | —                      |
| subagent_start.py      | —                                             | —                      |
| subagent_stop.py       | `--chat`                                      | —                      |
| pre_compact.py         | `--backup`                                    | `--verbose`             |

## Non-Obvious Behaviours

- **pre_tool_use.py** blocks on `rm -rf` variants (regex) and `.env` file access (not `.env.sample`). Exit 2 = blocked.
- **permission_request.py** with `--auto-allow`: outputs `{behavior: "allow"}` for Read/Glob/Grep and safe bash patterns. Not active in the distributed `hooks.json` — only `--log-only` is wired by default.
- **session_start.py** with `--load-context`: outputs git branch, uncommitted count, and context files as `additionalContext`.
- **stop.py** / **subagent_stop.py** with `--chat`: converts the session transcript JSONL into `<runtime_dir>/chat.json`.
- **setup.py** with `--install-deps`: auto-detects `package.json`/`requirements.txt`/`pyproject.toml` and runs the matching installer (`npm ci`, `pip install -r`, or `uv sync`).
- **session_end.py** with `--cleanup`: removes stale temp/log files.
- **user_prompt_submit.py** with `--name-agent`: calls `utils/llm/ollama.py --agent-name` (local Ollama, model via `OLLAMA_MODEL` env var, default `gpt-oss:20b`). If Ollama is unavailable, the agent name is simply not set.

## Runtime Output Location

All hook logs, transcript backups, and lock files are written under
`$CLAUDE_CODE_TMPDIR/skoghooks/<session_id>/` if `CLAUDE_CODE_TMPDIR` is set,
otherwise under the system temp directory (e.g. `/tmp/skoghooks/<session_id>/`).
`session_id` comes from each hook's own JSON stdin payload. This keeps output
scoped per-session regardless of the hook's working directory, and prevents
concurrent sessions from clobbering each other's logs. See
`scripts/utils/runtime_dir.py` for the implementation.

`utils/tts/tts_queue.py` and `utils/llm/task_summarizer.py` are also
session-scoped this way, but — like `--announce` above — remain unwired by
default.

## Requirements

- `uv` available on `PATH` (used to run the hook scripts)
- Ollama running locally, only if using `user_prompt_submit.py --name-agent`

## License

MIT

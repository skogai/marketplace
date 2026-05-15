#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
log_path="${SKOGAI_CODEX_HOOK_LOG:-${TMPDIR:-/tmp}/skogai-codex-hooks.jsonl}"

mkdir -p "$(dirname "$log_path")"

if command -v jq >/dev/null 2>&1; then
  printf '%s\n' "$input" |
    jq -c \
      --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
      '{
        timestamp: $timestamp,
        event: .hook_event_name,
        session_id: .session_id,
        cwd: .cwd,
        tool_name: (.tool_name // null),
        tool_use_id: (.tool_use_id // null)
      }' >>"$log_path"
else
  printf '{"timestamp":"%s","raw":%s}\n' \
    "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    "$(printf '%s' "$input" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')" >>"$log_path"
fi

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$("$SCRIPT_DIR/find-agent-root.sh")"
DOCS_DIR="$AGENT_DIR/docs/codex"
SCHEMA_DIR="$DOCS_DIR/hooks/schema/generated"

mkdir -p "$SCHEMA_DIR"

echo "hooks.md"
curl -fsSL "https://developers.openai.com/codex/hooks.md" -o "$DOCS_DIR/hooks.md"

SCHEMA_BASE="https://raw.githubusercontent.com/openai/codex/main/codex-rs/hooks/schema/generated"
for schema in \
    permission-request.command.input.schema.json \
    permission-request.command.output.schema.json \
    post-compact.command.input.schema.json \
    post-compact.command.output.schema.json \
    post-tool-use.command.input.schema.json \
    post-tool-use.command.output.schema.json \
    pre-compact.command.input.schema.json \
    pre-compact.command.output.schema.json \
    pre-tool-use.command.input.schema.json \
    pre-tool-use.command.output.schema.json \
    session-start.command.input.schema.json \
    session-start.command.output.schema.json \
    stop.command.input.schema.json \
    stop.command.output.schema.json \
    user-prompt-submit.command.input.schema.json \
    user-prompt-submit.command.output.schema.json; do
    echo "hooks/schema/generated/$schema"
    curl -fsSL "$SCHEMA_BASE/$schema" -o "$SCHEMA_DIR/$schema"
done

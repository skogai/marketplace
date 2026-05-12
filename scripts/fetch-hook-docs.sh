#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/fetch-claude-code-docs.sh"
"$SCRIPT_DIR/fetch-codex-hook-docs.sh"

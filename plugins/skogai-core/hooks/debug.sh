#!/usr/bin/env bash
# Debug hook

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/skogai-jq.sh"

skogai_jq_log "example.sh debug"

exit 0

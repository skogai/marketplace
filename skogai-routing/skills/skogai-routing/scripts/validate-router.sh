#!/usr/bin/env bash
# validate-router.sh — validate routing file(s) against router.schema.json
#
# Usage:
#   ./scripts/validate-router.sh <file> [file...]
#
# Exit codes:
#   0  all files passed or warned
#   1  one or more files failed validation

set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <file> [file...]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
SCHEMA_DIR="$SKILL_ROOT/schemas"
HELPER="$SCRIPT_DIR/_validate_router.py"

fail=0
for file in "$@"; do
  if ! uv run "$HELPER" "$SCHEMA_DIR" "$file"; then
    fail=1
  fi
done

exit "$fail"

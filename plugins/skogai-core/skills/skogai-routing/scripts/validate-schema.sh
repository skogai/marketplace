#!/usr/bin/env bash
# validate-schema.sh — validate framework files against skogai JSON schemas
#
# Usage:
#   ./scripts/validate-schema.sh [ROOT]
#
# ROOT defaults to the skill root (parent of scripts/).
# Pass an explicit path to validate a different framework directory.
#
# Exit codes:
#   0  all files passed or warned
#   1  one or more files failed validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-"$(dirname "$SCRIPT_DIR")"}"
SCHEMA_DIR="$ROOT/schemas"
HELPER="$SCRIPT_DIR/_validate_file.py"

if [[ ! -d "$SCHEMA_DIR" ]]; then
  echo "ERROR: schemas dir not found: $SCHEMA_DIR" >&2
  exit 1
fi
if [[ ! -f "$HELPER" ]]; then
  echo "ERROR: validator helper not found: $HELPER" >&2
  exit 1
fi

# ── schema overview ──────────────────────────────────────────────────────────
echo "=== skogai schema overview ==="
echo ""
echo "  schema dir: $SCHEMA_DIR"
echo ""
printf "  %-35s %s\n" "schema" "maps to type"
printf "  %-35s %s\n" "------" "------------"
for f in "$SCHEMA_DIR"/*.schema.json; do
  name="$(basename "$f")"
  type_val="$(python3 - "$f" << 'PY'
import json, sys, warnings
warnings.filterwarnings("ignore")
s = json.load(open(sys.argv[1]))
def find_type(obj):
    if isinstance(obj, dict):
        if obj.get('properties', {}).get('type', {}).get('const'):
            return obj['properties']['type']['const']
        for v in obj.values():
            r = find_type(v)
            if r: return r
    elif isinstance(obj, list):
        for item in obj:
            r = find_type(item)
            if r: return r
    return None
t = find_type(s)
print(t if t else '(shared defs)')
PY
)"
  printf "  %-35s %s\n" "$name" "$type_val"
done

echo ""
echo "=== validating files in: $ROOT ==="
echo ""

# ── validate all .md files that have frontmatter or an XML root tag ──────────
pass=0
fail=0
warn=0
total=0

while IFS= read -r -d '' file; do
  rel="${file#"$ROOT/"}"
  [[ "$rel" == schemas/* ]] && continue
  [[ "$(basename "$file")" == "README.md" ]] && continue

  first="$(head -1 "$file")"
  [[ "$first" == "---" ]] || echo "$first" | grep -qE "^<[a-z]" || continue

  total=$((total + 1))
  result="$(python3 "$HELPER" "$SCHEMA_DIR" "$file" 2>&1)"
  echo "  $result"

  case "${result:0:4}" in
    PASS) pass=$((pass + 1)) ;;
    FAIL) fail=$((fail + 1)) ;;
    WARN) warn=$((warn + 1)) ;;
  esac

done < <(find "$ROOT" -type f -name "*.md" -print0 | sort -z)

echo ""
echo "=== summary: $total checked | $pass passed | $fail failed | $warn warned ==="
echo ""

[[ "$fail" -eq 0 ]]

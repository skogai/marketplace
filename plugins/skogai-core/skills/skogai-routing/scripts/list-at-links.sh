#!/usr/bin/env bash
# Extract all @-links from one or more files. Shows file and linked path.
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: list-at-links.sh <file|dir> [...]" >&2
  exit 1
fi

find "$@" -type f -name '*.md' -print 2>/dev/null | sort |
  while IFS= read -r file; do
    links=$(grep -Eo '@[^[:space:]>)]+' "$file" 2>/dev/null | sort -u | paste -sd ' ' - || true)
    if [ -n "$links" ]; then
      printf '%s: %s\n' "$file" "$links"
    fi
  done

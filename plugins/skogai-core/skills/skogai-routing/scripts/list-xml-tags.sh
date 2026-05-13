#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  set -- SKILL.md workflows references templates
fi

find "$@" -type f \( -name '*.md' -o -name 'SKILL.md' \) -print 2>/dev/null |
  sort |
  while IFS= read -r file; do
    tags=$({ grep -Eoh '</?[A-Za-z][A-Za-z0-9_-]*[^>]*>' "$file" 2>/dev/null || true; } |
      sed -E 's/^<\///; s/^<//; s/[ >].*$//' |
      awk '!seen[$0]++' |
      paste -sd ' ' -)

    if [ -n "$tags" ]; then
      printf '%s: %s\n' "$file" "$tags"
    else
      printf '%s: %s\n' "$file" "(no xml tags)"
    fi
  done

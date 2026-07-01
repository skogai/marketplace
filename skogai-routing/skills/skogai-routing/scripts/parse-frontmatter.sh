#!/bin/bash
# Frontmatter parser for skogai routing files (SKOGAI.md, CLAUDE.md router blocks)
# Adapted from plugin-dev's plugin-settings/scripts/parse-frontmatter.sh

set -euo pipefail

show_usage() {
  echo "Usage: $0 <file.md> [field-name]"
  echo ""
  echo "Examples:"
  echo "  $0 SKOGAI.md            # show all frontmatter"
  echo "  $0 SKOGAI.md type       # extract the 'type' field"
  exit 0
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  show_usage
fi

FILE="$1"
FIELD="${2:-}"

if [ ! -f "$FILE" ]; then
  echo "Error: File not found: $FILE" >&2
  exit 1
fi

FRONTMATTER=$(awk '/^---$/{n++; next} n==1' "$FILE")

if [ -z "$FRONTMATTER" ]; then
  echo "Error: No frontmatter found in $FILE" >&2
  exit 1
fi

if [ -z "$FIELD" ]; then
  echo "$FRONTMATTER"
  exit 0
fi

VALUE=$(echo "$FRONTMATTER" | grep "^${FIELD}:" | sed "s/${FIELD}: *//" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\\(.*\\)'$/\\1/")

if [ -z "$VALUE" ]; then
  echo "Error: Field '$FIELD' not found in frontmatter" >&2
  exit 1
fi

echo "$VALUE"

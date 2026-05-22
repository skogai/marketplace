#!/usr/bin/env bash
# List all CAPS.md router files (CLAUDE.md, AGENTS.md, SKILL.md, PLAN.md, etc.)
set -euo pipefail

ROOT="${1:-.}"

find "$ROOT" -type f -name '[A-Z]*.md' |
  grep -v '/\.' |
  sort

#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat >&2 <<EOF
Usage: create-gh-issue.sh --title TITLE --body BODY [--ref PATH]... [--repo OWNER/REPO] [--dry-run]

  --title    Issue title (required)
  --body     Issue description (required)
  --ref      Path to a reference file relative to the skill root; may be repeated
  --repo     GitHub repo (default: current repo via gh)
  --dry-run  Print the issue body without creating the issue
EOF
  exit 1
}

TITLE=""
BODY=""
REFS=()
REPO_ARG=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)  TITLE="$2";      shift 2 ;;
    --body)   BODY="$2";       shift 2 ;;
    --ref)    REFS+=("$2");    shift 2 ;;
    --repo)   REPO_ARG="$2";   shift 2 ;;
    --dry-run) DRY_RUN=true;   shift   ;;
    *) usage ;;
  esac
done

[[ -z "$TITLE" || -z "$BODY" ]] && usage

issue_body="# Description

${BODY}"

for ref in "${REFS[@]}"; do
  ref_path="${SKILL_DIR}/${ref}"
  if [[ ! -f "$ref_path" ]]; then
    echo "Error: reference file not found: $ref_path" >&2
    exit 1
  fi
  section_title="$(basename "$ref" .md)"
  issue_body+="

# ${section_title}

$(cat "$ref_path")"
done

if "$DRY_RUN"; then
  echo "$issue_body"
  exit 0
fi

repo_flag=()
[[ -n "$REPO_ARG" ]] && repo_flag=(--repo "$REPO_ARG")

gh issue create \
  --title "$TITLE" \
  --body "$issue_body" \
  "${repo_flag[@]}"

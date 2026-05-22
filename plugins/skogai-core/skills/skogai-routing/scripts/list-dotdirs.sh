#!/usr/bin/env bash
# List dotfile directories — these should always be @-linked since they're hidden by default.
set -euo pipefail

ROOT="${1:-.}"

find "$ROOT" -maxdepth 3 -type d -name '.*' |
  grep -v '/.git' |
  sort

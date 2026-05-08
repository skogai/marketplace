#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"
ERRORS=0

fail() { echo "ERROR: $*" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "WARN:  $*"; }
ok()   { echo "OK:    $*"; }

echo "Validating $MANIFEST"
echo ""

# JSON syntax
if ! jq empty "$MANIFEST" 2>/dev/null; then
  fail "marketplace.json: invalid JSON syntax"
  exit 1
fi
ok "marketplace.json: valid JSON"

# Required top-level fields
for field in name owner plugins; do
  val=$(jq -r --arg f "$field" '.[$f] // empty' "$MANIFEST")
  if [[ -z "$val" ]]; then
    fail "marketplace.json: missing required field '$field'"
  fi
done

name=$(jq -r '.name' "$MANIFEST")
if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
  warn "marketplace name '$name' should be kebab-case (lowercase letters, digits, hyphens)"
fi
ok "marketplace name: $name"

# Owner fields
owner_name=$(jq -r '.owner.name // empty' "$MANIFEST")
[[ -z "$owner_name" ]] && fail "marketplace.json: owner.name is required"

# Plugins array
plugin_count=$(jq '.plugins | length' "$MANIFEST")
if [[ "$plugin_count" -eq 0 ]]; then
  warn "marketplace.json: no plugins defined"
else
  ok "plugins: $plugin_count defined"
fi

# Validate each plugin entry
jq -c '.plugins[]' "$MANIFEST" | while IFS= read -r plugin; do
  pname=$(echo "$plugin" | jq -r '.name // empty')
  [[ -z "$pname" ]] && fail "plugin entry missing 'name'"

  source=$(echo "$plugin" | jq -r '.source // empty')
  [[ -z "$source" ]] && fail "plugin '$pname': missing 'source'"

  if [[ ! "$pname" =~ ^[a-z0-9-]+$ ]]; then
    warn "plugin name '$pname' should be kebab-case"
  fi

  # For relative path sources, check the directory exists
  if echo "$source" | grep -qE '^\./'; then
    plugin_dir="$MARKETPLACE_ROOT/$source"
    if [[ ! -d "$plugin_dir" ]]; then
      fail "plugin '$pname': relative source '$source' does not exist"
    else
      # Check for plugin.json manifest
      if [[ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]]; then
        warn "plugin '$pname': no .claude-plugin/plugin.json found at $plugin_dir"
      else
        # Validate plugin.json syntax
        if ! jq empty "$plugin_dir/.claude-plugin/plugin.json" 2>/dev/null; then
          fail "plugin '$pname': .claude-plugin/plugin.json has invalid JSON"
        else
          ok "plugin '$pname': plugin.json valid"
        fi
      fi
    fi
  else
    ok "plugin '$pname': external source"
  fi
done

echo ""
if [[ "$ERRORS" -gt 0 ]]; then
  echo "Validation failed: $ERRORS error(s)" >&2
  exit 1
else
  echo "Validation passed"
fi

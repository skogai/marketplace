#!/usr/bin/env bash
# stop-quality-gate.sh — end-of-turn quality checks
#
# Called by stop.sh. Reads JSON input from $1 (file path).
# Runs project-specific linters/checks (non-blocking).

set -euo pipefail

input_file="$1"
VERBOSE="${CLAUDE_HOOK_VERBOSE:-false}"
TIMEOUT=30

log() {
  if [[ "$VERBOSE" == "true" ]]; then echo "[quality-gate] $*" >&2; fi
}

run_check() {
  local name="$1" cmd="$2"
  log "Running: $name"
  if timeout "$TIMEOUT" bash -c "$cmd" 2>/dev/null; then
    log "pass: $name"
  else
    log "fail: $name (non-blocking)"
  fi
  return 0
}

# --- project detection ---

is_nodejs()     { [[ -f "package.json" ]]; }
is_typescript() { [[ -f "tsconfig.json" ]]; }
is_python()     { [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; }
is_rust()       { [[ -f "Cargo.toml" ]]; }
is_go()         { [[ -f "go.mod" ]]; }
is_plain() {
  if is_nodejs || is_python || is_rust || is_go; then return 1; fi
  return 0
}

# --- project checks ---

check_nodejs() {
  log "Detected Node.js project"
  [[ ! -d "node_modules" ]] && return 0
  if grep -q '"lint"' package.json 2>/dev/null; then
    run_check "npm lint" "npm run lint --silent"
  fi
  if is_typescript; then
    if grep -q '"typecheck"' package.json 2>/dev/null; then
      run_check "typecheck" "npm run typecheck --silent"
    elif command -v tsc &>/dev/null; then
      run_check "tsc" "tsc --noEmit"
    fi
  fi
}

check_python() {
  log "Detected Python project"
  command -v ruff &>/dev/null && run_check "ruff" "ruff check . --fix --silent"
  command -v black &>/dev/null && run_check "black" "black --check --quiet ."
  if command -v mypy &>/dev/null && [[ -f "mypy.ini" || -f "pyproject.toml" ]]; then
    run_check "mypy" "mypy . --silent-imports"
  fi
}

check_rust() {
  log "Detected Rust project"
  command -v cargo &>/dev/null && run_check "cargo check" "cargo check --quiet"
  command -v cargo &>/dev/null && run_check "clippy" "cargo clippy --quiet -- -D warnings"
}

check_go() {
  log "Detected Go project"
  command -v go &>/dev/null && run_check "go vet" "go vet ./..."
  command -v staticcheck &>/dev/null && run_check "staticcheck" "staticcheck ./..."
}

# --- universal checks ---

check_secrets() {
  log "Checking for exposed secrets"
  if git rev-parse --git-dir &>/dev/null; then
    local staged_files
    staged_files=$(git diff --cached --name-only 2>/dev/null || true)
    if [[ -n "$staged_files" ]]; then
      if echo "$staged_files" | xargs grep -l -E "(API_KEY|SECRET|TOKEN|PASSWORD)\s*[=:]\s*['\"][A-Za-z0-9_\-]{16,}" 2>/dev/null; then
        echo "Warning: Possible hardcoded secrets in staged files" >&2
      fi
    fi
  fi
}

check_env_committed() {
  log "Checking .env not staged"
  if git rev-parse --git-dir &>/dev/null; then
    if git diff --cached --name-only 2>/dev/null | grep -q "^\.env"; then
      echo "Warning: .env file is staged for commit" >&2
    fi
  fi
}

# --- main ---

log "Starting quality checks"
if is_plain; then
  log "Plain repo, skipping language checks"
elif is_nodejs; then check_nodejs
elif is_python; then check_python
elif is_rust;   then check_rust
elif is_go;     then check_go
fi
check_secrets
check_env_committed
log "Quality checks complete"

exit 0

#!/usr/bin/env bash
set -euo pipefail

# Test join-todos transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing join-todos transformation..."

# Test 1: Basic array of todos
echo -n "Test 1: Basic array of todos... "
result=$(jq -r -f "$TRANSFORM" "$SCRIPT_DIR/test-input-1.json")
expected='Write tests (completed), Deploy (pending), Fix bug (in_progress)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Nested path to todos
echo -n "Test 2: Nested path to todos... "
result=$(jq -r -f "$TRANSFORM" --arg path "input.todos" "$SCRIPT_DIR/test-input-2.json")
expected='Fix bug (in_progress)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: Empty array
echo -n "Test 3: Empty array... "
result=$(jq -r -f "$TRANSFORM" "$SCRIPT_DIR/test-input-3.json")
expected=''
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: (empty string)"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Single todo
echo -n "Test 4: Single todo... "
result=$(jq -r -f "$TRANSFORM" "$SCRIPT_DIR/test-input-4.json")
expected='Single task (pending)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Missing status defaults to pending
echo -n "Test 5: Missing status defaults to pending... "
result=$(jq -r -f "$TRANSFORM" "$SCRIPT_DIR/test-input-5.json")
expected='Task A (pending), Task B (done)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Non-array input returns empty string
echo -n "Test 6: Non-array input returns empty string... "
result=$(jq -r -f "$TRANSFORM" "$SCRIPT_DIR/test-input-6.json")
expected=''
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: (empty string)"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Alternate field name (text instead of content)
echo -n "Test 7: Alternate field name (text instead of content)... "
result=$(jq -r -f "$TRANSFORM" "$SCRIPT_DIR/test-input-7.json")
expected='Alt field (active)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Custom separator
echo -n "Test 8: Custom separator... "
result=$(jq -r -f "$TRANSFORM" --arg separator " | " "$SCRIPT_DIR/test-input-1.json")
expected='Write tests (completed) | Deploy (pending) | Fix bug (in_progress)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Deep nested path
echo -n "Test 9: Deep nested path... "
result=$(jq -r -f "$TRANSFORM" --arg path "wrapper.items" "$SCRIPT_DIR/test-input-8.json")
expected='Nested A (ok), Nested B (pending)'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Path to non-existent field returns empty
echo -n "Test 10: Path to non-existent field returns empty... "
result=$(jq -r -f "$TRANSFORM" --arg path "missing.field" "$SCRIPT_DIR/test-input-8.json")
expected=''
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: (empty string)"
    echo "  Got: $result"
    exit 1
fi

echo "All join-todos tests passed!"
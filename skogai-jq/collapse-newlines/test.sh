#!/usr/bin/env bash
set -euo pipefail

# Test collapse-newlines transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing collapse-newlines transformation..."

# Test 1: Basic newline collapse
echo -n "Test 1: Basic newline collapse... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-1.json")
expected='{"text":"line one line two line three"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Nested path
echo -n "Test 2: Nested path... "
result=$(jq -c -f "$TRANSFORM" --arg path "message.body" "$SCRIPT_DIR/test-input-2.json")
expected='{"message":{"body":"hello world"}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: No newlines (unchanged)
echo -n "Test 3: No newlines (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-3.json")
expected='{"text":"no newlines here"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Empty string (unchanged)
echo -n "Test 4: Empty string (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-4.json")
expected='{"text":""}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Null value (unchanged)
echo -n "Test 5: Null value (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-5.json")
expected='{"text":null}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Non-string value (unchanged)
echo -n "Test 6: Non-string value (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-6.json")
expected='{"text":42}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Path doesn't exist (unchanged)
echo -n "Test 7: Path doesn't exist (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-7.json")
expected='{"other":"field"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Only newlines (becomes spaces)
echo -n "Test 8: Only newlines (becomes spaces)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-8.json")
expected='{"text":"   "}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Leading and trailing newlines
echo -n "Test 9: Leading and trailing newlines... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-9.json")
expected='{"text":" leading and trailing "}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Boolean false value (unchanged)
echo -n "Test 10: Boolean false value (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "text" "$SCRIPT_DIR/test-input-10.json")
expected='{"text":false}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 11: Raw string input (path="")
echo -n "Test 11: Raw string input (path empty)... "
result=$(echo '"hello\nworld"' | jq -f "$TRANSFORM" --arg path "")
expected='"hello world"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All collapse-newlines tests passed!"
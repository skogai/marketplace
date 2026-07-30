#!/usr/bin/env bash
set -euo pipefail

# Test format-timestamp transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing format-timestamp transformation..."

# Test 1: Format timestamp in object field (date)
echo -n "Test 1: Format timestamp in object field (date)... "
result=$(jq -c -f "$TRANSFORM" --arg path "event.created_at" --arg format "%Y-%m-%d" "$SCRIPT_DIR/test-input-1.json")
expected='{"event":{"created_at":"2023-11-14"}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Format timestamp in object field (time)
echo -n "Test 2: Format timestamp in object field (time)... "
result=$(jq -c -f "$TRANSFORM" --arg path "event.created_at" --arg format "%H:%M:%S" "$SCRIPT_DIR/test-input-1.json")
expected='{"event":{"created_at":"22:13:20"}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: Unix epoch (0) formats correctly
echo -n "Test 3: Unix epoch (0) formats correctly... "
result=$(jq -c -f "$TRANSFORM" --arg path "timestamp" --arg format "%Y-%m-%d" "$SCRIPT_DIR/test-input-2.json")
expected='{"timestamp":"1970-01-01"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Non-number value (unchanged)
echo -n "Test 4: Non-number value (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "created" --arg format "%Y-%m-%d" "$SCRIPT_DIR/test-input-3.json")
expected='{"created":"not-a-number"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Path doesn't exist (unchanged)
echo -n "Test 5: Path doesn't exist (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "missing" --arg format "%Y-%m-%d" "$SCRIPT_DIR/test-input-4.json")
expected='{"other":"field"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Null value (unchanged)
echo -n "Test 6: Null value (unchanged)... "
result=$(jq -c -f "$TRANSFORM" --arg path "ts" --arg format "%Y-%m-%d" "$SCRIPT_DIR/test-input-5.json")
expected='{"ts":null}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Deep nested path
echo -n "Test 7: Deep nested path... "
result=$(jq -c -f "$TRANSFORM" --arg path "deep.nested.time" --arg format "%Y-%m-%d" "$SCRIPT_DIR/test-input-6.json")
expected='{"deep":{"nested":{"time":"2023-11-14"}}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Raw number input (no path)
echo -n "Test 8: Raw number input (no path)... "
result=$(echo '1700000000' | jq -f "$TRANSFORM" --arg format "%Y-%m-%dT%H:%M:%SZ")
expected='"2023-11-14T22:13:20Z"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Current time returns a string (format only, can't test exact value)
echo -n "Test 9: Current time returns a string... "
result=$(jq -n -f "$TRANSFORM" --arg format "%H:%M:%S")
# Should be a quoted string matching HH:MM:SS pattern
if [[ "$result" =~ ^\"[0-9]{2}:[0-9]{2}:[0-9]{2}\"$ ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: quoted HH:MM:SS string"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Default format is HH:MM:SS
echo -n "Test 10: Default format is HH:MM:SS... "
result=$(echo '1700000000' | jq -f "$TRANSFORM")
expected='"22:13:20"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 11: ISO format
echo -n "Test 11: ISO format... "
result=$(jq -c -f "$TRANSFORM" --arg path "event.created_at" --arg format "%Y-%m-%dT%H:%M:%SZ" "$SCRIPT_DIR/test-input-1.json")
expected='{"event":{"created_at":"2023-11-14T22:13:20Z"}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All format-timestamp tests passed!"
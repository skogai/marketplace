#!/usr/bin/env bash
set -euo pipefail

# Test extract-content-array transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing extract-content-array transformation..."

# Test 1: Basic text extraction
echo -n "Test 1: Basic text extraction... "
result=$(jq -f "$TRANSFORM" --arg path "message.content" "$SCRIPT_DIR/test-input-1.json")
expected='"Hello world"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Multiple text items with default separator
echo -n "Test 2: Multiple text items (default separator)... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-2.json")
expected='"First\nSecond"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: Multiple text items with custom separator
echo -n "Test 3: Multiple text items (custom separator)... "
result=$(jq -f "$TRANSFORM" --arg path "content" --arg separator " " "$SCRIPT_DIR/test-input-2.json")
expected='"First Second"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Handle tool_use blocks
echo -n "Test 4: Handle tool_use blocks... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-3.json")
expected='"Using tool\n[tool_use: Read]"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Missing path returns null
echo -n "Test 5: Missing path returns null... "
result=$(jq -f "$TRANSFORM" --arg path "message.content" "$SCRIPT_DIR/test-input-4.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Empty string value (falsy but valid)
echo -n "Test 6: Empty string value... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-5.json")
expected='""'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Null text value
echo -n "Test 7: Null text value... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-6.json")
expected='""'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Empty array
echo -n "Test 8: Empty array... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-7.json")
expected='""'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: String content (not array) returns string directly
echo -n "Test 9: String content returns string... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-8.json")
expected='"plain string"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Handle tool_result with nested content
echo -n "Test 10: Handle tool_result with nested content... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-9.json")
expected='"Result text"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 11: Deep nested path
echo -n "Test 11: Deep nested path... "
result=$(jq -f "$TRANSFORM" --arg path "deep.nested.content" "$SCRIPT_DIR/test-input-10.json")
expected='"Deep value"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 12: Text value "0" (falsy but valid)
echo -n "Test 12: Text value '0' (falsy but valid)... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-11.json")
expected='"0"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 13: Plain strings in array
echo -n "Test 13: Plain strings in array... "
result=$(jq -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-12.json")
expected='"plain\nstrings\nin\narray"'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All extract-content-array tests passed!"

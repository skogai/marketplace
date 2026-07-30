#!/usr/bin/env bash
set -euo pipefail

# Test extract-tool-calls transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing extract-tool-calls transformation..."

# Test 1: Extract single tool call
echo -n "Test 1: Extract single tool call... "
result=$(jq -c -f "$TRANSFORM" --arg path "message.content" "$SCRIPT_DIR/test-input-1.json")
expected='[{"name":"Read","id":"123","input":{"path":"/file.txt"}}]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Extract multiple tool calls (skip text)
echo -n "Test 2: Extract multiple tool calls... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-2.json")
expected='[{"name":"Bash","id":"1","input":{"command":"ls"}},{"name":"Read","id":"2","input":{"path":"/test"}}]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: No tool calls returns empty array
echo -n "Test 3: No tool calls returns empty array... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-3.json")
expected='[]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Empty array returns empty array
echo -n "Test 4: Empty array returns empty array... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-4.json")
expected='[]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Missing path returns empty array
echo -n "Test 5: Missing path returns empty array... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-5.json")
expected='[]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Non-array content returns empty array
echo -n "Test 6: Non-array content returns empty array... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-6.json")
expected='[]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Null name value (falsy but valid)
echo -n "Test 7: Null name value... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-7.json")
expected='[{"name":null,"id":"1","input":{}}]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Empty string values (falsy but valid)
echo -n "Test 8: Empty string and null values... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-8.json")
expected='[{"name":"","id":"","input":null}]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Empty object returns empty array
echo -n "Test 9: Empty object returns empty array... "
result=$(jq -c -f "$TRANSFORM" --arg path "content" "$SCRIPT_DIR/test-input-9.json")
expected='[]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Deep nested path
echo -n "Test 10: Deep nested path... "
result=$(jq -c -f "$TRANSFORM" --arg path "deep.nested.content" "$SCRIPT_DIR/test-input-10.json")
expected='[{"name":"Test","id":"deep","input":{"a":1}}]'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All extract-tool-calls tests passed!"

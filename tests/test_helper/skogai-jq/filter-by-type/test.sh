#!/usr/bin/env bash
set -euo pipefail

# Test filter-by-type transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing filter-by-type transformation..."

# Test 1: Match user type
echo -n "Test 1: Match user type... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" "$SCRIPT_DIR/test-input-1.json")
expected='{"type":"user","message":{"content":"hello"}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: No match returns null
echo -n "Test 2: No match returns null... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" "$SCRIPT_DIR/test-input-2.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: Match assistant type
echo -n "Test 3: Match assistant type... "
result=$(jq -c -f "$TRANSFORM" --arg type "assistant" "$SCRIPT_DIR/test-input-2.json")
expected='{"type":"assistant","message":{"content":"hi"}}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Match system type
echo -n "Test 4: Match system type... "
result=$(jq -c -f "$TRANSFORM" --arg type "system" "$SCRIPT_DIR/test-input-3.json")
expected='{"type":"system","subtype":"turn_duration","durationMs":1000}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Missing type field returns null
echo -n "Test 5: Missing type field returns null... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" "$SCRIPT_DIR/test-input-4.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Null type value (falsy)
echo -n "Test 6: Null type value... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" "$SCRIPT_DIR/test-input-5.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Empty string type - match empty
echo -n "Test 7: Empty string type - match empty... "
result=$(jq -c -f "$TRANSFORM" --arg type "" "$SCRIPT_DIR/test-input-6.json")
expected='{"type":"","data":"empty type"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Inverted match - exclude user
echo -n "Test 8: Inverted match - exclude user... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" --arg invert "true" "$SCRIPT_DIR/test-input-3.json")
expected='{"type":"system","subtype":"turn_duration","durationMs":1000}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Inverted match - returns null when type matches
echo -n "Test 9: Inverted match - returns null when type matches... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" --arg invert "true" "$SCRIPT_DIR/test-input-1.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Match summary type
echo -n "Test 10: Match summary type... "
result=$(jq -c -f "$TRANSFORM" --arg type "summary" "$SCRIPT_DIR/test-input-7.json")
expected='{"type":"summary","summary":"Chat title"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 11: Match queue-operation type
echo -n "Test 11: Match queue-operation type... "
result=$(jq -c -f "$TRANSFORM" --arg type "queue-operation" "$SCRIPT_DIR/test-input-8.json")
expected='{"type":"queue-operation","operation":"dequeue"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 12: Empty object returns null
echo -n "Test 12: Empty object returns null... "
result=$(jq -c -f "$TRANSFORM" --arg type "user" "$SCRIPT_DIR/test-input-9.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 13: Boolean false type (falsy but exists)
echo -n "Test 13: Boolean false type... "
result=$(jq -c -f "$TRANSFORM" --arg type "false" "$SCRIPT_DIR/test-input-10.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All filter-by-type tests passed!"

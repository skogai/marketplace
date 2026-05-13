#!/usr/bin/env bash
set -euo pipefail

# Test to-skogchat transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing to-skogchat transformation..."

# Test 1: Convert user message
echo -n "Test 1: Convert user message... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-1.json")
expected='{"eid":"abc123","from":"user","to":"claude","content":"hello world","created-at":"2025-01-01T00:00:00Z","parent":null}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Convert assistant message with content array
echo -n "Test 2: Convert assistant message... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-2.json")
expected='{"eid":"def456","from":"claude","to":"user","content":"hi there","created-at":"2025-01-01T00:00:01Z","parent":"abc123"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: Skip system message
echo -n "Test 3: Skip system message... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-3.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: Skip summary message
echo -n "Test 4: Skip summary message... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-4.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: Assistant with tool_use
echo -n "Test 5: Assistant with tool_use... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-5.json")
expected='{"eid":"ghi789","from":"claude","to":"user","content":"Using tool\n[tool_use: Read]","created-at":"2025-01-01T00:00:02Z","parent":"def456"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Empty string content (falsy but valid)
echo -n "Test 6: Empty string content... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-6.json")
expected='{"eid":"jkl012","from":"user","to":"claude","content":"","created-at":"2025-01-01T00:00:03Z","parent":"ghi789"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Empty text in content array
echo -n "Test 7: Empty text in content array... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-7.json")
expected='{"eid":"mno345","from":"user","to":"claude","content":"","created-at":"2025-01-01T00:00:04Z","parent":null}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Skip queue-operation
echo -n "Test 8: Skip queue-operation... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-8.json")
expected='null'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Multiple text items joined
echo -n "Test 9: Multiple text items joined... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-9.json")
expected='{"eid":"pqr678","from":"claude","to":"user","content":"First\nSecond","created-at":"2025-01-01T00:00:05Z","parent":"mno345"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 10: Content "0" (falsy but valid)
echo -n "Test 10: Content '0' (falsy but valid)... "
result=$(jq -c -f "$TRANSFORM" --arg agent "claude" "$SCRIPT_DIR/test-input-10.json")
expected='{"eid":"stu901","from":"user","to":"claude","content":"0","created-at":"2025-01-01T00:00:06Z","parent":"pqr678"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 11: Different agent name
echo -n "Test 11: Different agent name... "
result=$(jq -c -f "$TRANSFORM" --arg agent "gptme" "$SCRIPT_DIR/test-input-2.json")
expected='{"eid":"def456","from":"gptme","to":"user","content":"hi there","created-at":"2025-01-01T00:00:01Z","parent":"abc123"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 12: Default agent name (no arg)
echo -n "Test 12: Default agent name... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-2.json")
expected='{"eid":"def456","from":"claude","to":"user","content":"hi there","created-at":"2025-01-01T00:00:01Z","parent":"abc123"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All to-skogchat tests passed!"

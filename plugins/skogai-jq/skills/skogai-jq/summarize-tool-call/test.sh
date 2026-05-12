#!/usr/bin/env bash
set -euo pipefail

# Test summarize-tool-call transformation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="$SCRIPT_DIR/transform.jq"

echo "Testing summarize-tool-call transformation..."

# Test 1: Read tool shows file_path
echo -n "Test 1: Read tool shows file_path... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-1.json")
expected='{"name":"Read","detail":"/home/user/src/main.py","summary":"Read: /home/user/src/main.py"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 2: Bash tool shows command
echo -n "Test 2: Bash tool shows command... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-2.json")
expected='{"name":"Bash","detail":"npm test --coverage","summary":"Bash: npm test --coverage"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 3: Edit tool shows file_path
echo -n "Test 3: Edit tool shows file_path... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-3.json")
expected='{"name":"Edit","detail":"/home/user/src/utils.ts","summary":"Edit: /home/user/src/utils.ts"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 4: WebFetch shows URL
echo -n "Test 4: WebFetch shows URL... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-4.json")
expected='{"name":"WebFetch","detail":"https://example.com/api/docs","summary":"WebFetch: https://example.com/api/docs"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 5: TodoWrite shows joined todos
echo -n "Test 5: TodoWrite shows joined todos... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-5.json")
expected='{"name":"TodoWrite","detail":"todos: Fix bug (completed), Deploy (pending)","summary":"TodoWrite: todos: Fix bug (completed), Deploy (pending)"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 6: Agent tool shows prompt
echo -n "Test 6: Agent tool shows prompt... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-6.json")
expected='{"name":"Agent","detail":"Search for authentication patterns","summary":"Agent: Search for authentication patterns"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 7: Unknown tool with empty input (no detail)
echo -n "Test 7: Unknown tool with empty input... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-7.json")
expected='{"name":"UnknownTool","detail":"","summary":"UnknownTool"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 8: Grep tool shows pattern
echo -n "Test 8: Grep tool shows pattern... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-8.json")
expected='{"name":"Grep","detail":"TODO|FIXME","summary":"Grep: TODO|FIXME"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 9: Newlines collapsed in detail
echo -n "Test 9: Newlines collapsed in detail... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-9.json")
expected="$(echo -n '{"name":"Bash","detail":"echo '"'"'line one\\nline two\\nline three'"'"'","summary":"Bash: echo '"'"'line one\\nline two\\nline three'"'"'"}')"
# Just check that the result contains no literal newlines in detail
detail=$(jq -r '.detail' "$SCRIPT_DIR/test-input-9.json" | jq -R -f "$TRANSFORM" 2>/dev/null || true)
result_detail=$(echo "$result" | jq -r '.detail')
if [[ "$result_detail" != *$'\n'* ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Detail should not contain literal newlines"
    echo "  Got: $result_detail"
    exit 1
fi

# Test 10: Write tool shows file_path
echo -n "Test 10: Write tool shows file_path... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-10.json")
expected='{"name":"Write","detail":"/tmp/output.txt","summary":"Write: /tmp/output.txt"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 11: WebSearch shows query
echo -n "Test 11: WebSearch shows query... "
result=$(jq -c -f "$TRANSFORM" "$SCRIPT_DIR/test-input-11.json")
expected='{"name":"WebSearch","detail":"jq streaming tutorial 2026","summary":"WebSearch: jq streaming tutorial 2026"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

# Test 12: Truncation with max_length
echo -n "Test 12: Truncation with max_length... "
result=$(jq -c -f "$TRANSFORM" --argjson max_length 10 "$SCRIPT_DIR/test-input-2.json")
expected='{"name":"Bash","detail":"npm test -…","summary":"Bash: npm test -…"}'
if [[ "$result" == "$expected" ]]; then
    echo "PASS"
else
    echo "FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    exit 1
fi

echo "All summarize-tool-call tests passed!"
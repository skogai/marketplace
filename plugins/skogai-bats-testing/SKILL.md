---
name: skogai-bats-testing
description: Master Bash Automated Testing System (Bats) for comprehensive shell script testing. Use when writing tests for shell scripts, creating test suites, using the skogai testing framework, debugging failing bats tests, or requiring test-driven development of shell utilities.
---

<essential_principles>

## Bats Testing with skogai

Bats (Bash Automated Testing System) is a TAP-compliant testing framework and the standard for all bash script testing in skogai projects. The skogai testing framework wraps bats-core with portable helpers for temp dirs, git repos, assertions, and script sourcing.

### 1. Test Structure

Every test file follows this pattern:

```bash
#!/usr/bin/env bats

load ../test-helper

setup() {
    setup_test_dir     # creates $TEST_DIR, cd's into it
}

teardown() {
    teardown_test_dir  # cleans up $TEST_DIR
}

@test "descriptive test name" {
    run command_under_test args
    assert_success
    assert_output_contains "expected"
}
```

### 2. The `run` + Assert Pattern

**Always use `run` before assertions.** The `run` keyword captures exit status in `$status` and stdout in `$output`. The `${lines[]}` array holds each line of output separately.

```bash
@test "example" {
    run my_command arg1 arg2
    assert_success              # $status -eq 0
    assert_output_equals "foo"  # $output == "foo"
}
```

Without `run`, assertions have nothing to check.

### 3. skogai Test Helper API

**Assertions** (all require `run` first):

| Assertion | Checks |
|-----------|--------|
| `assert_success` | `$status -eq 0` |
| `assert_failure` | `$status -ne 0` |
| `assert_output_contains "str"` | `$output` contains string |
| `assert_output_not_contains "str"` | `$output` does not contain string |
| `assert_output_equals "str"` | `$output` exactly matches string |
| `assert_file_exists "path"` | file exists at path |
| `assert_dir_exists "path"` | directory exists at path |

**Helper functions:**

| Helper | Purpose |
|--------|---------|
| `setup_test_dir` | Creates temp dir `$TEST_DIR`, cd's into it |
| `teardown_test_dir` | Removes `$TEST_DIR` |
| `setup_git_repo` | Initializes git repo in `$TEST_DIR` with initial commit |
| `source_script "name.sh"` | Sources script from `$SCRIPTS_DIR` without executing main |
| `skip_if_missing cmd` | Skips test if command not found |

**Environment variables:**

| Variable | Set By | Value |
|----------|--------|-------|
| `$PROJECT_ROOT` | test-helper | Parent of `tests/` directory (repo root) |
| `$SCRIPTS_DIR` | test-helper | `$PROJECT_ROOT/scripts` (overridable) |
| `$TEST_DIR` | `setup_test_dir` | Temporary directory for test isolation |
| `$BATS_TEST_DIRNAME` | bats-core | Directory containing the current `.bats` file |

### 4. Running Tests

```bash
# run all tests in a directory
bats tests/**/*.bats

# run specific test file
bats tests/pre-tool-use/pre-tool-use.bats

# TAP output for CI
bats tests/**/*.bats --tap

# parallel execution
bats tests/**/*.bats --jobs 4

# make run output visible (debug failing tests)
bats tests/**/*.bats --verbose-run
```

### 5. Installation

```bash
# Arch Linux
sudo pacman -S bats

# macOS
brew install bats-core

# npm (cross-platform)
npm install --global bats

# from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core && ./install.sh /usr/local

bats --version
```

</essential_principles>

<assertion_patterns>

## Raw Bats Assertions

When skogai helpers aren't available or you need more specific checks, use raw bats assertions directly.

### Exit Code Assertions

```bash
@test "command succeeds" {
    run true
    [ "$status" -eq 0 ]
}

@test "command fails as expected" {
    run false
    [ "$status" -ne 0 ]
}

@test "returns specific exit code" {
    run my_function --invalid
    [ "$status" -eq 127 ]
}
```

### Output Assertions

```bash
@test "output matches exact string" {
    run echo "hello world"
    [ "$output" = "hello world" ]
}

@test "output contains substring" {
    run echo "hello world"
    [[ "$output" == *"world"* ]]
}

@test "output matches regex" {
    run date +%Y
    [[ "$output" =~ ^[0-9]{4}$ ]]
}

@test "multi-line output via lines array" {
    run printf "line1\nline2\nline3"
    [ "${lines[0]}" = "line1" ]
    [ "${lines[1]}" = "line2" ]
    [ "${lines[2]}" = "line3" ]
}

@test "multi-line output exact match" {
    run printf "line1\nline2\nline3"
    [ "$output" = "line1
line2
line3" ]
}
```

### File Assertions

```bash
@test "file is created" {
    [ ! -f "$TEST_DIR/output.txt" ]
    my_function > "$TEST_DIR/output.txt"
    [ -f "$TEST_DIR/output.txt" ]
}

@test "file contents match" {
    echo "expected" > "$TEST_DIR/file.txt"
    [ "$(cat "$TEST_DIR/file.txt")" = "expected" ]
}

@test "file is readable" {
    touch "$TEST_DIR/test.txt"
    [ -r "$TEST_DIR/test.txt" ]
}

@test "file size is correct" {
    echo -n "12345" > "$TEST_DIR/test.txt"
    [ "$(wc -c < "$TEST_DIR/test.txt")" -eq 5 ]
}
```

</assertion_patterns>

<setup_teardown>

## Setup and Teardown Patterns

### Per-Test Setup/Teardown

Runs before/after **each** `@test`:

```bash
setup() {
    setup_test_dir
    source "${BATS_TEST_DIRNAME}/../bin/script.sh"
}

teardown() {
    teardown_test_dir
}
```

### Per-File Setup/Teardown

Runs once before/after **all** tests in the file. Use for expensive resources:

```bash
setup_file() {
    export SHARED_RESOURCE=$(mktemp -d)
    echo "expensive setup" > "$SHARED_RESOURCE/data.txt"
}

teardown_file() {
    rm -rf "$SHARED_RESOURCE"
}

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "first test uses shared resource" {
    [ -f "$SHARED_RESOURCE/data.txt" ]
}

@test "second test also uses it" {
    [ -d "$SHARED_RESOURCE" ]
}
```

### Setup with Directory Structure

```bash
setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/data/input"
    mkdir -p "$TEST_DIR/data/output"
    echo "line1" > "$TEST_DIR/data/input/file1.txt"
    echo "line2" > "$TEST_DIR/data/input/file2.txt"
    export INPUT_DIR="$TEST_DIR/data/input"
    export OUTPUT_DIR="$TEST_DIR/data/output"
}
```

</setup_teardown>

<test_patterns>

## Common Test Patterns

### Testing a script's functions (without executing main)

```bash
setup() {
    setup_test_dir
    cat > "$TEST_DIR/myscript.sh" << 'EOF'
my_function() {
    echo "result: $1"
}
EOF
    source "$TEST_DIR/myscript.sh"
}

@test "my_function returns expected result" {
    run my_function "input"
    assert_success
    assert_output_equals "result: input"
}
```

### Testing a project script via $SCRIPTS_DIR

```bash
@test "project script handles missing args" {
    run "$SCRIPTS_DIR/my-script.sh"
    assert_failure
    assert_output_contains "usage:"
}

@test "project script succeeds with valid input" {
    run "$SCRIPTS_DIR/my-script.sh" "valid-arg"
    assert_success
}
```

### Testing file operations

```bash
@test "script creates output file" {
    cat > "$TEST_DIR/generate.sh" << 'EOF'
#!/bin/bash
echo "generated content" > output.txt
EOF
    chmod +x "$TEST_DIR/generate.sh"

    run "$TEST_DIR/generate.sh"
    assert_success
    assert_file_exists "output.txt"

    run cat output.txt
    assert_output_contains "generated content"
}
```

### Testing git interactions

```bash
setup() {
    setup_test_dir
    setup_git_repo    # creates repo with initial commit
}

@test "can detect dirty working tree" {
    echo "change" > new.txt
    run git status --porcelain
    assert_success
    assert_output_contains "new.txt"
}

@test "can check git log" {
    run git log --oneline
    assert_success
    assert_output_contains "Initial commit"
}
```

### Testing error conditions

```bash
@test "fails with missing file" {
    run my_function "/nonexistent/file.txt"
    assert_failure
    assert_output_contains "not found"
}

@test "fails with empty input" {
    run my_function ""
    assert_failure
}

@test "fails with permission denied" {
    touch "$TEST_DIR/readonly.txt"
    chmod 000 "$TEST_DIR/readonly.txt"
    run my_function "$TEST_DIR/readonly.txt"
    assert_failure
    chmod 644 "$TEST_DIR/readonly.txt"
}

@test "provides helpful error message" {
    run my_function --invalid-option
    assert_failure
    assert_output_contains "Usage:"
}
```

### Conditional skipping

```bash
@test "requires docker" {
    skip_if_missing docker
    run docker ps
    assert_success
}

@test "requires jq for JSON parsing" {
    if ! command -v jq &>/dev/null; then
        skip "jq is not installed"
    fi
    run my_json_parser '{"key": "value"}'
    assert_success
}
```

### Testing specific exit codes

```bash
@test "returns exit code 2 on bad input" {
    run my_command --invalid
    [ "$status" -eq 2 ]
}
```

</test_patterns>

<mocking_stubbing>

## Mocking and Stubbing

### Function Mocking

Override a function the script under test calls:

```bash
@test "function uses mocked dependency" {
    # Override the real function
    my_external_tool() {
        echo "mocked output"
        return 0
    }
    export -f my_external_tool

    run my_function
    assert_success
    assert_output_contains "mocked output"
}
```

### Command Stubbing via PATH

Create fake executables that shadow real commands:

```bash
setup() {
    setup_test_dir
    STUBS_DIR="$TEST_DIR/stubs"
    mkdir -p "$STUBS_DIR"
    export PATH="$STUBS_DIR:$PATH"
}

create_stub() {
    local cmd="$1"
    local output="$2"
    local code="${3:-0}"

    cat > "$STUBS_DIR/$cmd" <<EOF
#!/bin/bash
echo "$output"
exit $code
EOF
    chmod +x "$STUBS_DIR/$cmd"
}

@test "works with stubbed curl" {
    create_stub curl '{ "status": "ok" }' 0
    run my_api_function
    assert_success
    assert_output_contains "ok"
}

@test "handles curl failure" {
    create_stub curl "connection refused" 1
    run my_api_function
    assert_failure
}
```

### Variable/Environment Stubbing

```bash
@test "respects environment override" {
    export MY_SETTING="override_value"
    run my_function
    assert_success
    assert_output_contains "override_value"
}

@test "uses default when var unset" {
    unset MY_SETTING
    run my_function
    assert_success
    assert_output_contains "default"
}
```

</mocking_stubbing>

<fixtures>

## Fixture Management

### Static Fixtures

Place fixture files in `tests/fixtures/` and reference via `$BATS_TEST_DIRNAME`:

```bash
setup() {
    setup_test_dir
    FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
}

@test "processes fixture file" {
    cp "$FIXTURES_DIR/input.txt" "$TEST_DIR/input.txt"
    run my_process_function "$TEST_DIR/input.txt"
    assert_success
    diff "$TEST_DIR/output.txt" "$FIXTURES_DIR/expected_output.txt"
}
```

### Dynamic Fixture Generation

```bash
generate_fixture() {
    local lines="$1"
    local file="$2"
    for i in $(seq 1 "$lines"); do
        echo "Line $i content" >> "$file"
    done
}

@test "handles large input" {
    generate_fixture 1000 "$TEST_DIR/large.txt"
    run my_function "$TEST_DIR/large.txt"
    assert_success
    [ "$(wc -l < "$TEST_DIR/large.txt")" -eq 1000 ]
}
```

</fixtures>

<shell_compatibility>

## Shell Compatibility Testing

```bash
@test "script works in bash" {
    run bash "${BATS_TEST_DIRNAME}/../bin/script.sh" arg1
    assert_success
}

@test "script works in sh (POSIX)" {
    run sh "${BATS_TEST_DIRNAME}/../bin/script.sh" arg1
    assert_success
}

@test "script works in dash" {
    skip_if_missing dash
    run dash "${BATS_TEST_DIRNAME}/../bin/script.sh" arg1
    assert_success
}
```

</shell_compatibility>

<ci_integration>

## CI/CD Integration

### GitHub Actions

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Bats
        run: npm install --global bats
      - name: Run Tests
        run: bats tests/*.bats
      - name: Run Tests (TAP output)
        run: bats tests/*.bats --tap | tee test_output.tap
```

### Makefile

```makefile
.PHONY: test test-verbose test-parallel

test:
	bats tests/*.bats

test-verbose:
	bats tests/*.bats --verbose

test-parallel:
	bats tests/*.bats --jobs 4
```

</ci_integration>

<file_conventions>

## File Naming and Structure

```
project/
├── hooks/                # hook scripts under test
├── scripts/              # scripts under test ($SCRIPTS_DIR)
└── tests/
    ├── test-helper.bash  # shared assertions and helpers
    ├── pre-tool-use/
    │   └── pre-tool-use.bats
    ├── stop/
    │   ├── git-dirty.bats
    │   └── quality-gate.bats
    └── fixtures/         # static test data (if needed)
        └── input.json
```

- Test files: `{category}-tests.bats` or `{script-name}.bats`
- Examples: `example-{category}-tests.bats`
- Templates: `{name}.bats.template`

</file_conventions>

<gotchas>

## Common Pitfalls

1. **Forgetting `run`** — assertions check `$status` and `$output` which are only set by `run`
2. **Not using `setup_test_dir`** — tests that create files without temp dirs pollute the workspace
3. **Heredoc quoting** — use `<< 'EOF'` (quoted) to prevent variable expansion in test fixtures
4. **Sourcing scripts that auto-execute** — use `source_script` helper or guard main code with `[[ "${BASH_SOURCE[0]}" == "${0}" ]]`
5. **Path assumptions** — use `$PROJECT_ROOT`, `$SCRIPTS_DIR`, `$TEST_DIR`, `$BATS_TEST_DIRNAME` instead of hardcoded paths
6. **Missing teardown** — always pair `setup_test_dir` with `teardown_test_dir` to avoid temp dir leaks
7. **Stubbed commands leaking** — stubs via PATH only persist within the test if `$TEST_DIR` is cleaned up properly
8. **Permission cleanup** — if you `chmod 000` a file in a test, restore permissions before teardown or `rm -rf` will fail

</gotchas>

<best_practices>

## Best Practices

1. **Test one thing per test** — single responsibility
2. **Use descriptive test names** — state what is being tested and expected outcome
3. **Clean up after tests** — always remove temporary files in teardown
4. **Test both success and failure paths** — don't just test the happy path
5. **Mock external dependencies** — isolate the unit under test
6. **Use fixtures for complex data** — makes tests readable and maintainable
7. **Use `setup_file` for expensive setup** — databases, large fixtures, network resources
8. **Prefer skogai helpers over raw assertions** — `assert_success` over `[ "$status" -eq 0 ]` when available

</best_practices>

<reference>

## Testing Framework Location

Key files in this repo:
- `tests/test-helper.bash` — shared assertions and helpers
- `tests/pre-tool-use/pre-tool-use.bats` — reference test suite (allow/block rules)
- `tests/stop/` — reference test suite (hook exit codes and output)

</reference>

---
title: Using argc for SkogAI-Aware Scripts
date: 2026-01-20
project: SkogAI
tags:
  - argc
  - scripts
  - validation
  - tooling
source: Fizzbuzz implementation session
status: active
permalink: claude/projects/dot-skogai/knowledge/learnings/2026-01-20-argc-script-framework
---

## The Problem

Plain bash scripts have no:

- Type validation (treat "foo" as 0)
- Automatic help generation
- Schema definition
- Input constraints

## The Solution: argc

`argc` is a bash CLI framework that adds all this with minimal boilerplate.

## Transformation

### Before (Plain Bash)

```bash
#!/usr/bin/env bash

fizzbuzz() {
  local n="$1"
  if [ -z "$n" ]; then
    echo "Usage: fizzbuzz <number>"
    return 1
  fi
  # ... logic ...
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  fizzbuzz "$@"
fi
```

Problems:

- No type validation
- Manual usage message
- No help generation
- Accepts invalid input (treats "foo" as 0)

### After (argc-powered)

```bash
#!/usr/bin/env bash

# @describe fizzbuzz implementation for skogai
# @arg int![`_choice_int`] The number to print
main() {
  local n="${argc_int}"
  # ... logic (same) ...
}

_choice_int() {
  seq 1 100
}

eval "$(argc --argc-eval "$0" "$@")"
```

Added:

- 2 comment lines for schema
- Choice function for validation
- One eval line
- Renamed function to `main()`

## What You Get Free

### 1. Auto-validation

```bash
$ fizzbuzz.sh foo
error: invalid value `foo` for `<INT>`
  [possible values: 1, 2, 3, ..., 100]
```

### 2. Auto-generated Help

```bash
$ fizzbuzz.sh --help
fizzbuzz implementation for skogai

USAGE: fizzbuzz.sh <INT>

ARGS:
  <INT>  The number to print
```

### 3. Type Safety

- `_choice_int()` defines valid inputs (1-100)
- argc validates before calling `main()`
- Invalid input never reaches your logic

### 4. Variable Injection

argc parses and injects validated args as `${argc_*}` variables automatically.

## Integration with SkogAI

Scripts in `.skogai/scripts/` with argc support:

- Work through `[@script:arg]` notation
- Provide help via `[@help:script]`
- Validate inputs before execution
- Return proper error messages

## Key Insight

You don't write validation, help text, or parsing code. You **declare** the interface in comments, and argc generates everything.

This is the "SkogAI way" - declarative interfaces with automatic implementation.

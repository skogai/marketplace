# tests/

Bats test suites for the hooks. Run with `bats tests/**/*.bats`.

## What tests are for

Tests catch regressions Claude could introduce — a lesson that stops being filtered, a body that stops being injected, a separator that disappears. They are not for verifying that bash works.

## Structured IO = the basic test stage is done

When a hook sources `skogai-jq.sh` and declares its schema with typed sentinels, the IO contract is already enforced. The type safety is in the implementation, not the test. Do not write tests that re-verify it.

Not a test:
- Hook exits 0
- Output is valid JSON
- Field `hookEventName` exists
- `$HOOK_PROMPT` equals the input prompt

## What to test

Content selection, filtering, and output shape — things that can silently regress:

- The right lesson body reaches `additionalContext` given a specific prompt
- A deprecated lesson does not appear even when its keywords match
- Multiple matching lessons are both present and separated
- The session log contains the full input (including `transcript_path`)

## Assertion style

Use skogai-jq transforms to extract and validate, not grep or string matching:

```bash
ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
```

Then assert the specific content that should be there — exact strings from the lesson body, not just "non-empty".

## Test naming

State the input and the expected output explicitly:

```
prompt 'build a docker container image' injects docker lesson body
deprecated lesson keywords in prompt produce no deprecated content in output
```

Not:
```
hook works correctly
injects the matching lesson body not just the title
```

<workflow>

<objective>
create bats tests for a skogai-core hook using schema-driven fixtures.
</objective>

<steps>

1. write `tests/<hookname>/schema.json` — list every meaningful input combination as examples. each example has `description`, `input` (the full hook JSON payload), and `output` (what the test asserts against).

2. generate fixture files from the schema:
   ```bash
   JQ_GEN="skogai-jq/test-generator/transform.jq"
   schema="tests/<hookname>/schema.json"
   dir=$(dirname "$schema")

   jq -f "$JQ_GEN" --arg format json "$schema" | jq -c '.[]' | while read -r case; do
     desc=$(echo "$case" | jq -r '.description' | tr ' ' '-' | tr -cd 'a-z0-9-')
     echo "$case" | jq '.input' > "$dir/${desc}.json"
   done
   ```
   re-run this whenever examples are added to the schema.

3. write `tests/<hookname>.bats` — one `@test` per fixture, loading files by path:
   ```bash
   HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hooks" && pwd)/<hookname>.sh"
   F="$(cd "$(dirname "$BATS_TEST_FILENAME")/<hookname>" && pwd)"

   setup()    { setup_test_dir; }
   teardown() { teardown_test_dir; rm -f /tmp/<session_id>.jsonl; }
   ```

4. assert on extracted content, not full output:
   ```bash
   # output assertions
   ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
   [[ "$ctx" == *"expected string"* ]]

   # log assertions — run without `run` so log is written to disk
   bash -c "cat '$F/fixture.json' | bash '$HOOK'" >/dev/null
   summary=$(tail -1 /tmp/<session_id>.jsonl | jq -r '.summary')
   [[ "$summary" == *"expected"* ]]
   ```

5. run and confirm all pass:
   ```bash
   bats tests/**/*.bats
   ```

</steps>

<validation>

- every input variant that could silently regress has a fixture
- no `write_input` helpers — inputs live in `tests/<hookname>/*.json`
- assertions check specific content, not that output is non-empty or valid JSON
- `bats tests/**/*.bats` passes from the plugin root

</validation>

<references>

- `tests/CLAUDE.md` — what to test, assertion style, test naming rules
- `skogai-jq/test-generator/` — the generator transform and its schema
- `skogai-jq/SKILL.md` — transform library used in hook logic

</references>

</workflow>

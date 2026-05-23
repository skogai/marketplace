<workflow>

<objective>
Validate framework files against skogai JSON schemas and surface structural gaps.
</objective>

<steps>

1. Run the validator from the framework root:
   `./scripts/validate-schema.sh [ROOT]`
   ROOT defaults to the skill directory; pass an explicit path for external frameworks.

2. Read the schema overview table printed at the top to confirm all expected types are mapped.

3. For each `FAIL` line: open the named file, read the error path, and fix the structural gap.

4. For each `WARN` line: decide whether the file should gain a `type` field in frontmatter or an XML root tag, or whether it is intentionally untyped (prose-only reference).

5. If fixing frontmatter: add `type: <router|workflow|reference|template|script|lesson>` to the YAML block.

6. If fixing a missing XML section: wrap the relevant content block in the required tag (e.g. `<objective>`, `<routing>`, `<steps>`, `<validation>`, `<overview>`, `<template>`).

7. Re-run the script after each fix to confirm the count moves from FAIL/WARN to PASS.

8. Commit only when summary shows 0 failures.

</steps>

<validation>

- `./scripts/validate-schema.sh` exits 0.
- Summary line shows 0 failed.
- Any remaining WARN lines are documented as intentionally untyped files.

</validation>

</workflow>

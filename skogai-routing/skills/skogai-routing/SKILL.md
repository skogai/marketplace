---
name: skogai-routing
description: This skill should be used when the user is authoring, reading, or reasoning about SKOGAI.md files, CLAUDE.md `<routes>` blocks, or any file that mixes YAML frontmatter with an XML root tag as part of the skogai routing convention. Trigger on "SKOGAI.md", "routing file", "<routes> tag", "type: router", or "at-linking convention".
---

# SkogAI Routing Convention

SKOGAI.md is not natively loaded by Claude Code. It is pulled into context the same
way any other file is: via a native `@`-link written inside a file Claude Code
*does* auto-load. In practice, a repo's `CLAUDE.md` contains one line:

```
- read @SKOGAI.md
```

That line is the entire loading mechanism. This skill does not implement loading —
it defines what should be *inside* SKOGAI.md once it's loaded, and how to validate it.

## v1 shape: frontmatter + `<routes>`

A routing file has two parts: YAML frontmatter, then one XML block.

```markdown
---
permalink: skogai-routing/claude
type: router
---

<routes>

- @SKOGAI.md
- /home/skogix/skogai/CLAUDE.md - the repo `skogai/skogai`

</routes>
```

**Frontmatter fields (v1):**

- `type` (required) — for a routing file this is always `router`. The type is
  what a validator uses to decide which schema/rules apply to the rest of the
  document, so it must match the XML root tag present in the body.
- `permalink` (recommended) — a stable slug identifying this document, independent
  of its current file path.

**`<routes>` body (v1, informational only):**

- A flat list, one entry per line: `- <path-or-@link> [- <description>]`.
- Entries may be `@`-links (auto-loaded by Claude Code) or plain paths (Claude
  reads them manually when relevant) — both are valid, `@`-links just also
  trigger auto-inclusion.
- Nothing in `<routes>` is auto-resolved beyond what `@`-linking already does
  natively. A path entry is a hint for Claude to go read that file when the
  task is relevant to it, not an automatic injection.

See `examples/SKOGAI.md.example` for a minimal file and `examples/CLAUDE.md.example`
for the one-line loader.

## Reading frontmatter

Use `scripts/parse-frontmatter.sh <file> [field]` to extract the YAML frontmatter
block (or a single field from it) from a routing file — adapted from
plugin-dev's `plugin-settings` frontmatter parser.

## Beyond `<routes>`: where this is headed

`<routes>` is the first of what is meant to become a small family of typed
documents, each pairing a frontmatter `type` with a matching XML root tag
(`router` ↔ `<routes>`, and eventually others such as `workflow`, `reference`,
`template`, `lesson`). Each type is checked against a JSON Schema keyed by its
`type` field. Do not invent additional types speculatively — only `router` is
implemented in v1. `schemas/router.schema.json` in this skill is deliberately
scoped to just that one type; extend it (or add sibling schema files) only
when a concrete second type is requested.

## Validating a routing file

Use `scripts/validate-router.sh <file>` to check a single file against
`schemas/router.schema.json`: frontmatter parses as YAML, `type` equals
`router`, and the body contains a `<routes>` XML section. This mirrors the
older ad-hoc implementation the convention grew out of (tag listing +
per-type JSON Schema validation) but scoped down to the one type that exists
today.

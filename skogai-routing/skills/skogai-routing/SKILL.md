---
name: skogai-routing
description: This skill should be used when the user is authoring, reading, scaffolding, or validating SKOGAI.md files, CLAUDE.md `<routes>` blocks, or any file that mixes YAML frontmatter with an XML root tag as part of the skogai routing convention. Trigger on "SKOGAI.md", "routing file", "<routes> tag", "type is router", "at-linking convention", "add a routing file", "set up SKOGAI.md", "validate SKOGAI.md", or "lint the routes tag".
allowed-tools: Bash(*validate_router.py*), Bash(*list_routers.py*)
---

# SkogAI Routing Convention

SKOGAI.md is not natively loaded by Claude Code. It is pulled into context the same
way any other file is: via a native `@`-link written inside a file Claude Code
_does_ auto-load. In practice, a repo's `CLAUDE.md` is itself a router document —
frontmatter plus a `<routes>` block whose entries `@`-link out to SKOGAI.md and
other files:

```markdown
---
permalink: skogai-routing/claude
type: router
---

<routes>

- @SKOGAI.md

</routes>
```

That `<routes>` block is the entire loading mechanism — CLAUDE.md and SKOGAI.md are
the same document type (`router`), just at different points in the tree. This skill
does not implement loading — it defines what a router document looks like, and how
to scaffold/validate one.

## v1 shape: frontmatter + `<routes>`

A routing file has two parts: YAML frontmatter, then one XML block.

```markdown
---
permalink: skogai-routing/skogai
type: router
---

<routes>

- @MY/PATH/TO/DIR/ - list a directory and allow reading from the files within
- @SUBFOLDER/SKOGAI.md - link to another subfolder's router

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

See `examples/SKOGAI.md.example` for a router with directory/subfolder routes and
`examples/CLAUDE.md.example` for a minimal router that just points at `@SKOGAI.md`.

## Reading frontmatter

Use `${CLAUDE_SKILL_DIR}/scripts/parse-frontmatter.sh <file> [field]` to extract
the YAML frontmatter block (or a single field from it) from a routing file —
adapted from plugin-dev's `plugin-settings` frontmatter parser.

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

Use `scripts/validate_router.py <file...>` to check one or more files against
`schemas/router.schema.json`: frontmatter parses as YAML, `type` equals
`router`, and the body contains a `<routes>` XML section. It's a single
`uv run --script` executable (schema path resolved relative to its own
location via `Path(__file__)`) — there's no separate shell wrapper, since a
wrapper would only exist to loop over args and resolve paths, both of which
Python already does natively.

Self-check, run live every time this skill loads (proof the validator and the
bundled example still agree, not just a description of the command):

- Bundled example: !`${CLAUDE_SKILL_DIR}/scripts/validate_router.py ${CLAUDE_SKILL_DIR}/examples/SKOGAI.md.example`

When the user asks to validate SKOGAI.md/CLAUDE.md routing files:

1. Resolve targets from the user's request: a given file path, or if a
   directory (or nothing) is given, Glob for `SKOGAI.md` and `CLAUDE.md`
   under that directory (default: cwd).
2. Skip files whose frontmatter `type` isn't `router` — this validator only
   covers that one document type in v1.
3. Run `${CLAUDE_SKILL_DIR}/scripts/validate_router.py <file...>`.
4. Report PASS/FAIL/WARN per file. For any FAIL, quote the specific schema
   error so the user knows exactly what to fix (e.g. missing `<routes>`
   section, `type` not `router`, missing frontmatter). Don't auto-fix
   failures — report them and let the user or a follow-up edit fix the file.

## Finding all router files in a project

Use `scripts/list_routers.py [root_dir] [-o output_file]` to recursively scan
a project for router documents: it walks every `*.md` file under `root_dir`
(default: cwd; skips `.git`/`node_modules`), parses frontmatter, and prints
the relative path of each file where `type: router`. This is a cheap
frontmatter-only scan (no schema validation) — its job is discovery ("what
router files exist here"), not correctness ("are they valid"); pipe the
result into `validate_router.py` for that.

When the user asks to list/find/inventory routing files across a project:

1. Resolve `root_dir` from the user's request, else the current working
   directory (or `${CLAUDE_PROJECT_DIR}` if the user means "this whole
   project" specifically, since that's the substitution that resolves to the
   project root regardless of current subdirectory — requires Claude Code
   v2.1.196+).
2. Run `${CLAUDE_SKILL_DIR}/scripts/list_routers.py <root_dir>`. If the user
   wants the list saved somewhere, pass `-o <path>`. If they want it saved but
   haven't named a path, default to a file under `/tmp` (e.g.
   `/tmp/routers-<root-dir-name>.txt`) rather than writing into the project —
   this default is provisional until a real project-relative save location
   (e.g. a `.claude/` or `.skogai/` convention) has actually been used and
   confirmed, so don't upgrade it to a project path on your own judgment.
3. Optionally follow up with
   `${CLAUDE_SKILL_DIR}/scripts/validate_router.py <files...>` on the
   discovered list if the user also wants validation, not just discovery.

## Printing the XML tags in every router file

Use `scripts/list_xml_tags.py [root_dir] [-o output_file]` — it does the same
router discovery as `list_routers.py` (frontmatter `type: router`, `.git`/
`node_modules` skipped) but prints, per file, the unique XML tag names found
in it: `<relative-path>: <tag1> <tag2> ...` (or `(no xml tags)`). This is the
automated form of "find the routers, then show me their tags" as a single
command instead of two manual steps — run this directly rather than chaining
`list_routers.py` output into something else by hand.

When the user asks what tags exist in the routing files (or wants an
overview of a project's `<routes>`-and-beyond structure):

1. Run `${CLAUDE_SKILL_DIR}/scripts/list_xml_tags.py <root_dir>` (root_dir:
   whatever the user pointed at, else cwd).
2. Report the per-file tag lines back to the user as-is. Same `/tmp` default
   as `list_routers.py` if they want the output saved but haven't named a
   path — don't invent a project-relative location.

## Scaffolding a new routing file

When the user asks to add/set up a routing file in a repo:

1. Resolve the target directory from the user's request, else the current
   working directory. Confirm it looks like a repo root (has `.git` or the
   user already told you it is one).
2. Check whether `SKOGAI.md` already exists there. If it does, stop and tell
   the user — do not overwrite silently.
3. Read `examples/SKOGAI.md.example` (relative to this skill's directory) as
   the template. Write a new `SKOGAI.md` in the target directory with:
   - `type: router` in frontmatter
   - `permalink` set from whatever the user specified, otherwise a
     reasonable slug derived from the repo/directory name (e.g.
     `<repo-name>/claude`)
   - an empty or minimal `<routes>` block — do not invent route entries the
     user hasn't asked for
4. Check the target's `CLAUDE.md`:
   - If it doesn't exist, ask the user before creating one — a missing
     CLAUDE.md may be intentional.
   - If it already has a `<routes>` block containing an `@SKOGAI.md` entry
     (in any form), leave it alone.
   - If it already has a `<routes>` block without that entry, add
     `- @SKOGAI.md` as a new line inside it.
   - If it has no `<routes>` block at all, ask the user before restructuring
     an existing CLAUDE.md into router form — don't silently convert it.
     `examples/CLAUDE.md.example` shows the target shape for a fresh file.
5. Report exactly what was created/edited. Don't run
   `scripts/validate_router.py` automatically — mention it as a next step.

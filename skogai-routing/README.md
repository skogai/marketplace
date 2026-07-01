# skogai-routing

Author and validate `SKOGAI.md` routing files for the skogai multi-repo setup.

`SKOGAI.md` isn't natively loaded by Claude Code the way `CLAUDE.md` is. Instead,
a repo's `CLAUDE.md` contains one line — `- read @SKOGAI.md` — and Claude Code's
native `@`-link auto-inclusion does the loading. This plugin doesn't implement
loading; it defines and validates what belongs *inside* the routing file: YAML
frontmatter plus an XML block, starting with `<routes>`.

## Skills

- **skogai-routing** — knowledge skill describing the convention (frontmatter
  `type: router` + `<routes>` XML tag), with scripts to read frontmatter and
  validate a routing file against `schemas/router.schema.json`. Auto-activates
  when authoring or reasoning about routing files.
- **init-routing** — scaffolds a new `SKOGAI.md` in a target repo and adds the
  `- read @SKOGAI.md` line to that repo's `CLAUDE.md`.
- **validate-routing** — validates `SKOGAI.md`/`CLAUDE.md` routing files
  against the router schema and reports pass/fail with specific errors.

## v1 scope

Only the `router` document type (frontmatter `type: router` + `<routes>` tag)
is implemented. `<routes>` entries are informational — Claude reads them
manually when relevant; only `@`-linked entries are auto-included, and that's
native Claude Code behavior, not something this plugin adds. Additional
document types (`workflow`, `reference`, `template`, `lesson`, ...) are a
possible future direction but are intentionally not built until requested.

## Requirements

`scripts/validate-router.sh` needs `uv` (for the Python schema-validation
helper, via `jsonschema` + `pyyaml`).

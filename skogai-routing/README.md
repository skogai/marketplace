# skogai-routing

Author and validate `SKOGAI.md` routing files for the skogai multi-repo setup.

`SKOGAI.md` isn't natively loaded by Claude Code the way `CLAUDE.md` is. Instead,
a repo's `CLAUDE.md` contains one line — `- read @SKOGAI.md` — and Claude Code's
native `@`-link auto-inclusion does the loading. This plugin doesn't implement
loading; it defines and validates what belongs *inside* the routing file: YAML
frontmatter plus an XML block, starting with `<routes>`.

## Skills

- **skogai-routing** — describes the convention (frontmatter `type: router` +
  `<routes>` XML tag), and covers the actions around it: scaffolding a new
  `SKOGAI.md` in a target repo (and wiring `- read @SKOGAI.md` into its
  `CLAUDE.md`), and validating routing files against
  `schemas/router.schema.json` with a pass/fail/warn report. Auto-activates
  when authoring, reasoning about, scaffolding, or validating routing files —
  it's one convention, so it's one skill.

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
...

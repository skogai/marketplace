---
permalink: skogai-routing/skogai
type: router
---

`skogai-routing` implements the SkogAI routing convention: files with YAML
frontmatter (`type: router`, optional `permalink`) and a body containing exactly
one `<routes>...</routes>` XML block listing `@`-links or plain paths. All
authoring/validation/scaffolding logic lives in the `skogai-routing` skill — read
that skill before editing the convention itself, don't reinvent it here.

## v1 scope

Only the `router` document type is implemented (frontmatter `type: router` +
`<routes>` tag). Other planned types (workflow/reference/template/lesson)
mentioned in related design discussions are **not built** — don't add support
for them without an explicit task to do so.

## Tooling

- `skills/skogai-routing/scripts/validate_router.py` and `list_routers.py` are
  `uv run --script` executables (dependencies resolved inline by `uv`, no
  separate install step). Requires `uv` on PATH.
- No Makefile, package manager, or conventional test runner in this plugin;
  `skills/skogai-routing/evals/evals.json` is skill-eval data, not a test suite.

## Gotchas

- `skills/skogai-routing-workspace/` is eval/iteration scratch data (not
  referenced in `plugin.json`, not a real plugin component) — don't treat it as
  source to maintain or ship.

<routes>

- @README.md - plugin overview
- @skills/skogai-routing/SKILL.md - all authoring/validation/scaffolding logic for the routing convention

</routes>

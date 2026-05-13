# CLAUDE.md - codex-hooks

<objective>
Route Claude Code work inside the `codex-hooks` plugin, which verifies Codex plugin marketplace compatibility for hook-related experiments.
</objective>

<mental_model>
This plugin is a small Codex-loadable compatibility target: keep the router compact, send ordered work to workflows, keep durable compatibility facts in references, and leave runtime behavior in skills.
</mental_model>

<endpoint_types>

| type | purpose | location |
| --- | --- | --- |
| Router | decide where plugin-local context goes next | `CLAUDE.md` |
| Workflow | ordered maintenance or validation steps | `workflows/*.md` |
| Reference | stable plugin scope and compatibility facts | `references/*.md` |
| Skill | Codex-loadable runtime behavior | `skills/*/SKILL.md` |
| Manifest | plugin metadata and marketplace contract | `.codex-plugin/plugin.json` |

</endpoint_types>

<routing>

| intent | endpoint |
| --- | --- |
| Run or inspect the Codex hooks smoke behavior | `skills/codex-hooks-smoke/SKILL.md` |
| Change plugin metadata, skills, or validation flow | `workflows/maintain-codex-hooks-plugin.md` |
| Understand what this plugin is allowed to own | `references/codex-hooks-scope.md` |
| Update Codex plugin manifest fields | `.codex-plugin/plugin.json` |
| Decide whether hook guidance belongs in this plugin | `references/codex-hooks-scope.md` |

</routing>

<local_conventions>

- Keep this plugin focused on Codex plugin and hook marketplace compatibility; do not move general hook implementation guidance here.
- Treat `skills/codex-hooks-smoke/SKILL.md` as the runtime smoke endpoint and preserve its exact success marker unless the tests and marketplace expectation change together.
- Keep procedural detail in `workflows/` and durable compatibility facts in `references/`.
- Keep manifest changes aligned with `.agents/plugins/marketplace.json` and the tests under `tests/codex-plugin/`.
- Prefer adding the smallest endpoint that owns the new information instead of expanding this router.

</local_conventions>

<success_criteria>

- A reader can determine the correct plugin-local endpoint in one pass.
- The router states scope, endpoint types, intent routing, local conventions, and success criteria without duplicating endpoint content.
- Every named plugin-local endpoint exists.
- Procedural maintenance detail lives in `workflows/` and durable scope knowledge lives in `references/`.

</success_criteria>

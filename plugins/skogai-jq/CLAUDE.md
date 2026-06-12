# CLAUDE.md - skogai-jq

## Purpose

skogai-jq is a plugin that packages a schema-driven jq transformation library — 60+ tested, composable JSON transforms — as a Claude Code skill.

## Routes

| Intent | Endpoint |
| --- | --- |
| Pick or use a transform for a JSON task | `skills/skogai-jq/SKILL.md` |
| Quick transform lookup (args, examples) | `skills/skogai-jq/CHEAT_SHEET.md` |
| Add or change a transform | `skills/skogai-jq/IMPLEMENTATION_SPEC.md` |
| jq pitfalls, working rules, known bugs | `skills/skogai-jq/CLAUDE.md` |
| Run the test suite | `skills/skogai-jq/test-all.sh` |
| Real-world usage scenarios | `skills/skogai-jq/USAGE_EXAMPLES.md` |
| Open implementation tickets | `skills/skogai-jq/tasks/` |

## Rules

- This plugin ships a single capability: the `skogai-jq` skill at `skills/skogai-jq/`. Do not duplicate its content here.
- Every transform lives in its own `<transform-name>/` directory with `transform.jq`, `schema.json`, `test.sh`, and `test-input-*.json` — see `skills/skogai-jq/AGENTS.md` for the full convention.
- Treat `skills/skogai-jq/SKILL.md` as the canonical entrypoint for using transforms.

## Success

- An agent lands on the right skill file (skill usage, cheat sheet, implementation spec, or working rules) without first reading transform internals.
- This file stays a thin pointer; procedures and reference material remain inside `skills/skogai-jq/`.

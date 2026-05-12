# AGENTS.md - skogai-jq

## OVERVIEW
Schema-driven jq transformation library for AI agents. Seventy sibling transform directories share the same contract: jq implementation, JSON schema, shell test harness, and numbered fixtures.

## STRUCTURE
```
skogai-jq/
├── SKILL.md                 # User-facing skill router
├── CLAUDE.md                # Working rules and pitfalls
├── IMPLEMENTATION_SPEC.md   # Canonical transform contract
├── test-all.sh              # Auto-discovers */test.sh
├── references/              # Load-on-demand docs
├── scripts/                 # Shared conversion utilities
├── tasks/                   # Planning tickets, not runtime code
└── <transform>/             # transform.jq, schema.json, test.sh, test-input-*.json
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add a transform | `IMPLEMENTATION_SPEC.md` | Required file/test/schema pattern |
| Debug jq pitfalls | `CLAUDE.md` | Falsy values, existence, type checks |
| Run all tests | `test-all.sh` | Auto-discovers child `test.sh` files |
| User-facing usage | `README.md`, `USAGE_EXAMPLES.md` | Examples and design principles |
| Quick transform lookup | `references/CHEAT_SHEET.md` | Arguments and examples |
| Utility conversion | `scripts/` | Claude stream/chat helpers |

## CONVENTIONS
- Every transform directory contains `transform.jq`, `schema.json`, `test.sh`, and `test-input-*.json`.
- Directory names, schema `name`, and docs use kebab-case and must match.
- Implementations are direct jq scripts; invoke with `jq -f <dir>/transform.jq` and `--arg` or `--argjson`.
- `schema.json` defines all args, input/output types, examples, and tags.
- `test.sh` is standalone Bash with `set -euo pipefail`, local `SCRIPT_DIR`, exact output assertions, and PASS/FAIL lines.
- Tests must cover the behavior risk, especially missing paths, wrong types, and falsy values: `null`, `false`, `0`, empty string, arrays, objects.
- `test-all.sh` discovers tests automatically; new transforms should not require editing it.

## ANTI-PATTERNS
- Do not use `// fallback` when `null` or `false` are valid values; use `try ... catch` or explicit logic.
- Do not use `getpath(...) != null` for existence; distinguish missing from present-null with `has()` patterns.
- Do not run `map()` or array operations before checking input type.
- Do not hardcode transform arguments; pass user values via `--arg` or `--argjson`.
- Do not add wrappers that hide the direct jq invocation.
- Do not put implementation code in `tasks/`, proposals, or reference docs.
- Do not create per-transform AGENTS files; this file covers the uniform module pattern.

## COMMANDS
```bash
# From plugins/dot-core/skills/skogai-jq
./test-all.sh
./crud-get/test.sh
echo '{"user":{"name":"skogix"}}' | jq -f crud-get/transform.jq --arg path "user.name"
```

## NOTES
- `scripts/` is the only non-transform code subdirectory; keep utilities reusable and minimal.
- `references/IMPLEMENTATION_SPEC.md` duplicates the root spec content; avoid divergent edits.
- Existing docs may claim all transforms have 8-17 tests, but the observed tree includes smaller harnesses. Preserve coverage quality over a fixed count.

# Codex Hooks Issues

Date: 2026-05-10

These are local issue candidates for the next session. Keep them local unless collaboration or CI needs hosted tracking.

## 1. Build Claude vs Codex Hook Compatibility Matrix

Severity: high

Source of truth:

- `docs/codex/hooks.md`
- `docs/codex/hooks/schema/generated/*.json`
- `docs/claude-code/hooks.md`
- `docs/claude-code/hooks-guide.md`

Outcome:

- A markdown matrix listing each event, common input fields, event-specific input fields, supported output fields, block/continue semantics, and known unsupported/fail-open fields.
- Clear labels for `shared`, `claude-only`, `codex-only`, and `same name, different semantics`.

Next action:

```bash
find docs/codex/hooks/schema/generated -type f -name '*.json' -print | sort
```

## 2. Add Codex Fixtures for Hook Tests

Severity: high

Events to cover:

- `SessionStart`
- `UserPromptSubmit`
- `PreToolUse`
- `PermissionRequest`
- `PostToolUse`
- `Stop`
- `PreCompact`
- `PostCompact`

Outcome:

- Test fixtures or inline Bats JSON that reflect the generated Codex schemas.
- Tests assert behavior that matters, not schema constants.

Next action:

```bash
jq -r '.title, (.required | join(", "))' docs/codex/hooks/schema/generated/*.input.schema.json
```

## 3. Decide Shared vs Platform-Specific skogai-jq Helpers

Severity: high

Problem:

`skogai-jq` should remain the generic JSON transform layer, but Claude and Codex output contracts are not identical.

Likely split:

- Shared: stdin capture, field extraction, JSONL logging, literal predicate transforms, common transform path handling.
- Platform-specific: context injection, block/allow decisions, permission request decisions, stop continuation semantics.

Outcome:

- Either separate helpers such as `skogai_jq_claude_*` / `skogai_jq_codex_*`, or a platform parameter that keeps output shape explicit.
- Tests for both platforms before refactor.

## 4. Implement Missing Codex PreCompact/PostCompact Hooks or Remove Tests

Severity: medium

Current failure:

`bats tests/**/*.bats` fails because `hooks/pre-compact.sh` is missing.

Context:

Codex generated schemas include `pre-compact` and `post-compact`, so the test intent is plausible, but the implementation is absent.

Outcome:

- Either add thin `pre-compact.sh` and `post-compact.sh` hooks using `skogai-jq.sh`, or remove/rename stale tests if those hooks are not part of this repo's intended surface yet.

## 5. Normalize Hook Registration Docs

Severity: medium

Problem:

Claude and Codex use different hook registration locations and trust/config behavior.

Outcome:

- Add a short repo doc or section in `hooks/AGENTS.md` describing where Claude hooks are registered and where Codex hooks are registered.
- Include the Codex feature flag:

```toml
[features]
codex_hooks = true
```

## 6. Add Setup Refresh Command for Downloaded Specs

Severity: low

Problem:

Docs are intentionally ignored and fetched locally. New repo checkouts need a single refresh command.

Outcome:

- Either document:

```bash
scripts/fetch-claude-code-docs.sh
scripts/fetch-codex-hook-docs.sh
```

- Or add a wrapper script such as `scripts/fetch-hook-docs.sh`.

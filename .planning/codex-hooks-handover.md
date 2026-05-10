# Codex Hooks Handover

Date: 2026-05-10

## Current State

The repo is a hook/plugin marketplace workspace that uses `skogai-jq` as the common JSON transform layer for hook input and output. The existing hook scripts are mostly Claude Code shaped, but Codex now has official hook docs and generated schemas that can be used as the source of truth for Codex-specific behavior.

Official Codex docs are downloaded by:

```bash
scripts/fetch-codex-hook-docs.sh
```

The downloaded docs are intentionally ignored:

```text
docs/codex/
```

Fetched sources:

- `docs/codex/hooks.md`
- `docs/codex/hooks/schema/generated/*.json`

The schemas come from:

```text
https://raw.githubusercontent.com/openai/codex/main/codex-rs/hooks/schema/generated
```

## Completed This Session

- Added `scripts/fetch-codex-hook-docs.sh`.
- Added `/docs/codex` to `.gitignore`.
- Downloaded the official Codex hooks page and generated schemas.
- Verified downloaded schemas with `jq`.
- Fixed `scripts/skogai-jq.sh` so JSONL logs are compact one-line records.
- Fixed `skogai_jq_bool` so it validates literal values and emits only `true` or `false`.
- Added regression coverage in `tests/skogai-jq/skogai-jq.bats`.

## Useful Verification Commands

```bash
bash -n scripts/fetch-codex-hook-docs.sh
scripts/fetch-codex-hook-docs.sh
jq -e . docs/codex/hooks/schema/generated/*.json >/dev/null
bats tests/skogai-jq/skogai-jq.bats
```

The full suite currently has unrelated failures because `hooks/pre-compact.sh` is missing:

```bash
bats tests/**/*.bats
```

## Important Observations

- Codex docs list `SessionStart`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `UserPromptSubmit`, and `Stop`.
- The generated Codex schema directory also includes `PreCompact` and `PostCompact`.
- Codex and Claude Code share event names and broad hook concepts, but output semantics differ.
- Codex `PreToolUse` blocking prefers `hookSpecificOutput.permissionDecision = "deny"` but still accepts legacy `{decision:"block", reason:"..."}`.
- Codex `PermissionRequest` has its own decision shape under `hookSpecificOutput.decision.behavior`.
- Codex `Stop` treats `decision:"block"` as "continue the turn", not as a rejection.
- Codex hook sources can live in user config or repo-local `.codex/`, but repo-local hooks require the project `.codex/` layer to be trusted.

## Next Session Goal

Compare Claude and Codex hook specs event by event, then decide what can be shared in `skogai-jq` and what needs platform-specific output helpers.

Start with:

1. Read `docs/codex/hooks.md`.
2. Inspect `docs/codex/hooks/schema/generated/*.json`.
3. Compare against `docs/claude-code/hooks.md` and `docs/claude-code/hooks-guide.md`.
4. Build a compatibility matrix for event inputs and outputs.
5. Convert that matrix into tests before changing hook behavior.

## Recommended Workspace Plan

No git worktree was created this session because the repo already has a dirty/untracked working tree with active hook work. Next session, create a separate worktree only after deciding whether to preserve the current uncommitted files as the base.

Suggested branch/worktree name:

```text
codex-hook-specs
```

Suggested first command after cleaning or intentionally carrying the current work:

```bash
git worktree add ../marketplace-codex-hooks -b codex-hook-specs
```

Use the current workspace if the untracked helper/test files are meant to be part of the same change.

# Runbook

This runbook covers marketplace maintenance, hook validation, local plugin smoke tests, and the known failure modes in this checkout.

## Deployment

<!-- AUTO-GENERATED: deployment:start -->
Generated from: `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`, `.codex/config.toml`, `docs/codex-marketplace.md`, `Argcfile.sh`, and `scripts/`.

| Step | Command | Expected Result |
| --- | --- | --- |
| Validate catalogs | `jq -e . .agents/plugins/marketplace.json .claude-plugin/marketplace.json` | Both marketplace catalogs parse as JSON. |
| Validate core hook manifest | `jq -e . plugins/skogai-core/hooks/hooks.json` | The installable `skogai-core` hook manifest parses as JSON. |
| Refresh docs snapshots when needed | `bash scripts/fetch-hook-docs.sh` | `docs/claude-code/` and `docs/codex/` snapshots are refreshed. |
| Run hook tests | `bats tests/**/*.bats` | Reference hooks and helper transforms pass. |
| Check Codex baseline | `codex mcp list` | The repo-local `context7` MCP server is visible. |
| Register local Codex marketplace | `env HOME=/tmp/codex-marketplace-test-home codex plugin marketplace add "$PWD"` | Codex reports that marketplace `skogai` was added. |
| Smoke-test Codex plugin visibility | `bats tests/codex-plugin/codex-plugin.bats` | The `codex-hooks-smoke` skill is discoverable in the temporary Codex home. |
| Update Claude marketplace install | `claude plugin marketplace update "$SKOGAI_MARKETPLACE_NAME"` | Updates the installed Claude Code marketplace entry. |
| Update Codex marketplace install | `codex plugin marketplace upgrade "$SKOGAI_MARKETPLACE_NAME"` | Updates the installed Codex marketplace entry. |
<!-- AUTO-GENERATED: deployment:end -->

## Health Checks

<!-- AUTO-GENERATED: health:start -->
Generated from: `hooks/CLAUDE.md`, `tests/CLAUDE.md`, `docs/codex-marketplace.md`, and current validation output.

| Surface | Health Check | Notes |
| --- | --- | --- |
| Claude catalog | `jq -e . .claude-plugin/marketplace.json` | Catalog source of truth for Claude Code. |
| Codex catalog | `jq -e . .agents/plugins/marketplace.json` | Catalog source of truth for Codex. |
| Codex plugin payload | `jq -e . plugins/codex-hooks/.codex-plugin/plugin.json` | Validates the smoke-test plugin metadata. |
| Codex hook manifest | `jq -e . plugins/codex-hooks/hooks.json` | Currently fails because the JSON array/object closing structure is invalid. |
| Core hook manifest | `jq -e . plugins/skogai-core/hooks/hooks.json` | Currently parses. |
| Hook runtime | `cat hooks/example-inputs/pre-tool-use.json \| bash hooks/pre-tool-use.sh` | Manual smoke test for repo-level reference hooks. |
| Hook logs | `jq . /tmp/<session_id>.jsonl` | `skogai_jq_log` writes JSONL to `/tmp/${HOOK_SESSION_ID}.jsonl`. |
| Codex MCP baseline | `codex mcp list` | Should include `[mcp_servers.context7]` from `.codex/config.toml`. |
| Codex marketplace smoke | `bats tests/codex-plugin/codex-plugin.bats` | Separates marketplace registration from installed-plugin visibility. |
<!-- AUTO-GENERATED: health:end -->

## Rollback

For docs-only changes, revert the docs commit or restore the affected files from `master`. For catalog or plugin manifest regressions, revert the manifest and rerun the JSON validation plus the relevant Claude/Codex smoke test before updating marketplace installs again.

For hook behavior regressions, restore the last known-good hook and its test fixture together. Keep hook runtime changes paired with Bats coverage so future agent edits cannot remove output, logging, or block/allow behavior silently.

## Common Issues

<!-- AUTO-GENERATED: issues:start -->
Generated from current validation commands and repository docs.

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `jq -e . plugins/codex-hooks/hooks.json` fails | `plugins/codex-hooks/hooks.json` has malformed closing structure. | Fix the JSON before wiring Codex hook behavior into the smoke-test plugin. |
| `bash Argcfile.sh --help` or `bash Argcfile.sh tools ...` fails | `marketplace::plugin::update` exists without a `marketplace::plugin` parent function. | Add the parent command or use direct `claude plugin ...` / `codex plugin ...` commands until the command tree is repaired. |
| Codex marketplace add succeeds but the smoke skill is missing | Marketplace registration and installed-plugin cache visibility are separate. | Run `tests/codex-plugin/codex-plugin.bats` or manually place/enable the plugin in a temporary Codex home as the test does. |
| Hook tests resolve paths under `/usr/lib/bats-core` | Helper paths are derived from `$0` instead of `BATS_TEST_FILENAME` or `BASH_SOURCE`. | Resolve roots from `BATS_TEST_FILENAME` in tests and `BASH_SOURCE` in sourced helpers. |
| Plugin hook works in this repo but fails when installed | The hook sourced repo-root `scripts/skogai-jq.sh` instead of the plugin-local copy. | Vendor and source `scripts/skogai-jq.sh` inside the plugin. |
| Plain stdout from a Codex hook breaks behavior | Codex hook outputs require the expected JSON shape for the event. | Use the `skogai_jq_codex_*` helpers documented in `docs/hook-compatibility.md`. |
<!-- AUTO-GENERATED: issues:end -->

## Staleness

<!-- AUTO-GENERATED: staleness:start -->
Generated on: 2026-05-16.

| Check | Result |
| --- | --- |
| Documentation files older than 90 days | None found under `docs/`. |
| Recent non-doc source changes | Marketplace catalogs, hook manifests, hook scripts, plugin payloads, tests, workflows, and repo guidance changed within the last 90 days. |
| Manual review flags | `plugins/codex-hooks/hooks.json` is invalid JSON; `Argcfile.sh` wrapper help/export is blocked by a missing parent command. |
<!-- AUTO-GENERATED: staleness:end -->

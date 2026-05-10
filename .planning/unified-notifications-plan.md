# Unified Notifications Plan

Date: 2026-05-09

## Current Surface

Sources:
- GitHub issues and PRs for `skogai/marketplace`
- GitHub issues importable through `gptodo import --source github`
- Linear issues and projects
- Claude Code GitHub workflow in `.skogai/.github/workflows/claude.yml`
- Local Claude/Codex hook events in `hooks/`
- Codex MCP connectors in `~/.codex/config.toml`
- Desktop notifications through Codex `notify`
- Local operator queue in `todo.list`

Channels:
- GitHub issue/PR pages
- Linear workspace
- Codex terminal notifications through `terminal-notifier`
- Claude hook output and session logs
- `todo.list` and planning markdown files

Current observations:
- `skogai/marketplace` has no open GitHub issues or PRs at the time of this inventory.
- `gptodo import --source github --repo skogbackup/skogix --dry-run --limit 20` found 3 importable issues and created no files.
- Linear is configured as a connector but the current session is expired, so live Linear workload could not be inventoried.
- Project-local Codex example config has TUI notifications disabled.
- User-level Codex config has desktop completion notifications enabled.
- The repo has strong hook/testing primitives.
- `todo.list` is the effective canonical personal queue and should stay that way unless collaboration pressure requires a heavier tracker.

Duplicates:
- GitHub issue/PR events can also become Claude workflow events.
- Local hook events can duplicate terminal notifications if every lifecycle marker emits a user-visible alert.
- GitHub issues, Linear issues, and hosted-git issues can duplicate `todo.list` unless they are treated as external mirrors with explicit purpose.

Gaps:
- No severity model is encoded.
- No encoded policy that says `todo.list` is the personal source of truth.
- No digest format for medium-signal updates.
- No bridge rule for when local todos become external issues.

## Event Model

Critical:
- Default-branch CI failure
- Failed deploy or release-blocking failure
- Security-sensitive finding or secret exposure
- Broken automation that blocks normal development

Handling:
- Interrupt now.
- One primary owner.
- One canonical issue or incident thread.

High:
- Review requested from the user
- Failing PR owned by the user
- Explicit handoff blocked on the user
- Agent workflow needs permission or external approval

Handling:
- Same-day alert.
- Prefer one desktop or terminal notification plus one canonical GitHub/Linear item.

Medium:
- Issue state changes
- Non-blocking comments
- Backlog movement
- Agent-generated follow-up proposals
- Hook quality warnings that do not block work

Handling:
- Digest or queue.
- No desktop interruption by default.

Low:
- Successful routine runs
- Repeated lifecycle markers
- Duplicate workflow comments
- Local telemetry and debug logs

Handling:
- Suppress or fold into logs.

## Routing Plan

GitHub issues and PRs:
- Gate: open, assigned, review requested, failed checks, `@claude` mention.
- Shape: immediate only for critical/high; otherwise digest.
- Channel: external collaboration mirror, not the personal queue.
- Action: import or sync through `gptodo` when the issue needs local follow-up.

Linear:
- Gate: assigned to user, urgent/high priority, blocked/blocking, due soon.
- Shape: digest only unless the item blocks a real external commitment.
- Channel: optional planning bridge, not the personal queue.
- Action: import through `gptodo import --source linear` if Linear remains useful for shared commitments.

Local hooks:
- Gate: security block, git dirty stop, quality gate failure, command permission request.
- Shape: immediate only when the hook blocks or requires a decision.
- Channel: terminal/hook output first; desktop only for long-running completion or blocked action.
- Action: fix local state, run tests, approve/deny, or create a canonical issue if it persists.

Codex desktop notifications:
- Gate: turn complete, approval requested, long-running task complete.
- Shape: narrow interrupt lane.
- Channel: `terminal-notifier`.
- Action: return to terminal, approve, review output.

Local `todo.list`:
- Gate: any personal follow-up that should not depend on a hosted tracker.
- Shape: canonical personal queue.
- Channel: local file.
- Action: keep actionable; promote externally only when collaboration, CI, release tracking, or remote automation needs a URL.

Self-hosted git:
- Gate: code hosting, remote backup, PR/review workflow, CI runner integration, or replacing GitHub issue dependency.
- Shape: infrastructure lane, not a new personal ticket system by default.
- Channel: Forgejo/Gitea/GitLab-style forge if adopted.
- Action: keep issues disabled or secondary until `todo.list` stops working.

## Consolidation

Keep:
- `todo.list` as the canonical personal operator queue.
- GitHub only where it is still useful for existing repo hosting, PR review, CI, or public collaboration.
- Linear only for shared planning or commitments that need other people to see state.
- Local hooks for immediate development guardrails.
- Codex desktop notifications for completion and approval prompts.

Suppress:
- Success notifications for routine hooks.
- Repeated lifecycle markers.
- Duplicate alerts for the same GitHub event after it has a canonical issue/PR.
- Duplicate external issues for items already tracked cleanly in `todo.list`.
- Desktop alerts for medium/low backlog churn.

Merge:
- Agent follow-ups should land in `todo.list` first.
- External issues should link back to the relevant local todo when they exist for collaboration.
- Hook failures that persist across sessions should become one canonical `todo.list` item first; create an external issue only when another system needs to act on it.

Canonical `todo.list` shape:

```text
- [ ] [severity/source] action-oriented title :: next concrete action
```

Optional detail can live below the item in planning markdown when needed; keep `todo.list` scannable.

## Next ECC Move

Make `todo.list` the operator surface, then build a digest around it.

Workflow:
- Capture `todo.list` first.
- Capture GitHub open issues/PRs only as external mirrors.
- Capture Linear assigned issues after re-authentication only if Linear remains in use.
- Capture local `todo.list`.
- Capture hook-blocking failures from recent logs if available.
- Classify each item into critical/high/medium/low.
- Emit one markdown digest under `.planning/notifications-digest.md`.

Do not add more channels until this digest proves the model. Once the digest is useful, wire only critical/high events to desktop notifications and keep medium/low as digest-only.

Suggested first automation:
- Use `gptodo import --source github --repo <owner/repo> --dry-run` before importing from any GitHub repo.
- Use `gptodo import --source github --repo <owner/repo>` to create local placeholder tasks with tracking links.
- Use `gptodo fetch` and `gptodo sync --use-cache` for routine state reconciliation.
- Use `gptodo sync --full` when the local queue may be stale.
- Keep `.planning/notifications-digest.md` as the human-readable snapshot, not the source of truth.

Suggested follow-up policy:
- `todo.list` is the canonical personal queue.
- GitHub or self-hosted git for code hosting, review, CI, and public collaboration.
- Linear for shared planning only if it earns its keep.
- Local planning markdown for context too bulky for `todo.list`.
- Desktop notifications only for interruption-worthy events.

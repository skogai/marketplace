# Plan: skogai-workflow skill

## Goal

Create `plugins/skogai-core/skills/skogai-workflow` — a router skill that guides the full lifecycle of a skogai change: from idea to work order, through implementation, to merge and planning-repo update.

## Relationship to skogai-routing

`skogai-routing` and `skogai-workflow` are sibling skills with different domains:

- `skogai-routing` answers: "where should this information live?" (meta-framework for structuring guidance)
- `skogai-workflow` answers: "how do I make a change to skogai?" (domain workflow for the change lifecycle)

`skogai-routing` should have a route pointing to `skogai-workflow` when the intent is about planning or executing a skogai change. `skogai-workflow` is built using the same routing framework pattern.

## The Lifecycle (what this skill owns)

```
1. DISCOVER    conversation → shared understanding of what needs to change
2. PLAN        understanding → work order (repo + instructions + context)
3. IMPLEMENT   work order → agent executes (assume smallest local LLM)
4. REVIEW      PR comes back → agent reviews, comments, or accepts
5. CLOSE       merge → update planning repo
```

No human-in-the-loop is assumed at any stage.

## Work Order Format

Three fields only:
- **repo** — which repository the change targets
- **instructions** — what to do
- **context** — supporting material (files and/or inline strings)

## Current Manual Steps (to be guided/automated)

- `argc dev workon <repo> <branch>` — spawns a worktree (owned by skogai/core; changes requested via work order)
- Manually create `.plans/<name>.md`
- Manually load context into the conversation
- Manually update planning repo after merge

## Long-Term Vision

```
argc dev workon marketplace skogai-workflow \
  --context .plans/skogai-workflow.md \
  --context "some inline context string"
```

This is a desired change to `argc dev workon` (skogai/core) — express as a work order when ready.

## Routing Table (draft)

| intent | endpoint |
| --- | --- |
| turn a conversation into a work order | `workflows/create-work-order.md` |
| scaffold `.plans/<name>.md` | `templates/work-order.md` |
| spawn a worktree for a change | `workflows/spawn-worktree.md` |
| review an incoming PR | `workflows/review-pr.md` |
| merge and update planning repo | `workflows/close-change.md` |
| understand the full change lifecycle | `references/change-lifecycle.md` |

## Open Questions

1. What triggers REVIEW — does the agent poll for PRs, or is it invoked explicitly?
2. What does "update planning repo" mean concretely — commit to `.plans/`, close the plan file, something else?

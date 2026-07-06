---
permalink: skogai-core/skogai
type: router
---

`skogai-core` bundles the everyday git/commit workflow (originally the
`commit-commands` plugin, reorganized in here) plus the `code-simplifier` agent.
It has no build step — pure commands and an agent definition.

<routes>

- @agents/code-simplifier.md - simplifies/refines recently changed code while preserving functionality
- @commands/commands/commit.md - /commit: generates and creates a commit from staged/unstaged changes
- @commands/commands/commit-push-pr.md - /commit-push-pr: commit, push, and open a PR in one step
- @commands/commands/clean_gone.md - /clean_gone: removes local branches/worktrees whose remote is gone
- @commands/README.md - full docs for the commit/push/PR/clean_gone command set

</routes>

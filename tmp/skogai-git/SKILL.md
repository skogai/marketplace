---
name: skogai-git
description: What should I do? — Git workflows, commit philosophy, PR workflows, branch management, tool selection routing. Orchestration across wt, gita, gh, and raw git. For tool configuration details ("How does this tool work?"), see skogai-worktrunk.
---

<essential_principles>

## Tool Selection

Choose the right tool for the job:

| Tool        | Use When                                      | Example                        |
| ----------- | --------------------------------------------- | ------------------------------ |
| **wt**      | Single repo, multiple branches simultaneously | `wt switch --create feature/x` |
| **gita**    | Multiple repos, unified operations            | `gita ll`, `gita pull`         |
| **gh**      | GitHub PRs, issues, checks                    | `gh pr create`, `gh pr view`   |
| **raw git** | Simple operations, edge cases                 | `git status`, `git log`        |

## Commit Philosophy

**Commit outcomes, not process.** The git log should read like a changelog of what shipped, not a diary of planning activity.

- Initialization commits: `docs: initialize [project] ([N] phases)`
- Feature commits: `feat([domain]): [one-liner summary]`
- Fix commits: `fix([domain]): [what was fixed]`
- WIP handoffs: `wip: [phase] paused at task [X]/[Y]`

## Atomic Commits

- 3+ files changed = consider 2+ commits
- Each commit should be independently reviewable
- Detect repo style from `git log --oneline -10` before committing

</essential_principles>

<intake>

What would you like to do?

1. Work in parallel (worktrees)
1. Manage multiple repos (gita)
1. Commit and push changes
1. Create or review PRs
1. Branch management
1. Get guidance on tool selection

If intent is clear from context, route directly. Otherwise, ask.

</intake>

<routing>

| Response                                      | Next Action                       | Workflow                       |
| --------------------------------------------- | --------------------------------- | ------------------------------ |
| 1, "worktree", "parallel", "wt"               | Route to worktree workflow        | workflows/worktree-parallel.md |
| "review", "pr review", "isolated review"      | Route to review workflow          | workflows/worktree-review.md   |
| 2, "multi-repo", "gita", "repos", "all repos" | Route to gita workflow            | workflows/multi-repo.md        |
| 3, "commit", "push", "save"                   | Route to commit workflow          | workflows/commit-push.md       |
| 4, "pr", "pull request", "create pr"          | Route to PR workflow              | workflows/pr-workflow.md       |
| 5, "branch", "merge", "cleanup", "delete"     | Route to branch workflow          | workflows/branch-management.md |
| 6, "guidance", "which tool", "help"           | Read references/tool-selection.md | Direct reference               |

**Intent-based routing (if user provides clear intent):**

- "create worktree for feature X" → workflows/worktree-parallel.md
- "review PR 123" → workflows/worktree-review.md
- "sync all my repos" → workflows/multi-repo.md
- "commit these changes" → workflows/commit-push.md
- "open a PR" → workflows/pr-workflow.md
- "merge feature branch" → workflows/branch-management.md
- "should I use wt or gita?" → references/tool-selection.md

**After reading the workflow, follow it exactly.**

</routing>

<quick_reference>

## wt (Worktrunk) Commands

```bash
wt list                      # List all worktrees and branches
wt switch <branch>           # Switch to existing worktree
wt switch --create <name>    # Create new worktree from current branch
wt merge [target]            # Merge current worktree to target
wt remove <branch>           # Remove worktree and optionally branch
wt step commit               # Commit with LLM-generated message
```

## gita Commands

```bash
gita ll                      # List all managed repos with status
gita st                      # Show git status across all repos
gita add <path>              # Add repo(s) to gita management
gita pull                    # Pull all repos
gita push                    # Push all repos
gita super <git-command>     # Run git command on all repos
```

## gh Commands

```bash
gh pr create                 # Create pull request
gh pr view [number]          # View PR details
gh pr checkout <number>      # Checkout PR branch
gh pr merge                  # Merge PR
gh pr list                   # List open PRs
```

</quick_reference>

<reference_index>

## Domain Knowledge

All in `references/`:

- **Philosophy:** commit-philosophy.md — commit outcomes, atomic commits, style detection
- **Guidance:** tool-selection.md — decision tree for wt vs gita vs gh vs raw git
- **Commands:** wt-commands.md, gita-commands.md — _cross-references to skogai-worktrunk_
- **Hooks:** hook-types.md — _cross-reference to skogai-worktrunk_

\</reference_index>

\<workflows_index>

## Workflows

All in `workflows/`:

| Workflow             | Purpose                                       |
| -------------------- | --------------------------------------------- |
| worktree-parallel.md | Create and manage worktrees for parallel work |
| worktree-review.md   | Isolated PR review in separate worktree       |
| multi-repo.md        | gita operations across multiple repos         |
| commit-push.md       | Semantic commits and push workflow            |
| branch-management.md | Create, switch, merge, cleanup branches       |
| pr-workflow.md       | Create, review, merge pull requests           |

</workflows_index>

<see_also>

## Related Skills

- **skogai-worktrunk** — "How does this tool work?" Tool configuration, operation details, hooks, permission models, submodule patterns, LLM commit setup. Use when you need to configure wt/gita or understand tool internals.
- **skogai-git** (this skill) — "What should I do?" Git workflows, commit philosophy, PR workflows, branch management, tool selection routing.

</see_also>

<success_criteria>

A well-executed git workflow:

- Uses the right tool for the job (wt vs gita vs gh vs raw git)
- Commits are atomic and independently reviewable
- Commit messages describe outcomes, not process
- Worktrees are cleaned up after merging
- PRs have clear summaries and test plans

</success_criteria>

---
title: tool-selection
type: note
permalink: skogai/skills/skogai-git/references/tool-selection
---

# Tool Selection Guide

## Decision Tree

```
Need to work with git?
├── Single repo?
│   ├── Multiple branches simultaneously? → wt
│   ├── Simple operations? → raw git
│   └── GitHub operations? → gh
└── Multiple repos?
    └── → gita
```

## wt (Worktrunk)

**Use when:**

- Working on multiple branches of ONE repo simultaneously
- Git-flow workflows (feature/release/hotfix branches)
- Projects with submodules that need isolation per branch
- Need to switch between branches without stashing
- Want hook automation (post-create, pre-merge)

**Don't use when:**

- Simple single-branch work
- Managing multiple separate repositories

**Key insight:** wt creates separate directory per branch. Each worktree is fully independent.

## gita

**Use when:**

- Managing MULTIPLE related repositories
- Checking status across many repos at once
- Syncing (pull/push) multiple repos simultaneously
- Running commands across repo groups
- Ecosystem-level operations

**Don't use when:**

- Working within a single repository
- Need branch-level isolation

**Key insight:** gita treats multiple repos as one unit. Operations apply to all (or groups).

## gh (GitHub CLI)

**Use when:**

- Creating pull requests
- Reviewing PRs
- Checking CI status
- Managing issues
- Any GitHub-specific operation

**Don't use when:**

- Local-only git operations
- Non-GitHub remotes

## Raw git

**Use when:**

- Simple operations (status, log, diff)
- Edge cases not covered by tools
- Learning/debugging
- Non-standard workflows

## Combining Tools

**wt + gita together:**

- Main project with submodules: wt for main repo, gita for overview
- Monorepo ecosystem: wt for features, gita for related services

**wt + gh together:**

- Create worktree for PR review: `wt switch --create pr-123`
- Then checkout PR: `gh pr checkout 123`

**gita + gh together:**

- Check PR status across repos: `gita super gh pr list`

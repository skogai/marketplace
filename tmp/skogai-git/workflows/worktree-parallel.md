---
title: worktree-parallel
type: note
permalink: skogai/skills/skogai-git/workflows/worktree-parallel
---

# Worktree Parallel Work

Create and manage worktrees for parallel development on multiple branches.

\<required_reading>

- skogai-worktrunk/SKILL.md (if unfamiliar with wt commands)
- skogai-worktrunk/reference/hook-types-reference.md (if setting up automation) \</required_reading>

<process>

## 1. Check Current State

```bash
wt list
```

Shows all branches, worktrees, and status.

## 2. Create New Worktree

```bash
# From default branch (main/master)
wt switch --create feature/my-feature

# From specific base
wt switch --create feature/my-feature --base develop
```

This:

- Creates new branch
- Creates worktree in configured path (default: `.worktrees/<branch>` in repo root)
- Runs `post-create` hooks (npm install, etc.)
- Switches to new worktree

## 3. Work in Worktree

```bash
# You're now in the worktree
pwd  # <repo-root>/.worktrees/feature/my-feature

# Work normally
git status
git add .
git commit -m "feat: add feature"
```

Each worktree is fully independent.

## 4. Switch Between Worktrees

```bash
# Switch to another worktree
wt switch feature/other-feature

# Switch to main
wt switch main
# Or shortcut:
wt switch ^
```

## 5. Merge When Done

```bash
# Merge current worktree to default target
wt merge

# Or to specific target
wt merge develop
```

This:

- Runs `pre-commit` hooks
- Creates commit
- Switches to target branch
- Runs `pre-merge` hooks (tests)
- Merges
- Pushes
- Runs `post-merge` hooks
- Cleans up worktree

## 6. Manual Cleanup (if needed)

```bash
# Remove worktree, delete branch if merged
wt remove feature/my-feature

# Force delete unmerged branch
wt remove feature/abandoned --force-delete

# Keep branch, just remove worktree
wt remove feature/my-feature --no-delete-branch
```

</process>

\<common_patterns>

## Git-Flow Feature

```bash
wt switch --create feature/login --base develop
# ... work ...
wt merge develop
```

## Hotfix

```bash
wt switch --create hotfix/critical --base main
# ... fix ...
wt merge main
```

## Multiple Features in Parallel

```bash
# Start first feature
wt switch --create feature/auth

# Start second feature (in new terminal)
wt switch --create feature/payments

# Switch between them
wt switch feature/auth
wt switch feature/payments

# Merge each when ready
wt switch feature/auth
wt merge
wt switch feature/payments
wt merge
```

## PR Review Isolation

```bash
wt switch --create review/pr-123
gh pr checkout 123
# ... review ...
wt remove review/pr-123 --force-delete
```

\</common_patterns>

\<worktree_setup>

## Environment and Gitignore Setup

When creating worktrees, ensure these are handled (wt handles this automatically via hooks):

### .gitignore Management

The `.worktrees/` directory should be in your repo's `.gitignore`. If not already present, add it:

```
.worktrees
```

### .env File Copying

Worktrees do not inherit `.env` files from the main repo (they are gitignored). After creating a worktree, copy environment files:

```bash
# Copy all .env files (skip .env.example which is committed)
cp .env .env.local .env.test .worktrees/<branch>/  2>/dev/null
```

Configure this as a `post-create` hook in `.config/wt.toml` to automate it:

```toml
post-create = ["npm install", "cp .env* .worktrees/$WT_BRANCH/ 2>/dev/null || true"]
```

\</worktree_setup>

<troubleshooting>

## Troubleshooting

### "Worktree already exists"

Use `wt list` to see existing worktrees. Switch to it with `wt switch <branch>`.

### "Cannot remove worktree: it is the current worktree"

Switch out of the worktree first, then remove:

```bash
wt switch ^           # switch to default branch
wt remove <branch>    # now remove it
```

### Lost in a worktree?

```bash
wt list               # shows all worktrees with paths
git rev-parse --show-toplevel  # shows current repo/worktree root
```

### .env files missing in worktree?

If a worktree was created without .env files, copy them manually from the main repo root:

```bash
cp $(git worktree list | head -1 | awk '{print $1}')/.env* . 2>/dev/null
```

</troubleshooting>

\<success_criteria>

- Worktree created and hooks ran
- Can switch between worktrees freely
- .env files present in worktree
- .worktrees/ in .gitignore
- Changes merged cleanly
- Worktree cleaned up after merge \</success_criteria>

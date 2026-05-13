---
title: worktree-review
type: note
permalink: skogai/skills/skogai-git/workflows/worktree-review
---

# Worktree PR Review

Isolated PR review in separate worktree to avoid disrupting current work.

\<required_reading>

- skogai-worktrunk/SKILL.md (if unfamiliar with wt commands) \</required_reading>

<process>

## 1. Check Current State

```bash
# What branch am I on?
git branch --show-current

# Do I have uncommitted changes?
git status
```

If you have uncommitted changes, a worktree lets you review without stashing.

## 2. Create Review Worktree

```bash
# Create worktree for review
wt switch --create review/pr-<number>
```

Example:

```bash
wt switch --create review/pr-123
```

## 3. Checkout PR Branch

```bash
# Checkout the PR using gh
gh pr checkout <number>

# Or manually
git fetch origin pull/<number>/head:pr-<number>
git checkout pr-<number>
```

Example:

```bash
gh pr checkout 123
```

## 4. Review the Code

```bash
# See what changed
gh pr diff

# View PR details
gh pr view

# Run tests
npm test

# Check specific files
git diff main..HEAD -- src/
```

## 5. Leave Review Comments

```bash
# Add review comment
gh pr review --comment -b "Looks good, minor suggestion on line 42"

# Approve
gh pr review --approve

# Request changes
gh pr review --request-changes -b "Please fix the security issue"
```

## 6. Cleanup

```bash
# Return to main worktree
wt switch main
# Or:
wt switch ^

# Remove review worktree
wt remove review/pr-123 --force-delete
```

</process>

\<decision_tree>

## When to Use Worktree for Review

**Use worktree if:**

- You have uncommitted changes you don't want to stash
- Review might take a while
- You want to run the PR code locally
- You need to switch between review and your work

**Skip worktree if:**

- You're already on the PR branch
- Quick review, no local testing needed
- No work in progress to protect

\</decision_tree>

\<quick_workflow>

## One-Liner Review Setup

```bash
wt switch --create review/pr-123 && gh pr checkout 123
```

## One-Liner Cleanup

```bash
wt switch ^ && wt remove review/pr-123 --force-delete
```

\</quick_workflow>

\<success_criteria>

- Review completed without disrupting current work
- PR approved/changes requested
- Review worktree cleaned up \</success_criteria>

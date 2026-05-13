---
title: branch-management
type: note
permalink: skogai/skills/skogai-git/workflows/branch-management
---

# Branch Management

Create, switch, merge, and cleanup branches.

<process>

## 1. Create Branch

**With wt (creates worktree):**

```bash
wt switch --create feature/my-feature
```

**Raw git (same directory):**

```bash
git checkout -b feature/my-feature
# Or:
git switch -c feature/my-feature
```

## 2. Switch Branch

**With wt:**

```bash
wt switch feature/other
wt switch main    # Or: wt switch ^
wt switch -       # Previous branch
```

**Raw git:**

```bash
git checkout feature/other
# Or:
git switch feature/other
```

## 3. List Branches

**With wt:**

```bash
wt list
```

**Raw git:**

```bash
git branch          # Local
git branch -r       # Remote
git branch -a       # All
```

## 4. Merge Branch

**With wt (full workflow):**

```bash
wt merge          # Merge to default target
wt merge develop  # Merge to specific branch
```

**Raw git:**

```bash
git checkout main
git merge feature/my-feature
git push
```

## 5. Delete Branch

**With wt:**

```bash
wt remove feature/my-feature              # Delete if merged
wt remove feature/my-feature --force-delete  # Force delete
```

**Raw git:**

```bash
git branch -d feature/my-feature    # Delete if merged
git branch -D feature/my-feature    # Force delete

# Delete remote branch
git push origin --delete feature/my-feature
```

## 6. Cleanup Stale Branches

```bash
# Prune remote-tracking branches
git fetch --prune

# Find merged branches
git branch --merged main

# Delete merged branches (careful!)
git branch --merged main | grep -v main | xargs git branch -d
```

## 7. Rename Branch

```bash
# Rename current branch
git branch -m new-name

# Rename specific branch
git branch -m old-name new-name

# Update remote
git push origin :old-name new-name
git push origin -u new-name
```

</process>

\<branch_naming>

## Conventions

| Pattern           | Use Case                |
| ----------------- | ----------------------- |
| `feature/name`    | New features            |
| `fix/name`        | Bug fixes               |
| `hotfix/name`     | Urgent production fixes |
| `release/version` | Release preparation     |
| `review/pr-123`   | PR review worktrees     |

## Examples

```
feature/user-authentication
feature/payment-integration
fix/login-redirect-loop
hotfix/security-patch
release/2.0.0
review/pr-456
```

\</branch_naming>

\<common_patterns>

## Feature Branch Flow

```bash
# Create from develop
wt switch --create feature/auth --base develop

# Work...
git commit -m "feat(auth): add login"

# Merge back
wt merge develop

# Cleanup automatic with wt
```

## Hotfix Flow

```bash
# Create from main
wt switch --create hotfix/critical --base main

# Fix...
git commit -m "fix(security): patch XSS vulnerability"

# Merge to main
wt merge main

# Also merge to develop if needed
git checkout develop
git merge main
git push
```

## Rebase Before Merge

```bash
# Update your branch with latest
git fetch origin
git rebase origin/main

# Or with wt
wt step rebase main
```

\</common_patterns>

\<success_criteria>

- Branches follow naming convention
- Feature branches merge cleanly
- Stale branches cleaned up
- No orphaned remote branches \</success_criteria>

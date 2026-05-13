---
title: pr-workflow
type: note
permalink: skogai/skills/skogai-git/workflows/pr-workflow
---

# Pull Request Workflow

Create, review, and merge pull requests using gh CLI.

<process>

## 1. Prepare Branch

```bash
# Ensure changes are committed
git status

# Push branch to remote
git push -u origin feature/my-feature
```

## 2. Create PR

**Interactive:**

```bash
gh pr create
```

**With options:**

```bash
gh pr create --title "feat: add user authentication" \
  --body "## Summary
- Add login/logout endpoints
- JWT token handling
- Session management

## Test Plan
- [ ] Unit tests pass
- [ ] Manual login test
- [ ] Token expiry verified"
```

**Draft PR:**

```bash
gh pr create --draft
```

**Assign reviewers:**

```bash
gh pr create --reviewer username1,username2
```

## 3. View PR

```bash
# View current branch's PR
gh pr view

# View specific PR
gh pr view 123

# View in browser
gh pr view --web
```

## 4. Review PR

**Checkout PR locally:**

```bash
gh pr checkout 123
```

**With worktree isolation:**

```bash
wt switch --create review/pr-123
gh pr checkout 123
```

**View diff:**

```bash
gh pr diff 123
```

**Leave review:**

```bash
# Comment
gh pr review 123 --comment -b "Looks good, minor suggestion"

# Approve
gh pr review 123 --approve

# Request changes
gh pr review 123 --request-changes -b "Please fix the security issue"
```

## 5. Update PR

```bash
# Make changes locally
git add .
git commit -m "fix: address review feedback"

# Push updates
git push
```

## 6. Check CI Status

```bash
gh pr checks 123

# Wait for checks
gh pr checks 123 --watch
```

## 7. Merge PR

```bash
# Default merge
gh pr merge 123

# Squash merge
gh pr merge 123 --squash

# Rebase merge
gh pr merge 123 --rebase

# Delete branch after merge
gh pr merge 123 --delete-branch
```

## 8. Cleanup

```bash
# If using worktree
wt switch ^
wt remove review/pr-123 --force-delete

# Delete local branch
git branch -d feature/my-feature
```

</process>

\<pr_template>

## Standard PR Body

```markdown
## Summary
- [What this PR does]
- [Key changes]

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Notes
[Any additional context, breaking changes, or follow-up needed]
```

## Feature PR

```markdown
## Summary
Add [feature name] to [component].

- [Key implementation detail 1]
- [Key implementation detail 2]
- [User-facing change]

## Test Plan
- [ ] New tests added
- [ ] Existing tests pass
- [ ] Manual testing: [specific scenario]

## Screenshots
[If UI changes]
```

## Bug Fix PR

```markdown
## Summary
Fix [issue description].

**Root cause:** [What was wrong]
**Solution:** [How it was fixed]

## Test Plan
- [ ] Regression test added
- [ ] Verified fix in [environment]
- [ ] No side effects observed
```

\</pr_template>

\<common_patterns>

## Quick PR

```bash
# One-liner: push and create PR
git push -u origin HEAD && gh pr create --fill
```

## PR from Fork

```bash
gh pr create --repo upstream/repo --head myuser:feature-branch
```

## List Open PRs

```bash
gh pr list

# Filter by author
gh pr list --author @me

# Filter by label
gh pr list --label "bug"
```

## Close PR Without Merging

```bash
gh pr close 123
```

\</common_patterns>

\<success_criteria>

- PR has clear summary and test plan
- CI checks pass
- Reviews addressed
- Merged and branch cleaned up \</success_criteria>

---
match:
  keywords: [git, commit, push, branch, pr, pull request, worktree]
  tools: [post-tool-use, user-prompt-submit]
version: 1
always_apply: true
status: active
---

# git workflow best practices

## rule

stage and commit only the files that belong to the current change.

## context

when work involves git commits, branches, pull requests, or worktrees.

## pattern

```bash
git status --short
git add path/to/file
git commit -m "type: describe change"
```

## outcome

the commit stays reviewable, unrelated local work is preserved, and handoff state is clear.

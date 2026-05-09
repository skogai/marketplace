# lesson examples

this document shows the simple version first: one markdown file with frontmatter,
matched by `lesson_matcher.py`.

## minimal lesson

`knowledge/lessons/workflow/git.md`:

```markdown
---
match:
  keywords: [git, commit, push, branch, pr, pull request, worktree]
  tools: [user-prompt-submit]
version: 1
status: active
---

# git workflow best practices

## rule
stage and commit only the files that belong to the current change.

## context
when work involves git commits, branches, pull requests, or worktrees.

## pattern
git status --short
git add path/to/file
git commit -m "type: describe change"
```

## manual matcher check

```bash
python hooks/lesson_matcher.py \
  --mode tool \
  --text 'my text contains the word: git' \
  --tool 'user-prompt-submit'
```

that should return the git lesson body.

## when to split details out

for now, prefer a single concise lesson. add expanded companion docs only when
the runtime lesson would otherwise become too large to inject.

## another possible lesson

````markdown
---
match:
  keywords: [test, build, push]
version: 1
status: active
---

# test before push

## rule
run the closest relevant test before pushing shared code.

## context
when a task changes executable code or hook behavior.

## pattern
```bash
make build
pytest tests/
```

## outcome
broken changes are caught before they leave the workspace.
````

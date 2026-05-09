# lessons

this directory contains small context lessons loaded by the dot-core hook matcher.

## how lessons work

lessons are markdown files with yaml frontmatter. the matcher reads `match.keywords`
and `match.tools`, scores them against hook context, and injects the best matches
as additional context.

current modes:

- `session-start`: injects lessons marked `always_apply: true`
- `prompt`: matches keywords against the user prompt
- `tool`: matches tool names and optional text

## lesson format

```markdown
---
match:
  keywords: [git, commit]
  tools: [user-prompt-submit]
version: 1
status: active
---
# lesson title

lesson content in markdown...
```

## available lessons

### workflow

- **git.md** - git workflow best practices and commit conventions

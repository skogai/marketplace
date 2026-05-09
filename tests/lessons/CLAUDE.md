# lessons

shared lessons for skogai-agents. these lessons provide
behavioral guidance, workflow patterns, and tool-specific
knowledge that can be loaded dynamically based on context
keywords.

## categories

| category | description |
|----------|-------------|
| [autonomous](./autonomous/) | autonomous operation patterns and session management |
| [communication](./communication/) | github collaboration and professional communication patterns |
| [concepts](./concepts/) | core concepts and mental models |
| [patterns](./patterns/) | reusable behavioral patterns |
| [social](./social/) | social interaction and communication patterns |
| [tools](./tools/) | tool-specific lessons (shell, git, etc.) |
| [workflow](./workflow/) | workflow and process lessons |

## usage

lessons are automatically loaded by skogai-lessons when conversation context matches the lesson's keywords.

## lesson format

each lesson follows a standard format with yaml frontmatter:

```frontmatter
---
match:
  keywords:
    - "trigger phrase"
    - "another trigger"
version: 1  # optional: increment on meaningful rewrites (content/keyword changes)
status: active  # active | automated | deprecated | archived
---
```

with the markdown itself is recommended to at least have these categories 

```markdown
# lesson_title
optional short description.

## rule
one-sentence imperative.

## context
when this applies.

## pattern
minimal correct example.

## outcome
benefits when followed.
```

if the markdown headers exists then the lesson can also be brought up again, much later, when parsed by local agents.

see the documentation for `skogai-lessons` for more details on creating and using lessons.


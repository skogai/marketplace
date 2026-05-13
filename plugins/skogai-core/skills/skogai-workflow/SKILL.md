---
name: skogai-workflow
description: Step-by-step workflow for implementing features in skogai projects. Load this skill when starting any non-trivial feature or change.
version: 0.1.0
---

# skogai-workflow

A workflow for planning and shipping features in skogai projects. Follow the phases in order.

---

## Discovery

**Goal**: Understand the intent of the change — what we currently have and what is needed.

- `CLAUDE.md`, `PLAN.md` and similar files (caps rule, if in caps they are supposed to be included as a routing document) are assumed to be included

**TODO:** What commands, tools and information is needed in this step?

---

## Create Work-Order

**Goal**: Produce a self-contained description of the change — enough for an agent in a fresh worktree to implement it without needing to ask questions.

Update `PLAN.md` with a link and description to the detailed work-order under "Near-Term Tasks" together with a link to the file inside `.plans/`

A good work-order includes:

- **What**: a clear, specific description of the change
- **Why**: the motivation or problem being solved
- **Context**: relevant file paths, function names, patterns, and codebase snippets the implementor will need
- **Constraints**: conventions to follow, things not to change, edge cases to handle
- **Acceptance criteria**: how to know the implementation is correct

**TODO:** What commands, tools and information is needed in this step?

## Review

**Goal**: When a change is implemented the "meta-projects" documentation should also be updated.

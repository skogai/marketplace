---
name: skogai-workflow
description: Step-by-step workflow for implementing features in skogai projects. Load this skill when starting any non-trivial feature or change.
version: 0.1.0
---

# skogai-workflow

A workflow for planning and shipping features in skogai projects. Follow the phases in order.

---

## Phase 1: Discovery

**Goal**: Understand the intent of the change — what we currently have and what is needed.

1. Read `CLAUDE.md` and `PLAN.md` (if present) to orient yourself in the project.
2. Explore the codebase to find existing code relevant to the requested change.
3. Identify what already exists that can be reused or extended.

### Clarifying Questions

**Do not skip this step.** The user holds information that is not in the code.

After exploring, surface all ambiguities in a single organized list:

- What problem does this change solve?
- What should it do that it doesn't do today?
- Any constraints, requirements, or things it must not break?
- Edge cases or error conditions to handle?

Wait for answers before proceeding.

---

## Phase 2: Create Work-Order

**Goal**: Produce a self-contained description of the change — enough for an agent in a fresh worktree to implement it without needing to ask questions.

Update `PLAN.md` with a link and description to the detailed work-order under "Near-Term Tasks" together with a link to the file inside `.plans/`

A good work-order includes:

- **What**: a clear, specific description of the change
- **Why**: the motivation or problem being solved
- **Context**: relevant file paths, function names, patterns, and codebase snippets the implementor will need
- **Constraints**: conventions to follow, things not to change, edge cases to handle
- **Acceptance criteria**: how to know the implementation is correct

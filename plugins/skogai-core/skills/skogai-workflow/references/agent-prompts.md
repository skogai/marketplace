# Agent Prompt Templates

Ready-to-use prompts for each agent type. Adapt `[feature]`, `[area]`, and `[scope]` to context.

---

## code-explorer

For Phase 2 (Codebase Exploration), launch 2–3 of these in parallel:

**Similar features:**
```
Find features similar to [feature] and trace through their implementation comprehensively.
Focus on: entry points, call chain, data transformations, and how they integrate with the rest of the codebase.
Return a list of 5–10 key files essential for understanding this area.
```

**Architecture/abstractions:**
```
Map the architecture and abstractions for [area], tracing through the code comprehensively.
Focus on: abstraction layers, module boundaries, design patterns, and conventions.
Return a list of 5–10 key files essential for understanding this area.
```

**Integration points:**
```
Analyze [existing feature/area] to identify integration points relevant to [feature].
Focus on: interfaces, extension points, shared state, and cross-cutting concerns.
Return a list of 5–10 key files essential for understanding this area.
```

**UI/testing patterns:**
```
Identify UI patterns, testing approaches, and extension points relevant to [feature].
Return a list of 5–10 key files essential for understanding this area.
```

---

## code-architect

For Phase 4 (Architecture Design), launch 2–3 of these in parallel with different focuses:

**Minimal approach:**
```
Design a minimal implementation of [feature] that makes the smallest possible change to the codebase.
Maximize reuse of existing code and abstractions. Avoid introducing new patterns unless necessary.
Provide a complete blueprint: files to create/modify, data flow, and phased build sequence.
```

**Clean architecture:**
```
Design a clean, maintainable implementation of [feature] prioritizing long-term code health.
Focus on elegant abstractions, clear separation of concerns, and testability.
Provide a complete blueprint: files to create/modify, data flow, and phased build sequence.
```

**Pragmatic balance:**
```
Design a pragmatic implementation of [feature] balancing speed and quality.
Reuse existing patterns where sensible, introduce new abstractions only where they earn their complexity.
Provide a complete blueprint: files to create/modify, data flow, and phased build sequence.
```

---

## code-reviewer

For Phase 5 (Quality Review), launch 3 of these in parallel:

**Simplicity/DRY/elegance:**
```
Review the recent changes for simplicity, DRY violations, and code elegance.
Focus on unnecessary complexity, duplicated logic, and opportunities to simplify.
Only report issues with confidence ≥ 80.
```

**Bugs/functional correctness:**
```
Review the recent changes for bugs and functional correctness.
Focus on logic errors, null/undefined handling, race conditions, and edge cases.
Only report issues with confidence ≥ 80.
```

**Project conventions:**
```
Review the recent changes for adherence to project conventions and abstractions.
Check CLAUDE.md for explicit rules. Focus on naming, patterns, imports, and framework conventions.
Only report issues with confidence ≥ 80.
```

---

## code-simplifier

For optional post-review refinement:

```
Simplify and refine the recently modified code for clarity, consistency, and maintainability.
Preserve all functionality. Focus on [scope of changes].
```

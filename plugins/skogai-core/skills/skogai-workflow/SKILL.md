---
name: skogai-workflow
description: This skill should be used when the user asks to "start a workflow", "plan a feature", "explore the codebase", "design an architecture", "review my code", "run the full workflow", "use skogai workflow", "what agents do I use", "how do I approach this feature", or wants guidance on orchestrating code-explorer, code-architect, code-reviewer, code-simplifier, feature-dev, or revise-claude-md together into a coherent development process.
version: 0.1.0
---

# skogai-workflow

The skogai-workflow orchestrates all skogai-core agents and commands into a structured development meta-process. Each phase uses the right agent or command for the job. The implementation itself is intentionally excluded — the workflow covers everything before and after it.

## Available Components

| Component | Type | Role in workflow |
|---|---|---|
| `code-explorer` | agent | Deep codebase analysis — trace execution paths, map architecture, identify patterns |
| `code-architect` | agent | Implementation blueprint — files to create/modify, data flow, build sequence |
| `code-reviewer` | agent | Post-implementation review — bugs, security, conventions, confidence-scored issues |
| `code-simplifier` | agent | Post-implementation refinement — clarity, DRY, maintainability |
| `/feature-dev` | command | Full guided workflow — wraps phases 1–7 with agent orchestration built in |
| `/revise-claude-md` | command | Session wrap-up — persist learnings to CLAUDE.md |

---

## Workflow Phases

### Phase 1: Discovery

**Goal**: Understand what needs to be built before touching any code.

- If the request is ambiguous, ask: what problem does this solve, what should it do, any constraints?
- Summarize understanding and confirm with user before proceeding.
- Create a todo list covering all remaining phases.

**Skip if**: the task is a clearly scoped bug fix or the user has already provided full context.

---

### Phase 2: Codebase Exploration

**Goal**: Build deep, concrete understanding of relevant existing code.

Launch 2–3 `code-explorer` agents **in parallel**, each targeting a different angle:

- Similar features — trace how analogous features are implemented end-to-end
- Architecture/abstractions — map layers, patterns, module boundaries
- Integration points — identify what the new feature must plug into

Ask each agent to return a list of 5–10 key files. After agents complete, **read those files** — do not skip this. Agent summaries alone are insufficient; the actual file content is what enables confident architecture decisions.

Present a summary of findings: patterns discovered, conventions in use, relevant abstractions.

---

### Phase 3: Clarifying Questions

**Goal**: Eliminate ambiguity before committing to a design.

This phase is critical and must not be skipped. After reading the codebase:

1. Review findings against the original request
2. Identify underspecified aspects: edge cases, error handling, scope boundaries, performance needs, backward compatibility, design preferences
3. Present all questions to the user in one organized list
4. **Wait for answers before proceeding**

If the user says "whatever you think is best", provide a concrete recommendation and ask for explicit confirmation.

---

### Phase 4: Architecture Design

**Goal**: Produce a decisive, actionable blueprint.

Launch 2–3 `code-architect` agents **in parallel**, each with a different focus:

- **Minimal** — smallest change, maximum reuse of existing code
- **Clean** — maintainability, elegant abstractions, long-term fit
- **Pragmatic** — balance of speed and quality

After agents return:
1. Form an opinion on which approach fits best (consider: fix vs feature, urgency, complexity)
2. Present a brief summary of each, their trade-offs, and **a clear recommendation with reasoning**
3. Ask the user which approach to use

**Do not begin implementation until the user selects an approach.**

---

### Phase 5: Quality Review

**Goal**: Catch issues in the implementation before considering it done.

Launch 3 `code-reviewer` agents **in parallel**, each with a different lens:

- Simplicity, DRY, elegance
- Bugs and functional correctness
- Project conventions and abstraction adherence

Consolidate findings. Highlight the highest-severity issues with a recommendation on which to fix now vs later. Present to user and ask what they want to do — fix now, log for later, or proceed as-is.

Optionally follow with `code-simplifier` if significant refactoring opportunities were found.

---

### Phase 6: Session Wrap-up

**Goal**: Persist learnings so future sessions start with better context.

Run `/revise-claude-md` at the end of any session where non-obvious patterns, conventions, or gotchas were discovered.

Do not run it if nothing meaningful was learned beyond what is already documented.

---

## Choosing the Right Entry Point

| Situation | Start here |
|---|---|
| New feature, full context needed | `/feature-dev` (runs the full workflow automatically) |
| Exploring before deciding anything | `code-explorer` agents only |
| Have a plan, need a blueprint | `code-architect` agents only |
| Implementation done, need review | `code-reviewer` agents → optionally `code-simplifier` |
| Wrapping up a session | `/revise-claude-md` |
| Want manual control over each phase | Follow the phases above directly |

---

## Parallelism Rules

- Always launch multiple agents of the same type **in parallel** (single message, multiple Agent tool calls)
- Never wait for one explorer to finish before launching the next
- Reviewer agents for different lenses are always parallel
- Architect agents for different approaches are always parallel
- Read identified key files **after** all agents in a phase complete, not interleaved

---

## Additional Resources

- **`references/agent-prompts.md`** — ready-to-use prompt templates for each agent type

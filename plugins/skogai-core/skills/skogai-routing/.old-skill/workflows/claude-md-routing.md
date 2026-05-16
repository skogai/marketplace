<required_reading>
**Read these reference files NOW:**
1. references/claude-md-rules.md — the 6 rules for CLAUDE.md routing
2. references/at-linking.md — @-link mechanics (how @ works in Claude Code)
</required_reading>

<objective>
Create or audit a CLAUDE.md routing file. CLAUDE.md files form a hierarchical link chain that routes agents to content through progressive disclosure.
</objective>

<process>

<step_1>
**Determine the role: router or content-loader?**

Ask: "When an agent enters this directory, should they get ALL the content, or should they choose what to explore?"

- **All content** → this is a **content-loader**. @-link every content file. Done.
- **Choose what to explore** → this is a **router**. Continue to step 2.

Rule of thumb: leaf directories with a focused topic (like `soul/`, `core/`) are content-loaders. Mid-level directories with diverse sub-areas (like `personal/`, the workspace root) are routers.
</step_1>

<step_2>
**Identify sub-areas and classify each.**

List everything in the directory. For each item, classify:

| Item | Type | Link style |
|------|------|------------|
| Sub-dir with lightweight CLAUDE.md (small index/table) | Sub-router | @-link |
| Sub-dir with content-loader CLAUDE.md (@-links many files) | Content-loader | Plain path |
| Large content file (profile, document, reference) | Content | Plain path |
| Small identity/context file | Context | @-link (if essential) or plain path |

**The test for @-link:** If loading this file would add more than ~50 lines to context transitively, use a plain path.
</step_2>

<step_3>
**Write the CLAUDE.md.**

Use the template from `templates/claude-md-router.md`. Fill in:

1. **Identity block** — 1-3 lines in `<what_is_this>` describing the directory
2. **Routes section** — @-linked items (lightweight sub-routers, small indexes)
3. **Contents section** — plain-path items with descriptions for discoverability

Keep it under 30 lines. If you're writing more, content probably belongs in a separate file.
</step_3>

<step_4>
**Validate the chain.**

Check:
- [ ] No router @-links a content-loader CLAUDE.md
- [ ] Every @-linked file is lightweight (won't bloat context transitively)
- [ ] Non-@-linked files have descriptions sufficient for an agent to decide whether to read them
- [ ] The file is under 30 lines
- [ ] The link chain from the parent CLAUDE.md reaches this file (no orphans)
</step_4>

</process>

<audit_mode>
**Auditing an existing CLAUDE.md:**

Check for these violations:

1. **Router @-links content-loader** — A routing CLAUDE.md @-links another CLAUDE.md that itself @-links many files. Fix: change to plain path.
2. **Missing discoverability** — Files exist in the directory but aren't listed anywhere. Fix: add to contents section.
3. **Too much content** — The CLAUDE.md itself contains paragraphs of content instead of routing. Fix: move content to separate files, replace with brief descriptions and paths.
4. **@-linked content files** — Large files (profiles, documents) are @-linked instead of plain-pathed. Fix: remove @ prefix.
5. **Bare directory links** — `@soul/` instead of `@soul/CLAUDE.md`. Fix: point to the specific CLAUDE.md file.
6. **Orphaned from chain** — No parent CLAUDE.md routes to this one. Fix: add entry in parent.
</audit_mode>

<success_criteria>
This workflow is complete when:
- [ ] CLAUDE.md exists and is under 30 lines
- [ ] Router/content-loader role is correct for the directory's purpose
- [ ] No router @-links a content-loader
- [ ] All directory contents are either @-linked or listed as plain paths
- [ ] The file is reachable from the parent CLAUDE.md link chain
</success_criteria>

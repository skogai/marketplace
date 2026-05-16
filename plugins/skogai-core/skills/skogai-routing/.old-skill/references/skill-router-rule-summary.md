<rule_summary>

<purpose>
This skill is meant to be the canonical starting point for a surrounding information-routing framework. It decides where knowledge, procedures, reusable structures, and executable helpers should live, then routes work to the smallest useful endpoint.
</purpose>

<rules>

- Start with intent: identify what the user is trying to do before choosing an endpoint.
- Route directly when intent is clear; ask only when the requested path is genuinely ambiguous.
- Keep `SKILL.md` as the entrypoint, not the knowledge base.
- Put core principles and immediate routing guidance near the top of `SKILL.md`.
- Move procedural detail into `workflows/`.
- Move reusable background knowledge into `references/`.
- Move repeatable output formats into `templates/`.
- Move executable repeatable operations into `scripts/`.
- Use progressive disclosure: load only the files needed for the current task.
- Keep references one level deep from `SKILL.md`.
- Prefer adding a focused reference file over bloating `SKILL.md`.
- Use semantic XML tags in framework bodies instead of markdown headings.
- Keep markdown formatting only inside XML sections, such as lists, emphasis, code blocks, and links.
- Make YAML frontmatter precise because it controls skill discovery.
- Write descriptions in third person and include both capability and trigger conditions.
- Name skills and endpoints with lowercase hyphenated verb-noun names when names are part of discovery.
- Trust the agent: provide constraints, routing, examples, and context, but avoid overexplaining obvious behavior.
- Match instruction strictness to task risk: freer guidance for judgment-heavy work, stricter sequences for fragile operations.
- Use templates when consistent output matters.
- Use scripts when repeated manual work can be safely automated.
- Treat legacy or imported creator skills as source material to absorb or retire, not competing entrypoints.
- Judge success by whether the skill routes quickly, stays small, and helps real tasks complete.

</rules>

<current_router_intents>

- Decide where information should live.
- Create a new skill or endpoint.
- Audit or modify an existing skill or endpoint.
- Add a workflow, reference, template, or script to a skill.
- Get guidance on skill design.
- Create or audit a routing file such as `CLAUDE.md` or similar project guidance.
- Apply the router's structure and progressive disclosure patterns to another workflow.

</current_router_intents>

<rewrite_implications>

- The rewritten `SKILL.md` should be much smaller than the current one.
- Test snippets and unrelated command examples should not live in the production router body.
- The router should describe ownership, intake, routing, and success criteria only.
- Detailed teaching material should move to references.
- Each workflow should own its own procedure and validation.
- The framework should be rewritten endpoint by endpoint, not by expanding the router.

</rewrite_implications>

</rule_summary>

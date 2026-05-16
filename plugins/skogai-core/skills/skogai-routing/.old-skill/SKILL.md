---
name: skogai-routing
description: Routes information, instructions, workflows, references, templates, and executable helpers into a progressive framework. Use as the starting point when deciding where knowledge should live, which endpoint should handle a request, or how a skill-like system should be structured.
---

<objective>
Provide the starting point for a surrounding information framework.

This skill does not try to contain the whole system. It identifies the user's intent, chooses the right endpoint, loads only the material needed for the current task, and keeps every deeper instruction owned by the file best suited to maintain it.
</objective>

<core_model>
Treat every file in the framework as an endpoint with a clear job:

- `SKILL.md` is the router.
- `workflows/` contains procedures to follow.
- `references/` contains reusable knowledge to read.
- `templates/` contains structures to copy and fill.
- `scripts/` contains repeatable operations to execute when present.

Route by intent first, then by file type. Do not force menu navigation when the user's intent is already clear.
</core_model>

<framework_rules>

- Start here when deciding where information belongs.
- Keep the router small; move detail outward.
- Load only the endpoint needed for the current task.
- Prefer one focused endpoint over one broad mixed-purpose file.
- Keep references one level deep from the router.
- Use semantic XML tags for skill bodies and routing files.
- Keep markdown formatting inside XML sections only.
- Write discovery metadata in precise third person.
- Give the agent constraints, defaults, and examples; avoid explaining what the agent already knows.
- Match strictness to risk: flexible guidance for judgment work, exact steps for fragile workflows.
- Use templates when output consistency matters.
- Use scripts when repeated work can be safely automated.
- Retire or absorb legacy entrypoints once this router owns their purpose.

</framework_rules>

<quick_start>
When invoked:

1. Restate the user's intent in one short phrase.
2. Decide whether this is routing, authoring, auditing, extension, or framework design.
3. Open the matching workflow or reference below.
4. Follow that endpoint's instructions.
5. Stop loading files once the current task has enough context.

If the request is ambiguous, ask the smallest question that separates the possible routes.
</quick_start>

<routing>

| intent | endpoint |
| --- | --- |
| Create a new skill or framework endpoint | `workflows/create-new-skill.md` |
| Create an exhaustive domain knowledge skill | `workflows/create-domain-expertise-skill.md` |
| Audit or revise an existing skill | `workflows/audit-skill.md` |
| Verify whether skill content is current | `workflows/verify-skill.md` |
| Add a workflow | `workflows/add-workflow.md` |
| Add a reference | `workflows/add-reference.md` |
| Add a template | `workflows/add-template.md` |
| Add a script | `workflows/add-script.md` |
| Convert a simple skill into a router | `workflows/upgrade-to-router.md` |
| Decide where information should live | `workflows/get-guidance.md` |
| Create or audit a project routing file | `workflows/claude-md-routing.md` |
| Apply routing principles inline | `references/skill-router-rule-summary.md` |

</routing>

<reference_index>

| topic | endpoint |
| --- | --- |
| Router rules | `references/skill-router-rule-summary.md` |
| Core principles | `references/core-principles.md` |
| Skill structure | `references/skill-structure.md` |
| XML tags | `references/use-xml-tags.md` |
| Common patterns | `references/common-patterns.md` |
| Clear instruction style | `references/be-clear-and-direct.md` |
| Workflow validation | `references/workflows-and-validation.md` |
| Template usage | `references/using-templates.md` |
| Script usage | `references/using-scripts.md` |
| Executable code | `references/executable-code.md` |
| API safety | `references/api-security.md` |
| Iteration and testing | `references/iteration-and-testing.md` |
| Project routing files | `references/claude-md-rules.md` |
| At-linking | `references/at-linking.md` |

</reference_index>

<endpoint_design>
Use this structure when creating or rewriting endpoints:

- A router answers "where should this go?"
- A workflow answers "what steps should be followed?"
- A reference answers "what should be known?"
- A template answers "what shape should the output have?"
- A script answers "what repeatable action should be run?"

If one endpoint starts answering more than one of these questions, split it.
</endpoint_design>

<success_criteria>
The framework is working when:

- The router can be read quickly.
- A request reaches the right endpoint without search-heavy wandering.
- Detail lives outside the router.
- Each endpoint has one obvious purpose.
- The agent loads less context, not more.
- New workflows, references, templates, and scripts have predictable homes.
- The system improves by adding better endpoints instead of enlarging the entrypoint.
</success_criteria>

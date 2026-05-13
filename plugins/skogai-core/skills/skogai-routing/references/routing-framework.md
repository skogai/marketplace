<routing_framework>

<overview>
The framework organizes agent-facing information by purpose. The root router should not teach every detail; it should send the agent to the smallest endpoint that can complete the task.
</overview>

<routing_file>
A routing file is a compact entrypoint for a context.

It owns:

- scope
- intent detection
- endpoint selection
- success criteria
- local conventions needed before loading deeper files

It should not own long procedures, broad reference material, or repeated templates.
</routing_file>

<endpoint_types>

| type | question answered | common location |
| --- | --- | --- |
| Router | Where should this go next? | `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, nested routers |
| Workflow | What steps should be followed? | `workflows/*.md` |
| Reference | What should be known? | `references/*.md` |
| Template | What shape should output take? | `templates/*.md` |
| Script | What repeatable check or action should run? | `scripts/*` |

</endpoint_types>

<unified_routing_model>
`simple-skill`, `SKILL.md`, `AGENTS.md`, and `CLAUDE.md` are all routing files. They differ by scope, not by core structure.

- A simple skill routes one small capability.
- `SKILL.md` routes a reusable capability package.
- `AGENTS.md` routes repo-local agent behavior.
- `CLAUDE.md` routes Claude-specific project behavior.

When rewriting older material, collapse special cases into this unified model unless the host runtime requires a different format.
</unified_routing_model>

<progressive_disclosure>
Progressive disclosure means loading information only when it becomes relevant.

Use it by:

- keeping routers short
- naming endpoints clearly
- linking only direct child endpoints
- putting deep detail in references selected by workflows
- avoiding "just in case" context

</progressive_disclosure>

</routing_framework>

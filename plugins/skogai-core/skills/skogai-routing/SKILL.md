---
name: skogai-routing
description: Routes information through a progressive framework of routing files, workflows, references, templates, and scripts. Use as the starting point when deciding where guidance belongs, which endpoint should handle a request, or how to structure an agent-facing knowledge system.
---

<objective>
Act as the root router for an agent-facing information framework.

This skill treats `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, and small local guidance files as variants of the same pattern: a routing file. A routing file is a compact entrypoint that states ownership, identifies intent, and points to the smallest useful endpoint.
</objective>

<mental_model>
Every file has one job:

- Routing files answer "where should this go next?"
- Workflows answer "what steps should be followed?"
- References answer "what should be known?"
- Templates answer "what shape should output take?"
- Scripts answer "what repeatable check or action should run?"

If a file starts doing more than one job, split it or demote the extra detail into a more specific endpoint.
</mental_model>

<quick_start>
When invoked:

1. Identify the user's intent.
2. Decide whether the task is routing, authoring, auditing, templating, or validation.
3. Load one matching endpoint from `<routing>`.
4. Follow that endpoint and stop loading context once the task is clear.
5. Create or update the smallest file that owns the needed behavior.

Ask a question only when two routes would produce meaningfully different files.
</quick_start>

<routing>

| intent                           | endpoint                                |
| -------------------------------- | --------------------------------------- |
| Decide where guidance belongs    | `workflows/route-information.md`        |
| Create or rewrite a routing file | `workflows/write-routing-file.md`       |
| Create a workflow endpoint       | `workflows/write-workflow.md`           |
| Create a reference endpoint      | `workflows/write-reference.md`          |
| Create or revise templates       | `workflows/write-template.md`           |
| Add helper scripts or checks     | `workflows/write-script.md`             |
| Audit framework structure        | `workflows/audit-framework.md`          |
| Validate files against schemas   | `workflows/validate-schema.md`          |
| Browse schema definitions        | `schemas/README.md`                     |
| Create tests for a hook          | `workflows/write-hook-tests.md`         |
| Understand @-linking mechanics   | `references/at-linking.md`              |
| Apply claude.md routing rules    | `references/claude-md-routing-rules.md` |
| Understand the core model        | `references/routing-framework.md`       |
| Choose XML tags                  | `references/xml-tags.md`                |
| Use naming and ownership rules   | `references/naming-and-ownership.md`    |

</routing>

<routing_file_variants>

| variant        | scope                                          |
| -------------- | ---------------------------------------------- |
| `SKILL.md`     | Reusable capability or package entrypoint      |
| `AGENTS.md`    | Repository or working-context entrypoint       |
| `CLAUDE.md`    | Claude-specific project entrypoint             |
| `simple-skill` | Minimal routing file for one small capability  |
| Nested router  | Subdomain entrypoint inside a larger framework |

These are not separate concepts. They are routing files with different scope and runtime conventions.
</routing_file_variants>

<framework_rules>

- Keep routing files small.
- Route by intent before file type.
- Put durable concepts in references.
- Put ordered procedures in workflows.
- Put reusable output shapes in templates.
- Put repeatable inspection or execution in scripts.
- Keep endpoint references one level deep from the router that names them.
- Prefer one focused endpoint over one mixed-purpose file.
- Use semantic XML sections in agent-facing bodies.
- Keep markdown headings out of XML-structured bodies.
- Preserve existing runtime conventions when adapting to `AGENTS.md`, `CLAUDE.md`, or another host format.

</framework_rules>

<success_criteria>
The framework is healthy when:

- A new task reaches the right endpoint quickly.
- The root router remains readable in one pass.
- Similar entrypoints share one routing-file model.
- Workflows, references, templates, and scripts have predictable homes.
- Helper scripts can inspect the framework without becoming required for comprehension.
- Old or competing routing concepts are absorbed into the unified model.
  </success_criteria>

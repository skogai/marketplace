---
name: skogai-routing
description: routes information through a progressive framework of routing files, workflows, references, templates, and scripts. use as the starting point when deciding where guidance belongs, which endpoint should handle a request, or how to structure an agent-facing knowledge system.
---

<objective>
act as the root router for an agent-facing information framework.

this skill treats `skill.md`, `agents.md`, `claude.md`, and small local guidance files as variants of the same pattern: a routing file. a routing file is a compact entrypoint that states ownership, identifies intent, and points to the smallest useful endpoint.
</objective>

<mental_model>
every file has one job:

- routing files answer "where should this go next?"
- workflows answer "what steps should be followed?"
- references answer "what should be known?"
- templates answer "what shape should output take?"
- scripts answer "what repeatable check or action should run?"

if a file starts doing more than one job, split it or demote the extra detail into a more specific endpoint.
</mental_model>

<quick_start>
when invoked:

1. identify the user's intent.
2. decide whether the task is routing, authoring, auditing, templating, or validation.
3. load one matching endpoint from `<routing>`.
4. follow that endpoint and stop loading context once the task is clear.
5. create or update the smallest file that owns the needed behavior.

ask a question only when two routes would produce meaningfully different files.
</quick_start>

<routing>

| intent                           | endpoint                             |
| -------------------------------- | ------------------------------------ |
| decide where guidance belongs    | `workflows/route-information.md`     |
| create or rewrite a routing file | `workflows/write-routing-file.md`    |
| create a workflow endpoint       | `workflows/write-workflow.md`        |
| create a reference endpoint      | `workflows/write-reference.md`       |
| create or revise templates       | `workflows/write-template.md`        |
| add helper scripts or checks     | `workflows/write-script.md`          |
| list all caps router files       | `scripts/list-caps-files.sh`         |
| list @-links in routing files    | `scripts/list-at-links.sh`           |
| list dotdirs needing @-links     | `scripts/list-dotdirs.sh`            |
| create tests for a hook          | `workflows/write-hook-tests.md`      |
| audit framework structure        | `workflows/audit-framework.md`       |
| understand the core model        | `references/routing-framework.md`       |
| choose xml tags                  | `references/xml-tags.md`                |
| use naming and ownership rules   | `references/naming-and-ownership.md`    |
| understand @-linking mechanics   | `references/at-linking.md`              |
| apply claude.md routing rules    | `references/claude-md-routing-rules.md` |

</routing>

<routing_file_variants>

| variant        | scope                                          |
| -------------- | ---------------------------------------------- |
| `skill.md`     | reusable capability or package entrypoint      |
| `agents.md`    | repository or working-context entrypoint       |
| `claude.md`    | claude-specific project entrypoint             |
| `simple-skill` | minimal routing file for one small capability  |
| nested router  | subdomain entrypoint inside a larger framework |

these are not separate concepts. they are routing files with different scope and runtime conventions.
</routing_file_variants>

<framework_rules>

- keep routing files small.
- route by intent before file type.
- put durable concepts in references.
- put ordered procedures in workflows.
- put reusable output shapes in templates.
- put repeatable inspection or execution in scripts.
- keep endpoint references one level deep from the router that names them.
- prefer one focused endpoint over one mixed-purpose file.
- use semantic xml sections in agent-facing bodies.
- keep markdown headings out of xml-structured bodies.
- preserve existing runtime conventions when adapting to `agents.md`, `claude.md`, or another host format.
  </framework_rules>

<success_criteria>
the framework is healthy when:

- a new task reaches the right endpoint quickly.
- the root router remains readable in one pass.
- similar entrypoints share one routing-file model.
- workflows, references, templates, and scripts have predictable homes.
- helper scripts can inspect the framework without becoming required for comprehension.
- old or competing routing concepts are absorbed into the unified model.
  </success_criteria>

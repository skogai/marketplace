# schemas

JSON Schema (draft 2020-12) definitions for skogai routing framework documents.

| file | purpose | key required sections |
| --- | --- | --- |
| `defs.schema.json` | shared `$defs` (slug, path, tag, xmlSection, link, heading) | — |
| `frontmatter.schema.json` | YAML frontmatter block; requires `type` | `type` |
| `document.schema.json` | normalized document envelope | `path`, `type`, `sections` |
| `router.schema.json` | routing file variant | `<objective>`, `<routing>` sections |
| `workflow.schema.json` | workflow endpoint | `<objective>`, `<steps>`, `<validation>` sections |
| `reference.schema.json` | reference endpoint | `<overview>` section |
| `template.schema.json` | template endpoint | `<template>` section |
| `script.schema.json` | script endpoint | `type: script` |
| `lesson.schema.json` | lesson document | `match`, `status`, `version` in frontmatter; `rule`, `context`, `pattern` headings |

## type → schema mapping

| frontmatter `type` | schema file |
| --- | --- |
| `router` | `router.schema.json` |
| `workflow` | `workflow.schema.json` |
| `reference` | `reference.schema.json` |
| `template` | `template.schema.json` |
| `script` | `script.schema.json` |
| `lesson` | `lesson.schema.json` |

## validate

```sh
./scripts/validate-schema.sh [path-to-framework-root]
```

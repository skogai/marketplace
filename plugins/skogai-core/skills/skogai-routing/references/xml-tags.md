<xml_tags>

<overview>
Use semantic XML tags to make agent-facing guidance easy to scan, parse, and validate. Markdown formatting can appear inside XML sections, but markdown headings should not structure XML-based files.
</overview>

<common_tags>

| tag | purpose |
| --- | --- |
| `<objective>` | What this file is for |
| `<quick_start>` | Immediate operating steps |
| `<routing>` | Intent-to-endpoint mapping |
| `<mental_model>` | Core abstraction or model |
| `<rules>` | Constraints that should usually hold |
| `<workflow>` | Ordered procedure |
| `<reference>` | Durable conceptual material |
| `<template>` | Copyable output structure |
| `<validation>` | Checks to run before finishing |
| `<success_criteria>` | What done looks like |

</common_tags>

<selection_rules>

- Use tags for meaning, not decoration.
- Prefer a small stable tag set over bespoke labels everywhere.
- Do not mix two tags for the same concept in one file.
- Use tables and lists inside tags when they make routing faster.
- Keep required tags minimal for small files.

</selection_rules>

</xml_tags>

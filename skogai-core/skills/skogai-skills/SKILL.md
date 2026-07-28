---
name: skogai-skills
description: helps users discover and install agent skills when they ask questions like "how do i do x", "find a skill for x", "is there a skill that can...", or express interest in extending capabilities. this skill should be used when the user is looking for functionality that might exist as an installable skill.
---

<skill>

# skogai-skills

This skill helps with discovering, creating, integrating and installing skills for any SkogAI-project.

skogai-skills is build around the open agent skills ecosystem and use a fork of `Skills CLI`, a skills package manager by vercel-labs (`npx skills`).

<activation>

## when to use this skill

use this skill when the user:

- asks "how do i do x" where x might be a common task with an existing skill
- says "find a skill for x" or "is there a skill for x"
- asks "can you do x" where x is a specialized capability
- expresses interest in extending agent capabilities
- wants to search for tools, templates, or workflows
- mentions they wish they had help with a specific domain (design, testing, deployment, etc.)

</activation>

<routes>

- @references/common-skill-categories.md
- @references/no-skills-are-found.md
- @references/skills-cli.md
- @workflow/create-a-skill.md
- @workflow/find-a-skill.md

</routes>

</skill>

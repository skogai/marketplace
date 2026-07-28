---
type: workflow
permalink: skogai-skills/create-a-skill
---

<workflow>

## how to create a skogai-skill

### step 1: understand what already exists

use @workflow/find-a-skill.md first. if a well-tested skill already covers the need, installing beats building. only create a new skill when:

- no existing skill covers the task, or
- existing skills are close but conflict with skogai conventions, or
- the knowledge is project- or user-specific and doesn't belong upstream

### step 2: discuss with the user

before writing anything, agree on:

1. **the trigger** — what user phrases should activate the skill? this becomes the frontmatter `description`
2. **the scope** — one skill does one thing. "helps with git" is too broad; "writes conventional commits from a mixed worktree" is right
3. **the shape** — is it a workflow (steps to follow), a reference (facts to look up), or both?

### step 3: scaffold the structure

```
skill-name/
├── SKILL.md          # entrypoint: activation + routes, nothing else
├── workflow/         # step-by-step procedures, one file per procedure
└── references/       # lookup material, one file per topic
```

initialize with the cli if starting from scratch:

```bash
npx skills init skill-name
```

then reshape it to the skogai layout above.

### step 4: write SKILL.md

keep the entrypoint lean — details live in `workflow/` and `references/`, SKILL.md only routes to them:

```markdown
---
name: skill-name
description: one line stating what it does and the user phrases that should trigger it
---

<skill>

# skill-name

one or two sentences on what this skill covers.

<activation>

## when to use this skill

use this skill when the user:

- [trigger phrase or situation]
- [trigger phrase or situation]

</activation>

<routes>

- @references/[topic].md
- @workflow/[procedure].md

</routes>

</skill>
```

### step 5: write the workflow and reference files

every file follows the same conventions:

1. **frontmatter** — `type: workflow` or `type: reference`, plus `permalink: skill-name/file-name`
2. **semantic tag wrapper** — `<workflow>` or `<reference>` matching the type
3. **lowercase prose** — headings and body text stay lowercase; code, commands, and proper names keep their casing
4. **steps for workflows** — `### step n: [verb phrase]` with concrete commands and example blocks
5. **@-links between files** — reference sibling files as `@workflow/name.md`, never restate their content

### step 6: verify

1. read SKILL.md as if you were a fresh agent — can you reach every file through the routes block?
2. check the frontmatter `description` against the triggers from step 2 — it is the only thing the agent sees before activation
3. trigger the skill in a new session with one of the agreed phrases and confirm it activates

</workflow>

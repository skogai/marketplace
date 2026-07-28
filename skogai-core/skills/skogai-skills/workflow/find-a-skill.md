---
type: workflow
permalink: skogai-skills/find-a-skill
---

<workflow>

## how to help users find skills

### step 1: understand what they need

when a user asks for help with something, identify:

1. the domain (e.g., react, testing, design, deployment)
2. the specific task (e.g., writing tests, creating animations, reviewing prs)
3. whether this is a common enough task that a skill likely exists

### step 2: check the leaderboard first

before running a cli search, check the [skills.sh leaderboard](https://skills.sh/) to see if a well-known skill already exists for the domain. the leaderboard ranks skills by total installs, surfacing the most popular and battle-tested options.

for example, top skills for web development include:

- `vercel-labs/agent-skills` — react, next.js, web design (100k+ installs each)
- `anthropics/skills` — frontend design, document processing (100k+ installs)

### step 3: search for skills

if the leaderboard doesn't cover the user's need, run the find command:

```bash
npx skills find [query] [--owner <owner>]
```

for example:

- user asks "how do i make my react app faster?" → `npx skills find react performance`
- user asks "can you help me with pr reviews?" → `npx skills find pr review`
- user asks "i need to create a changelog" → `npx skills find changelog`

### step 4: verify quality before recommending

**do not recommend a skill based solely on search results.** always verify:

1. **install count** — prefer skills with 1k+ installs. be cautious with anything under 100.
2. **source reputation** — official sources (`vercel-labs`, `anthropics`, `microsoft`) are more trustworthy than unknown authors.
3. **github stars** — check the source repository. a skill from a repo with <100 stars should be treated with skepticism.

### step 5: present options to the user

when you find relevant skills, present them to the user with:

1. the skill name and what it does
2. the install count and source
3. the install command they can run
4. a link to learn more at skills.sh

example response:

```
i found a skill that might help! the "react-best-practices" skill provides
react and next.js performance optimization guidelines from vercel engineering.
(185k installs)

to install it:
npx skills add vercel-labs/agent-skills@react-best-practices

learn more: https://skills.sh/vercel-labs/agent-skills/react-best-practices
```

### step 6: offer to install

if the user wants to proceed, you can install the skill for them:

```bash
npx skills add <owner/repo@skill> -g -y
```

the `-g` flag installs globally (user-level) and `-y` skips confirmation prompts.

</workflow>

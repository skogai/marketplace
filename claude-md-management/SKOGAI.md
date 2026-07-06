---
permalink: claude-md-management/skogai
type: router
---

`claude-md-management` keeps a repo's CLAUDE.md aligned with reality over time. It
pairs a skill for periodic maintenance with a command for end-of-session capture:

| | claude-md-improver (skill) | /revise-claude-md (command) |
|---|---|---|
| Purpose | Keep CLAUDE.md aligned with codebase | Capture session learnings |
| Triggered by | Codebase changes | End of session |
| Use when | Periodic maintenance | Session revealed missing context |

<routes>

- @README.md - full usage docs and examples
- @skills/claude-md-improver/SKILL.md - audits/improves CLAUDE.md against the current codebase
- @commands/revise-claude-md.md - end-of-session command that captures learnings into CLAUDE.md

</routes>

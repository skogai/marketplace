---
permalink: plugin-dev/skogai
type: router
---

`plugin-dev` is the toolkit for building other Claude Code plugins: seven skills
covering hooks, MCP integration, plugin structure, settings, commands, agents, and
skill development, plus a `/create-plugin` command and three agents (agent-creator,
plugin-validator, skill-reviewer) for scaffolding and reviewing plugin components.

<routes>

- @README.md - full toolkit overview
- @commands/create-plugin.md - scaffolds a new plugin
- @agents/agent-creator.md - AI-assisted agent scaffolding
- @agents/plugin-validator.md - validates plugin structure/manifest
- @agents/skill-reviewer.md - reviews skill quality
- @skills/plugin-structure/SKILL.md - plugin organization and manifest configuration
- @skills/command-development/SKILL.md - slash commands with frontmatter and arguments
- @skills/agent-development/SKILL.md - autonomous agent creation
- @skills/skill-development/SKILL.md - skills with progressive disclosure and strong triggers
- @skills/hook-development/SKILL.md - hooks API and event-driven automation
- @skills/mcp-integration/SKILL.md - Model Context Protocol server integration
- @skills/plugin-settings/SKILL.md - configuration patterns via .claude/plugin-name.local.md

</routes>

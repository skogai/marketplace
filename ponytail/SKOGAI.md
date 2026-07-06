---
permalink: ponytail/skogai
type: router
---

`ponytail` is "lazy senior dev mode": it forces the simplest, shortest solution
that actually works (YAGNI, stdlib first, no unrequested abstractions) via hooks
that inject behavior into every session, plus companion skills/commands for
auditing code against that philosophy. Unlike the other plugins here, it's a full
Node project with its own package.json, MCP server, and test suite — run its
tests from within the plugin directory: `cd ponytail && npm test`.

<routes>

- @README.md - philosophy, installation, and usage
- @AGENTS.md - agent-facing behavior notes
- @skills/ponytail/SKILL.md - core lazy-senior-dev behavior
- @skills/ponytail-audit/SKILL.md - audits code against the ponytail philosophy
- @skills/ponytail-debt/SKILL.md - tracks/reports complexity debt
- @skills/ponytail-gain/SKILL.md - reports simplification gains
- @skills/ponytail-help/SKILL.md - help/usage skill
- @skills/ponytail-review/SKILL.md - review skill
- @hooks/hooks.json - lifecycle hook wiring
- @ponytail-mcp/README.md - the bundled MCP server
- @docs/ - platform-native and agent-portability design notes
- @benchmarks/README.md - correctness/behavior benchmark suite

</routes>

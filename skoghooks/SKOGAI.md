---
permalink: skoghooks/skogai
type: router
---

`skoghooks` wires a script into every Claude Code lifecycle event (setup,
session start/end, prompt submit, tool use and tool-use failure, permission
requests, notifications, stop, subagent start/stop, pre-compact) to provide
consistent logging and context handling across sessions.

<routes>

- @README.md - installation and full event/hook rundown
- @hooks/hooks.json - the lifecycle hook wiring itself
- @scripts/ - one Python handler per lifecycle event, plus validators/ and utils/

</routes>

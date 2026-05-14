---
name: at-linking
type: reference
permalink: skogai/at-linking
---

<overview>
how @-linking works in claude code — the proactive import system for passing file contents and permissions to agents and subagents simultaneously. critical when routing through workflows or dispatching subagents.
</overview>

<what_it_does>
`@path/to/file` in claude.md or a user message causes that file to be:

- collected and cached at session start (proactive import — no active lookup needed)
- available to read immediately
- effectively `cat /path/to/file >> context`

**@ is the source of truth.** the read tool often returns cached content when it makes sense (example: when asking subagents to research something it would all happen outside the users actual file system). @ always expands from the real filesystem at prompt-time and updates the cache to mirror reality.
</what_it_does>

<where_it_works>
- **claude.md files** (global and project-level) — loaded at session start, up to six levels deep
- **user messages** — `@inbox.md` appended literally to the message; small changes show as git diff between cached and current version
- **messages to subagents** — a message to a subagent is a user message in the backend; @ works the same way
</where_it_works>

<permissions>
@-linking is **both context and permission** — it simultaneously:

1. passes file contents into the message (the cli is smart and only appends a diff and updates if needed)
2. grants the agent permission to access that path

permission rules:

- a file must have been @-linked actively by the user somewhere already (directly or indirectly)
- opening a session in a path approves reading in that directory
- @-linking something outside the session path (or already approved paths) triggers an additional approval prompt
- subagents follow the same permission flow as the parent
- dotfiles/folders follow restrictive rules (sometimes hidden by default, sometimes not usable from links, settings files, environment variables etc)
- example: files like `.claude/settings.json`, `~/.ssh/` or `.env` would need explicit linkings for different reasons
</permissions>

<rules_for_agents>
**always @-link files in messages to subagents.** a subagent cannot read files that haven't been linked. treat @-links like function arguments.

| context                | rule                                                                                  |
| ---------------------- | ------------------------------------------------------------------------------------- |
| subagent messages      | @-link every file the subagent needs to read                                          |
| plan mode              | works against cached data only — if not @-linked or previously read, it doesn't exist |
| glob/grep in subagents | only searches what's been cached/permitted — no @-link = no results, silently         |
| workflows              | @-link referenced files when routing, not just naming them                            |
| skills/commands        | @-linking in some cases literally replaces itself with the content of the file        |

**never assume a subagent can "just look it up."** no @-link = no access, with no error to indicate why.
</rules_for_agents>

<known_unknowns>
- **recursive depth:** works six levels deep (last confirmed)
- **memory files:** they only "pre-load" x amounts of rows, hopefully injects @-links if space exists. also the memory folder itself already have the permissions needed.
- **globs:** only `@a`, `@~/`, `@/`, `@./` — no wildcard patterns. if claude use his glob-tool it either run ripgrep on the users machine and always asks for permission or run the "ripgrep alternative" against however the provider cache their data
- **resolution:** relative to the file being read; normally cwd for claude/user depending on settings (for example if the cwd get reset between tool calls)
- **guarantee:** a @-link is a "please read" not a contract — not guaranteed to be included in context if for example limits are exceeded
</known_unknowns>

<companion_reference>
for claude.md routing rules (when to @-link vs plain path, router vs content-loader distinction), see [claude-md-routing-rules.md](./claude-md-routing-rules.md).
</companion_reference>

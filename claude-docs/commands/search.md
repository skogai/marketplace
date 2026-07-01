---
description: Search the downloaded Claude Code documentation for a query
argument-hint: <query>
---

Search the local Claude Code documentation cache for information about: $ARGUMENTS

The documentation is stored as markdown files under `${CLAUDE_PLUGIN_ROOT}/tmp/docs/`, one file per topic (e.g. `hooks.md`, `mcp.md`, `plugins-reference.md`).

Steps:

1. If `${CLAUDE_PLUGIN_ROOT}/tmp/docs/` is empty or missing, tell the user to restart their session (the `SessionStart` hook downloads the docs), or run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/download-docs.sh` directly to fetch them now.
2. Use `grep -ril` (or ripgrep if available) over `${CLAUDE_PLUGIN_ROOT}/tmp/docs/` to find files matching the query terms in "$ARGUMENTS".
3. Read the matching file(s) and extract the sections most relevant to the query.
4. Answer the user's question directly, citing which doc file(s) the answer came from (e.g. "See `hooks.md`").
5. If nothing matches, say so plainly rather than guessing — don't fabricate documentation content.

Keep the answer focused on what was asked; don't dump entire doc files unless the user asks for the full page.

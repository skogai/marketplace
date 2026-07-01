---
name: init-routing
description: Scaffold a new SKOGAI.md routing file in a repo and wire it into CLAUDE.md via a `- read @SKOGAI.md` line. Use when the user asks to "add a routing file", "set up SKOGAI.md", "add SKOGAI.md to this repo", or references adding a routing CLAUDE.md/SKOGAI.md to a specific repo.
tools: Read, Write, Edit, Bash
---

Scaffold a v1 skogai routing file for the target repo.

1. Resolve the target directory from the user's request, else the current
   working directory. Confirm it looks like a repo root (has `.git` or the
   user already told you it is one).
2. Check whether `SKOGAI.md` already exists there. If it does, stop and tell
   the user — do not overwrite silently.
3. Read `${CLAUDE_PLUGIN_ROOT}/skills/skogai-routing/examples/SKOGAI.md.example`
   as the template. Write a new `SKOGAI.md` in the target directory with:
   - `type: router` in frontmatter
   - `permalink` set from whatever the user specified, otherwise a
     reasonable slug derived from the repo/directory name (e.g.
     `<repo-name>/claude`)
   - an empty or minimal `<routes>` block — do not invent route entries the
     user hasn't asked for
4. Check the target's `CLAUDE.md`:
   - If it doesn't exist, ask the user before creating one — a missing
     CLAUDE.md may be intentional.
   - If it exists and already contains `read @SKOGAI.md` (in any form),
     leave it alone.
   - Otherwise, append a line `- read @SKOGAI.md` (matching
     `examples/CLAUDE.md.example` from the `skogai-routing` skill) under a
     sensible existing section, or add a small new section if none fits.
5. Report exactly what was created/edited. Do not run
   `scripts/validate-router.sh` automatically — mention it as a next step
   the user can run via the `validate-routing` skill.

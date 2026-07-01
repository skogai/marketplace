---
name: validate-routing
description: Validate SKOGAI.md / CLAUDE.md routing files against the skogai router convention (frontmatter type: router, well-formed <routes> block). Use when the user asks to "validate SKOGAI.md", "check the routing file", "lint the routes tag", or after creating/editing a routing file.
tools: Read, Bash, Glob
---

Validate one or more skogai routing files.

1. Resolve targets from the user's request:
   - If a file path is given, validate that file directly.
   - If a directory (or nothing) is given, find candidate files with Glob:
     `SKOGAI.md` and `CLAUDE.md` under that directory (default: cwd).
   - Skip files whose frontmatter `type` isn't `router` — this validator
     only covers that one document type in v1.
2. Run this plugin's validator:
   `bash ${CLAUDE_PLUGIN_ROOT}/skills/skogai-routing/scripts/validate-router.sh <file...>`
3. Report PASS/FAIL/WARN per file, and for any FAIL, quote the specific
   schema error so the user knows exactly what to fix (e.g. missing
   `<routes>` section, `type` not `router`, missing frontmatter).
4. Do not attempt to auto-fix failures — report them and let the user or a
   follow-up edit fix the file.

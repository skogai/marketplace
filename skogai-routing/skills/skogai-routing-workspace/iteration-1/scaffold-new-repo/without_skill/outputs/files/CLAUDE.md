---
permalink: skogtasks/claude
type: router
---

<routes>

- @SKOGAI.md

</routes>

## Repository Purpose

`skogtasks` is the standalone home for the SkogAI task tooling, split out of the
marketplace repo into its own repository.

Claude Code loads this `CLAUDE.md` automatically on session start. It intentionally
holds no project detail of its own — it only routes into `@SKOGAI.md`, which is the
real entry point for the repo's context. Keep durable project knowledge in the routed
files, not here.

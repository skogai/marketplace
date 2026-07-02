# skogtasks

The SkogAI task tooling, split out into its own repository.

## Context routing

This repo uses the SkogAI routing convention so Claude Code picks up context
automatically:

- `CLAUDE.md` — auto-loaded by Claude Code on session start; routes to `SKOGAI.md`.
- `SKOGAI.md` — the actual entry-point router for the repo; routes into this README
  and (as the repo grows) into the source, docs, and any sub-projects.

When you add real project structure, add a `@path - description` line to the
`<routes>` block of `SKOGAI.md` (or a nested `SKOGAI.md`) rather than dumping detail
into `CLAUDE.md`.

## Layout

```
skogtasks/
├── CLAUDE.md    # router: Claude Code entry point → SKOGAI.md
├── SKOGAI.md    # router: repo entry point → content
└── README.md    # this file
```

Source and tooling get added here as the split-out progresses.

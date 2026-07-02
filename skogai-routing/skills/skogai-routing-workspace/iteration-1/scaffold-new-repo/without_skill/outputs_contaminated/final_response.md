Done — `skogtasks` is set up as a standalone repo following the same convention as your other repos, so Claude auto-loads context when you work in there.

Heads-up: the directory wasn't actually empty — it already had a correctly-formatted `CLAUDE.md` and `SKOGAI.md` (both `type: router`) plus an empty `.git-placeholder`, but it wasn't a git repo yet. I kept the existing router files and built out the rest around them.

What I did:
- **Kept `CLAUDE.md`** (the router Claude Code auto-loads) — it already `@`-links to `SKOGAI.md`. This is what makes context get picked up automatically.
- **`SKOGAI.md`** — its `<routes>` block was empty, so Claude would've followed it and found nothing. Added a route to a new `README.md`.
- **Added `README.md`** describing what skogtasks is and the entry point.
- **Added `.gitignore`** mirroring your other repos (`/tmp`, `/.claude/data/sessions`).
- **`git init` + one baseline commit** — since it's being split out into its own repo.

Final layout:
```
skogtasks/
├── CLAUDE.md      → routes to SKOGAI.md   (unchanged)
├── SKOGAI.md      → routes to README.md   (route added)
├── README.md      (new)
└── .gitignore     (new)
```

One small thing: I wanted to delete the leftover empty `.git-placeholder` (only there to track the empty dir — now redundant), but the safety hook blocked the removal, so it's still there. It's a 0-byte file and harmless; delete it whenever with `git rm .git-placeholder`.

Since I don't know skogtasks' internal structure yet, `SKOGAI.md` just routes to the README for now — add real routes (task files, config, etc.) as you build it out.

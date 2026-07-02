Done — `skogtasks` is set up the same way as your other repos, so Claude picks up context automatically when you work in there.

**What I did:**

1. `git init` in the target dir (default branch `master`, git identity set to your name/email).
2. Created the SkogAI routing chain:
   - **`CLAUDE.md`** — the file Claude Code auto-loads. `type: router`, permalink `skogtasks/claude`, routes to `@SKOGAI.md`. No project detail lives here on purpose.
   - **`SKOGAI.md`** — the real entry-point router. `type: router`, permalink `skogtasks/skogai`, routes to `@README.md`, and carries the "never waste time…" `<rules>` block.
   - **`README.md`** — documents the routing convention and layout for anyone landing in the repo.
3. Committed the scaffold (pre-commit hook passed).

**Context chain:** working in `skogtasks/` → Claude loads `CLAUDE.md` → `SKOGAI.md` → `README.md`, identical to the marketplace and skogai repos.

**Judgment calls (empty repo):** since there's no source yet, `SKOGAI.md` routes to the README as the one real content file — add a `@path - description` line there for each source dir / sub-project as you move code in. Didn't add a `.gitignore` or license (nothing to ignore yet; out of scope for context pickup).

As you split code in, the only upkeep is extending the `<routes>` block in `SKOGAI.md` — leave `CLAUDE.md` as the thin router.

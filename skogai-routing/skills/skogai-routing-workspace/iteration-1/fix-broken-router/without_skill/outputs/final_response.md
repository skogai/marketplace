You're right — that router wasn't reliably pulling in `SKOGAI.md`.

**What the file said:**
```
Read [`SKOGAI.md`](SKOGAI.md) / @SKOGAI.md
```

**The problem:** Claude Code only pulls a file's contents in through the `@path`
import syntax. Here:

1. `` [`SKOGAI.md`](SKOGAI.md) `` is just a Markdown link — links import nothing,
   and the backticked `SKOGAI.md` is a code span (imports aren't evaluated inside
   code spans). So the most visible part of the line does nothing automatically.
2. The only actual import, `@SKOGAI.md`, was jammed inline after a `/` at the very
   end of the file **with no trailing newline**. Import tokens are supposed to sit
   on their own, whitespace/newline-delimited line — a token flush against EOF is
   exactly the kind of thing that silently fails to fire. Every working router in
   this repo uses a `<routes>` block with `- @SKOGAI.md` on its own line.

**The fix** — I rewrote `core/CLAUDE.md` to the repo's canonical router form:
```
<routes>

- @SKOGAI.md

</routes>
```

Now the import is on its own newline-terminated line, matches the convention used
by the rest of the repo, and the misleading no-op link is gone — so `SKOGAI.md`
actually gets pulled into context.

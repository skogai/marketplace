# Transcript — Scaffold `skogtasks` as its own repo (baseline, no skill)

**Task:** Set up a new, currently-empty repo at
`…/eval1-baseline/skogtasks` "the way we do it everywhere else" so Claude Code
picks up context automatically when working in it.

**Constraint:** No special routing skill loaded — act as a normal Claude Code
agent, inferring the convention from the surrounding repos.

## Step 1 — Learn the convention by observation

I did **not** read the `skogai-routing` skill docs (to keep this a clean baseline).
Instead I inspected files that a normal agent would naturally have in context or
discover:

- `marketplace/CLAUDE.md` and `marketplace/SKOGAI.md`
- `~/skogai/CLAUDE.md`, `~/skogai/SKOGAI.md`
- `~/skogai/projects/skogai-routing/SKOGAI.md`

Observed pattern, consistent across every repo:

1. **`CLAUDE.md` at repo root** — the file Claude Code auto-loads. It has
   frontmatter `permalink: <repo>/claude` + `type: router`, and its body is a
   `<routes>` block whose single route is `@SKOGAI.md`. It carries little/no
   project detail itself.
2. **`SKOGAI.md` at repo root** — the real content router. Frontmatter
   `permalink: <repo>/skogai` + `type: router`, a `<routes>` block of
   `@path - description` lines pointing at content/sub-projects, and (in the
   top-level skogai repo) a `<rules>` block.
3. Permalinks follow `<repo-name>/claude` and `<repo-name>/skogai`.

So for `skogtasks` the permalinks are `skogtasks/claude` and `skogtasks/skogai`.

## Step 2 — Initialize the git repo

```
git init            # in the target dir → default branch "master"
git config user.name  "Emil Skogsund"
git config user.email "emil@skogsund.se"
```

## Step 3 — Create the routing scaffold

Created three files in the target repo:

- **`CLAUDE.md`** — router → `@SKOGAI.md`, with a short note that Claude loads it
  automatically and that durable detail belongs in the routed files.
- **`SKOGAI.md`** — router → `@README.md`, plus the same `<rules>` block the
  top-level skogai repo carries ("never waste time…"), since it reads as a
  house rule rather than repo-specific content.
- **`README.md`** — explains the routing convention and the (minimal) layout, so a
  human landing in the fresh repo understands why the two router files exist.

## Step 4 — Commit and verify

```
git add -A
git commit -m "Scaffold skogtasks repo with SkogAI routing (CLAUDE.md → SKOGAI.md)"
```

A pre-commit hook (inherited from the environment's git template) ran and passed
(no trailing whitespace, checks OK). `git log` shows the single scaffold commit;
`ls -la` confirms `CLAUDE.md`, `SKOGAI.md`, `README.md` at the root.

## Assumptions / judgment calls

- **Repo name → permalink stem:** used `skogtasks` for both permalinks, matching
  how `marketplace` and `skogai` derive theirs from the directory name.
- **`SKOGAI.md` routes to `README.md`:** the repo is empty, so there's no source or
  sub-project to route to yet. I pointed it at the README as the one real content
  file and documented that new routes get added here as the split-out grows. This
  keeps the router non-empty and self-explanatory rather than leaving an empty
  `<routes>` block (as the marketplace root currently has).
- **Included the `<rules>` block** from the top-level skogai repo because it's a
  cross-cutting working preference, not repo-specific content.
- **Added a README** even though not strictly part of the routing chain — every
  repo in the ecosystem that isn't a bare router has one, and it documents intent
  for the next person.
- **Did not add a `.gitignore` or license** — nothing to ignore yet in an empty
  split, and licensing is out of scope for "pick up context automatically."
- Set git `user.name`/`user.email` on the new repo to match the global identity so
  the scaffold commit is attributed correctly.

## Result

Working in the `skogtasks` dir, Claude Code now auto-loads `CLAUDE.md`, which routes
to `SKOGAI.md`, which routes to the README — the same context chain every other repo
in the ecosystem uses.

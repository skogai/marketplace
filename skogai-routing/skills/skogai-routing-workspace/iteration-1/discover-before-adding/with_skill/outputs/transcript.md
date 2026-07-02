# Transcript — Discover existing routing before adding a plugin

**Task:** Before the user adds a new plugin to the marketplace repo, inventory the
routing already wired up so nothing gets duplicated. Read-only inspection of
`/home/skogix/.local/src/marketplace`.

**Skill used:** `skogai-routing` (SKILL.md at
`skogai-routing/skills/skogai-routing/SKILL.md`).

## Step 1 — Read the skill

Read SKILL.md to pick the right workflow. The task is "what routing already
exists here" — a *discovery* question, so the relevant sections are:

- "Finding all router files in a project" → `scripts/list_routers.py`
- "Printing the XML tags in every router file" → `scripts/list_xml_tags.py`
- "Validating a routing file" → `scripts/validate_router.py`

The scaffolding section was intentionally *not* used — the task is read-only and
explicitly says do not create/edit/delete files in the repo.

## Step 2 — Discover router files

Ran the discovery scripts against the repo root (used the actual skill dir as
`CLAUDE_SKILL_DIR` since I'm not inside a live Claude Code skill runtime):

```
./scripts/list_routers.py /home/skogix/.local/src/marketplace
CLAUDE.md
SKOGAI.md

./scripts/list_xml_tags.py /home/skogix/.local/src/marketplace
CLAUDE.md: routes
SKOGAI.md: routes
```

`list_routers.py` walks *every* `*.md` under the root (skipping `.git`/
`node_modules`) and reports only `type: router` files, so this is an exhaustive
inventory: exactly **two** router files exist, both at the repo root. No plugin
subdirectory (claude-code-setup, plugin-dev, skogai-routing, skoghooks, etc.)
contains its own router. Both routers use only the `<routes>` tag — no other
typed XML blocks are in play yet.

## Step 3 — Read the routers

- `SKOGAI.md`: frontmatter `permalink: marketplace/skogai`, `type: router`, and
  an **empty** `<routes>` block. It is the designated hub but currently routes
  to nothing.
- `CLAUDE.md`: frontmatter `permalink: marketplace/claude`, `type: router`, a
  `<routes>` block with a single entry `- @SKOGAI.md`, followed by the prose
  project documentation. This is the auto-loaded entry point that pulls SKOGAI.md
  into context via native `@`-linking.

So the wired-up chain is: `CLAUDE.md` --(@SKOGAI.md)--> `SKOGAI.md` --> (empty).

## Step 4 — Validate

```
./scripts/validate_router.py CLAUDE.md SKOGAI.md
PASS  CLAUDE.md
PASS  SKOGAI.md
```

Both pass the router schema (frontmatter parses, `type: router`, `<routes>`
section present).

## Step 5 — Cross-check the plugin manifest

Read `.claude-plugin/marketplace.json` for context, since the user is about to
add a plugin. Current plugins: claude-code-setup, claude-md-management,
code-simplifier, commit-commands, feature-dev, plugin-dev, skill-creator,
skogai-routing, skoghooks. None of these register any routing files — routing
and the plugin manifest are separate mechanisms here. Adding a plugin means a
`./{plugin-name}/` dir + a manifest entry; it does **not** by itself touch the
routing chain.

## Assumptions / judgment calls

- Ran the bundled scripts directly with a resolved skill dir rather than through
  a live `${CLAUDE_SKILL_DIR}` substitution, since this run is outside an
  interactive skill session. Behavior is identical.
- Treated the provided `skogai-routing-workspace/.../outputs/` path as the
  sanctioned output sink (it is untracked scratch space), and did not write
  anything else into the repo — the "read-only" constraint applies to the repo's
  own tracked content, which I only read.
- Interpreted "routing already wired up" as the skogai routing convention
  (router docs + `<routes>`), which is what the skill governs — not, e.g., HTTP
  routing (none present).

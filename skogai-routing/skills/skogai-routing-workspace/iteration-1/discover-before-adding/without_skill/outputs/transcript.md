# Transcript — Discover existing routing before adding a plugin

Task: read-only inspection of `/home/skogix/.local/src/marketplace` to find what
routing is already wired up, so a new plugin doesn't duplicate it. No skill was
loaded for this run; I used general Claude Code judgment.

Assumption noted up front: "do not modify files in the repo" refers to the repo
content being inspected. The two deliverables were still written to the
designated `.../discover-before-adding/without_skill/outputs/` path, which is
inside the repo but is the explicit save target for this task.

## Steps

1. **Listed the repo root and read the marketplace manifest**
   (`.claude-plugin/marketplace.json`). Found 9 plugins registered:
   claude-code-setup, claude-md-management, code-simplifier, commit-commands,
   feature-dev, plugin-dev, skill-creator, **skogai-routing**, skoghooks.
   The `skogai-routing` entry is the routing-specific one — its description is
   "Author and validate SKOGAI.md routing files: YAML frontmatter plus XML tags
   (starting with `<routes>`), loaded into CLAUDE.md via native @-linking," and
   it registers a skill at `./skills/skogai-routing`.

2. **Read `CLAUDE.md` at the repo root.** It is itself a router document:
   frontmatter `permalink: marketplace/claude`, `type: router`, and a `<routes>`
   block whose single entry is `- @SKOGAI.md`. So the project's own routing
   convention is already in use at the top level.

3. **Searched the whole tree for routing artifacts** — `SKOGAI.md` files, files
   containing a `<routes>` tag, and files with `type: router` frontmatter.
   Routing lives entirely inside the `skogai-routing` plugin plus the two
   root-level router files. `claude-md-management` mentions `<routes>` only in
   passing inside its improver skill.

4. **Explored the `skogai-routing` plugin tree.** It is the canonical home of
   the routing convention and ships:
   - `skills/skogai-routing/SKILL.md` — defines the router document type
     (frontmatter `type: router` + `<routes>` XML block), scaffolding rules, and
     validation workflow.
   - `scripts/` — `validate_router.py`, `list_routers.py`, `list_xml_tags.py`,
     `parse-frontmatter.sh`, `_lib.py` (shared parsing).
   - `schemas/router.schema.json`, `examples/{SKOGAI,CLAUDE}.md.example`,
     `evals/evals.json`.
   - A `skogai-routing-workspace/` eval scaffold (this task's output dir lives
     under it).

5. **Ran the plugin's own discovery/validation scripts** against the repo to
   confirm current state rather than infer it:
   - `list_routers.py .` → reports `CLAUDE.md` and `SKOGAI.md` as the router
     files (plus one fixture under the workspace evals).
   - Confirmed a root `SKOGAI.md` now exists (72 bytes): frontmatter
     `permalink: marketplace/skogai`, `type: router`, with an **empty**
     `<routes>` block.
   - `validate_router.py CLAUDE.md SKOGAI.md` → **PASS** for both.
   - `list_xml_tags.py .` → both root files expose only the `routes` tag.

## Conclusions drawn

- Routing here follows one convention: `type: router` frontmatter + a `<routes>`
  XML block, chained via native `@`-links. `CLAUDE.md` → `@SKOGAI.md` is the
  active chain; `SKOGAI.md`'s `<routes>` block is currently empty.
- The convention, its schema, validators, and scaffolding logic are all owned by
  the existing `skogai-routing` plugin. A new plugin should **reuse** it, not
  reimplement routing.
- Only two things a new plugin might touch: (a) the marketplace manifest
  (`plugins` array) and (b) optionally a route entry — but route entries belong
  in `SKOGAI.md`'s `<routes>` block, and per the skill's own rules that block is
  left minimal unless explicitly requested.

## Read-only compliance

No files under inspection were created, edited, or deleted. Scripts run were the
repo's own read-only discovery/validation tools (`list_routers.py`,
`validate_router.py`, `list_xml_tags.py`), which only read and print. The only
writes are the two deliverables in this `outputs/` directory.

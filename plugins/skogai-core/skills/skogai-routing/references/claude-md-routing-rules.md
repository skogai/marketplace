---
name: claude-md-routing-rules
type: reference
permalink: skogai/claude-md-routing-rules
---

<overview>
rules for authoring claude.md files as routing files in a hierarchical link chain. complements at-linking.md (which covers @-link mechanics) with the philosophy of when and why to use @ vs plain paths.
</overview>

<rule_1_routers_not_content>
**claude.md files are routers, not content.**

a claude.md routes agents to the right files. it should be lightweight (under ~30 lines). if you're writing paragraphs of content in a claude.md, that content belongs in a separate file that the claude.md routes to.

good: brief identity block + list of paths with descriptions
bad: full documentation, long explanations, inline content
</rule_1_routers_not_content>

<rule_2_at_link_vs_plain_path>
**@-link vs plain path — the loading decision.**

- `@path` = **eagerly loaded** into context. the file contents are injected when the claude.md is read.
- `path` (no @) = **listed for discovery**, loaded on demand when explicitly read.

use @-link for:

- lightweight sub-routers (another claude.md that is itself small)
- small index files (e.g., a table of era names)
- content that IS the point of entering that directory

use plain path for:

- content-heavy files (profiles, full documents, large references)
- files that would bloat context if auto-loaded
- claude.md files that are content-loaders (see rule 4)
</rule_2_at_link_vs_plain_path>

<rule_3_link_chain_pattern>
**the link chain — each level routes deeper.**

claude.md files form a hierarchy. each level routes to the next, not to everything:

```
~/.claude/CLAUDE.md          (global entry point)
  -> ~/claude/CLAUDE.md      (workspace router)
  -> personal/CLAUDE.md      (area router)
  -> soul/CLAUDE.md          (content loader)
  -> core/CLAUDE.md          (content loader)
```

no level should try to be comprehensive. route to the next level and let it handle the rest. this is progressive disclosure applied to the filesystem.
</rule_3_link_chain_pattern>

<rule_4_router_vs_content_loader>
**router vs content-loader — the critical distinction.**

two types of claude.md:

**routing claude.md** (e.g., `personal/CLAUDE.md`):
- routes to sub-areas
- should NOT @-link content-heavy loaders
- lists content-loaders as plain paths instead

**content-loader claude.md** (e.g., `soul/CLAUDE.md`):
- leaf node that @-links all its content files
- loading content is its explicit job
- when an agent reads this file, they want ALL the content

**the transitive bloat rule:** if a claude.md @-links another claude.md that itself @-links many files, ALL those files load transitively. a router that @-links a content-loader defeats progressive disclosure.

```
# BAD — personal/CLAUDE.md @-links soul/CLAUDE.md which @-links 10 files
# result: entering personal/ loads ALL soul content automatically

# GOOD — personal/CLAUDE.md lists soul/CLAUDE.md as plain path
# result: agent sees soul/ exists, reads it only when needed
```
</rule_4_router_vs_content_loader>

<rule_5_when_to_at_link>
**when to @-link from a router.**

@-link from a routing claude.md ONLY when the target is:
- another lightweight router/index (small claude.md, just a table or short list)
- a small identity or context block that defines "what is this directory"

do NOT @-link:
- content-loader claude.md files (they pull in everything underneath)
- large content files (profiles, documents, full references)
- files where the description in the router is sufficient for discovery
</rule_5_when_to_at_link>

<rule_6_discoverability_section>
**list non-@-linked files for discoverability.**

files that aren't @-linked should still be listed as plain paths so agents know they exist. use a section like "contents" or "also here":

```markdown
## routes

- @sub-area/CLAUDE.md -- lightweight sub-router

## contents

- profile.md       -- agent profile (read when needed)
- journal/         -- session records, append-only
- INDEX.md         -- curated highlights index
```

the descriptions matter — they help agents decide whether to read the file without loading it.
</rule_6_discoverability_section>

<companion_reference>
for @-link mechanics (how @ works, permissions, subagent rules, caching behavior), see [at-linking.md](./at-linking.md).
</companion_reference>

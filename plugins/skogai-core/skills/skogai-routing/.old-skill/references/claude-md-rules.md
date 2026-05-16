<overview>
Rules for authoring CLAUDE.md files as routing files in a hierarchical link chain. Complements at-linking.md (which covers @-link mechanics) with the *philosophy* of when and why to use @ vs plain paths.
</overview>

<rule_1_routers_not_content>
**CLAUDE.md files are routers, not content.**

A CLAUDE.md routes agents to the right files. It should be lightweight (under ~30 lines). If you're writing paragraphs of content in a CLAUDE.md, that content belongs in a separate file that the CLAUDE.md routes to.

Good: brief identity block + list of paths with descriptions
Bad: full documentation, long explanations, inline content
</rule_1_routers_not_content>

<rule_2_at_link_vs_plain_path>
**@-link vs plain path — the loading decision.**

- `@path` = **eagerly loaded** into context. The file contents are injected when the CLAUDE.md is read.
- `path` (no @) = **listed for discovery**, loaded on demand when explicitly read.

**Use @-link for:**
- Lightweight sub-routers (another CLAUDE.md that is itself small)
- Small index files (e.g., a table of era names)
- Content that IS the point of entering that directory

**Use plain path for:**
- Content-heavy files (profiles, full documents, large references)
- Files that would bloat context if auto-loaded
- CLAUDE.md files that are content-loaders (see rule 4)
</rule_2_at_link_vs_plain_path>

<rule_3_link_chain_pattern>
**The link chain — each level routes deeper.**

CLAUDE.md files form a hierarchy. Each level routes to the next, not to everything:

```
~/.claude/CLAUDE.md          (global entry point)
  -> ~/claude/CLAUDE.md      (workspace router)
    -> personal/CLAUDE.md    (area router)
      -> soul/CLAUDE.md      (content loader)
      -> core/CLAUDE.md      (content loader)
```

No level should try to be comprehensive. Route to the next level and let it handle the rest. This is progressive disclosure applied to the filesystem.
</rule_3_link_chain_pattern>

<rule_4_router_vs_content_loader>
**Router vs content-loader — the critical distinction.**

Two types of CLAUDE.md:

**Routing CLAUDE.md** (e.g., `personal/CLAUDE.md`):
- Routes to sub-areas
- Should NOT @-link content-heavy loaders
- Lists content-loaders as plain paths instead

**Content-loader CLAUDE.md** (e.g., `soul/CLAUDE.md`):
- Leaf node that @-links all its content files
- Loading content is its explicit job
- When an agent reads this file, they want ALL the content

**The transitive bloat rule:** If a CLAUDE.md @-links another CLAUDE.md that itself @-links many files, ALL those files load transitively. A router that @-links a content-loader defeats the purpose of progressive disclosure.

```
# BAD — personal/CLAUDE.md @-links soul/CLAUDE.md which @-links 10 files
# Result: entering personal/ loads ALL soul content automatically

# GOOD — personal/CLAUDE.md lists soul/CLAUDE.md as plain path
# Result: agent sees soul/ exists, reads it only when needed
```
</rule_4_router_vs_content_loader>

<rule_5_when_to_at_link>
**When to @-link from a router.**

@-link from a routing CLAUDE.md ONLY when the target is:
- Another lightweight router/index (small CLAUDE.md, just a table or short list)
- A small identity or context block that defines "what is this directory"

Do NOT @-link:
- Content-loader CLAUDE.md files (they pull in everything underneath)
- Large content files (profiles, documents, full references)
- Files where the description in the router is sufficient for discovery
</rule_5_when_to_at_link>

<rule_6_discoverability_section>
**List non-@-linked files for discoverability.**

Files that aren't @-linked should still be listed as plain paths so agents know they exist. Use a section like "contents" or "also here":

```markdown
## routes

- @sub-area/CLAUDE.md -- lightweight sub-router

## contents

- profile.md       -- agent profile (read when needed)
- journal/         -- session records, append-only
- INDEX.md         -- curated highlights index
```

The descriptions matter — they help agents decide whether to read the file without loading it.
</rule_6_discoverability_section>

<companion_reference>
For @-link mechanics (how @ works, permissions, subagent rules, caching behavior), see [at-linking.md](./at-linking.md).
</companion_reference>

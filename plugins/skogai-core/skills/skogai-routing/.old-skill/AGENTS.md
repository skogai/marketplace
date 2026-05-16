# AGENTS.md — skogai-routing

## OVERVIEW
Canonical skill router for Claude Code. Defines the progressive disclosure pattern and progressive skill structure.

## STRUCTURE
```
skogai-routing/
├── SKILL.md              # Router (short, semantic XML)
├── workflows/           # Procedural guidance
├── references/          # Deep references (loaded on demand)
├── templates/           # Copyable templates
└── scripts/            # Optional automation
```

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Core principles | `references/core-principles.md` |
| Skill structure | `references/skill-structure.md` |
| XML tags | `references/use-xml-tags.md` |
| Common patterns | `references/common-patterns.md` |

## ROUTING RULES
- `SKILL.md`: semantic XML, NO markdown headings
- Descriptions: third person
- References: one level deep only
- Prefer adding new reference over bloating SKILL.md

## ANTI-PATTERNS
- DO NOT use markdown headings in skill body
- DO NOT put full content in SKILL.md (bloat)
- DO NOT reference deep (more than one level)
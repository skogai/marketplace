# AGENTS.md — knowledge/concepts

## OVERVIEW
Dense knowledge base: lessons, patterns, decisions. Mostly markdown documentation with YAML frontmatter.

## STRUCTURE
38 files across concepts/, decisions/, patterns/

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Active memory | `concepts/active-memory.md` (724 lines) |
| Model providers | `concepts/model-providers.md` (664 lines) |
| Multi-agent | `concepts/multi-agent.md` (584 lines) |
| Lessons index | `concepts/` |

## COMPLEXITY HOTSPOTS
- `model-providers.md` — highest maintenance risk: massive provider matrix
- `active-memory.md` — dense config documentation
- `multi-agent.md` — many routing examples

## ANTI-PATTERNS
- No `.md` files > 500 lines should share same file
- Frontmatter lessons loaded at session start via `always_apply`
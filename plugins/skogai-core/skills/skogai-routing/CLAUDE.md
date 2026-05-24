# AGENTS.md - skogai-routing

## Purpose

This repo defines a small routing framework for agent-facing guidance. Treat `SKILL.md` as the canonical entrypoint.

## Structure

```
skogai-routing/
├── SKILL.md
├── workflows/
├── references/
├── templates/
├── scripts/
└── old-skill/
```

## Rules

- Keep `SKILL.md` compact and route outward.
- Treat `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, and simple-skill templates as routing-file variants.
- Put procedures in `workflows/`.
- Put durable concepts in `references/`.
- Put output shapes in `templates/`.
- Put small repeatable checks in `scripts/`.
- Preserve `old-skill/` as source material unless explicitly asked to delete it.

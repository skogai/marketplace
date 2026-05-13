# agents.md - skogai-routing

## purpose

this repo defines a small routing framework for agent-facing guidance. treat `skill.md` as the canonical entrypoint.

## structure

```
skogai-routing/
├── SKILL.md
├── workflows/
├── references/
├── templates/
├── scripts/
```

## rules

- keep `SKILL.md` compact and route outward.
- treat `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, and simple-skill templates as routing-file variants.
- put procedures in `workflows/`.
- put durable concepts in `references/`.
- put output shapes in `templates/`.
- put small repeatable checks in `scripts/`.
- preserve `old-skill/` as source material unless explicitly asked to delete it.

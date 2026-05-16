<codex_hooks_scope>

<overview>
`codex-hooks` is a narrow compatibility plugin for proving that this marketplace can expose a Codex-loadable plugin while hook support evolves.
</overview>

<owned_context>

| area | ownership |
| --- | --- |
| Plugin manifest | Owns Codex plugin metadata for this compatibility target. |
| Smoke skill | Owns the minimal runtime marker used to prove Codex can load the plugin. |
| Compatibility notes | Owns plugin-local facts needed before changing this compatibility target. |

</owned_context>

<out_of_scope>

- General hook implementation patterns belong to the repo-level hook docs or the plugin that owns a real hook.
- Broad Codex configuration guidance belongs in repo-level Codex documentation.
- Reusable skogai routing guidance belongs in `plugins/skogai-core/skills/skogai-routing/`.

</out_of_scope>

<compatibility_facts>

- Codex does not use `CLAUDE.md` as its primary context file, but this nested router exists for Claude Code and follows the shared skogai routing model.
- The plugin manifest declares the Codex plugin contract and currently exposes skills from `./skills/`.
- The smoke skill is intentionally dependency-free so marketplace loading can be validated without hook runtime behavior.

</compatibility_facts>

</codex_hooks_scope>

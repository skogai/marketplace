<workflow>

<objective>
Maintain the `codex-hooks` plugin without expanding it beyond Codex plugin marketplace and hook compatibility validation.
</objective>

<steps>

1. Identify whether the requested change affects runtime skill behavior, plugin metadata, marketplace exposure, or tests.
2. Read `references/codex-hooks-scope.md` before broadening plugin responsibility.
3. Keep smoke behavior in `skills/codex-hooks-smoke/SKILL.md` and manifest metadata in `.codex-plugin/plugin.json`.
4. If marketplace exposure changes, check `.agents/plugins/marketplace.json` for matching catalog data.
5. If validation expectations change, update or run the focused tests under `tests/codex-plugin/`.
6. Keep new procedural guidance in `workflows/` and new stable facts in `references/`.

</steps>

<validation>

- The plugin still exposes the intended Codex-loadable payload.
- Metadata, marketplace entries, and tests agree on the plugin name and skill expectations.
- The router remains short and points to the smallest useful endpoint.

</validation>

</workflow>

<workflow>

<objective>
Audit the routing framework for clarity, ownership, and progressive disclosure.
</objective>

<steps>

1. Read `SKILL.md`.
2. Check that every route points to an existing endpoint.
3. Check that routers are not carrying workflow or reference bloat.
4. Check that workflows own ordered steps.
5. Check that references own durable concepts.
6. Check that templates are copyable.
7. Run helper scripts when present.
8. Report duplicate ownership, missing routes, dead endpoints, and unclear names.

</steps>

<validation>

- Findings cite files.
- Proposed fixes preserve the unified routing-file model.
- The audit favors moving detail outward over enlarging routers.

</validation>

</workflow>

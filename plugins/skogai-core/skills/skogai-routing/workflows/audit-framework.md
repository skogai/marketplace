<workflow>

<objective>
audit the routing framework for clarity, ownership, and progressive disclosure.
</objective>

<steps>

1. read `skill.md`.
2. check that every route points to an existing endpoint.
3. check that routers are not carrying workflow or reference bloat.
4. check that workflows own ordered steps.
5. check that references own durable concepts.
6. check that templates are copyable.
7. run helper scripts when present.
8. report duplicate ownership, missing routes, dead endpoints, and unclear names.

</steps>

<validation>

- findings cite files.
- proposed fixes preserve the unified routing-file model.
- the audit favors moving detail outward over enlarging routers.

</validation>

</workflow>

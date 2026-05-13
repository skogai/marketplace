<workflow>

<objective>
create small helper scripts for repeatable inspection, validation, or mechanical tasks.
</objective>

<steps>

1. choose a narrow script purpose.
2. prefer read-only inspection unless execution is clearly needed.
3. print concise, deterministic output.
4. accept paths as arguments when useful.
5. avoid hidden mutation.
6. document the script in a nearby reference or route only when discoverability matters.

</steps>

<validation>

- the script can be run from the repo root.
- it has a clear success and failure signal.
- the framework remains understandable without running the script.

</validation>

</workflow>

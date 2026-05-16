<workflow>

<objective>
Create small helper scripts for repeatable inspection, validation, or mechanical tasks.
</objective>

<steps>

1. Choose a narrow script purpose.
2. Prefer read-only inspection unless execution is clearly needed.
3. Print concise, deterministic output.
4. Accept paths as arguments when useful.
5. Avoid hidden mutation.
6. Document the script in a nearby reference or route only when discoverability matters.

</steps>

<validation>

- The script can be run from the repo root.
- It has a clear success and failure signal.
- The framework remains understandable without running the script.

</validation>

</workflow>

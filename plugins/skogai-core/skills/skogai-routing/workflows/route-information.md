<workflow>

<objective>
Decide where a piece of guidance, procedure, template, or automation belongs.
</objective>

<steps>

1. Identify the user's immediate intent.
2. Classify the content by the question it answers:
   - "Where next?" -> routing file
   - "What steps?" -> workflow
   - "What should be known?" -> reference
   - "What shape?" -> template
   - "What should run?" -> script
3. Check whether an existing endpoint already owns that question.
4. Update the existing owner when the new content strengthens the same purpose.
5. Create a new endpoint when the content has a distinct purpose.
6. Add or update a route only if another file needs to discover this endpoint.

</steps>

<validation>

- The selected endpoint has one clear job.
- The root router does not gain detailed procedural or reference content.
- The new route is discoverable from the nearest relevant router.

</validation>

</workflow>

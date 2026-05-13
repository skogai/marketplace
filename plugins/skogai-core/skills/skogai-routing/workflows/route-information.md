<workflow>

<objective>
decide where a piece of guidance, procedure, template, or automation belongs.
</objective>

<steps>

1. identify the user's immediate intent.
2. classify the content by the question it answers:
   - "where next?" -> routing file
   - "what steps?" -> workflow
   - "what should be known?" -> reference
   - "what shape?" -> template
   - "what should run?" -> script
3. check whether an existing endpoint already owns that question.
4. update the existing owner when the new content strengthens the same purpose.
5. create a new endpoint when the content has a distinct purpose.
6. add or update a route only if another file needs to discover this endpoint.

</steps>

<validation>

- the selected endpoint has one clear job.
- the root router does not gain detailed procedural or reference content.
- the new route is discoverable from the nearest relevant router.

</validation>

</workflow>

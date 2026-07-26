# Phase 4 — Implement

Only reachable when `plan.md` has `status: approved`. If it does not, you are in Phase 3;
go back and ask for approval.

## Execution discipline

Work `tasks.md` top to bottom. The order is not decorative — it was chosen so each task
lands on a codebase where its dependencies already exist.

Check items off in the file as you finish them (`- [ ]` → `- [x]`). This is the progress
record a future session reads to know where things stopped, so update it as you go rather
than in a batch at the end.

`scenarios.feature` is the definition of done. Before declaring a task complete, ask which
scenario it moves toward, and whether that scenario would now pass. If a task maps to no
scenario at all, that is worth a moment's suspicion — either the scenario list has a gap,
or the task is scope creep.

## Tests

Where the repo has a test suite, write the test before the implementation — the
`superpowers:test-driven-development` skill covers this properly if it is installed.
The acceptance scenarios give you the outer loop; unit tests give you the inner one.

Run the suite before checking off any task that changed behavior. Report failures with the
actual output rather than summarizing them.

## Stage boundaries in Large cycles

Stop at the end of each `## Stage N` and report:

- What the stage delivered
- Which scenarios now pass
- Anything that surprised you

Then wait. The point of stages is that the human reviews in digestible pieces; blowing
through all of them and presenting a 3,000-line diff defeats the structure entirely.

Commit at stage boundaries if the repo is a git repo and the user has asked for commits.

## When the plan turns out to be wrong

This happens, and it is not a failure — it is the plan doing its job by being specific
enough to be falsifiable.

Do not silently improvise around it. Stop, say what you found, and propose the amendment.
Small corrections (a file is named differently, a helper already exists) you can just make
and note. Anything that changes what the user will experience, or that invalidates a
scenario, goes back to the human before you continue — update `plan.md` and
`spec-delta.md` to match reality once they agree.

A plan that quietly diverges from the code is worse than no plan, because the review it
received no longer means anything.

## What you must not do here

- Do not write inside `spec/`. That is Phase 6, and only after Validate passes.
- Do not mark the final promote task as done. Validate has to run first.
- Do not expand scope beyond `tasks.md`. Note the idea in the plan's Open questions and
  keep moving; adding scope is the human's call.

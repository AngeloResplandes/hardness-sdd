---
name: sdd-implement
description: Phase 4 of the SDD harness — executes an approved cycle by working tasks.md top to bottom, checking items off as it goes, with scenarios.feature as the definition of done. Use when a cycle's plan.md has status approved and tasks remain unchecked; when the user says "implementa o ciclo", "pode implementar", "continua a implementação", "segue pro próximo stage"; or when resuming an interrupted cycle. Refuses to run against a draft plan, never writes into spec/, and never checks off the final promote task.
---

# Phase 4 — Implement

## Invariants binding this phase

1. **You do not write inside `spec/`.** Before any Write or Edit, check the path — if it
   starts with `spec/`, stop. That is `sdd-promote`, and only after validation passes.
2. **No implementation before a human approves `plan.md`.** The frontmatter is the record,
   not the conversation.
3. **`scenarios.feature` is the definition of done** — what the user experiences, not how it
   is built.

## Which cycle

1. If the user named one, use that.
2. Otherwise take the newest folder under `cycles/` — newest **by folder name** (the
   `Q{q}{yyyy}/{MMDD}` prefix sorts chronologically), not by mtime, which changes whenever any
   file is touched.
3. Two candidates from the same day and the user did not say which → **ask**.

State which cycle you resolved to before writing any code.

## Precondition

`plan.md` must have `status: approved`. If it says `draft`, you are in the gate, not in
implementation — go back, summarize the plan, and ask the human to approve. Do not accept
approval that exists only in the conversation; the frontmatter is the record.

If the human just said "aprovado" and the file still says draft, record the approval first
(that is `sdd-refine`'s step 6), then come back here.

## What your scope is

Two different things can bring you here, and they have different scopes:

- **Normal run** — every unchecked task in `tasks.md`, top to bottom.
- **After a failed validation** — if `validation.md` exists with `result: fail`, your scope is
  **the gaps it lists**, under `## Correções — validação N` in `tasks.md`. The rest of the
  checklist is already done and marked; do not re-execute it. Read `validation.md` before
  touching anything, and work only what it found missing.

Getting this wrong wastes a full cycle of work redoing what already passed.

## When the state is broken

Stop and hand back to the human. Do not improvise around any of these — improvising around a
gate is the one failure this harness exists to prevent.

| Symptom | Likely cause | What to do |
|---|---|---|
| `plan.md` has no `status:` field | Frontmatter hand-edited or truncated | **PARE.** Show it. Ask whether the plan was approved. Never assume a value in either direction. |
| `status: draft` but tasks already checked | Implementation happened before the gate | **PARE.** List the checked tasks. Ask: approve retroactively, or revert? |
| `tasks.md` missing or empty | Refine did not finish | Return to `sdd-refine`. Do not author tasks yourself — tasks nobody reviewed are not a plan. |
| `scenarios.feature` missing | Refine did not finish | Return to `sdd-refine`. Without it you have no definition of done. |
| A task names a file or module that does not exist | Plan drifted from the codebase | If it is a rename, adjust and note it. If the task no longer makes sense, stop — see *When the plan turns out to be wrong*. |
| The test suite will not run at all (broken deps, missing config) | Environment problem, not a code problem | **PARE.** Report the actual command and error. Do not check off behavior-changing tasks you could not test, and do not mark them as done-with-caveats. |
| Same task fails twice in a row | The approach in the plan does not work | **PARE** after the second attempt. Report both attempts and what you learned. Do not keep trying variations — three silent retries burn context and hide the real problem. |

**Stop condition, in general:** if the fix is not obviously mechanical, stop and report rather
than trying a third approach. The human can unblock in one message; you can burn a whole
session guessing.

## Execution discipline

Work `tasks.md` top to bottom. The order is not decorative — it was chosen so each task lands
on a codebase where its dependencies already exist.

Check items off in the file as you finish them (`- [ ]` → `- [x]`). This is the progress
record a future session reads to know where things stopped, so update it as you go rather
than in a batch at the end. A session that dies mid-cycle should leave behind an accurate
picture, not an optimistic one.

`scenarios.feature` is the definition of done. Before declaring a task complete, ask which
scenario it moves toward, and whether that scenario would now pass. If a task maps to no
scenario at all, that is worth a moment's suspicion — either the scenario list has a gap, or
the task is scope creep.

## Tests

Where the repo has a test suite, write the test before the implementation — the
`superpowers:test-driven-development` skill covers this properly if it is installed. The
acceptance scenarios give you the outer loop; unit tests give you the inner one.

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

This happens, and it is not a failure — it is the plan doing its job by being specific enough
to be falsifiable.

Do not silently improvise around it. Stop, say what you found, and propose the amendment.
Small corrections (a file is named differently, a helper already exists) you can just make and
note. Anything that changes what the user will experience, or that invalidates a scenario,
goes back to the human before you continue — update `plan.md` and `spec-delta.md` to match
reality once they agree.

A plan that quietly diverges from the code is worse than no plan, because the review it
received no longer means anything.

## What you must not do here

- **Do not write inside `spec/`.** That is `sdd-promote`, and only after validation passes.
- **Do not check off the final promote task.** `sdd-validate` has to run first.
- **Do not expand scope beyond `tasks.md`.** Note the idea in the plan's Open questions and
  keep moving; adding scope is the human's call, and `plan.md`'s *Fora de escopo* section is
  what `sdd-validate` will check you against.

## Then

When every task except the promote task is checked, hand off to `sdd-validate`. Do not
declare the cycle done — "the tasks are checked" is a claim, and validation is where claims
get tested.

## Closing report

End every run with this block — including at each stage boundary in a Large cycle.

```markdown
**Fase:** Implement — <ok | atenção | erro>
**Resultado:** <N/M tarefas concluídas. Suíte: <comando> — <resultado>.>
**Artefatos:** <arquivos de código tocados, + tasks.md>
**Próximo passo:** "valida o ciclo"
```

`atenção` when the plan diverged, a task was skipped, or the suite has failures you did not
cause. `erro` when you stopped mid-task.

At a stage boundary the next step is the human's review, not validation — say so:
`**Próximo passo:** revise o Stage <N> e me diga para seguir.`

Never report `ok` with a failing suite. Put the real output in *Resultado*; a summarized
failure is a failure the human cannot act on.

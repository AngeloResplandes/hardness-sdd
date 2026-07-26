---
name: spec-cycle
description: Spec-Driven Development lifecycle — turns a raw feature idea into a reviewed plan, task list, and business-level acceptance scenarios BEFORE any code is written, then implements against them, validates, and promotes the canonical spec. Use this whenever the user starts a new feature, refactor, or non-trivial bugfix; says "vamos construir/implementar X", "nova feature", "novo ciclo", "quero fazer X"; mentions cycles, request.md, plan.md, tasks.md, scenarios.feature, spec-delta, SDD, spec-driven; asks to refine a request, validate a cycle, or update/promote specs; or asks "onde parei" / "qual o próximo passo" in a repo containing cycles/ or spec/. Prefer this over jumping straight to code any time the work would touch more than a couple of files.
---

# Spec-Cycle

A spec-driven workflow for turning vague intent into working software, with a human
review gate placed where corrections are cheapest.

## Why this exists

When someone says "implement a list of episodes" and you start coding immediately, three
things go wrong: you silently guess the requirements they didn't state, nobody can review
the result because there is nothing to review it *against*, and the project's docs quietly
drift out of sync with the code.

This workflow fixes all three by making the requirement a reviewable artifact first. The
cost of fixing a wrong 40-line plan is trivial. The cost of fixing 2,000 lines of wrong
code is not. Every rule below exists to move corrections earlier.

## The two layers

Keep these straight — most of the workflow's value collapses if they blur.

| Layer | Path | Nature |
|---|---|---|
| **Cycle** | `cycles/Q{q}{yyyy}/{MMDD}-<slug>/` | Ephemeral. Describes **one change**. A delta. Never rewritten after the cycle closes — it is the archaeology of *why*. |
| **Canonical spec** | `spec/`, `spec/features/<feature>/` | Permanent. Describes the system's **current state**. Always reflects what is actually shipped. |

Same relationship as migrations vs. schema in a database. Cycles accumulate; the spec stays
singular and true.

## Invariants

These four are the workflow. Everything else is procedure.

1. **`spec/` has exactly one writer: the Promote phase.** The Refine phase writes its
   proposed spec changes to `spec-delta.md` and stops there. If refine wrote directly into
   `spec/`, the canonical spec would assert behavior that does not exist in the codebase
   yet — the docs would describe a system nobody built. Promotion happens only after
   Validate passes, when the claim has become true.

2. **No implementation before a human approves `plan.md`.** The gate is recorded in the
   file itself (`status: approved` in plan.md frontmatter), not in conversation memory, so
   a fresh session in a new terminal can still tell whether approval happened.

3. **Refine asks every question in ONE message.** Fifteen rounds of "and what if the list
   is empty?" burns the scarcest resource in the loop — the human's attention. Pay one
   consolidated cost instead.

4. **`scenarios.feature` describes what the user experiences, never how it is built.**
   Storage keys, CSS architecture, and HTML attributes are implementation; they belong in
   the feature readme, not in acceptance criteria. See `references/gherkin.md`.

## Where am I?

Detect the phase from the filesystem, not from conversation history. Read the newest
cycle folder under `cycles/` (or the one the user names) and match:

| What exists | Phase | Do this |
|---|---|---|
| No cycle folder | **1 — Start** | Create the folder and `request.md`. |
| `request.md` only | **2 — Refine** | Ask the consolidated question set. |
| `plan.md` with `status: draft` | **3 — Gate** | Stop. Ask the human to review and approve. Do not code. |
| `plan.md` with `status: approved`, unchecked tasks | **4 — Implement** | Work `tasks.md` in order. |
| All tasks checked except the promote task | **5 — Validate** | Run the validation checklist. |
| `validation.md` with `result: pass` | **6 — Promote** | Apply `spec-delta.md` into `spec/`. |
| Promote task checked | **Done** | Report and offer to close the branch. |

If the user's request names a phase explicitly ("refina isso", "valida o ciclo",
"atualiza a spec"), honor that instead of inferring.

## Phase 1 — Start

Get today's real date (`Get-Date -Format 'yyyy-MM-dd'` on PowerShell, `date +%F` on bash).
Never guess it — the folder name is the cycle's permanent identity.

Create `cycles/Q{quarter}{year}/{MMDD}-<slug>/request.md` from `assets/request.md`.
Quarter is derived from the month: Jan–Mar = Q1, Apr–Jun = Q2, Jul–Sep = Q3, Oct–Dec = Q4.
The slug is kebab-case and describes the capability, not the ticket number
(`episodes-list-webcomponent`, not `JIRA-4412`).

`request.md` is the **raw problem statement**: Context, Intent, Constraints, References,
Attachments. It contains no plan and no tasks — the human declares the problem, the
workflow proposes the solution. If the user dictates their request conversationally, write
it up for them, then show it and ask them to correct anything you got wrong before moving
on. Their words are the source of truth here.

Offer to create a branch named after the cycle (`git switch -c 0726-episodes-list`) if the
repo is a git repo and the user is on the default branch.

## Phase 2 — Refine

Read `references/refine.md` before running this phase. It contains the question
checklist and the drafting rules for all four output artifacts.

Outputs, all inside the cycle folder:

- `plan.md` — the delta against the current canonical spec, with `status: draft`
- `scenarios.feature` — business-level Gherkin acceptance criteria
- `tasks.md` — an ordered, agent-executable checklist
- `spec-delta.md` — a **proposal** for how `spec/` should change (written, never applied)

`spec-delta.md` is produced whenever the cycle touches any behavior described in `spec/`.
If the repo has no `spec/` directory at all, say so and offer to bootstrap one — a spec
hub that does not exist cannot drift, but it also cannot be reviewed against.

## Phase 3 — Approval gate

Stop here and say so plainly. Summarize what the plan commits to in a few lines, point at
the three files, and ask the human to review. Do not soften this into "let me know if you
want changes, otherwise I'll start" — that turns an explicit gate into an implicit one.

The human approves by saying so; you then set `status: approved` in the plan's frontmatter
and add an `approved_at` date. Recording it in the file is what makes the gate survive a
new session.

## Phase 4 — Implement

Read `references/implement.md`. In short: work `tasks.md` top to bottom, check items off
as you complete them, keep `scenarios.feature` as the definition of done, and stop at
stage boundaries in Large cycles so the human can review in reasonable chunks.

## Phase 5 — Validate

Read `references/validate.md`. Produces `validation.md` in the cycle folder with a
`result: pass | fail` frontmatter field. A fail sends you back to Phase 4 with a specific
list of what is missing — never to Phase 6.

## Phase 6 — Promote

Read `references/update-spec.md`. This is the only phase permitted to write inside
`spec/`. It applies `spec-delta.md`, marks the delta as promoted, and checks off the final
task.

## Cycle size

Classify during Refine; it changes how `tasks.md` is shaped.

| Size | Rough signal | tasks.md shape |
|---|---|---|
| **Small** | One module, no new contract, < ~5 files | Flat ordered checklist |
| **Medium** | One module, new UI or new endpoint, no cross-team contract | Flat ordered checklist |
| **Large** | Multiple modules, a new public/integration contract, a migration, or work you would not want in a single pull request | Numbered `## Stage N` sections, each independently reviewable and mergeable |

When in doubt between two sizes, pick the larger. An over-structured small cycle costs a
few extra headings; an under-structured large cycle costs a 3,000-line review nobody does
properly.

## Language

Write the artifacts in the language the human used in `request.md` — Portuguese by
default here. Gherkin keywords stay in whatever language the project's test runner is
configured for; if unknown, use English keywords (`Given/When/Then`) with Portuguese
content, which every Cucumber-family runner accepts.

## When not to use this

A one-line typo fix, a dependency bump, a question about existing code, or exploratory
spiking does not need a cycle. Say so and just do the work. Ceremony applied to trivia is
how good processes get abandoned.

## Files in this skill

- `references/refine.md` — the consolidated question set and artifact drafting rules
- `references/gherkin.md` — business-level vs. implementation-level scenarios, with examples
- `references/implement.md` — execution discipline during Phase 4
- `references/validate.md` — the validation checklist and `validation.md` format
- `references/update-spec.md` — promotion rules for `spec/`
- `assets/` — templates for every artifact
- `README.md` — the human-facing guide (not for you; point the user at it if they ask how to drive this)

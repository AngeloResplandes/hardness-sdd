---
name: sdd
description: Orchestrator for the Spec-Driven Development harness — detects which phase a cycle is in from the filesystem and routes to the phase skill that handles it. Use this whenever the user starts a new feature, refactor, or non-trivial bugfix; says "vamos construir/implementar X", "nova feature", "novo ciclo", "quero fazer X"; mentions cycles, request.md, plan.md, tasks.md, scenarios.feature, spec-delta, SDD, spec-driven; or asks "onde parei" / "qual o próximo passo" in a repo containing cycles/ or spec/. Prefer this over jumping straight to code any time the work would touch more than a couple of files. If the user names a phase directly ("refina", "implementa o ciclo", "valida", "promove a spec"), the matching sdd-* phase skill handles it without going through here.
---

# SDD — harness

Spec-Driven Development as a set of skills. This one is the **orchestrator**: it knows the
model, decides where you are, and hands off. It does not do phase work itself.

## The phase skills

| Phase | Skill | Produces |
|---|---|---|
| 1 — Start | `sdd-start` | `request.md` |
| 2 — Refine (+ approval gate) | `sdd-refine` | `plan.md`, `scenarios.feature`, `tasks.md`, `spec-delta.md` |
| 4 — Implement | `sdd-implement` | code, checked-off tasks |
| 5 — Validate | `sdd-validate` | `validation.md` |
| 6 — Promote | `sdd-promote` | updated `spec/` |

Phase 3 is the human approval gate. It has no skill because it is not work you do — it is
work you **stop** for. `sdd-refine` owns both sides of it: raising the gate, and recording
the approval when it comes.

## Why this exists

When someone says "implement a list of episodes" and you start coding immediately, three
things go wrong: you silently guess the requirements they didn't state, nobody can review
the result because there is nothing to review it *against*, and the project's docs quietly
drift out of sync with the code.

This harness fixes all three by making the requirement a reviewable artifact first. The
cost of fixing a wrong 40-line plan is trivial. The cost of fixing 2,000 lines of wrong
code is not. Every rule here exists to move corrections earlier.

## The two layers

Keep these straight — most of the workflow's value collapses if they blur.

| Layer | Path | Nature |
|---|---|---|
| **Cycle** | `cycles/Q{q}{yyyy}/{MMDD}-<slug>/` | Ephemeral. Describes **one change**. A delta. Never rewritten after the cycle closes — it is the archaeology of *why*. |
| **Canonical spec** | `spec/`, `spec/features/<feature>/` | Permanent. Describes the system's **current state**. Always reflects what is actually shipped. |

Same relationship as migrations vs. schema in a database. Cycles accumulate; the spec stays
singular and true.

## Invariants

These four are the harness. Everything else is procedure. They bind every phase skill.

1. **`spec/` has exactly one writer: `sdd-promote`.** `sdd-refine` writes its proposed spec
   changes to `spec-delta.md` and stops there. If refine wrote directly into `spec/`, the
   canonical spec would assert behavior that does not exist in the codebase yet — the docs
   would describe a system nobody built. Promotion happens only after validation passes,
   when the claim has become true.

2. **No implementation before a human approves `plan.md`.** The gate is recorded in the
   file itself (`status: approved` in plan.md frontmatter), not in conversation memory, so
   a fresh session in a new terminal can still tell whether approval happened.

3. **Refine asks every question in ONE message.** Fifteen rounds of "and what if the list
   is empty?" burns the scarcest resource in the loop — the human's attention. Pay one
   consolidated cost instead.

4. **`scenarios.feature` describes what the user experiences, never how it is built.**
   Storage keys, CSS architecture, and HTML attributes are implementation; they belong in
   the feature readme, not in acceptance criteria.

## Where am I?

Detect the phase from the filesystem, not from conversation history. Read the newest cycle
folder under `cycles/` (or the one the user names) and match:

| What exists | Phase | Route to |
|---|---|---|
| No cycle folder | **1 — Start** | `sdd-start` |
| `request.md` only | **2 — Refine** | `sdd-refine` |
| `plan.md` with `status: draft` | **3 — Gate** | Stop. Ask the human to review and approve. Do not code. |
| `plan.md` with `status: approved`, unchecked tasks | **4 — Implement** | `sdd-implement` |
| All tasks checked except the promote task | **5 — Validate** | `sdd-validate` |
| `validation.md` with `result: pass` | **6 — Promote** | `sdd-promote` |
| Promote task checked | **Done** | Report and offer to close the branch |

Announce the phase you detected and the evidence for it ("`plan.md` está `status: draft`,
então estamos no portão"), then invoke the phase skill. Getting this wrong silently is how
someone ends up implementing against an unapproved plan.

If the user's request names a phase explicitly ("refina isso", "valida o ciclo", "atualiza
a spec"), honor that instead of inferring — and expect the phase skill to have been loaded
directly, without passing through here.

## Cycle size

Classified during Refine; it changes how `tasks.md` is shaped and how `sdd-implement`
paces itself.

| Size | Rough signal | tasks.md shape |
|---|---|---|
| **Small** | One module, no new contract, < ~5 files | Flat ordered checklist |
| **Medium** | One module, new UI or new endpoint, no cross-team contract | Flat ordered checklist |
| **Large** | Multiple modules, a new public/integration contract, a migration, or work you would not want in a single pull request | Numbered `## Stage N` sections, each independently reviewable and mergeable |

When in doubt between two sizes, pick the larger. An over-structured small cycle costs a
few extra headings; an under-structured large cycle costs a 3,000-line review nobody does
properly.

## Language

Write the artifacts in the language the human used in `request.md` — Portuguese by default
here. Gherkin keywords stay in whatever language the project's test runner is configured
for; if unknown, use English keywords (`Given/When/Then`) with Portuguese content, which
every Cucumber-family runner accepts.

## When not to use this

A one-line typo fix, a dependency bump, a question about existing code, or exploratory
spiking does not need a cycle. Say so and just do the work. Ceremony applied to trivia is
how good processes get abandoned.

## Files

- `references/naming.md` — cycle folder naming, quarter derivation, slug rules
- `README.md` — the human-facing guide (not for you; point the user at it if they ask how
  to drive this)

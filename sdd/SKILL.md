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

Each phase skill repeats the invariants that bind it, because each is invocable on its own
without passing through here. If you change one, change it in the phase skills too.

### The guard that has to fire at the moment of action

Invariant 1 is a principle, and principles lose to momentum. This is the operational form,
and it belongs in every skill that is not `sdd-promote`:

> **Before any Write or Edit, check the path. If it starts with `spec/`, stop — you are in
> the wrong phase.** Write the proposal into `spec-delta.md` instead.

Stated as a check on the action rather than a rule about the workflow, because that is when
it is needed: not while reasoning about phases, but in the moment of reaching for the tool.

## Where am I?

Detect the phase from the filesystem, not from conversation history. Resolve which cycle
you are looking at first (`references/naming.md`, *Resolving "the current cycle"*), then walk
the rules below.

**Evaluate in order. The first rule that matches wins.** The order is load-bearing: the
error states sit above the phase they would otherwise be mistaken for, so a broken cycle
stops instead of being routed into work.

| # | Condition | Phase | Action |
|---|---|---|---|
| 1 | `cycles/` missing, or exists with no cycle folder | **1 — Start** | `sdd-start` |
| 2 | Cycle folder exists but has no `request.md` | **1 — Start** | Orphan folder. Confirm with the human before reusing or replacing it. |
| 3 | `request.md`, no `plan.md` | **2 — Refine** | `sdd-refine` |
| 4 | `plan.md` has no `status:` in frontmatter | **ERRO** | Stop. See *When the state is broken*. |
| 5 | `plan.md` is `draft` **and** any task is checked | **ERRO** | Stop. Implementation happened without a gate. See below. |
| 6 | `plan.md` is `draft` | **3 — Gate** | Stop. Ask the human to review and approve. Do not code. |
| 7 | `validation.md` says `result: fail` | **4 — Implement** | `sdd-implement`, scoped to the gaps listed in `validation.md` — not the whole checklist. |
| 8 | `plan.md` is `approved`, tasks other than promote unchecked | **4 — Implement** | `sdd-implement` |
| 9 | All tasks except promote checked; no `validation.md`, or it predates the last code change | **5 — Validate** | `sdd-validate` |
| 10 | `validation.md` is `pass` and `spec-delta.md` is `proposed` | **6 — Promote** | `sdd-promote` |
| 11 | `validation.md` is `pass` and there is no `spec-delta.md` | **6 — Promote** | Only valid if the cycle genuinely changed nothing described in `spec/`. Confirm that with the human, then close the cycle without promoting. If it did change something, refine skipped an artifact — go back. |
| 12 | `spec-delta.md` is `promoted`, or the promote task is checked | **Done** | Report and offer to close the branch. |

If nothing matches, say so rather than picking the closest rule. An unmatched state is a state
this table does not model, and the human should hear that plainly.

Announce the phase you detected and the evidence for it ("`plan.md` está `status: draft`,
então estamos no portão"), then invoke the phase skill. Getting this wrong silently is how
someone ends up implementing against an unapproved plan.

If the user's request names a phase explicitly ("refina isso", "valida o ciclo", "atualiza
a spec"), honor that instead of inferring — and expect the phase skill to have been loaded
directly, without passing through here.

## When the state is broken

Some states are not a phase — they are damage, usually from a hand-edited file or a session
that died mid-write. Routing them into a phase makes it worse. Stop and hand back to the
human instead.

| Symptom | Likely cause | What to do |
|---|---|---|
| `plan.md` has no `status:` field | Frontmatter hand-edited or truncated | **PARE.** Show the frontmatter as it stands. Ask the human whether this plan was approved. Never assume either value — assuming `draft` discards real work, assuming `approved` walks through the gate. |
| `plan.md` is `draft` but tasks are checked | Someone implemented before the gate | **PARE.** List which tasks are checked. Ask whether to approve retroactively (records `approved_at` today, noting it was after the fact) or to revert the work. |
| `plan.md` is `approved` but `approved_at: null` | Approval recorded partially | Ask the human for the approval date, or set today's date and say you did. Minor — do not block on it. |
| `tasks.md` or `scenarios.feature` missing while `plan.md` exists | Refine did not finish | Return to `sdd-refine` to complete the missing artifacts. Do not invent them — they were never reviewed. |
| `validation.md` is `pass` but tasks are unchecked | Validation ran against the wrong state, or files changed after | Re-run `sdd-validate`. A stale pass is the one failure mode that puts a lie into `spec/`. |
| Two cycle folders from the same day, user did not say which | Ambiguous | Ask. Guessing writes a plan into someone else's cycle. |

The rule underneath all of these: **when the filesystem contradicts itself, the human
resolves it, not you.** Every one of these states is cheap to fix by asking and expensive to
fix after you have acted on a guess.

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

- `references/naming.md` — cycle folder naming, quarter derivation, slug rules, resolving
  "the current cycle"
- `references/reporting.md` — the closing report format every phase ends with
- `README.md` — the human-facing guide (not for you; point the user at it if they ask how
  to drive this)

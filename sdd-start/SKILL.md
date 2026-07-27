---
name: sdd-start
description: Phase 1 of the SDD harness — opens a new cycle folder and captures the human's raw problem statement in request.md. Use when the user is starting a new feature, refactor, or non-trivial bugfix and no cycle folder exists yet; says "novo ciclo", "abre um ciclo", "vamos construir X", "nova feature", "quero fazer X"; or dictates a request conversationally that needs to be written up. Do not use to write plans or tasks — request.md holds the problem only, and sdd-refine proposes the solution.
---

# Phase 1 — Start

Opens the cycle and captures the problem. Nothing else. The single most common way to ruin
this phase is to helpfully write the solution into it.

## What request.md is

The **raw problem statement**, owned by the human. It declares the problem; the harness
proposes the solution in `sdd-refine`. If the plan is already sitting in `request.md`, the
refine phase has nothing left to discover — which kills the exact step where you find out
what the human hadn't thought about.

Sections: Context, Intent, Taste / Constraints, References, Attachments. No plan, no tasks,
no file lists, no acceptance criteria.

## Steps

**1. Get the real date and build the folder name.**

Read `../sdd/references/naming.md` for the rules. In short: `cycles/Q{q}{yyyy}/{MMDD}-<slug>/`,
date from `Get-Date -Format 'yyyy-MM-dd'` (PowerShell) or `date +%F` (bash) — never guessed.

**2. Check whether a cycle is already open.**

If the newest cycle folder has no `validation.md` with `result: pass` and no checked promote
task, it is unfinished. Say so and ask whether this is a new cycle or a continuation of that
one. Opening a second cycle on top of an abandoned one is how a `cycles/` directory becomes
unreadable.

**3. Write `request.md` from `assets/request.md`.**

If the user dictated their request conversationally, write it up for them — that is a
service, not an overstep. Their words are the source of truth: preserve their vocabulary and
their emphasis rather than translating it into your own phrasing. Where they were vague, stay
vague; do not resolve ambiguity here, that is refine's job and it needs the ambiguity intact
to know what to ask about.

Leave a section empty rather than inventing content for it. An empty **Attachments** is
honest; a fabricated one is a lie the plan will inherit.

**4. Show it and ask for corrections.**

```
Escrevi o request a partir do que você falou. Leia e corrija o que eu entendi errado —
é o único documento que é seu, e tudo depois deriva dele.
```

Then stop. Do not slide into refine in the same breath; the human has to actually read this
one.

**5. Offer a branch.**

If the repo is a git repo and the user is on the default branch, offer a branch named after
the cycle: `git switch -c 0726-episodes-list`. Offer — do not create it unasked.

## Then

Once the human confirms `request.md` is right, the next phase is `sdd-refine`. Say so and let
them trigger it, or ask if they want to go straight into refining.

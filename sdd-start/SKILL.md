---
name: sdd-start
description: Phase 1 of the SDD harness — opens a new cycle folder and captures the human's raw problem statement in request.md. Use when the user is starting a new feature, refactor, or non-trivial bugfix and no cycle folder exists yet; says "novo ciclo", "abre um ciclo", "vamos construir X", "nova feature", "quero fazer X"; or dictates a request conversationally that needs to be written up. Do not use to write plans or tasks — request.md holds the problem only, and sdd-refine proposes the solution.
---

# Phase 1 — Start

Opens the cycle and captures the problem. Nothing else. The single most common way to ruin
this phase is to helpfully write the solution into it.

## Invariants binding this phase

1. **You do not write inside `spec/`.** Before any Write or Edit, check the path — if it
   starts with `spec/`, stop. Only `sdd-promote` writes there.
2. **`request.md` holds the problem, never the solution.** No plan, no tasks, no file lists,
   no acceptance criteria — those are `sdd-refine`'s output, and it needs the problem stated
   without them.
3. **The date is read from the system, never inferred.**

## What request.md is

The **raw problem statement**, owned by the human. It declares the problem; the harness
proposes the solution in `sdd-refine`. If the plan is already sitting in `request.md`, the
refine phase has nothing left to discover — which kills the exact step where you find out
what the human hadn't thought about.

Sections: Context, Intent, Taste / Constraints, References, Attachments. No plan, no tasks,
no file lists, no acceptance criteria.

## Steps

**1. Get the real date and build the folder name.**

```
cycles/Q{quarter}{year}/{MMDD}-<slug>/
```

Example: `cycles/Q32026/0726-episodes-list-webcomponent/`

Get today's **real** date first — `Get-Date -Format 'yyyy-MM-dd'` (PowerShell) or `date +%F`
(bash). Never guess it and never infer it from conversation context; a cycle dated wrong is
mis-filed permanently.

Quarter comes from the month, not a fiscal calendar: Jan–Mar `Q1`, Apr–Jun `Q2`, Jul–Sep `Q3`,
Oct–Dec `Q4`.

The slug is kebab-case and names the **capability**, not the ticket:

- `episodes-list-webcomponent` — good
- `JIRA-4412` — bad; meaningless in six months and to anyone outside the tracker
- `fix-bug` — bad; every cycle is a fix of something

If a ticket number matters, put it in `request.md` under References. The folder name is for
humans reading the repo two years from now.

The `sdd` skill's `references/naming.md` holds the canonical version of these rules.

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

## When the state is broken

| Symptom | Likely cause | What to do |
|---|---|---|
| Newest cycle is unfinished (no `validation.md: pass`, promote task unchecked) | Previous cycle abandoned or still running | Ask: continuation of that one, or genuinely new? Opening a second cycle on top of an abandoned one is how `cycles/` becomes unreadable. |
| A folder with today's date and the same slug already exists | Start ran before | Do not overwrite. Show what is in it and ask whether to continue there or pick a different slug. |
| The date command fails or returns something unexpected | Shell issue | **PARE.** Ask the human for today's date. Never fall back to a date inferred from conversation context — a mis-dated cycle is mis-filed permanently. |
| The repo has no `cycles/` directory | First cycle ever | Not an error. Create it. |
| The request is a typo fix, dependency bump, or a question | Ceremony applied to trivia | Say so and just do the work. See below. |

## When a cycle is the wrong tool

A one-line typo fix, a dependency bump, a question about existing code, or exploratory spiking
does not need a cycle. Say so and do the work directly.

This skill is invocable on its own, without passing through the `sdd` orchestrator, so this
judgment has to be made here — nobody upstream will make it for you.

## Then

Once the human confirms `request.md` is right, the next phase is `sdd-refine`. Say so and let
them trigger it, or ask if they want to go straight into refining.

## Closing report

End with this block. `atenção` when the request has gaps you could not fill from what the
human said; `erro` when you stopped without writing it.

```markdown
**Fase:** Start — <ok | atenção | erro>
**Resultado:** <uma linha>
**Artefatos:** <path do request.md>
**Próximo passo:** leia e corrija o request — é o único documento que é seu. Depois: "refina o ciclo".
```

The next step is always the human reading `request.md`. Never point at refine as if it were
ready to run; this phase ends in a review, not a handoff.

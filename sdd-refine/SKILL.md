---
name: sdd-refine
description: Phase 2 of the SDD harness (plus the phase 3 human approval gate) — turns request.md into a reviewable plan.md, business-level scenarios.feature, executable tasks.md, and a proposed spec-delta.md, then stops and asks a human to approve before any code is written. Use when a cycle folder has request.md but no plan.md; when the user says "refina", "refina o ciclo", "refina isso", "monta o plano"; or when the user approves a draft plan ("aprovado", "pode implementar") and status: approved must be recorded. Never writes into spec/ and never starts implementing.
---

# Phase 2 — Refine, and the gate that follows it

This is the phase that earns the whole harness its keep: it is where ambiguity gets killed
while it is still cheap. It ends by **stopping** — refine that flows straight into
implementation has removed the only review point that matters.

## Invariants binding this phase

1. **You do not write inside `spec/`.** Before any Write or Edit, check the path — if it
   starts with `spec/`, stop. The proposal goes in `spec-delta.md`; `sdd-promote` applies it
   after validation passes. Writing it now would make the canonical spec assert behavior that
   does not exist yet.
2. **No implementation before a human approves `plan.md`.** You raise the gate and record the
   approval in the file. You never walk through it.
3. **Ask every question in ONE message.**
4. **`scenarios.feature` describes what the user experiences, never how it is built.**

## Step 0 — Resolve which cycle you are in

1. If the user named a cycle, use that.
2. Otherwise take the newest folder under `cycles/` — newest **by folder name** (the
   `Q{q}{yyyy}/{MMDD}` prefix sorts chronologically), not by filesystem mtime, which changes
   whenever any file is touched.
3. If two candidates share the same day and the user did not say which, **ask**. Guessing here
   means writing a plan into someone else's cycle.

State which cycle you resolved to before doing anything else.

## Step 1 — Read before asking

Read, in this order:

1. The cycle's `request.md`.
2. Every canonical doc it references under `spec/` — and their neighbors. If the request
   points at `spec/features/episodes-list/`, also read `spec/architecture.md` and any
   sibling feature that already solves a similar problem.
3. The actual code for the module being touched, enough to know what already exists.

The point is to arrive at Step 2 with questions the human could not have answered by reading
the repo themselves. A question whose answer is sitting in `spec/architecture.md` wastes
their time and erodes their trust in the process.

## Step 2 — Ask everything in one message

Read `references/questions.md` now. It holds the question areas, how to phrase them so they
are cheap to answer, and what to do when the human answers only part of the list.

Then send **one** message — grouped under headings, numbered — and stop and wait.

This is invariant 3, and it is the one that protects the human's attention. Fifteen rounds of
"e se a lista estiver vazia?" costs more than the ambiguity it resolves.

## Step 3 — Classify the cycle size

Size decides the shape of `tasks.md`. Small and Medium get a flat checklist; Large gets
numbered `## Stage N` sections, each independently reviewable and mergeable.

**Large** means: multiple modules, a new public or integration contract, a migration, or work
you would not want to land in a single pull request. When torn between two sizes, pick the
larger — an over-structured small cycle costs a few extra headings; an under-structured large
one costs a 3,000-line review nobody does properly.

Record it in the plan's frontmatter.

## Step 4 — Draft the four artifacts

Templates live in `assets/`. Write all four; they are read together during review.

### plan.md

A **delta**, not a from-scratch description. The reader already knows the system; tell them
what changes. Frontmatter carries the approval gate:

```yaml
---
cycle: 0726-episodes-list-webcomponent
size: Medium
status: draft
approved_at: null
---
```

Sections: Resumo, Estado atual, Mudanças propostas, Fora de escopo, Riscos e mitigações,
Open questions.

"Estado atual" is not filler — writing it forces you to actually verify what `spec/` claims,
and it is where you discover the spec is already wrong.

"Fora de escopo" is what holds the line during implementation and what `sdd-validate` checks
against. Vague scope boundaries produce scope creep that nobody can call out afterward.

### scenarios.feature

Read `references/gherkin.md` before writing this. The single most common failure is scenarios
that describe implementation. Business-level only.

### tasks.md

An ordered checklist a competent agent could execute without re-asking the human. Each item
names files or modules concretely. The order is load-bearing: each task should land on a
codebase where its dependencies already exist.

Pick the template by size — this is the decision from step 3:

- **Small / Medium** → `assets/tasks.md` (flat list, no stages)
- **Large** → `assets/tasks-staged.md` (`## Stage N` sections)

Do not use stages in a Small or Medium cycle. Stages exist so implementation stops for review
partway through; a Small cycle that stops twice is friction with nothing on the other side.

The final task is always, verbatim, and always last:

```markdown
- [ ] Promover `spec-delta.md` para `spec/` (fase Promote — só após Validate passar)
```

It is mandatory because it is the task everyone forgets, and forgetting it is exactly how the
canonical spec rots.

**Nothing goes after it.** Three skills identify it positionally — `sdd-implement` must not
check it, `sdd-validate` requires every *other* task checked, `sdd-promote` checks it to close
the cycle. Adding trailing items ("rodar a suíte", "executar Validate") makes "the final task"
ambiguous and breaks all three at once. Running the suite and validating are phases with their
own skills; they are not checklist items.

### spec-delta.md

The proposed change to canonical docs, written as a proposal and **not applied**. For each
affected file: its path, what it says now, what it should say after, and why.

If a file under `spec/` needs to be created rather than edited, say so and include the full
intended content — `sdd-promote` should be a mechanical application, not a second round of
authoring.

Frontmatter tracks promotion state:

```yaml
---
status: proposed
promoted_at: null
---
```

Produce this whenever the cycle touches any behavior described in `spec/`. If the repo has no
`spec/` directory at all, say so and offer to bootstrap one — a spec hub that does not exist
cannot drift, but it also cannot be reviewed against.

**Do not write inside `spec/` in this phase.** That is `sdd-promote`'s exclusive job, and only
after validation passes.

## Step 5 — Raise the gate (phase 3)

Stop here and say so plainly. Summarize what the plan commits to in a few lines, point at the
four files, and ask the human to review.

Do not soften this into "let me know if you want changes, otherwise I'll start" — that turns
an explicit gate into an implicit one, and implicit gates are the ones people walk through
without looking.

Worth telling them where to look hardest:

- **`plan.md`** — the *Fora de escopo* section is what holds back scope creep, and *Estado
  atual* is where they usually discover the spec was already wrong.
- **`scenarios.feature`** — disagreeing with a scenario here costs one line; discovering it
  after implementation costs a rewrite.
- **`tasks.md`** — the order matters, and anything that looks too big for one task is.

### Make the approval require having read

A gate only works if passing through it costs attention. "Aprovado" typed reflexively is the
most common way this whole process degrades into paperwork — all of the cost, none of the
benefit.

So do not end with a bare "pode aprovar?". End by putting the **two or three most consequential
decisions** in the plan back as a direct confirmation question:

```
Confirmo antes de implementar:
1. Sem paginação no MVP — a lista carrega todos os episódios de uma vez.
2. O download de documentos aparece só para admin.
3. Falha da API mostra estado de erro com botão "tentar de novo", não um toast.
```

Pick the ones that would be expensive to reverse after implementation: scope boundaries,
permission rules, anything you assumed because the human did not answer. Someone can type
"aprovado" without reading a plan. They cannot confirm three specific claims without reading
at least those three.

If any of them came from an assumption rather than an answer, say which — those are the ones
most likely to be wrong.

## Step 6 — Record the approval

When the human approves, edit `plan.md` frontmatter:

```yaml
status: approved
approved_at: 2026-07-26
```

Recording it **in the file** is what makes the gate survive a new session on another machine
three weeks later. An approval that lives only in the conversation evaporates with the
conversation.

If they ask for changes instead, apply them and re-raise the gate. Do not treat "muda o
cenário 3" as approval of everything else.

Then hand off to `sdd-implement`.

## When the state is broken

| Symptom | Likely cause | What to do |
|---|---|---|
| No `request.md` in the cycle folder | Start never ran | Return to `sdd-start`. Do not write the request yourself and refine it in the same breath — you would be reviewing your own understanding instead of the human's. |
| `request.md` already contains a plan, tasks, or acceptance criteria | Solution written into the problem | Say so. Refine against the *problem* in it and ask the human to confirm the parts you are treating as pre-decided. A request that already answers everything makes this phase theater. |
| `plan.md` already exists with `status: approved` | Cycle already passed the gate | **PARE.** Re-refining approved work silently invalidates the approval. Ask whether they want to amend the plan (which re-opens the gate: set `status: draft`) or move on to `sdd-implement`. |
| `plan.md` exists as `draft` | Refine ran before | Not an error. Update the existing artifacts rather than overwriting from scratch — the human may have edited them. |
| No `spec/` directory anywhere in the repo | Project never had one | Not an error. Say so and offer to bootstrap it. Write `spec-delta.md` anyway, as the seed of the spec that does not exist yet. |
| The request is a typo fix, dependency bump, or a question | Ceremony applied to trivia | Say so plainly and just do the work. See *When a cycle is the wrong tool*. |

## When a cycle is the wrong tool

A one-line typo fix, a dependency bump, a question about existing code, or exploratory spiking
does not need a cycle. If the request is one of those, say so and do the work directly instead
of opening artifacts around it.

This matters here specifically because this skill gets invoked directly ("refina isso") without
passing through the `sdd` orchestrator — so this is the only place the judgment gets made.
Ceremony applied to trivia is how good processes get abandoned.

## Closing report

This skill has two distinct endings — the gate, and the approval — and they close differently.

**After drafting the artifacts (step 5), the phase ends at the gate.** That is not `ok`; the
phase is waiting:

```markdown
**Fase:** Refine — atenção
**Resultado:** 4 artefatos escritos. Ciclo classificado como <tamanho>. <N> open questions.
**Artefatos:** plan.md, scenarios.feature, tasks.md, spec-delta.md
**Próximo passo:** revise os 4 arquivos e confirme os pontos acima. Nada é implementado até `status: approved`.
```

Use `atenção` whenever there are open questions — those are assumptions carried into
implementation, and they deserve to be visible at the moment of approval, not buried in the
plan.

**After recording the approval (step 6):**

```markdown
**Fase:** Refine — ok
**Resultado:** Aprovado e registrado em plan.md (status: approved, approved_at: <data>).
**Artefatos:** plan.md
**Próximo passo:** "implementa o ciclo"
```

## Files

- `references/questions.md` — the question checklist for step 2
- `references/gherkin.md` — business-level vs. implementation-level scenarios, with examples
- `assets/` — templates for the four artifacts

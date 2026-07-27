---
name: sdd-refine
description: Phase 2 of the SDD harness (plus the phase 3 human approval gate) — turns request.md into a reviewable plan.md, business-level scenarios.feature, executable tasks.md, and a proposed spec-delta.md, then stops and asks a human to approve before any code is written. Use when a cycle folder has request.md but no plan.md; when the user says "refina", "refina o ciclo", "refina isso", "monta o plano"; or when the user approves a draft plan ("aprovado", "pode implementar") and status: approved must be recorded. Never writes into spec/ and never starts implementing.
---

# Phase 2 — Refine, and the gate that follows it

This is the phase that earns the whole harness its keep: it is where ambiguity gets killed
while it is still cheap. It ends by **stopping** — refine that flows straight into
implementation has removed the only review point that matters.

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

Group the questions under headings, number them so answers can be terse, and send them as a
single message. Then stop and wait.

Cover these areas. Drop any that genuinely do not apply — an empty section is noise, and
padding the list with irrelevant questions trains the human to skim.

**Produto e escopo**
- What is explicitly out of scope for this cycle?
- Who are the user roles involved, and does behavior differ between them?
- What is the smallest version that would still be worth shipping?

**Dados e integração**
- Where does the data come from — which service, endpoint, or table?
- What is the shape of the payload, and who owns that contract?
- Pagination, sorting, expected volume?
- What happens when the source is slow, empty, or down?

**UX e comportamento**
- Empty state, loading state, error state — what does the user see in each?
- What is the behavior on mobile / small viewport?
- Which actions are reversible, and is there a confirmation?
- Accessibility expectations (keyboard navigation, screen reader, contrast)?

**Segurança e conformidade**
- Who is allowed to see or do this, and where is that enforced — client, server, or both?
- Does this touch personal or regulated data (PII, health, financial)?
- What must be audited or logged?

**Testes e rollout**
- What is the definition of done for QA — automated, manual, or both?
- Feature flag, gradual rollout, or straight to production?
- What is the rollback story if it goes wrong?

**Contrato de integração**
- Public API surface: props, attributes, events, callbacks, return shapes.
- Is this contract versioned? Who else consumes it?
- What breaks downstream if it changes later?

Ask for a decision, not a lecture. "Paginação: infinite scroll, botão 'carregar mais', ou sem
paginação?" gets answered in one word. "Como devemos lidar com paginação?" gets answered with
a paragraph or with silence.

Where you have a genuine recommendation, state it inline and mark it — the human can then
just say "todos os defaults, exceto 3 e 7", which is a much cheaper reply than composing
answers from scratch.

If the human answers only part of the list, do not silently fill the rest. Draft what you
can, and record every unanswered item in `plan.md` under **Open questions**, with the
assumption you are proceeding on. Assumptions written down are reviewable; assumptions held
in your head are not.

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

The final task is always, verbatim:

```markdown
- [ ] Promover `spec-delta.md` para `spec/` (fase Promote — só após Validate passar)
```

It is mandatory because it is the task everyone forgets, and forgetting it is exactly how the
canonical spec rots.

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

## Files

- `references/gherkin.md` — business-level vs. implementation-level scenarios, with examples
- `assets/` — templates for the four artifacts

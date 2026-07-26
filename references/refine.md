# Phase 2 — Refine

Turns `request.md` into a reviewable plan. This is the phase that earns the whole workflow
its keep: it is where ambiguity gets killed while it is still cheap.

## Step 1 — Read before asking

Read, in this order:

1. The cycle's `request.md`.
2. Every canonical doc it references under `spec/` — and their neighbors. If the request
   points at `spec/features/episodes-list/`, also read `spec/architecture.md` and any
   sibling feature that already solves a similar problem.
3. The actual code for the module being touched, enough to know what already exists.

The point is to arrive at Step 2 with questions the human could not have answered by
reading the repo themselves. A question whose answer is sitting in `spec/architecture.md`
wastes their time and erodes their trust in the process.

## Step 2 — Ask everything in one message

Group the questions under headings, number them so answers can be terse, and send them as
a single message. Then stop and wait.

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

Ask for a decision, not a lecture. "Paginação: infinite scroll, botão 'carregar mais', ou
sem paginação?" gets answered in one word. "Como devemos lidar com paginação?" gets
answered with a paragraph or with silence.

Where you have a genuine recommendation, state it inline and mark it — the human can then
just say "todos os defaults, exceto 3 e 7", which is a much cheaper reply than composing
answers from scratch.

If the human answers only part of the list, do not silently fill the rest. Draft what you
can, and record every unanswered item in `plan.md` under **Open questions**, with the
assumption you are proceeding on. Assumptions written down are reviewable; assumptions
held in your head are not.

## Step 3 — Draft the four artifacts

Templates live in `../assets/`. Write all four; they are read together during review.

### plan.md

A **delta**, not a from-scratch description. The reader already knows the system; tell
them what changes. Frontmatter carries the approval gate:

```yaml
---
cycle: 0726-episodes-list-webcomponent
size: Medium
status: draft
---
```

Sections: Resumo, Estado atual (what `spec/` says today), Mudanças propostas, Fora de
escopo, Riscos e mitigações, Open questions.

"Estado atual" is not filler — writing it forces you to actually verify what the spec
claims, and it is where you discover the spec is already wrong.

### scenarios.feature

Read `gherkin.md` before writing this. The single most common failure is scenarios that
describe implementation. Business-level only.

### tasks.md

An ordered checklist a competent agent could execute without re-asking the human. Each
item names files or modules concretely. Small/Medium get a flat list; Large gets numbered
`## Stage N` sections.

The final task is always, verbatim:

```markdown
- [ ] Promover `spec-delta.md` para `spec/` (fase Promote — só após Validate passar)
```

It is mandatory because it is the task everyone forgets, and forgetting it is exactly how
the canonical spec rots.

### spec-delta.md

The proposed change to canonical docs, written as a proposal and **not applied**. For each
affected file: its path, what it says now, what it should say after, and why.

If a file under `spec/` needs to be created rather than edited, say so and include the
full intended content — Promote should be a mechanical application, not a second round of
authoring.

Frontmatter tracks promotion state:

```yaml
---
status: proposed
promoted_at: null
---
```

## Step 4 — Hand off to the gate

Do not start implementing, and do not touch `spec/`. Summarize the plan in a few lines,
list the four files, and hand control back to the human for Phase 3.

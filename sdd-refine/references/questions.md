# The refine question set

Read this at step 2, after reading the request, the spec, and the code — not before. Half of
these are usually answered by the repo already, and asking those is what teaches the human to
skim the list.

## How to ask

**One message. Grouped under headings. Numbered**, so answers can be terse ("1: sim, 2: só
admin, 3: default").

**Ask for a decision, not a lecture.** "Paginação: infinite scroll, botão 'carregar mais', ou
sem paginação?" gets answered in one word. "Como devemos lidar com paginação?" gets answered
with a paragraph, or with silence.

**Mark your recommendations inline.** When you have a genuine default, say it. The human can
then reply "todos os defaults, exceto 3 e 7" — a far cheaper answer than composing one from
scratch, and cheap answers are what keep this phase from being skipped.

**Drop what does not apply.** An empty section is noise. A list padded with irrelevant
questions trains the human to skim, and skimming is how the one question that mattered gets
missed.

**Never ask what the repo answers.** A question whose answer sits in `spec/architecture.md`
wastes their time and erodes trust in the process.

## The areas

### Produto e escopo
- What is explicitly out of scope for this cycle?
- Who are the user roles involved, and does behavior differ between them?
- What is the smallest version that would still be worth shipping?

### Dados e integração
- Where does the data come from — which service, endpoint, or table?
- What is the shape of the payload, and who owns that contract?
- Pagination, sorting, expected volume?
- What happens when the source is slow, empty, or down?

### UX e comportamento
- Empty state, loading state, error state — what does the user see in each?
- What is the behavior on mobile / small viewport?
- Which actions are reversible, and is there a confirmation?
- Accessibility expectations (keyboard navigation, screen reader, contrast)?

### Segurança e conformidade
- Who is allowed to see or do this, and where is that enforced — client, server, or both?
- Does this touch personal or regulated data (PII, health, financial)?
- What must be audited or logged?

### Testes e rollout
- What is the definition of done for QA — automated, manual, or both?
- Feature flag, gradual rollout, or straight to production?
- What is the rollback story if it goes wrong?

### Contrato de integração
- Public API surface: props, attributes, events, callbacks, return shapes.
- Is this contract versioned? Who else consumes it?
- What breaks downstream if it changes later?

## Partial answers

If the human answers only part of the list, **do not silently fill the rest.** Draft what you
can and record every unanswered item in `plan.md` under **Open questions**, each with the
assumption you are proceeding on.

Assumptions written down are reviewable. Assumptions held in your head are not — and they
surface during implementation, when they are expensive.

Carry the most consequential of those assumptions into the approval confirmation at the gate.
An assumption the human never explicitly saw is an assumption nobody approved.

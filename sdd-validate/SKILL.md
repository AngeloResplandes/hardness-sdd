---
name: sdd-validate
description: Phase 5 of the SDD harness — checks an implemented cycle against its own tasks, scenarios, plan, and out-of-scope list, runs the test suite, and writes validation.md with result pass or fail. Use when a cycle's tasks are all checked except the final promote task; when the user says "valida o ciclo", "valida", "roda a validação", "está pronto?"; or before any attempt to promote the spec. A fail sends the cycle back to sdd-implement, never forward to sdd-promote.
---

# Phase 5 — Validate

The checkpoint that stands between "the tasks are checked off" and "the canonical spec may
now claim this exists". Promotion without validation is how `spec/` starts lying.

Run this against the actual repository state. Checking a box in `tasks.md` is a claim;
validation is where the claim gets tested. Read the code and run the commands — do not
validate from memory of having written it.

## Checklist

**1. Tasks**
Every item in `tasks.md` is checked, except the final promote task. Any unchecked item is an
automatic fail — list it.

**2. Scenarios**
Walk `scenarios.feature` scenario by scenario. For each one, record how you know it holds: an
automated test that covers it (cite file and line), a manual verification you actually
performed, or `NÃO VERIFICADO`.

Never infer that a scenario passes because the code "looks right" — that is the exact
judgment the scenario exists to replace. `NÃO VERIFICADO` is an honest answer and a useful
one; a fabricated pass is neither.

**3. Test suite**
Run it. Record the real command and the real output. If the repo has no test suite, say that
explicitly rather than skipping the line silently.

**4. Plan fidelity**
Does the implementation match `plan.md`? Divergences are not automatically failures, but each
one must be either reflected back into `plan.md` and `spec-delta.md`, or flagged as a known
gap. Undocumented divergence is a fail.

**5. Spec-delta accuracy**
Re-read `spec-delta.md` against what was actually built. It was written before the code
existed, so drift is normal. Correct it now — `sdd-promote` applies it mechanically and will
propagate whatever errors survive here.

**6. Out of scope respected**
Nothing shipped that `plan.md` listed as out of scope. Scope creep that reached production
needs to be surfaced, not absorbed.

## Output

Write `validation.md` in the cycle folder, from `assets/validation.md`:

```markdown
---
result: pass
validated_at: 2026-07-26
---

# Validação — <slug do ciclo>

## Tarefas
- 12/12 concluídas (exceto a promoção da spec, que é a fase seguinte)

## Cenários
| Cenário | Como foi verificado |
|---|---|
| Ver episódios em ordem cronológica | `episodes-list.spec.ts:42` |
| Lista vazia mostra estado apropriado | `episodes-list.spec.ts:88` |
| Filtrar por status | verificação manual no ambiente local |

## Suíte de testes
`npm test` — 148 passed, 0 failed

## Divergências do plano
- Nenhuma. / ou: <lista, com o que foi feito a respeito>

## Pendências
- Nenhuma. / ou: <lista>
```

## On a fail

`result: fail` is a normal outcome, not an embarrassment — it is the checkpoint working.

List precisely what is missing, return to `sdd-implement`, and do not touch `spec/`. Re-run
this phase after the gaps are closed. Never soften a fail into a pass with caveats; the
frontmatter is what `sdd-promote` reads, and it reads it literally.

## Then

On a pass, hand off to `sdd-promote`.

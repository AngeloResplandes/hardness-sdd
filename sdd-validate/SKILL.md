---
name: sdd-validate
description: Phase 5 of the SDD harness — checks an implemented cycle against its own tasks, scenarios, plan, and out-of-scope list, runs the test suite, and writes validation.md with result pass or fail. Use when a cycle's tasks are all checked except the final promote task; when the user says "valida o ciclo", "valida", "roda a validação", "está pronto?"; or before any attempt to promote the spec. A fail sends the cycle back to sdd-implement, never forward to sdd-promote.
---

# Phase 5 — Validate

The checkpoint that stands between "the tasks are checked off" and "the canonical spec may
now claim this exists". Promotion without validation is how `spec/` starts lying.

## Invariants binding this phase

1. **You do not write inside `spec/`.** Before any Write or Edit, check the path — if it
   starts with `spec/`, stop. You correct `spec-delta.md`; `sdd-promote` applies it.
2. **You do not fix what you find.** Validation that repairs its own failures is not a
   checkpoint. Report the gap and hand back to `sdd-implement`.
3. **A claim is not a verification.** A checked box, code that looks right, and your own
   memory of writing it are all claims. Run the command; read the file.

Run this against the actual repository state. Checking a box in `tasks.md` is a claim;
validation is where the claim gets tested. Read the code and run the commands — do not
validate from memory of having written it.

## Which cycle

If the user named one, use that. Otherwise take the newest folder under `cycles/` — newest
**by folder name** (`Q{q}{yyyy}/{MMDD}` sorts chronologically), not by mtime. Two candidates
from the same day and no instruction → ask. State which one you resolved to.

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

Never soften a fail into a pass with caveats; the frontmatter is what `sdd-promote` reads,
and it reads it literally.

**A fail is not done until the gaps are executable.** Listing them in `validation.md` and
saying "volte para a implementação" leaves `sdd-implement` looking at a checklist where every
box is already ticked — it will conclude there is nothing to do and the cycle deadlocks.
Close the loop yourself:

1. Write the gaps into `tasks.md` as a new section at the end, before the promote task:

   ```markdown
   ## Correções — validação 1

   - [ ] <lacuna concreta, citando arquivo/módulo e o cenário que ela destrava>
   - [ ] <lacuna concreta>
   ```

2. If a gap means a previously checked task was not actually complete, **uncheck it**
   (`- [x]` → `- [ ]`) and say so in your report. A checked box that is not true is worse
   than an unchecked one.

3. Only then hand back to `sdd-implement`, pointing at that section as its scope.

Do not touch `spec/` on a fail, under any circumstance.

## Re-validating

A cycle can validate several times. Each run must be able to tell what changed since the last
one, otherwise "corrigido" is an unverifiable claim.

- Increment `attempt:` in the frontmatter (first run is `1`).
- Fill the **Resolvido desde a última validação** section: one line per gap from the previous
  run, with how you verified it is now closed. A gap that is still open stays in *Pendências*
  — it does not silently disappear between runs.
- Re-run the whole checklist, not just the previously failing items. Fixes break things that
  used to work, and a targeted re-check is exactly how that gets missed.

## When the state is broken

| Symptom | Likely cause | What to do |
|---|---|---|
| The test suite will not run (broken deps, missing config) | Environment problem | Record the real command and error under *Suíte de testes*. This is `result: fail` — an unrunnable suite means the scenarios are unverified, and unverified is not a pass. |
| The repo has no test suite at all | Project has none | Not automatically a fail. Say so explicitly, and verify each scenario manually or mark it `NÃO VERIFICADO`. A cycle can pass with manual verification; it cannot pass with silence. |
| `scenarios.feature` missing or empty | Refine did not finish | **PARE.** There is no definition of done to validate against. Return to `sdd-refine`. |
| `plan.md` is `draft` | The gate was never passed | **PARE.** Validating unapproved work is meaningless. Return to the gate. |
| Tasks unchecked but the work looks done | Implementation did not update the checklist | Do not check them off yourself — that destroys the progress record. Report which ones and let `sdd-implement` close them. |

**Never infer a pass.** If you cannot verify a scenario, `NÃO VERIFICADO` is the answer, and
enough of them is a `fail`. The whole point of this phase is that it does not take claims at
face value — including your own from earlier in the session.

## Then

On a pass, hand off to `sdd-promote`.

## Closing report

```markdown
**Fase:** Validate — <ok | atenção | erro>
**Resultado:** result: <pass|fail> (tentativa <N>). <X/Y cenários verificados.> Suíte: <comando> — <resultado>.
**Artefatos:** validation.md<, + tasks.md se você acrescentou correções>
**Próximo passo:** <"promove a spec" | "implementa o ciclo" (corrigindo as lacunas listadas)>
```

Status mapping, which is not the same as `result`:

- `result: pass`, nothing outstanding → **ok**
- `result: pass` with `NÃO VERIFICADO` scenarios or known gaps → **atenção**, and the next
  step is the human deciding whether those block promotion
- `result: fail` → **atenção** (the checkpoint worked as designed — this is not an `erro`)
- Could not validate at all → **erro**

Always state the attempt number. "Validou" on attempt 3 is a different fact than on attempt 1,
and it is the number that reveals whether the plan was any good.

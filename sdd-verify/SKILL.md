---
name: sdd-verify
description: Phase 4.5 of the SDD harness — proves an implemented cycle actually runs. Starts the dev server, exercises the scenarios in a real browser (Playwright, Cypress, a browser MCP, or a scripted manual pass), runs the test suite, and writes verification.md with per-scenario evidence. Use when a cycle's tasks are checked and before sdd-validate; when the user says "roda o servidor", "abre o navegador", "testa no browser", "verifica se está funcionando", "roda os testes", "sobe a aplicação"; or when a scenario needs runtime evidence rather than a code reading. Also use standalone to run a project's server or tests without a cycle. Never installs a browser automation stack and never edits code to make a check pass.
---

# Phase 4.5 — Verify

Implementation says the code was written. Verification says the code **runs**. Those are
different claims, and the gap between them is where most "está pronto" turns out to be false.

This phase produces evidence. `sdd-validate` then judges that evidence against the scenarios.
Keeping the two apart matters: the phase that runs things has an interest in them working, and
the phase that judges should not.

## Invariants binding this phase

1. **You do not fix anything here.** Not the code, not the config, not a failing test. A
   verification run that repairs what it finds is measuring its own repairs. Record the
   failure, stop, and hand back to `sdd-implement`.
2. **You do not write inside `spec/`.** Before any Write or Edit, check the path — if it
   starts with `spec/`, stop.
3. **You do not install dependencies to make verification possible.** Adding Playwright,
   changing a lockfile, or upgrading a package is an architectural decision that belongs to a
   human in a cycle of its own. Offer it; never do it.
4. **Observed, or not verified.** There is no third state. Code that looks correct is not
   evidence, and neither is a server that started.

## Which cycle

If the user named one, use that. Otherwise take the newest folder under `cycles/` — newest
**by folder name** (`Q{q}{yyyy}/{MMDD}` sorts chronologically), not by mtime. Two candidates
from the same day and no instruction → ask.

This skill also runs **without a cycle** — "sobe o servidor", "roda os testes" on their own.
In that mode, do steps 1–2 (and 4 if asked), report, and skip `verification.md` entirely.

## Step 1 — Resolve the commands

Read `references/runtime.md`. In short: the cycle's `plan.md` first, then
`spec/architecture.md`, then the project manifest, and only then ask.

State the commands you resolved to and where you got them, before running anything. A command
sourced from a guess should be visibly a guess.

## Step 2 — Run the test suite

Run it first. It is the cheapest signal and it fails fastest.

Record the **real command and the real output** — counts, and the actual failure text for
anything that failed. Never summarize a failure into "alguns testes falharam"; the output is
what makes it actionable.

A failing suite does not stop the phase. Keep going and check the browser too — knowing both
"the tests fail" and "the page also does not load" in one round is worth more than discovering
them one at a time.

## Step 3 — Start the server

Start it in the **background**, so it stays up while you check it, and capture its output.

Then wait for it to actually be ready. Do not sleep a fixed number of seconds and hope:

- Watch the output for the line where it reports the URL it bound to.
- Or poll the URL until it answers.

**Take the port from the server's own output, not from your inference.** Dev servers move to
another port when the expected one is taken, and a browser check against the wrong port fails
in a way that looks like a broken app.

If it does not come up within a reasonable window (~60s for most stacks), stop waiting and
report the output. A server that never started is a `result: fail` with the log attached, not
a reason to retry three more times.

**Always shut it down when the phase ends**, including when the phase ends in a failure. A
background dev server left running holds the port and makes the next run fail for a reason
that has nothing to do with the code.

## Step 4 — Exercise the scenarios in a browser

Only for cycles with a user interface. Skip it, and say you skipped it, for a library, a CLI,
or a backend-only change.

Work from `scenarios.feature` — that is the list of things a user should be able to do. Do not
improvise a tour of the app; the scenarios are the contract, and anything outside them is not
what this cycle promised.

**With automation available** (the project's Playwright/Cypress, or a browser MCP): drive each
scenario, capture a screenshot per scenario, note the actual result. Do not write new E2E test
files into the project — running a scenario is verification, adding a test file is
implementation and it was never in `tasks.md`.

**Without automation**: this is a manual pass, and the point is to make it *repeatable*. Give
the human a numbered script tied to the scenarios — the URL, what to click, what they should
see — and ask them to confirm. Then record what they confirmed, attributed to them.

```
Servidor no ar: http://localhost:5173

1. Abra /pacientes/123/historias — deve listar os episódios em ordem cronológica (cenário 1)
2. Filtre por status "aberto" — só episódios abertos ficam visíveis (cenário 3)
3. Abra /pacientes/999/historias (sem episódios) — deve aparecer o estado vazio (cenário 2)

Confirma cada um? Se algum divergir, me diga o que você viu.
```

**Never mark a scenario verified because you inferred it.** A scenario you could not exercise
is `NÃO VERIFICADO`, and that is an honest, useful answer. The empty state and the failure
state are the two most commonly skipped and the two most commonly broken — if the scenarios
list them, exercise them.

Also record anything that broke in the browser console. A page that renders while throwing
errors is not working, it is failing quietly.

## Step 5 — Write `verification.md`

Use `assets/verification.md`. Frontmatter:

```yaml
---
result: pass | fail
verified_at: <yyyy-mm-dd>
server: http://localhost:5173
method: playwright | cypress | mcp | manual | n/a
---
```

`result: pass` means every scenario was **observed** to work. Any `NÃO VERIFICADO`, any failing
test, any console error → `fail`. This file is evidence for `sdd-validate`, and evidence that
overstates itself is worse than no evidence, because the next phase trusts it.

## When the state is broken

| Symptom | Likely cause | What to do |
|---|---|---|
| No command found for the dev server | Undocumented project | Ask once, with what you found as the proposed default. Record the answer in `plan.md` under *Runtime*. |
| Server exits immediately | Port in use, missing env var, broken build | Report the **actual output**. Port conflicts and missing `.env` are the usual two, and both are the human's call — do not free the port or invent env values. |
| Server starts but the page is blank | Build error, wrong route, JS exception | Capture the console output and the network tab if you have them. Blank page plus a clean console is a different bug from blank page plus a stack trace. |
| Tests fail | Could be the implementation, could be the environment | Not your call to diagnose here. Record and hand back. If the same suite passed in `sdd-implement`, say so — that difference is the clue. |
| Browser automation exists but is not configured (no baseURL, no browsers installed) | Setup never finished | Report it. `npx playwright install` is a machine-level action — offer it, do not run it. |
| A scenario cannot be exercised at all (needs prod data, a third-party account, a device) | Not verifiable in this environment | `NÃO VERIFICADO` with the reason. This is a legitimate outcome; hiding it is not. |
| Verification passes but you noticed something ugly outside the scenarios | Out of scope | Note it under *Observações*. Do not fix it, do not fail the cycle for it. |

**Stop condition:** if a check fails twice for the same reason, stop and report both attempts.
Do not try a third variation — repeated retries burn context and bury the original error.

## Closing report

```markdown
**Fase:** Verify — <ok | atenção | erro>
**Resultado:** result: <pass|fail>. Suíte: <comando> — <resultado>. Navegador: <X/Y cenários observados> (<método>).
**Artefatos:** verification.md<, screenshots/>
**Próximo passo:** <"valida o ciclo" | "implementa o ciclo" (corrigindo o que falhou)>
```

`atenção` when it passed with `NÃO VERIFICADO` scenarios or console noise. `erro` when you
could not run the project at all — that is different from the project running and failing,
and the distinction tells the human whether to look at their environment or at the code.

Say explicitly that the server was shut down.

## Files

- `references/runtime.md` — detecting commands, port, and browser tooling per stack
- `assets/verification.md` — the evidence template

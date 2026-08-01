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
**by the date the name encodes**, not by mtime. Reorder to `yyyyMMdd` before comparing —
`Q{q}{yyyy}` puts the quarter first, so a plain string sort ranks `Q42025` above `Q32026` and
picks a cycle from last year. Two candidates from the same day and no instruction → ask.

This skill also runs **without a cycle** — "sobe o servidor", "roda os testes" on their own.
In that mode, do steps 1–2 (and 4 if asked), report, and skip `verification.md` entirely.

## Step 1 — Resolve the commands

Read `references/runtime.md`. In short: the cycle's `plan.md` first, then
`spec/architecture.md`, then the project manifest, and only then ask.

State the commands you resolved to and where you got them, before running anything. A command
sourced from a guess should be visibly a guess.

## Step 2 — Run the test suite

Run it first. It is the cheapest signal and it fails fastest.

**Unit and E2E are two different suites — do not conflate their results.** In projects that
have both, the unit runner's default glob often picks up the E2E specs it cannot execute.
Vitest scanning a Playwright `e2e/` directory reports:

```
FAIL  e2e/episodes.spec.js
Error: Playwright Test did not expect test() to be called here.
Test Files  1 failed | 1 passed (2)
      Tests  3 passed (3)
```

Every actual test passed. The failure is a runner collision, not a defect — and reporting that
cycle as `fail` sends someone hunting a bug that does not exist. Read the counts: "Tests"
is the real signal, "Test Files" includes files that never ran.

When you see it, say so plainly in *Suíte de testes* and record both numbers. It is worth
flagging under *Observações* as a project config issue (the fix is an `exclude` in the vitest
config), but it is **not** yours to fix here and not grounds for failing the cycle.

Record the **real command and the real output** — counts, and the actual failure text for
anything that failed. Never summarize a failure into "alguns testes falharam"; the output is
what makes it actionable.

A failing suite does not stop the phase. Keep going and check the browser too — knowing both
"the tests fail" and "the page also does not load" in one round is worth more than discovering
them one at a time.

## Step 3 — Start the server

### First: check whether the E2E runner already starts one

**Do not start a server the test runner is going to start itself.** Playwright's
`webServer` block and Cypress's `start-server-and-test` launch and stop the app as part of the
run. Starting your own first produces one of two outcomes, and both are bad:

- `reuseExistingServer: false` (common in CI configs) → the run **fails outright** with
  `http://localhost:5173 is already used`, zero scenarios executed, for a reason that has
  nothing to do with the code.
- `reuseExistingServer: true` → it silently attaches to *your* server instead of the one the
  config describes, so you verified something the config never sanctioned.

```bash
grep -l "webServer" playwright.config.* 2>/dev/null
grep -l "start-server-and-test" package.json 2>/dev/null
```

If either matches, **skip to step 4 and let the runner own the server's lifecycle.** Start a
server yourself only when there is no automation, or when the automation does not manage one.
Say in your report which of the two happened — "servidor gerenciado pelo Playwright" and
"servidor iniciado por mim" are different facts about how the evidence was produced.

### Otherwise, start it yourself

A dev server never exits on its own, so it cannot be run like a normal command — it has to be
detached, watched until ready, and killed by something that can find it again afterwards.

### Start it, redirecting output to a file

```bash
npm run dev > /tmp/sdd-server.log 2>&1 &
```

**Redirect to a file rather than relying on captured output.** A backgrounded server produces
no output where you can see it — the log file is the only way to read the port line, and it is
also the evidence you attach when the server fails to start.

### Wait for it to be ready — never a fixed sleep

Poll until the URL line appears, then confirm the URL answers:

```bash
for i in $(seq 1 60); do
  url=$(sed -e 's/\x1b\[[0-9;]*m//g' /tmp/sdd-server.log | grep -oE 'https?://localhost:[0-9]+' | head -1)
  [ -n "$url" ] && break
  sleep 0.5
done
curl -s -o /dev/null -w '%{http_code}' "$url/"
```

**Strip ANSI escape codes before parsing.** Vite, Next, and most modern dev servers colorize
their output, and the codes land *inside* the number — the raw line reads
`localhost:\e[1m5173\e[22m`. A grep against the raw log either misses the port or captures
garbage, and the browser check then runs against nothing. The `sed` above is not optional.

**Take the port from that line, not from your inference.** Dev servers move to another port
when the expected one is taken — Vite prints `Port 5173 is in use, trying another one...` and
binds 5174. An agent that assumed 5173 would silently check a *different, older* server, which
is worse than failing: it verifies stale code and reports a pass.

If nothing appears within ~60s, stop and report the log. A server that never started is a
`result: fail` with the log attached, not a reason to retry.

### Shut it down — and verify the port is actually free

**On Windows this is where naive shutdown fails silently.** `npm run dev` spawns the real
server as a *child* of npm, and under Git Bash the recorded `$!` is a Bash PID, not the Windows
PID holding the port. `kill $!` reports success and leaves the server running.

Find the process by the port it holds, and kill the tree:

```bash
# Windows / Git Bash
pid=$(netstat -ano | grep ":5173 " | grep LISTENING | awk '{print $NF}' | head -1)
taskkill //PID $pid //T //F      # //T kills the child that actually holds the port

# macOS / Linux
kill $(lsof -ti:5173)
```

Then **confirm the port is free** rather than trusting the kill reported success:

```bash
netstat -ano | grep ":5173 " | grep LISTENING || echo "porta liberada"
```

Do this even when the phase ends in failure. A leftover dev server holds the port, and the next
run either fails to start or — far worse — silently attaches to the stale one.

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
| Log file stays empty and nothing binds | The start command failed before printing anything | Read the log anyway — the failure is usually in the first lines (missing script, module not found). An empty log after 60s with no listening port is `result: fail`. |
| The port line never parses, but the server is up | ANSI codes not stripped | Re-parse with the `sed` filter in step 3. Do not fall back to a guessed port — that is how a check runs against the wrong server. |
| Kill reported success but the port is still held | Windows: killed the Bash PID, not the Windows child | Find the PID via `netstat -ano` on the port and `taskkill //PID <pid> //T //F`. Always re-check the port after killing; a shutdown you did not confirm did not happen. |
| A server from a previous run is still listening | Earlier phase did not clean up | **PARE** before starting another. Two servers on adjacent ports means your check may hit the stale one. Kill the old one first, and say you found it. |
| Server starts but the page is blank | Build error, wrong route, JS exception | Capture the console output and the network tab if you have them. Blank page plus a clean console is a different bug from blank page plus a stack trace. |
| Tests fail | Could be the implementation, could be the environment | Not your call to diagnose here. Record and hand back. If the same suite passed in `sdd-implement`, say so — that difference is the clue. |
| Browser automation exists but is not configured (no baseURL, no browsers installed) | Setup never finished | Report it. `npx playwright install` is a machine-level action — offer it, do not run it. |
| `Executable doesn't exist at ...chromium-<N>` while a different `chromium-<M>` is installed | Playwright upgraded; its browser build no longer matches | Not a code failure. The binaries are versioned to the Playwright release, so having "Chromium installed" is not enough. Offer `npx playwright install chromium` — a ~115MB machine-level download, so it is the human's call, not yours. |
| `is already used, make sure that nothing is running on the port` | You started a server the runner also manages | Kill yours and let the runner own it. See step 3 — this is why the `webServer` check comes first. |
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

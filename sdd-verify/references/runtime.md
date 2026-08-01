# Discovering how this project runs

The harness is stack-agnostic, so the commands are never assumed — they are read out of the
repository. Detection is cheap and wrong guesses are expensive: a "server failed to start"
that was really a wrong command sends the whole cycle back to implementation for no reason.

## Order of resolution

1. **The cycle's `plan.md`.** If a previous run recorded commands under *Runtime*, use those.
   They were confirmed by a human once; do not re-derive them.
2. **`spec/architecture.md`.** Projects that document their own commands are the easy case.
3. **The manifest** — see the table below.
4. **Ask.** Once, in one message, with what you found as the proposed default.

Never invent a command that has no evidence behind it. `npm start` on a repo whose
`package.json` has no `start` script is a fabricated fact, and the error it produces looks
like a broken app rather than a broken guess.

## Where to look, by stack

| Signal file | Read | Typical dev server | Typical tests |
|---|---|---|---|
| `package.json` | `scripts` | `dev`, `start`, `serve` | `test`, `test:unit`, `vitest`, `jest` |
| `pyproject.toml` | `[tool.poetry.scripts]`, `[project.scripts]` | `uvicorn`, `flask run`, `manage.py runserver` | `python -m pytest` |
| `manage.py` | — | `python manage.py runserver` | `python manage.py test` / `python -m pytest` |
| `Makefile` | targets | `make dev`, `make run`, `make serve` | `make test` |
| `Cargo.toml` | — | `cargo run` | `cargo test` |
| `go.mod` | — | `go run ./...` | `go test ./...` |
| `composer.json` | `scripts` | `php artisan serve` | `composer test`, `phpunit` |
| `Gemfile` | — | `bin/rails server` | `bundle exec rspec` |
| `docker-compose.yml` | `services` | `docker compose up` | varies — read the service |

Prefer the script the project defines over the underlying tool. `npm run dev` is what the
team runs; `vite --port 3000` is an implementation detail that drifts.

**Python: use `python -m pytest`, not bare `pytest`.** The `-m` form puts the current
directory on `sys.path`; the bare console script does not. On a normal `app/` + `tests/`
layout without an editable install, bare `pytest` dies at collection with `ModuleNotFoundError`
on the project's own package — an error that reads like broken code but is purely an
invocation artifact. Observed: same repo, same tests, `2 passed` under `-m` and
`1 error during collection` without it.

## The port and base URL

Getting this wrong produces a browser check against nothing.

Look, in order: an explicit `--port` in the script, `.env` / `.env.local` / `.env.example`,
the framework config (`vite.config`, `next.config`, `application.properties`), then the
framework's documented default (Vite 5173, Next 3000, CRA 3000, Django 8000, Rails 3000,
Flask 5000, FastAPI/uvicorn 8000).

**Confirm the port from the server's own startup output** rather than trusting the inference.
Every dev server prints the URL it actually bound to, and that line is the ground truth —
including when it silently picked a different port because yours was taken.

That line is almost always colorized, with the escape codes landing *inside* the number
(`localhost:\e[1m5173\e[22m`). Strip them before parsing:

```bash
sed -e 's/\x1b\[[0-9;]*m//g' server.log | grep -oE 'https?://localhost:[0-9]+' | head -1
```

Observed on Vite 5: a second instance prints `Port 5173 is in use, trying another one...` and
binds 5174 — with both servers answering HTTP 200. Inferring the port there does not error, it
verifies the wrong application.

## Browser automation

Check what the project already has before reaching for anything new:

| Present | Use |
|---|---|
| `playwright.config.*`, `@playwright/test` | The project's own Playwright runner |
| `cypress.config.*` | Cypress |
| A browser MCP server in the session | Drive the browser through it |
| None of the above | Manual verification — see `SKILL.md` |

Two things to check before running it, both of which fail the phase for reasons unrelated to
the code:

- **Does the config manage its own server?** `webServer` in `playwright.config.*`, or
  `start-server-and-test` in `package.json`. If so, do not start one yourself — see step 3.
- **Are the browser binaries the version this Playwright wants?** They are pinned per release
  (`chromium-1234`, not "chromium"), so an upgraded Playwright fails against binaries that are
  merely present. The error names the exact expected path.

**Do not install a browser automation stack to close a cycle.** Adding Playwright to a project
that never had it is a dependency decision, an architectural one, and it belongs in a cycle of
its own with a human approving it — not smuggled in as a side effect of verification. Offer it
as a suggestion in your report; never as an action.

## Recording what you found

Once resolved, write the commands into the cycle's `plan.md` under a `## Runtime` section:

```markdown
## Runtime

- Dev server: `npm run dev` — http://localhost:5173
- Testes: `npm test`
- E2E: `npx playwright test` (config em `playwright.config.ts`)
- Build: `npm run build`
```

This is what makes the second run cheap, and it is the thing worth promoting into
`spec/architecture.md` when the cycle closes — how a project runs is permanent knowledge
about the project, not a fact about one cycle.

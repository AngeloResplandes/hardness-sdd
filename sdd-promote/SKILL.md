---
name: sdd-promote
description: Phase 6 of the SDD harness — the only phase allowed to write inside spec/. Applies a validated spec-delta.md into the canonical spec, writing the system's new current state rather than a changelog, then closes the cycle. Use when validation.md says result pass and spec-delta.md is still status proposed; or when the user says "promove a spec", "atualiza a spec", "aplica o delta", "fecha o ciclo". Refuses to run if validation did not pass.
---

# Phase 6 — Promote

The only phase permitted to write inside `spec/`.

## Invariants binding this phase

You hold the write privilege the other phases are denied, so the constraints here are on how
you use it:

1. **You write into `spec/` only after `validation.md` says `pass`.** The privilege is
   conditional on the claim having become true.
2. **You apply the delta; you do not author it.** If a change requires writing spec content
   that is not in `spec-delta.md`, stop — that content was never reviewed.
3. **You write the new state, never the change.** No changelog, no "antes era X". That history
   lives in the cycle folder and in git.
4. **The cycle folder is frozen once promoted.** Never edit it retroactively to match a later
   change; a later change gets its own cycle.

## Which cycle

If the user named one, use that. Otherwise take the newest folder under `cycles/` — newest
**by folder name** (`Q{q}{yyyy}/{MMDD}` sorts chronologically), not by mtime. Two candidates
from the same day and no instruction → ask. State which one you resolved to before writing
anything into `spec/`.

## Preconditions

Refuse to run and say exactly which one failed if any of these is false:

- `validation.md` exists with `result: pass`
- `spec-delta.md` exists with `status: proposed`
- Every task except the final promote task is checked

These are not bureaucracy. Promotion is the moment the canonical spec starts asserting that
something is true of the system. If validation did not pass, the assertion is false — and a
false spec is worse than a missing one, because people trust it and build on it.

If a precondition fails, name the phase that has to run first and stop.

## When the state is broken

| Symptom | Likely cause | What to do |
|---|---|---|
| `validation.md` missing | Validate never ran | **PARE.** Run `sdd-validate` first. Promoting unvalidated work is the one action this harness cannot undo cheaply — it puts a false claim into the canonical spec. |
| `validation.md` says `fail` | Gaps still open | **PARE.** Name the gaps it lists and return to `sdd-implement`. Do not promote "the parts that passed" — a partial spec update describes a system that does not exist. |
| `spec-delta.md` already `promoted` | Promote ran before | **PARE.** Report what it already applied. Re-applying is not idempotent: the delta says "hoje diz X → passa a dizer Y", and `spec/` no longer says X. |
| `spec-delta.md` missing | Refine skipped it | **PARE.** If the cycle genuinely changed nothing in `spec/`, say so and close the cycle without promoting. Otherwise return to `sdd-refine`. |
| The delta's "Hoje" text does not match what `spec/` actually says | Spec changed after the delta was written | **PARE.** Show both. Applying a stale delta silently overwrites whatever changed in between — possibly another cycle's work. |
| A target file under `spec/` does not exist and the delta does not mark it NEW | Delta drifted | Do not guess the content. Report it and return to `sdd-refine` or `sdd-validate` (step 5 exists to catch exactly this). |

**Stop condition:** if applying a change would require you to *author* spec content rather
than transcribe it from the delta, stop. This phase is mechanical application. Authoring here
means writing canonical documentation nobody reviewed.

## Applying the delta

Work through `spec-delta.md` file by file and apply each change to the real docs under
`spec/`.

**Write the new state, not the change.** The canonical spec describes the system as it is
today. It should read as though the feature always existed. Delete anything the change made
untrue. Resist the urge to leave a trail — no "previously this returned X", no "changed in Q3
2026", no changelog sections. That history already lives in the cycle folder and in git;
duplicating it here is how spec files grow into archaeological digs nobody reads.

**Reconcile, don't append.** If a section already covers the same ground, rewrite that
section. Bolting a new paragraph onto the end leaves two descriptions of the same behavior,
and the reader has no way to know which one is current.

**Fix what you find.** If applying the delta reveals that `spec/` was already wrong about
something adjacent, correct it and mention it in your report. Leaving a known lie in place
because it was out of scope defeats the purpose of having a canonical spec.

## Closing the cycle

1. Set `status: promoted` and `promoted_at: <date>` in `spec-delta.md` frontmatter.
2. Check off the final task in `tasks.md`.
3. Append one row to `cycles/index.md` (create it with the header below if absent).
4. Report what changed in `spec/` — one line per file.

### The index

One row per closed cycle. It costs a line to write and it is the only place the harness
accumulates evidence about itself — which cycles were oversized, how often plans survive
validation on the first try, whether scenario counts track cycle size.

```markdown
# Ciclos

| Ciclo | Tamanho | Cenários | Validações | Promovido |
|---|---|---|---|---|
| Q32026/0726-episodes-list-webcomponent | Medium | 9 | 2 | 2026-07-28 |
```

`Validações` is the `attempt` number from `validation.md`. A column of 3s means refine is
producing plans that do not survive contact with the code — that is worth knowing, and it is
invisible without the index.

Do not editorialize in the index. It is data; the analysis happens when someone reads a
column of it.

The cycle folder is now frozen. It stays in the repo as the record of why the spec says what
it says; never edit it retroactively to match a later change. A future cycle that alters this
behavior gets its own folder and its own delta.

## Closing report

```markdown
**Fase:** Promote — <ok | atenção | erro>
**Resultado:** <N arquivos de spec/ atualizados. Ciclo fechado.>
**Artefatos:** <cada arquivo de spec/ tocado>, spec-delta.md, tasks.md, cycles/index.md
**Próximo passo:** commit, PR ou merge — o que você preferir.
```

`atenção` when you corrected something in `spec/` beyond the delta (see *Fix what you find*) —
that is a change nobody reviewed, so it has to be visible rather than folded into the summary.

## Then

Offer next steps rather than assuming: commit, open a pull request, or merge the branch. The
`superpowers:finishing-a-development-branch` skill covers that decision if it is installed.

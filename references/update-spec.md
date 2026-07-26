# Phase 6 — Promote

The only phase permitted to write inside `spec/`.

## Preconditions

Refuse to run and say why if any of these is false:

- `validation.md` exists with `result: pass`
- `spec-delta.md` exists with `status: proposed`
- Every task except the final promote task is checked

These are not bureaucracy. Promotion is the moment the canonical spec starts asserting
that something is true of the system. If validation did not pass, the assertion is false,
and a false spec is worse than a missing one — people trust it and build on it.

## Applying the delta

Work through `spec-delta.md` file by file and apply each change to the real docs under
`spec/`.

**Write the new state, not the change.** The canonical spec describes the system as it is
today. It should read as though the feature always existed. Delete anything the change
made untrue. Resist the urge to leave a trail — no "previously this returned X", no
"changed in Q3 2026", no changelog sections. That history already lives in the cycle
folder and in git; duplicating it here is how spec files grow into archaeological digs
nobody reads.

**Reconcile, don't append.** If a section already covers the same ground, rewrite that
section. Bolting a new paragraph onto the end leaves two descriptions of the same
behavior, and the reader has no way to know which one is current.

**Fix what you find.** If applying the delta reveals that `spec/` was already wrong about
something adjacent, correct it and mention it in your report. Leaving a known lie in place
because it was out of scope defeats the purpose of having a canonical spec.

## Closing the cycle

1. Set `status: promoted` and `promoted_at: <date>` in `spec-delta.md` frontmatter.
2. Check off the final task in `tasks.md`.
3. Report what changed in `spec/` — one line per file.

The cycle folder is now frozen. It stays in the repo as the record of why the spec says
what it says; never edit it retroactively to match a later change. A future cycle that
alters this behavior gets its own folder and its own delta.

## Then

Offer next steps rather than assuming: commit, open a pull request, or merge the branch.
The `superpowers:finishing-a-development-branch` skill covers that decision if it is
installed.

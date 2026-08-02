---
name: sdd-capability
description: Phase 1.5 of the SDD harness — classifies the cycle's size and, when it is Large, resolves the capability constraints that must hold before implementation into capability.md. Turns product intent into explicit engineering constraints: invariants, trust boundaries, data ownership, lifecycle transitions, and the interfaces that cross services. Use when a cycle has request.md but no plan.md; when the user says "mapeia a capacidade", "quais as restrições", "isso cruza serviços"; or when a feature spans multiple modules, repos, or teams and needs a contract before coding. Exits immediately for Small and Medium cycles — it exists to stop large work from being planned on implicit assumptions, not to add ceremony to small work.
---

# Phase 1.5 — Capability

Sits between the problem (`request.md`) and the solution (`plan.md`). It answers one question,
and only that question:

> **What must be true before implementation can start?**

Not "what should we build" — Start captured that. Not "how do we build it" — Refine decides
that. This phase makes explicit the constraints that otherwise live only in senior-engineer
memory and surface halfway through a pull request.

**For Small and Medium cycles this phase does nothing but classify and step aside.** That is
the design, not a shortcut. A phase that runs on every cycle regardless of stakes is ceremony,
and ceremony applied to trivia is how good processes get abandoned.

## Invariants binding this phase

1. **You do not write inside `spec/`.** Before any Write or Edit, check the path — if it
   starts with `spec/`, stop. Only `sdd-promote` writes there. Constraints you discover about
   the canonical spec go in `capability.md`, and reach `spec/` only through `spec-delta.md`
   and a passing validation.
2. **You do not write `plan.md`, `tasks.md`, or `scenarios.feature`.** Those are `sdd-refine`'s
   output and they go through the human gate. This phase produces constraints; it does not
   propose a solution. If you find yourself writing "criar o componente X", stop — that is a
   task, and you are in the wrong phase.
3. **You do not invent product truth.** An unresolved question is recorded as unresolved. A
   constraint you inferred is marked as inferred. The value of this artifact is that a reader
   can tell which lines are decided and which are assumed.
4. **Size is recorded in `capability.md`, and Refine reads it rather than re-deriving it.**
   Two phases classifying independently is two chances to disagree.

## Which cycle

If the user named one, use that. Otherwise take the newest folder under `cycles/` — newest
**by the date the name encodes**, not by mtime. Reorder to `yyyyMMdd` before comparing —
`Q{q}{yyyy}` puts the quarter first, so a plain string sort ranks `Q42025` above `Q32026` and
picks a cycle from last year. Two candidates from the same day and no instruction → ask. State
which one you resolved to before writing anything.

## Step 1 — Read before deciding

Read, in this order:

1. The cycle's `request.md` — the problem, in the human's own words.
2. Every canonical doc it references under `spec/`, plus their neighbors. If the request points
   at `spec/features/episodes-list/`, also read `spec/architecture.md` and any sibling feature
   that already solved a similar problem.
3. The code for the modules the request touches — enough to know what already exists, what
   contracts are already published, and who consumes them.
4. Any durable product context the repo carries: `PRODUCT.md`, `docs/product/`, RFCs, migration
   notes, operating-model docs.

You are reading for **constraints**, not for solutions. The question in your head is "what would
break if we got this wrong?", not "how would I implement this?".

## Step 2 — Classify the size

This is the decision that determines whether the rest of the phase runs. It used to happen in
Refine; it happens here now, because the routing depends on it.

| Size | Signal | This phase |
|---|---|---|
| **Small** | One module, no new contract, < ~5 files | Records the size and exits |
| **Medium** | One module, new UI or new endpoint, no cross-team contract | Records the size and exits |
| **Large** | Multiple modules, a new public or integration contract, a migration, or work you would not want to land in a single pull request | Runs in full |

**When torn between two sizes, pick the larger.** An over-structured small cycle costs a few
extra headings; an under-structured large one costs a 3,000-line review nobody does properly.

If `cycles/index.md` exists, read it before deciding. The `Validações` column is the useful one:
if cycles you sized the way you are about to size this one have been needing two or three
validation rounds, that is evidence your plans at that size are under-specified. Size up, or
break the work smaller. Writing that column and never reading it makes it bookkeeping instead
of feedback.

### If the cycle is Small or Medium

Write nothing but the size, and say so plainly:

```
Ciclo classificado como Medium — um módulo, sem contrato novo entre serviços.
A fase Capability não se aplica; ela existe para trabalho que cruza serviços.
Próximo passo: "refina o ciclo".
```

Record the size so Refine does not re-derive it. Write **only** the frontmatter block of
`capability.md` with `applies: false` — a four-line file, not a template full of empty
headings:

```yaml
---
cycle: <MMDD-slug>
size: Medium
applies: false
---

Ciclo Small/Medium — fase Capability não se aplica.
```

Then stop. Do not slide into Refine in the same breath.

### If the cycle is Large

Continue to step 3. Say which signals made it Large — "toca três módulos e publica um endpoint
novo que o app mobile vai consumir" — because that sentence is what a reviewer checks your
classification against.

## Step 3 — Restate the capability

Compress the ask into one precise statement covering three things:

- **who** the user or operator is
- **what** new capability exists after this ships
- **what outcome changes** because of it

If this statement comes out weak or hedged, the implementation will drift. A capability you
cannot state in three lines is usually two capabilities.

Write it in the human's own vocabulary where you can. This sentence gets quoted in review, and
a restatement the requester does not recognize as their own request is a restatement that has
already drifted.

## Step 4 — Resolve the constraints

This is the work. Extract the things that must hold before implementation — the ones that
usually live only in someone's head:

**Business rules and invariants.** What must be true of the system at all times, regardless of
path taken? "Um episódio nunca aparece para um usuário de outra clínica" is an invariant; it
constrains every query, every cache, and every endpoint that touches episodes.

**Scope boundaries.** What does this capability explicitly not own? Boundaries stated here are
what `plan.md`'s *Fora de escopo* inherits, and what `sdd-validate` checks against.

**Trust boundaries.** Where does data cross from trusted to untrusted, or between tenants,
services, or privilege levels? Where is each rule enforced — client, server, or both? A rule
enforced only on the client is not a rule; it is a suggestion.

**Data ownership.** Which service or table is the source of truth for each entity? Who is
allowed to write it? What is the contract, and who else already consumes it?

**Lifecycle and state transitions.** What states does the entity have, which transitions are
legal, which are irreversible, and what happens to in-flight work during each one?

**Rollout and migration.** Feature flag, gradual rollout, or straight to production? Does
existing data need to be migrated or backfilled? Is the change backwards-compatible for
consumers already in production, and if not, who has to ship first?

**Failure and recovery.** What happens when a dependency is slow, empty, or down? What is
retryable and what is not? What is the rollback story?

**Policy: auth, billing, compliance, audit.** Who may see or do this? Does it touch personal or
regulated data? What must be logged, and for how long?

### Separate the three kinds of statement

This is what makes the artifact useful in review, and it is the rule most easily lost:

| Kind | Meaning | How to mark it |
|---|---|---|
| **Fixed policy** | Non-negotiable — legal, security, contractual, or already shipped and depended upon | State it flatly, cite where it comes from |
| **Architecture preference** | A default the team leans toward, reversible with a reason | Say it is a preference and name the alternative |
| **Open** | Genuinely undecided, and implementation depends on it | Put it under *Questões em aberto* with the assumption you would proceed on |

Collapsing these three into one flat list of bullets is how a preference gets implemented as if
it were policy, and how an open question gets silently closed by whoever writes the code first.

### Separate promises from implementation

User-visible promises ("o médico vê os episódios em ordem cronológica") belong in the capability
contract. Implementation details ("guardamos o token em `localStorage`") do not — they are
Refine's business, and they change without the capability changing.

This is the same rule that governs `scenarios.feature`, applied one phase earlier.

### When the request conflicts with what exists

If the request contradicts an existing repo constraint — a published contract, a documented
invariant, a compliance rule — **say so clearly instead of smoothing it over.** Show both: what
the request asks for, and what the repo currently guarantees. Then put it under *Questões em
aberto* as a blocking decision.

A conflict discovered here costs a conversation. The same conflict discovered during
implementation costs the implementation.

## Step 5 — Write capability.md

Use `assets/capability.md`. Write it in the language the human used in `request.md` —
Portuguese by default here.

Read `references/constraints.md` before writing if you want worked examples of a constraint
stated well versus stated uselessly. The difference between "precisa ser seguro" and "um
episódio nunca é retornado para um usuário de outra clínica; enforcement no servidor, na query"
is the difference between an artifact that shapes the plan and one that decorates it.

Leave a section empty rather than filling it with plausible-sounding content. An empty
**Rollout** heading is honest and reviewable; an invented one is a constraint nobody agreed to
that the plan will inherit as if they had.

## Step 6 — Hand off

This phase has no human gate of its own. The gate is still Refine's, and it is still the
approval of `plan.md` — adding a second gate here would double the review cost for one
artifact that the plan is about to restate anyway.

But this phase does end in a **decision**, and it belongs to the human. End with the handoff
stated explicitly, in exactly one of these three forms:

| Handoff | When | Next |
|---|---|---|
| **Pronto para refinar** | Constraints resolved, no blocking open questions | `sdd-refine` |
| **Precisa de revisão de arquitetura** | The constraints are clear but a structural decision exceeds this cycle's authority | A human architecture decision, then `sdd-refine` |
| **Precisa de decisão de produto** | A blocking open question that only the requester can answer | The human answers, then `sdd-refine` |

Never report "pronto para refinar" while a blocking question is open. The point of naming the
handoff is that it is the one line a busy reader trusts — and a handoff that says "ready" when
it is not is worse than no handoff, because it will be believed.

If there are open questions that are **not** blocking, carry them forward: `sdd-refine` folds
them into its single question message rather than asking them again. Say which ones you are
handing over, so they do not get asked twice or dropped entirely.

## What this phase is not

**It is not a second planning stack.** If you find yourself writing an ordered list of files to
change, you have crossed into `tasks.md`. Stop.

**It is not a design document.** Component structure, class names, and CSS strategy are
implementation. This artifact should survive a complete rewrite of the implementation without
needing an edit.

**It is not a question round.** `sdd-refine` owns the one-message question rule, and it owns it
because the human's attention is the scarcest thing in the loop. If your constraint-gathering
turns up questions, record them — do not open a second interrogation. The one exception is a
question so blocking that the artifact cannot be written at all without it; ask that one, and
say why it could not wait.

## When the state is broken

| Symptom | Likely cause | What to do |
|---|---|---|
| No `request.md` in the cycle folder | Start never ran | Return to `sdd-start`. Do not write the request yourself and derive constraints from it in the same breath — you would be extracting constraints from your own understanding rather than the human's. |
| `plan.md` already exists | Refine already ran | **PARE.** Ask whether they want the capability mapped retroactively (useful — it often reveals what the plan assumed silently) or to continue with `sdd-implement`. Do not rewrite the plan from here. |
| `capability.md` exists with `applies: false` and the user is asking for constraints anyway | Size was classified as Small/Medium | Not an error. Ask whether the cycle grew. If it did, re-classify to Large, say what changed, and run in full — cycles do grow, and a stale classification is worth correcting. |
| `capability.md` exists and is filled in | This phase ran before | Not an error. Update it rather than overwriting from scratch — the human may have edited it. Say which sections you changed. |
| The request is a typo fix, dependency bump, or a question | Ceremony applied to trivia | Say so and just do the work. No cycle, no capability. |
| No `spec/` directory anywhere in the repo | Project never had one | Not an error, but say so. Constraints you would have checked against the spec are now unverified assumptions — mark them as inferred rather than stating them flatly. |
| The request spans what are clearly two capabilities | Scope not yet split | Say so and show the split. Two capabilities in one cycle produce a plan whose *Fora de escopo* cannot hold, because the boundary runs through the middle of the work. |

The rule underneath these: **when the filesystem contradicts itself, the human resolves it, not
you.** Every one of these states is cheap to fix by asking and expensive to fix after acting on
a guess.

## When a cycle is the wrong tool

A one-line typo fix, a dependency bump, a question about existing code, or exploratory spiking
does not need a cycle, and certainly does not need a capability map. Say so and do the work.

This skill is invocable on its own, without passing through the `sdd` orchestrator, so this
judgment has to be made here — nobody upstream will make it for you.

## Closing report

**Small or Medium — the phase correctly did nothing:**

```markdown
**Fase:** Capability — ok
**Resultado:** Ciclo classificado como <Small|Medium>. Fase não se aplica.
**Artefatos:** capability.md (só a classificação)
**Próximo passo:** "refina o ciclo"
```

**Large — the phase ran:**

```markdown
**Fase:** Capability — <ok | atenção | erro>
**Resultado:** Ciclo Large. <N> invariantes, <N> fronteiras de confiança, <N> questões em aberto. Handoff: <pronto para refinar | revisão de arquitetura | decisão de produto>.
**Artefatos:** capability.md
**Próximo passo:** <"refina o ciclo" | a decisão específica que você está aguardando>
```

Use `atenção` whenever there is a blocking open question or a conflict with an existing repo
constraint. Those are the two findings that change what happens next, and burying either one in
the body of the artifact is how it gets read past.

## Files

- `assets/capability.md` — the artifact template
- `references/constraints.md` — worked examples: constraints stated well vs. uselessly, and the
  fixed/preference/open distinction with cases

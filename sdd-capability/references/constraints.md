# Writing constraints that are worth writing

Read this before filling in `capability.md`. The rule "record the constraints" does not survive
contact with a real request on its own — the failure mode is not forgetting to write
constraints, it is writing constraints that are true, agreeable, and useless.

## The test

A constraint earns its place if it can **change what someone builds**.

> "O sistema precisa ser seguro."

Nobody disagrees, nobody can act on it, and no implementation is excluded by it. It is a value,
not a constraint. Delete it.

> "Um episódio nunca é retornado para um usuário de outra clínica. Garantido no servidor, na
> query — não por filtro no cliente."

This one excludes implementations. It tells you the filter cannot live in the frontend, it tells
you the query needs the clinic scope, and it gives a reviewer something to check. That is a
constraint.

Apply the test line by line: **if the opposite is absurd, the line is not a constraint.** "Os
dados precisam estar corretos" has no meaningful opposite. "Um episódio cancelado continua
visível no histórico, mas nunca na timeline ativa" does.

## Well stated vs. uselessly stated

| Useless | Useful |
|---|---|
| Precisa ter boa performance | A timeline carrega até 500 episódios sem paginação; acima disso o comportamento não está definido — ver questões em aberto |
| Precisa respeitar permissões | Download de documento só para papel `admin`; garantido no servidor, no endpoint, não escondendo o botão |
| Tratar erros adequadamente | API fora do ar mostra estado de erro com ação de repetir; nunca lista vazia, que é indistinguível de "paciente sem episódios" |
| Deve ser compatível | O endpoint `/episodes` já é consumido pelo app mobile v2.3; adicionar campo é seguro, renomear ou remover exige o mobile subir primeiro |
| Os dados são sensíveis | Episódio contém dado de saúde: acesso auditado com usuário, paciente e timestamp; retenção do log por 5 anos |

The pattern in the right column: **a number, a place where it is enforced, or a named
consequence.** A constraint without at least one of those three cannot be verified, and a
constraint nobody can verify will not be respected.

## The three kinds, and why mixing them is expensive

Every line in the artifact is one of three things. The reader has to be able to tell which,
because the cost of being wrong differs by an order of magnitude between them.

### Fixed policy

Non-negotiable. Legal, security, contractual, or already shipped and depended upon by someone
else. Changing it is not this cycle's decision and probably not this team's.

> Dado de saúde não sai da região `sa-east-1`. Restrição contratual, `docs/compliance/lgpd.md`.

State it flatly and **cite where it comes from.** A policy without a source gets challenged in
review by someone who suspects it is actually a preference — and the citation is what ends that
conversation in ten seconds instead of a meeting.

### Architecture preference

A default the team leans toward. Reversible, given a reason.

> Preferimos estender o `<ehr-module>` existente em vez de criar um componente novo.
> Alternativa: componente independente, se a timeline precisar de um ciclo de vida próprio.

Always **name the alternative and the condition that would flip it.** A preference written
without its alternative reads exactly like policy, and gets implemented as if it were — which is
how a reversible default hardens into an unquestioned constraint that nobody remembers choosing.

### Open

Genuinely undecided, and the implementation depends on the answer.

> **Episódio cancelado aparece na timeline?** — BLOQUEIA — assumindo: não aparece, mas continua
> acessível pelo histórico.

Two things are mandatory here: whether it **blocks**, and the **assumption you would proceed
on**. An open question without an assumption is a question that stalls the cycle. An open
question without a blocking flag makes the handoff line unreliable, and the handoff line is the
one thing a busy reader trusts.

### What mixing them costs

Flatten the three into one bullet list and both failure directions happen at once. A preference
gets treated as policy, so nobody challenges a choice that was always negotiable. An open
question gets treated as decided, closed silently by whoever writes that file first — and it
surfaces in review as "wait, when did we decide that?", which is the most expensive moment to
discover it.

## Promises vs. implementation

The same rule that governs `scenarios.feature`, applied one phase earlier.

**A user-visible promise belongs here:**

> O médico vê os episódios em ordem cronológica decrescente, o mais recente primeiro.

**An implementation detail does not:**

> Os episódios são ordenados no cliente com `Array.prototype.sort` sobre o campo `startedAt`.

The second one is `sdd-refine`'s business and it can change without the capability changing.
The test is mechanical: **would this line need editing if the implementation were rewritten from
scratch, with identical user-visible behavior?** If yes, it is implementation — move it out.

That test is also why the artifact stays useful across cycles. The implementation gets replaced;
the promise is what the next person needs to not break.

## Invariants deserve extra care

An invariant is the strongest thing in the artifact: true at all times, on every path, not just
on the happy one. Most of what gets written under "invariantes" is actually a happy-path
behavior wearing the word.

> A lista mostra os episódios do paciente.

That is a behavior. It holds when things work.

> Um episódio nunca é visível para um usuário fora da clínica que o criou — nem em cache, nem em
> resposta de erro, nem em log.

That is an invariant. It constrains the error paths, the caching layer, and the logging, which
is exactly where the behavior version silently stops applying.

**Where an invariant is enforced is part of the invariant.** "Garantido no servidor, na query"
excludes an entire class of implementation. "Garantido no cliente" usually means it is not
guaranteed at all — a client-side rule is a suggestion, because the client is the part of the
system you do not control.

## When the request conflicts with what exists

This is the highest-value thing this phase can find, and the easiest to smooth over — because
smoothing it over feels helpful and cooperative in the moment.

Do not resolve it. **Show both sides and mark it blocking:**

> **Conflito.** O request pede que o episódio seja editável depois de fechado.
> `spec/features/episodes/readme.md` afirma que episódio fechado é imutável, e o serviço de
> faturamento depende disso para reconciliação.
> — BLOQUEIA — precisa de decisão de produto.

The temptation is to pick the reading that makes the request implementable and move on. Resist
it. A conflict surfaced here costs one conversation; the same conflict discovered during
implementation costs the implementation, and discovered after release it costs whoever depended
on the invariant you quietly broke.

## Empty sections

Leave a section empty rather than filling it with something plausible.

An empty **Rollout e migração** heading is honest: it says nobody has thought about it yet, and
a reviewer can see that and decide whether it matters. A plausible invented one — "rollout
gradual com feature flag" when nobody decided that — is a constraint nobody agreed to, and
`plan.md` will inherit it as though they had.

The artifact's whole value is that a reader can tell decided from assumed. Filling gaps with
reasonable-sounding content destroys exactly that property, and it does it invisibly.

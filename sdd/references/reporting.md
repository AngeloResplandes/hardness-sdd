# Closing report format

Shared by every phase skill. Each one ends its run with this block, in the human's language.

The point is that the user should never have to read prose to find out whether they can
proceed. A phase either finished, finished with something worth knowing, or stopped — and the
next action is either theirs or yours. Those two facts belong in a fixed place.

## The block

```markdown
**Fase:** <nome> — <ok | atenção | erro>
**Resultado:** <uma linha>
**Artefatos:** <paths tocados, ou "nenhum">
**Próximo passo:** <o comando exato que o usuário deve dar, ou o que você está aguardando>
```

## The status values

| Status | Meaning | Next step points at |
|---|---|---|
| **ok** | The phase did what it was for | The next phase |
| **atenção** | It finished, but something needs a human decision — open questions, `NÃO VERIFICADO` scenarios, a divergence from the plan | The decision, stated as a question |
| **erro** | It stopped without finishing | What has to be fixed first |

`atenção` is the one that earns its keep. A phase that technically completed while leaving
three assumptions unverified is not the same as one that completed cleanly, and collapsing
both into "pronto" is how unreviewed assumptions reach production.

## Rules

**Próximo passo is a command, not a direction.** "implementa o ciclo" is actionable;
"prossiga para a implementação" makes the user go find out how. When the next move is the
human's — a gate, a decision, a correction — say what you are waiting for, explicitly.

**Never report `ok` on a phase that stopped.** A stop is `erro`, even when stopping was the
correct behavior. The status describes whether the phase completed, not whether you behaved
well.

**Artefatos lists what you actually wrote**, not what you intended to write. This is what a
future session reads to reconstruct where things stopped.

## Example

```markdown
**Fase:** Validate — atenção
**Resultado:** 11 de 12 cenários verificados; "filtro por status" ficou NÃO VERIFICADO.
**Artefatos:** cycles/Q32026/0726-episodes-list/validation.md
**Próximo passo:** decidir se o cenário não verificado bloqueia a promoção — se sim,
volto para a implementação; se não, me diga e eu registro como lacuna conhecida.
```

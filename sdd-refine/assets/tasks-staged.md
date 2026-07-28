# Tarefas — <nome da feature>

<!--
Checklist em estágios, para ciclos Large.
Ciclos Small e Medium usam tasks.md (lista plana, sem estágios).

Cada "## Stage N" é revisável e mergeável de forma independente: ao terminar
um estágio, a fase Implement para e mostra o que entregou. Um estágio que não
faz sentido sozinho não é um estágio — junte com o vizinho.

A ordem importa — cada tarefa assume que as anteriores já existem.

A última tarefa é sempre a promoção da spec, verbatim, fora de qualquer
estágio, e é a única que a fase Implement não marca. Não acrescente nada
depois dela: Validate e Promote são fases, não tarefas.
-->

## Stage 1 — <nome do estágio>

- [ ] <tarefa concreta, citando arquivo/módulo>
- [ ] <tarefa concreta>
- [ ] <teste que cobre o cenário X de scenarios.feature>

## Stage 2 — <nome do estágio>

- [ ] <tarefa concreta>
- [ ] <teste que cobre o cenário Y>

---

- [ ] Promover `spec-delta.md` para `spec/` (fase Promote — só após Validate passar)

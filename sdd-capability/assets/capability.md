---
cycle: <MMDD-slug>
size: Large
applies: true
handoff: pronto para refinar | revisão de arquitetura | decisão de produto
---

# Capacidade — <nome da capacidade>

<!--
O que precisa ser VERDADE antes da implementação começar.
Não é plano, não é lista de tarefas, não é design de componente.

Este arquivo deve sobreviver a uma reescrita completa da implementação
sem precisar de edição. Se uma linha aqui quebra quando alguém troca de
framework, ela é implementação e está no arquivo errado.
-->

## Capacidade

<!-- Uma frase precisa, cobrindo três coisas:
     quem é o usuário/operador · o que passa a existir depois disso ir para produção ·
     que resultado muda por causa disso.

     Se você não consegue dizer em três linhas, provavelmente são duas capacidades. -->

## Atores e superfícies

<!-- Quem interage com isso, e por onde.
     Papéis de usuário, serviços consumidores, jobs, operadores. -->

| Ator | Superfície | O que faz |
|---|---|---|
|  |  |  |

## Invariantes

<!-- O que precisa ser verdade SEMPRE, independente do caminho percorrido.
     Cada um com o ponto onde é garantido (cliente, servidor, banco).
     Regra garantida só no cliente não é regra, é sugestão. -->

- **<invariante>** — garantido em: <onde>

## Fronteiras de confiança

<!-- Onde o dado cruza de confiável para não confiável, entre tenants,
     entre serviços, ou entre níveis de privilégio. -->

-

## Propriedade dos dados

<!-- Qual serviço/tabela é fonte da verdade para cada entidade,
     quem pode escrever, qual o contrato, e quem já consome. -->

| Entidade | Fonte da verdade | Quem escreve | Quem consome |
|---|---|---|---|
|  |  |  |  |

## Estados e transições

<!-- Estados da entidade, quais transições são legais, quais são
     irreversíveis, e o que acontece com trabalho em andamento. -->

| De | Para | Gatilho | Reversível? |
|---|---|---|---|
|  |  |  |  |

## Interfaces

<!-- O contrato que cruza a fronteira: endpoints, eventos, props,
     payloads. Forma de entrada e de saída. Quem versiona.
     O que quebra downstream se mudar depois. -->

-

## Política — auth, billing, compliance, auditoria

<!-- Quem pode ver ou fazer, e onde isso é garantido.
     Dado pessoal ou regulado? O que precisa ser auditado? -->

-

## Rollout e migração

<!-- Feature flag, rollout gradual, ou direto para produção?
     Dado existente precisa de migração ou backfill?
     É retrocompatível para quem já consome? Se não, quem sobe primeiro? -->

-

## Falha e recuperação

<!-- Dependência lenta, vazia ou fora do ar: o que acontece?
     O que é retentável. Qual a história de rollback. -->

-

## Fora de escopo desta capacidade

<!-- O que esta capacidade explicitamente NÃO possui.
     É daqui que o `Fora de escopo` do plan.md deriva. -->

-

## Preferências de arquitetura

<!-- Defaults que o time prefere, mas que são reversíveis com um motivo.
     NÃO são política fixa — marque a alternativa. -->

- **<preferência>** — alternativa: <alternativa>, revertível se <condição>

## Questões em aberto

<!-- Genuinamente indecidido, e a implementação depende.
     Marque quais BLOQUEIAM: sem elas o refino não pode começar.

     Uma questão registrada aqui não deve ser perguntada de novo pelo
     sdd-refine — ele lê este arquivo antes de montar a mensagem dele. -->

- **<pergunta>** — <BLOQUEIA | não bloqueia> — assumindo: <premissa>

## Conflitos com o que já existe

<!-- Onde o request contradiz um contrato publicado, um invariante
     documentado, ou uma regra de compliance. Mostre os dois lados.
     Se não houver, escreva "Nenhum." -->

-

## Handoff

<!-- Exatamente um dos três, e o motivo em uma linha. -->

**<pronto para refinar | precisa de revisão de arquitetura | precisa de decisão de produto>**
— <motivo em uma linha>

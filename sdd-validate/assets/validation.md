---
result: pass | fail
attempt: <N>
validated_at: <yyyy-mm-dd>
---

<!--
attempt NÃO é sempre 1. Antes de escrever este arquivo, leia o attempt do
validation.md que já existe no ciclo e some 1. Só é 1 se o arquivo não existia.
Reescrever o arquivo a partir deste template sem ler o valor anterior zera o
contador — e é ele que vira a coluna "Validações" do cycles/index.md.
-->

# Validação — <slug do ciclo>

## Tarefas

<!-- N/N concluídas, exceto a promoção da spec (fase seguinte).
     Qualquer item não marcado é falha automática — liste-o. -->

-

## Cenários

<!-- Um por linha de scenarios.feature. "Como foi verificado" aceita três
     respostas: um teste automatizado (cite arquivo:linha), uma verificação
     manual que você realmente fez, ou NÃO VERIFICADO.
     Não infira aprovação porque o código "parece certo". -->

| Cenário | Como foi verificado |
|---|---|
|  |  |

## Suíte de testes

<!-- Comando real e saída real. Se o repo não tem suíte, diga isso
     explicitamente em vez de omitir a linha. -->

`<comando>` — <resultado>

## Resolvido desde a última validação

<!-- Só a partir da tentativa 2. Uma linha por lacuna da rodada anterior,
     com como você verificou que fechou. Lacuna ainda aberta não some daqui:
     ela continua listada em Pendências. -->

- N/A (primeira validação).

## Divergências do plano

<!-- Cada divergência foi refletida em plan.md/spec-delta.md, ou está
     registrada como lacuna conhecida. Divergência não documentada é falha. -->

- Nenhuma.

## Fora de escopo

<!-- Confirmação de que nada listado como fora de escopo foi entregue. -->

- Respeitado.

## Pendências

- Nenhuma.

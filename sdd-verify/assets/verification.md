---
result: pass | fail
verified_at: <yyyy-mm-dd>
server: <url base, ou n/a>
method: playwright | cypress | mcp | manual | n/a
---

# Verificação de runtime — <slug do ciclo>

<!--
EVIDÊNCIA, não julgamento. Esta fase registra o que foi observado;
quem decide se isso satisfaz os cenários é a fase Validate.

Regra única: observado ou NÃO VERIFICADO. Código que "parece certo"
não é evidência. Servidor que subiu não é evidência de que a tela funciona.
-->

## Comandos

<!-- De onde vieram: plan.md, spec/architecture.md, package.json, ou perguntado. -->

- Servidor: `<comando>` — <url>  (fonte: <onde>)
- Testes: `<comando>`  (fonte: <onde>)
- E2E: `<comando ou "não há">`

## Suíte de testes

<!-- Comando real e saída real. Falha vai com o texto do erro, não resumida. -->

`<comando>` — <N passed, M failed>

<!-- Se falhou:
```
<saída real da falha>
```
-->

## Servidor

<!-- A porta é a que o servidor imprimiu, não a que você inferiu. -->

- Subiu em: <url>
- Tempo até responder: <~Ns>
- Encerrado ao fim da fase: sim

## Cenários exercitados

<!-- Um por cenário de scenarios.feature. "Como foi observado" aceita:
     passo automatizado (cite o arquivo), verificação manual confirmada pelo
     humano (diga que foi ele), ou NÃO VERIFICADO com o motivo. -->

| Cenário | Como foi observado | Resultado |
|---|---|---|
|  |  |  |

## Console do navegador

<!-- Página que renderiza lançando erro não está funcionando —
     está falhando em silêncio. -->

- Sem erros. / ou: <lista>

## Observações

<!-- Coisas notadas fora do escopo dos cenários. Registre; não conserte,
     e não reprove o ciclo por elas. -->

- Nenhuma.

## Não verificado

<!-- Cenários que não deu para exercitar, com o motivo.
     Resposta legítima. Omitir não é. -->

- Nenhum.

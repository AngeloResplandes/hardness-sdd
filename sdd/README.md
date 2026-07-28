# SDD — Harness de Spec-Driven Development

Um **conjunto de skills** para o [Claude Code](https://claude.com/claude-code), não uma skill
só. Transforma uma ideia solta em código passando por um plano revisável — com um portão
humano antes de qualquer linha ser escrita. A revisão acontece no artefato mais barato de
consertar: um plano de 40 linhas, não 2.000 linhas de código.

## O problema

Quando você pede "implementa uma lista de episódios" direto pro agente, três coisas dão
errado:

- ele adivinha em silêncio os requisitos que você não disse;
- ninguém consegue revisar o resultado, porque não existe um *contra o quê*;
- a documentação do projeto vai ficando defasada em relação ao código.

O ganho real não é processo — é que o agente passa a ter um alvo escrito e verificável, e
você deixa de ser o único lugar onde o requisito existe.

## As skills

| Skill | Fase | Faz |
|---|---|---|
| **`sdd`** | — | Orquestrador. Detecta em que fase o ciclo está e chama a skill certa. |
| **`sdd-start`** | 1 | Abre a pasta do ciclo e escreve o `request.md`. |
| **`sdd-refine`** | 2 + 3 | Pergunta tudo, escreve os 4 artefatos, **para** no portão e registra a aprovação. |
| **`sdd-implement`** | 4 | Executa o `tasks.md` de cima pra baixo. |
| **`sdd-validate`** | 5 | Confere tudo contra o repo real e gera `validation.md`. |
| **`sdd-promote`** | 6 | Aplica o delta em `spec/`. É a única que escreve lá. |

Cada uma é invocável sozinha. Você não precisa passar pelo orquestrador: "valida o ciclo"
carrega `sdd-validate` direto. E não precisa decorar nada — as descriptions cobrem o jeito
como você já fala.

A **fase 3 não tem skill** de propósito. Ela não é trabalho que se faz, é trabalho pra onde
se **para**. Quem levanta o portão e quem registra a aprovação é a `sdd-refine`.

## Como funciona

```
  VOCÊ escreve          CLAUDE pergunta        VOCÊ revisa       CLAUDE executa
      │                       │                     │                  │
  request.md  ──────►  plan.md + tasks.md  ──────►  ✋ APROVA  ──────►  código
   sdd-start           scenarios.feature          (portão)         sdd-implement
                       spec-delta.md                                    │
                        sdd-refine                                      ▼
                                                                  validation.md
                                                                   sdd-validate
                                                                        │
                                                                        ▼
                                                                  spec/ atualizado
                                                                   sdd-promote
```

Duas camadas de documento, na mesma relação que *migrations* têm com o *schema* de um banco.
Ciclos acumulam; a spec continua única e correta.

| | Onde | O que é |
|---|---|---|
| **Ciclo** | `cycles/Q32026/0726-slug/` | Efêmero. Uma mudança. Um delta. Fica no histórico como arqueologia do *porquê*. |
| **Spec** | `spec/` | Permanente. O estado atual do sistema. Sempre verdadeiro. |

## Os invariantes

1. **`spec/` tem exatamente um escritor: a `sdd-promote`.** O refino escreve a proposta em
   `spec-delta.md` e para. Promover antes de validar faria a spec afirmar comportamento que
   ainda não existe no código.
2. **Nada de implementação antes de um humano aprovar o `plan.md`.** O portão fica gravado no
   arquivo (`status: approved`), não na memória da conversa — sobrevive a sessão nova.
3. **O refino pergunta tudo em UMA mensagem.** Quinze rodadas de "e se a lista estiver vazia?"
   queimam o recurso mais escasso do fluxo: sua atenção.
4. **`scenarios.feature` descreve o que o usuário vive, nunca como aquilo é construído.**

## Instalação

Copie as seis pastas (`sdd`, `sdd-start`, `sdd-refine`, `sdd-implement`, `sdd-validate`,
`sdd-promote`) para um dos dois lugares:

```bash
# pessoal — vale em todos os seus projetos
~/.claude/skills/

# ou por projeto — versionado junto com o repo
<seu-repo>/.claude/skills/
```

Não tem build nem instalação: são arquivos markdown.

---

# Guia de uso

## Começar um ciclo

```
preciso de um webcomponent <ehr-episodes-list> que mostre os episódios do
paciente em timeline na aba Histórias, com filtro por data e status e download
de documentos. Sem iframe, Shadow DOM, mesmo padrão de auth do <ehr-module>.
```

Dispara sozinha quando você diz isso, ou "vamos construir X", ou "nova feature".

O Claude cria a pasta do ciclo e escreve o `request.md` a partir do que você falou.
**Leia e corrija.** É o único documento que é seu; tudo depois deriva dele.

## Refinar

```
refina o ciclo
```

Ele manda **uma mensagem só** com todas as perguntas, agrupadas e numeradas.

Responda tudo de uma vez. É pra isso que serve o formato — você paga um custo de contexto em
vez de quinze. Se ele sugerir defaults, dá pra responder assim:

> todos os defaults, exceto 3 (paginação: botão "carregar mais") e 7 (só admin vê o download)

Não sabe alguma? Diga "não sei ainda". Ele registra em **Open questions** no `plan.md` com a
premissa que está assumindo. Premissa escrita é revisável; premissa na cabeça dele não é.

## O portão de aprovação ✋

Ele para e pede sua revisão. **Este é o momento que paga o processo inteiro.** Leia os
arquivos com atenção:

- **`plan.md`** — a seção *Fora de escopo* é a mais importante: é ela que segura scope creep
  na implementação. E confira *Estado atual*, onde você costuma descobrir que a spec já estava
  errada.
- **`scenarios.feature`** — se você discorda de um cenário, o código ia sair errado. Corrigir
  aqui custa uma linha.
- **`tasks.md`** — a ordem importa. Se algo parece grande demais pra uma tarefa, é.

Ele termina o refino te devolvendo as **duas ou três decisões mais consequentes** do plano
como uma pergunta direta:

```
Confirmo antes de implementar:
1. Sem paginação no MVP — a lista carrega todos os episódios de uma vez.
2. O download de documentos aparece só para admin.
3. Falha da API mostra estado de erro com botão "tentar de novo", não um toast.
```

Isso é de propósito. Dá pra digitar "aprovado" sem ler um plano; não dá pra confirmar três
afirmações específicas sem ler pelo menos aquelas três. Se alguma veio de uma premissa dele em
vez de uma resposta sua, ele marca qual — são justamente as mais prováveis de estarem erradas.

Aprove dizendo:

```
aprovado, pode implementar
```

Ele marca `status: approved` no `plan.md`. O portão fica gravado **no arquivo**, então amanhã,
num terminal novo, ele ainda sabe que você aprovou.

Quer mudanças antes? Só falar: "muda o cenário 3 pra X" / "tira o filtro por data do escopo".

## Implementar

```
implementa o ciclo
```

Em ciclos **Large**, ele para no fim de cada `## Stage N` e mostra o que entregou. Revise e
mande seguir. É de propósito: revisar 300 linhas três vezes funciona; revisar 3.000 de uma
vez, não.

Se o plano se revelar errado no meio do caminho, ele para e avisa em vez de improvisar.

## Validar

```
valida o ciclo
```

Gera `validation.md` percorrendo cada cenário e registrando *como* foi verificado — teste
automatizado, verificação manual, ou `NÃO VERIFICADO`. Rodar a suíte é parte do checklist.

`result: fail` é resultado normal — é o checkpoint funcionando. As lacunas viram tarefas de
verdade no `tasks.md`, numa seção `## Correções — validação N` (o `N` é o número da tentativa,
então cada rodada ganha a sua), e qualquer tarefa que estava marcada sem estar pronta é
**desmarcada**. Aí é só mandar `implementa o ciclo` de novo: ele trabalha só as lacunas da
rodada atual, não a checklist inteira.

Cada rodada incrementa `attempt:` no `validation.md` e registra o que foi resolvido desde a
anterior. Se um ciclo chega na terceira validação, o sinal não é sobre a implementação — é
sobre o plano.

## Promover a spec

```
promove a spec
```

Só roda se `validation.md` estiver `pass`. Aplica o `spec-delta.md` dentro de `spec/`,
escrevendo o **estado novo** (sem "antes era X", sem changelog — isso já está no ciclo e no
git), marca o delta como promovido e fecha a última tarefa.

Também acrescenta uma linha em `cycles/index.md`: ciclo, tamanho, nº de cenários, quantas
validações foram necessárias, data. Custa uma linha por ciclo e é o único lugar onde dá pra
ver o processo se comportando ao longo do tempo — uma coluna de `3` em *Validações* diz que o
refino está produzindo planos que não sobrevivem ao contato com o código.

## Como toda fase termina

Independente da fase, a última coisa que ele escreve tem sempre a mesma forma:

```
**Fase:** Validate — atenção
**Resultado:** 11 de 12 cenários verificados; "filtro por status" ficou NÃO VERIFICADO.
**Artefatos:** cycles/Q32026/0726-episodes-list/validation.md
**Próximo passo:** decidir se o cenário não verificado bloqueia a promoção.
```

Você nunca precisa ler um parágrafo pra descobrir se pode seguir. Três estados:

- **ok** — a fase fez o que devia, o próximo passo é a fase seguinte.
- **atenção** — terminou, mas tem coisa pra você decidir: premissa não confirmada, cenário não
  verificado, divergência do plano.
- **erro** — parou sem terminar, e o *Próximo passo* diz o que destrava.

O **atenção** é o que mais paga. Uma fase que terminou deixando três premissas por verificar
não é a mesma coisa que uma que terminou limpa, e juntar as duas em "pronto" é exatamente como
premissa não revisada chega em produção.

## Perdeu o fio

```
onde parei?
```

O orquestrador detecta a fase pelo estado dos arquivos, não pela memória da conversa. Funciona
em sessão nova, em outra máquina, três semanas depois.

Se ele encontrar um estado **contraditório** — `plan.md` sem `status`, plano em `draft` com
tarefas já marcadas, `validation.md` dizendo `pass` com tarefas em aberto — ele para e te
devolve o problema em vez de escolher uma interpretação. Arquivo editado à mão e sessão que
morreu no meio da escrita são as causas comuns, e adivinhar qualquer uma delas custa muito
mais caro do que perguntar.

---

## Erros comuns

**Aprovar o plano sem ler direito.** O portão só vale se você usar. Aprovar no automático
transforma o processo em burocracia pura — todo o custo, nenhum benefício.

**Escrever plano ou tarefas dentro do `request.md`.** O `request.md` é o *problema*. Se você já
entrega a solução pronta ali, elimina justamente a parte em que o refino descobre o que você
não tinha pensado.

**Editar a pasta do ciclo depois de fechado.** Ela é o registro histórico de por que a spec diz
o que diz. Mudou de ideia? Ciclo novo, delta novo.

**Cenário descrevendo implementação.** `Então a chave "ehr_token" é gravada no localStorage`
quebra numa refatoração que não mudou nada pro usuário. O certo é `Então ele continua vendo a
lista sem precisar logar de novo`.

**Usar ciclo pra tudo.** Correção de typo, bump de dependência, pergunta sobre código: não
precisa de ciclo. Cerimônia aplicada a trivialidade é como processo bom morre. O harness sabe
disso e vai te dizer.

---

## Estrutura

O que o harness contém:

```
.claude/skills/
├── sdd/                    # orquestrador
│   ├── SKILL.md            # camadas, invariantes, detecção de fase, roteamento
│   ├── README.md           # este arquivo
│   └── references/
│       ├── naming.md       # nome de pasta, trimestre, slug, resolução do ciclo atual
│       └── reporting.md    # formato do relatório de fechamento
├── sdd-start/
│   ├── SKILL.md
│   └── assets/request.md
├── sdd-refine/
│   ├── SKILL.md            # perguntas, artefatos, portão, registro da aprovação
│   ├── references/
│   │   ├── questions.md    # o conjunto de perguntas da fase 2
│   │   └── gherkin.md      # cenário de negócio vs. de implementação
│   └── assets/             # plan.md, scenarios.feature, tasks.md,
│                           # tasks-staged.md, spec-delta.md
├── sdd-implement/
│   └── SKILL.md
├── sdd-validate/
│   ├── SKILL.md
│   └── assets/validation.md
└── sdd-promote/
    └── SKILL.md
```

O que ele gera no seu projeto:

```
seu-repo/
├── cycles/
│   ├── index.md                     ← uma linha por ciclo fechado (sdd-promote)
│   └── Q32026/
│       └── 0726-episodes-list-webcomponent/
│           ├── request.md          ← você escreve       (sdd-start)
│           ├── plan.md             ← draft → approved   (sdd-refine)
│           ├── scenarios.feature   ←                    (sdd-refine)
│           ├── tasks.md            ←                    (sdd-refine)
│           ├── spec-delta.md       ← proposta → aplicada (sdd-refine → sdd-promote)
│           └── validation.md       ←                    (sdd-validate)
└── spec/
    ├── architecture.md
    └── features/
        └── episodes-list/
            └── readme.md           ← só a sdd-promote escreve aqui
```

## Idioma

Instruções do agente em inglês (melhor adesão do modelo); artefatos gerados em português.

## Origem

Adaptado de um fluxo de SDD originalmente escrito para o Cursor, depois reestruturado de uma
skill monolítica (`spec-cycle`) para um conjunto de skills por fase.

As inconsistências do original foram corrigidas:

- **A separação entre proposta e promoção de spec.** O fluxo original se contradizia: uma nota
  dizia que o refino *não* promove pra `spec/`, mas a última linha das próprias instruções
  mandava promover — e o agente obedeceria a instrução, não a nota. O efeito seria a spec
  canônica afirmando comportamento que ainda não existe no código. Agora a regra é estrutural:
  só a `sdd-promote` tem essa instrução.
- **`validate-cycle` e `update-spec` eram citados mas nunca definidos.** Agora são skills
  reais, com checklist e formato de saída.
- **O portão humano virou estado em arquivo**, não um acordo verbal que evapora quando a sessão
  fecha.
- **Tamanho do ciclo ganhou critério objetivo.** O original mandava usar stages em ciclos
  "Large" sem definir Large.
- **Os cenários Gherkin ganharam exemplos bons e ruins** — a regra "não descreva implementação"
  sozinha não segura o modelo.

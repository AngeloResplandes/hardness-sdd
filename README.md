# spec-cycle

Skill de **Spec-Driven Development** para o [Claude Code](https://claude.com/claude-code).

Transforma uma ideia solta em código passando por um plano revisável — com um portão
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

## Como funciona

```
  VOCÊ escreve          CLAUDE pergunta        VOCÊ revisa       CLAUDE executa
      │                       │                     │                  │
  request.md  ──────►  plan.md + tasks.md  ──────►  ✋ APROVA  ──────►  código
                       scenarios.feature          (portão)              │
                       spec-delta.md                                    ▼
                                                                   validation.md
                                                                        │
                                                                        ▼
                                                                  spec/ atualizado
```

Duas camadas de documento, na mesma relação que *migrations* têm com o *schema* de um banco.
Ciclos acumulam; a spec continua única e correta.

| | Onde | O que é |
|---|---|---|
| **Ciclo** | `cycles/Q32026/0726-slug/` | Efêmero. Uma mudança. Um delta. Fica no histórico como arqueologia do *porquê*. |
| **Spec** | `spec/` | Permanente. O estado atual do sistema. Sempre verdadeiro. |

## Os invariantes

1. **`spec/` tem exatamente um escritor: a fase Promote.** O refino escreve a proposta em
   `spec-delta.md` e para. Promover antes de validar faria a spec afirmar comportamento que
   ainda não existe no código.
2. **Nada de implementação antes de um humano aprovar o `plan.md`.** O portão fica gravado
   no arquivo (`status: approved`), não na memória da conversa — sobrevive a sessão nova.
3. **O refino pergunta tudo em UMA mensagem.** Quinze rodadas de "e se a lista estiver
   vazia?" queimam o recurso mais escasso do fluxo: sua atenção.
4. **`scenarios.feature` descreve o que o usuário vive, nunca como aquilo é construído.**

## Instalação

Copie a pasta para um dos dois lugares:

```bash
# pessoal — vale em todos os seus projetos
~/.claude/skills/spec-cycle/

# ou por projeto — versionado junto com o repo
<seu-repo>/.claude/skills/spec-cycle/
```

Não tem build nem instalação: são arquivos markdown.

---

# Guia de uso

## Começar um ciclo

```
/spec-cycle preciso de um webcomponent <ehr-episodes-list> que mostre os
episódios do paciente em timeline na aba Histórias, com filtro por data e
status e download de documentos. Sem iframe, Shadow DOM, mesmo padrão de
auth do <ehr-module>.
```

Também dispara sozinha quando você diz "vamos construir X" ou "nova feature" num repo que
tenha `cycles/` ou `spec/`. Não precisa decorar o comando.

O Claude cria a pasta do ciclo e escreve o `request.md` a partir do que você falou.
**Leia e corrija.** É o único documento que é seu; tudo depois deriva dele.

## Refinar

Ele manda **uma mensagem só** com todas as perguntas, agrupadas e numeradas.

Responda tudo de uma vez. É pra isso que serve o formato — você paga um custo de contexto
em vez de quinze. Se ele sugerir defaults, dá pra responder assim:

> todos os defaults, exceto 3 (paginação: botão "carregar mais") e 7 (só admin vê o
> download)

Não sabe alguma? Diga "não sei ainda". Ele registra em **Open questions** no `plan.md` com
a premissa que está assumindo. Premissa escrita é revisável; premissa na cabeça dele não é.

## O portão de aprovação ✋

Ele para e pede sua revisão. **Este é o momento que paga o processo inteiro.** Leia os três
arquivos com atenção:

- **`plan.md`** — a seção *Fora de escopo* é a mais importante: é ela que segura scope creep
  na implementação. E confira *Estado atual*, onde você costuma descobrir que a spec já
  estava errada.
- **`scenarios.feature`** — se você discorda de um cenário, o código ia sair errado. Corrigir
  aqui custa uma linha.
- **`tasks.md`** — a ordem importa. Se algo parece grande demais pra uma tarefa, é.

Aprove dizendo:

```
aprovado, pode implementar
```

Ele marca `status: approved` no `plan.md`. O portão fica gravado **no arquivo**, então
amanhã, num terminal novo, ele ainda sabe que você aprovou.

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

`result: fail` é resultado normal. Volta pra implementação com a lista do que falta.

## Promover a spec

```
promove a spec
```

Só roda se `validation.md` estiver `pass`. Aplica o `spec-delta.md` dentro de `spec/`,
escrevendo o **estado novo** (sem "antes era X", sem changelog — isso já está no ciclo e no
git), marca o delta como promovido e fecha a última tarefa.

## Perdeu o fio

```
/spec-cycle onde parei?
```

A fase é detectada pelo estado dos arquivos, não pela memória da conversa. Funciona em
sessão nova, em outra máquina, três semanas depois.

---

## Erros comuns

**Aprovar o plano sem ler direito.** O portão só vale se você usar. Aprovar no automático
transforma o processo em burocracia pura — todo o custo, nenhum benefício.

**Escrever plano ou tarefas dentro do `request.md`.** O `request.md` é o *problema*. Se você
já entrega a solução pronta ali, elimina justamente a parte em que o refino descobre o que
você não tinha pensado.

**Editar a pasta do ciclo depois de fechado.** Ela é o registro histórico de por que a spec
diz o que diz. Mudou de ideia? Ciclo novo, delta novo.

**Cenário descrevendo implementação.** `Então a chave "ehr_token" é gravada no localStorage`
quebra numa refatoração que não mudou nada pro usuário. O certo é
`Então ele continua vendo a lista sem precisar logar de novo`.

**Usar ciclo pra tudo.** Correção de typo, bump de dependência, pergunta sobre código: não
precisa de ciclo. Cerimônia aplicada a trivialidade é como processo bom morre. A skill sabe
disso e vai te dizer.

---

## Estrutura

O que a skill contém:

```
spec-cycle/
├── SKILL.md               # ciclo de vida, detecção de fase, invariantes
├── README.md              # este arquivo
├── references/            # carregados só na fase que precisa deles
│   ├── refine.md          # checklist de perguntas + escrita dos artefatos
│   ├── gherkin.md         # cenários de negócio vs. implementação
│   ├── implement.md       # disciplina de execução
│   ├── validate.md        # checklist de validação
│   └── update-spec.md     # regras de promoção da spec
└── assets/                # templates dos artefatos, em português
```

O que ela gera no seu projeto:

```
seu-repo/
├── cycles/
│   └── Q32026/
│       └── 0726-episodes-list-webcomponent/
│           ├── request.md          ← você escreve
│           ├── plan.md             ← Refine (status: draft → approved)
│           ├── scenarios.feature   ← Refine
│           ├── tasks.md            ← Refine
│           ├── spec-delta.md       ← Refine (proposta) → Promote (aplicada)
│           └── validation.md       ← Validate
└── spec/
    ├── architecture.md
    └── features/
        └── episodes-list/
            └── readme.md           ← só a fase Promote escreve aqui
```

## Idioma

Instruções do agente em inglês (melhor adesão do modelo); artefatos gerados em português.

## Origem

Adaptado de um fluxo de SDD originalmente escrito para o Cursor. As inconsistências do
original foram corrigidas:

- **A separação entre proposta e promoção de spec.** O fluxo original se contradizia: uma
  nota dizia que o refino *não* promove pra `spec/`, mas a última linha das próprias
  instruções mandava promover — e o agente obedeceria a instrução, não a nota. O efeito
  seria a spec canônica afirmando comportamento que ainda não existe no código.
- **`validate-cycle` e `update-spec` eram citados mas nunca definidos.** Agora são fases
  reais, com checklist e formato de saída.
- **O portão humano virou estado em arquivo**, não um acordo verbal que evapora quando a
  sessão fecha.
- **Tamanho do ciclo ganhou critério objetivo.** O original mandava usar stages em ciclos
  "Large" sem definir Large.
- **Os cenários Gherkin ganharam exemplos bons e ruins** — a regra "não descreva
  implementação" sozinha não segura o modelo.

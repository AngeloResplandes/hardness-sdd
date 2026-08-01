# harness-sdd

Um harness de **Spec-Driven Development** para o [Claude Code](https://claude.com/claude-code):
sete skills que transformam uma ideia solta em código passando por um plano revisável, com um
portão humano antes de qualquer linha ser escrita — e uma fase que prova que o que foi
construído realmente roda.

A revisão acontece no artefato mais barato de consertar — um plano de 40 linhas, não 2.000
linhas de código.

## Instalação

Copie as sete pastas de skill para um dos dois lugares:

```bash
# pessoal — vale em todos os seus projetos
~/.claude/skills/

# ou por projeto — versionado junto com o repo
<seu-repo>/.claude/skills/
```

```bash
cp -r sdd sdd-start sdd-refine sdd-implement sdd-verify sdd-validate sdd-promote ~/.claude/skills/
```

Não tem build nem dependência: são arquivos markdown. As sete pastas precisam ficar **lado a
lado** no mesmo diretório de skills.

## Uso rápido

```
preciso de um webcomponent que mostre os episódios do paciente em timeline    → abre o ciclo
refina o ciclo                                                                → plano + cenários + tarefas
aprovado, pode implementar                                                    → portão ✋
implementa o ciclo                                                            → código
verifica o ciclo                                                              → sobe servidor, navegador, testes
valida o ciclo                                                                → validation.md
promove a spec                                                                → spec/ atualizado
```

O `sdd-verify` também roda sozinho, fora de um ciclo: `sobe o servidor`, `roda os testes`.

Perdeu o fio? `onde parei?` — a fase é detectada pelos arquivos, não pela memória da conversa.

## As skills

| Skill | Fase | Faz |
|---|---|---|
| `sdd` | — | Orquestrador. Detecta a fase e roteia. |
| `sdd-start` | 1 | Abre o ciclo, escreve o `request.md`. |
| `sdd-refine` | 2 + 3 | Pergunta tudo, escreve os 4 artefatos, para no portão. |
| `sdd-implement` | 4 | Executa o `tasks.md`. Cobre depuração quando algo quebra. |
| `sdd-verify` | 4.5 | Sobe o servidor, exercita os cenários no navegador, roda os testes. Gera evidência. |
| `sdd-validate` | 5 | Julga a evidência contra os cenários, gera `validation.md`. |
| `sdd-promote` | 6 | Aplica o delta em `spec/`. Única que escreve lá. |

`sdd-verify` e `sdd-validate` são separadas de propósito: quem **roda** não é quem **julga**.
Uma fase que produz e avalia a própria evidência não é checkpoint nenhum.

## Documentação

**[Guia de uso completo](sdd/README.md)** — como dirigir o fluxo, o que revisar em cada
portão, erros comuns, e a estrutura de arquivos que o harness gera no seu projeto.

Para entender as decisões de design, os `SKILL.md` são legíveis por humanos — comece por
[sdd/SKILL.md](sdd/SKILL.md), que traz os invariantes e o modelo de duas camadas.

## Estrutura

```
sdd/                    # orquestrador — invariantes, roteamento, detecção de fase
├── SKILL.md
├── README.md           # guia de uso (o documento principal para humanos)
└── references/
    ├── naming.md       # nome de pasta, trimestre, slug, resolução do ciclo atual
    └── reporting.md    # formato do relatório de fechamento

sdd-start/              # fase 1
sdd-refine/             # fases 2 e 3
sdd-implement/          # fase 4 (+ depuração)
sdd-verify/             # fase 4.5 — runtime: servidor, navegador, testes
sdd-validate/           # fase 5
sdd-promote/            # fase 6
```

## Idioma

Instruções do agente em inglês (melhor adesão do modelo); artefatos gerados em português.

# hardness-sdd

Um harness de **Spec-Driven Development** para o [Claude Code](https://claude.com/claude-code):
seis skills que transformam uma ideia solta em código passando por um plano revisável, com um
portão humano antes de qualquer linha ser escrita.

A revisão acontece no artefato mais barato de consertar — um plano de 40 linhas, não 2.000
linhas de código.

## Instalação

Copie as seis pastas de skill para um dos dois lugares:

```bash
# pessoal — vale em todos os seus projetos
~/.claude/skills/

# ou por projeto — versionado junto com o repo
<seu-repo>/.claude/skills/
```

```bash
cp -r sdd sdd-start sdd-refine sdd-implement sdd-validate sdd-promote ~/.claude/skills/
```

Não tem build nem dependência: são arquivos markdown. As seis pastas precisam ficar **lado a
lado** no mesmo diretório de skills.

## Uso rápido

```
preciso de um webcomponent que mostre os episódios do paciente em timeline    → abre o ciclo
refina o ciclo                                                                → plano + cenários + tarefas
aprovado, pode implementar                                                    → portão ✋
implementa o ciclo                                                            → código
valida o ciclo                                                                → validation.md
promove a spec                                                                → spec/ atualizado
```

Perdeu o fio? `onde parei?` — a fase é detectada pelos arquivos, não pela memória da conversa.

## As skills

| Skill | Fase | Faz |
|---|---|---|
| `sdd` | — | Orquestrador. Detecta a fase e roteia. |
| `sdd-start` | 1 | Abre o ciclo, escreve o `request.md`. |
| `sdd-refine` | 2 + 3 | Pergunta tudo, escreve os 4 artefatos, para no portão. |
| `sdd-implement` | 4 | Executa o `tasks.md`. |
| `sdd-validate` | 5 | Confere contra o repo real, gera `validation.md`. |
| `sdd-promote` | 6 | Aplica o delta em `spec/`. Única que escreve lá. |

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
sdd-implement/          # fase 4
sdd-validate/           # fase 5
sdd-promote/            # fase 6
```

## Idioma

Instruções do agente em inglês (melhor adesão do modelo); artefatos gerados em português.

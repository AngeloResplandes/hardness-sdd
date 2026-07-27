# Writing `scenarios.feature`

Acceptance scenarios are a contract with the human about **observable behavior**. They are
the definition of done, and they are read by people who do not know how the code works.

## The test

Every scenario must answer *"what does the user experience?"* — never *"how is it built?"*

A useful check: would this scenario survive a complete rewrite of the implementation? If
swapping localStorage for a cookie, or CSS Grid for Flexbox, would break the scenario, then
the scenario is describing implementation and belongs in the feature's `readme.md` instead.

## Bad → good

**Bad — describes storage mechanism**
```gherkin
Cenário: Token é persistido
  Quando o usuário faz login
  Então a chave "ehr_token" é gravada no localStorage
```

**Good — describes what the user perceives**
```gherkin
Cenário: Sessão sobrevive a um refresh da página
  Dado que o usuário está autenticado
  Quando ele recarrega a página
  Então ele continua vendo a lista de episódios sem precisar logar de novo
```

---

**Bad — describes markup**
```gherkin
Cenário: Componente renderiza
  Então o elemento <ehr-episodes-list> tem o atributo shadow-root
```

**Good — describes the outcome**
```gherkin
Cenário: Estilos do componente não vazam para a página hospedeira
  Dado que a aba "Histórias" já possui seus próprios estilos
  Quando a lista de episódios é embarcada na aba
  Então a aparência dos elementos existentes da aba permanece inalterada
```

---

**Bad — a title naming a mechanism**
```gherkin
Cenário: Chamada GET /episodes com query param status
```

**Good — a title naming a user goal**
```gherkin
Cenário: Filtrar episódios por status para achar os que estão em aberto
```

## Scenario Outline over duplication

When scenarios differ only by a value, collapse them. Six near-identical scenarios hide the
one that is actually different.

```gherkin
Esquema do Cenário: Filtrar episódios por status
  Dado que o paciente possui episódios em diferentes status
  Quando o usuário filtra por "<status>"
  Então apenas os episódios com status "<status>" são exibidos

  Exemplos:
    | status     |
    | aberto     |
    | encerrado  |
    | cancelado  |
```

## Coverage worth having

Aim for the top user-observable behaviors, not exhaustive combinatorics — typically 5 to 12
scenarios for a Medium cycle. Make sure these are among them:

- The happy path, stated plainly.
- The empty state (no data yet) — the most commonly forgotten scenario, and the one users hit
  first on a fresh account.
- The failure state (source unavailable) — what the user sees, not the status code.
- The permission boundary, if roles differ.
- Each distinct user-facing action the request asked for.

## Keywords and language

Content in the human's language. Keywords follow whatever the project's runner is configured
for. If the repo already has `.feature` files, match them exactly. If not and the language is
unclear, use English keywords with Portuguese content — every Cucumber-family runner accepts
that, and it avoids a broken parse on the first run.

Portuguese keywords, if the runner is configured for `pt`:
`Funcionalidade`, `Cenário`, `Esquema do Cenário`, `Exemplos`, `Dado`, `Quando`, `Então`, `E`, `Mas`.

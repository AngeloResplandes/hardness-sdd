# Critérios de aceite — comportamento observável pelo usuário.
# Nada de detalhe de implementação: chave de storage, classe CSS, atributo HTML
# e nome de endpoint pertencem ao readme.md da feature, não a este arquivo.
#
# Teste rápido: este cenário sobreviveria a uma reescrita completa da implementação?
# Se não, ele está descrevendo o "como", não o "o quê".

Funcionalidade: <nome da feature>
  Como <papel do usuário>
  Quero <capacidade>
  Para <resultado de negócio>

  Contexto:
    Dado que <pré-condição comum a todos os cenários>

  Cenário: <objetivo do usuário, não mecanismo técnico>
    Dado que <estado inicial>
    Quando <ação do usuário>
    Então <o que o usuário passa a ver ou conseguir fazer>

  Cenário: <estado vazio — o cenário mais esquecido e o primeiro que o usuário encontra>
    Dado que <não há dados ainda>
    Quando <ação do usuário>
    Então <o que o usuário vê no lugar>

  Cenário: <falha da origem de dados>
    Dado que <o serviço está indisponível>
    Quando <ação do usuário>
    Então <o que o usuário vê, e o que consegue fazer a seguir>

  Esquema do Cenário: <variação por parâmetro, em vez de cenários duplicados>
    Dado que <estado inicial>
    Quando o usuário <ação com "<parametro>">
    Então <resultado esperado para "<parametro>">

    Exemplos:
      | parametro |
      |           |
      |           |

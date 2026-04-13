# PRD: Controle de Parcelas Automatico

## Visao Geral

Na planilha Google Sheets, compras parceladas sao rastreadas com uma coluna PARCELAS no formato "atual/total" (ex: 1/10, 2/10). A cada mes, Ramon copia manualmente cada entrada parcelada para a aba do proximo mes, incrementando o numero da parcela. Esse processo e tedioso, repetitivo e propenso a erros — esquecer uma parcela significa que o total do mes fica incorreto.

O ControlAi precisa automatizar esse processo: ao registrar uma compra parcelada, o sistema deve gerar automaticamente as entradas futuras nos meses subsequentes, eliminando trabalho manual e garantindo precisao nos totais mensais.

Exemplos reais da planilha:
- iPhone 13: R$589,90/mes por 10 meses (1/10 a 10/10)
- Disney+: R$46,88/mes por 12 meses
- Bodytech natacao: R$129,43/mes por 10 meses
- Apple Watch: R$900,00 em 2x
- Leroy: R$267,53/mes por 8 meses

## Objetivos

- Eliminar 100% do trabalho manual de copiar parcelas entre meses
- Garantir que o total mensal reflita corretamente todas as parcelas ativas
- Permitir visualizacao de compromissos futuros (quanto ja esta comprometido nos proximos meses)
- Reduzir erros de esquecimento de parcelas a zero

## Historias de Usuario

- Como Ramon, eu quero registrar uma compra em 10x e que as 9 parcelas restantes aparecam automaticamente nos meses seguintes para que eu nao precise copiar manualmente
- Como Ramon, eu quero ver todas as parcelas ativas de um mes para que eu saiba quanto do mes ja esta comprometido com parcelas anteriores
- Como Aline, eu quero ver quantas parcelas ainda faltam de uma compra para que eu saiba quando aquele gasto vai terminar
- Como Ramon, eu quero poder cancelar as parcelas futuras de uma compra (em caso de devolucao ou renegociacao) para que os meses seguintes sejam atualizados
- Como Ramon, eu quero ver o total comprometido com parcelas nos proximos 3 meses para que eu possa planejar novos gastos
- Como Ramon, eu quero editar o valor de uma parcela futura (em caso de reajuste) sem afetar as parcelas ja pagas

## Funcionalidades Principais

### RF01 - Geracao Automatica de Parcelas Futuras

Ao registrar uma compra com parcelas (ex: 1/12 por R$100,00), o sistema deve:
- Criar a entrada da primeira parcela no mes atual (1/12)
- Gerar automaticamente as entradas das parcelas 2/12 ate 12/12 nos meses subsequentes
- Cada parcela futura herda: descricao, valor, cartao, final do cartao, categoria
- As parcelas futuras sao marcadas como "parcela automatica" para diferenciar de entradas manuais

### RF02 - Visualizacao de Parcelas do Mes

Na listagem de gastos do mes, parcelas automaticas devem:
- Exibir o indicador de parcela (ex: "3/10")
- Ser visualmente distinguiveis de compras avulsas
- Mostrar a descricao original da compra

### RF03 - Resumo de Parcelas Ativas

Disponibilizar uma visao consolidada de todas as compras parceladas ativas:
- Descricao da compra
- Valor da parcela
- Parcela atual / total
- Mes de inicio e mes de termino
- Cartao utilizado
- Valor total da compra (soma de todas as parcelas)

### RF04 - Cancelamento de Parcelas Futuras

Permitir cancelar as parcelas restantes de uma compra:
- Cancelar todas as parcelas futuras (nao pagas) de uma compra
- Manter o historico das parcelas ja lancadas
- Solicitar confirmacao antes de cancelar

### RF05 - Edicao de Parcelas Futuras

Permitir editar parcelas futuras individualmente ou em lote:
- Alterar valor de parcelas futuras (ex: reajuste)
- Alterar cartao de parcelas futuras
- Alterar categoria de parcelas futuras

### RF06 - Projecao de Comprometimento Futuro

Exibir o total ja comprometido com parcelas nos proximos meses:
- Total de parcelas por mes futuro (proximo 1, 2, 3... meses)
- Ajudar no planejamento de novos gastos parcelados

## Experiencia do Usuario

**Fluxo de registro de compra parcelada:**
1. Usuario acessa formulario de entrada manual
2. Preenche dados da compra (descricao, valor, cartao, categoria)
3. No campo parcelas, informa "numero de parcelas" (ex: 10)
4. Sistema calcula e exibe: "10x de R$589,90 — ultima parcela em dez/2026"
5. Usuario confirma → sistema cria todas as parcelas automaticamente
6. Toast de confirmacao: "Compra parcelada registrada — 10 parcelas criadas"

**Visualizacao no mes:**
- Parcelas automaticas aparecem na lista de gastos normalmente, com badge "3/10"
- Ao tocar em uma parcela, o usuario pode ver detalhes da compra original e todas as parcelas

**Consideracoes de UX:**
- O registro de parcelas deve ser simples — apenas informar o numero de parcelas
- O sistema calcula o valor por parcela se o usuario informar o valor total
- Parcelas futuras devem ser editaveis e cancelaveis de forma intuitiva
- A projecao futura ajuda o usuario a evitar comprometer demais o orcamento

**Acessibilidade:**
- Indicadores de parcela devem ser textuais, nao apenas visuais
- Acoes de cancelamento devem ter confirmacao clara

## Restricoes Tecnicas de Alto Nivel

- Depende do PRD de Modelo de Dados (estrutura de parcelas no banco)
- Depende do PRD de Entrada Manual (formulario de registro)
- Parcelas futuras devem ser geradas de forma atomica (todas ou nenhuma)
- O sistema deve lidar com meses de diferentes duracao (28, 30, 31 dias)
- Parcelas canceladas devem manter historico para auditoria
- A geracao de parcelas futuras nao deve impactar a performance do registro

## Fora de Escopo

- Juros ou correcao monetaria sobre parcelas
- Integracao com operadoras de cartao para obter parcelas automaticamente
- Parcelas com valores variaveis pre-definidos (ex: financiamento com tabela SAC/Price)
- Notificacoes sobre parcelas proximas do vencimento
- Renegociacao de parcelas (alterar numero total de parcelas de uma compra existente)
- Antecipacao de parcelas

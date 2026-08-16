# Tarefa 4.0: Simplificar a fonte unica de leitura de "gasto do mes"

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Com todo o historico ja migrado (Tarefa 3.0) e toda compra nova ja gerando statement (Tarefa 1.0), esta tarefa elimina o `CASE`/`OR` condicional por `number_of_installments` em `BudgetPeriodSqlSupport`, que hoje decide entre `installments.amount` e `payment_notifications.amount`. O `INSTALLMENTS_JOIN` vira `INNER JOIN` e o `PERIOD_MATCH_PREDICATE`/`AMOUNT_EXPRESSION` passam a depender exclusivamente do statement. `GetBudgetSummaryProvider` se beneficia automaticamente por ja usar esse support. `PaymentNotificationPeriodQueryProvider` tem o `ORDER BY` do sort `"amount"` ajustado para usar o valor do statement em vez do valor bruto da compra.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot`: mudanca concentrada no `BudgetPeriodSqlSupport` ja existente, sem novo componente.
</skills>

<requirements>
- PRD 3.1 (nenhuma tela/endpoint/relatorio calcula "gasto do mes" somando o valor bruto da compra).
- PRD 3.2 (elimina a logica condicional entre "valor da parcela" e "valor total").
- Ver Tech Spec, secao "BudgetPeriodSqlSupport" em Visao Geral dos Componentes, bloco de codigo em "Interfaces Principais", e "Decisoes Principais" ("Simplificacao do SQL so depois do backfill").
</requirements>

## Subtarefas

- [x] 4.1 Alterar `BudgetPeriodSqlSupport.INSTALLMENTS_JOIN` de `LEFT JOIN` para `INNER JOIN`.
- [x] 4.2 Simplificar `PERIOD_MATCH_PREDICATE` para comparar apenas `DATE_FORMAT(i.due_date, '%Y-%m') = :yearMonth`, removendo o branch por `number_of_installments`.
- [x] 4.3 Simplificar `AMOUNT_EXPRESSION` para `i.amount`, removendo o `CASE WHEN`.
- [x] 4.4 Ajustar `PaymentNotificationPeriodQueryProvider` — `ORDER BY` do sort `"amount"` passa a usar `MAX(i.amount)` em vez de `pn.amount`.
- [x] 4.5 Confirmar que `GetBudgetSummaryProvider` continua funcionando sem mudanca de codigo propria (so se beneficia do support simplificado).
- [x] 4.6 Atualizar/remover testes que dependiam do comportamento antigo do `CASE`/`OR`.

## Detalhes de Implementacao

Ver Tech Spec, bloco de codigo Kotlin em "Interfaces Principais" com a versao simplificada de `BudgetPeriodSqlSupport`. Esta tarefa so pode ser feita apos a Tarefa 3.0 estar concluida — caso contrario compras historicas ainda sem statement desapareceriam dos totais.

## Criterios de Sucesso

- Nenhuma query em `GetBudgetSummaryProvider` ou `PaymentNotificationPeriodQueryProvider` contem `CASE WHEN ... number_of_installments` ou `OR` condicionado a esse campo.
- Os totais de "Real" por categoria e por planejamento continuam identicos aos da Tarefa 3.0 (nenhuma regressao de valor apos a simplificacao).
- A listagem ordenada por "Maiores" (`sort = amount`) reflete o valor do statement do mes, nao o valor bruto da compra.

## Testes da Tarefa

- [x] Testes de unidade: verificacao do SQL/predicate gerado (ausencia de `CASE`/`OR` por `number_of_installments`).
- [x] Testes de integracao: `GetBudgetSummaryProviderIT` (ou equivalente) — compra parcelada distribuida corretamente entre meses continua batendo apos a simplificacao; compra a vista/Pix/dinheiro tambem.
- [x] Teste de regressao: totais antes/depois da simplificacao identicos para a mesma massa de dados (reaproveita a verificacao da Tarefa 3.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/budget/application/BudgetPeriodSqlSupport.kt`
- `application/payments_notification/application/PaymentNotificationPeriodQueryProvider.kt`
- `application/budget/application/GetBudgetSummaryProvider.kt` (sem mudanca de logica propria)
- `src/test/kotlin/.../budget/application/GetBudgetSummaryProviderTest.kt` (ou equivalente)

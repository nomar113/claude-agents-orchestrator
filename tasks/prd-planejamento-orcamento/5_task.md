# Tarefa 5.0: Backend — GetBudgetSummaryProvider: agregacao SQL de valor real por categoria e meio de pagamento

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o provider que calcula os valores reais (actual) por categoria e por meio de pagamento, agregando dados de `payment_notifications`. Criar os endpoints GET /budgets?month (enriquecido com valores reais) e GET /budgets/summary (resumo compacto para dashboard).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- GetBudgetSummaryProvider usando JdbcTemplate (padrao existente)
- Query SQL: SUM(amount) de payment_notifications agrupado por category_id para o mes
- Query SQL: SUM(amount) de payment_notifications agrupado por payment_method_id para o mes
- Filtros: deleted_at IS NULL, purchased_at entre inicio e fim do mes
- Calculo: difference = expected - actual, percentUsed = (totalActual / totalExpected) * 100
- Categorias sem gasto no mes devem retornar actual = 0
- Endpoint GET /budgets?month=YYYY-MM retorna BudgetSummary completo
- Endpoint GET /budgets/summary?month=YYYY-MM retorna resumo compacto (totais apenas)
</requirements>

## Subtarefas

- [ ] 5.1 Criar GetBudgetSummaryProvider com queries SQL via JdbcTemplate
- [ ] 5.2 Criar GetBudgetSummaryUseCase e gateway
- [ ] 5.3 Criar BudgetSummaryResponse e BudgetCompactSummaryResponse
- [ ] 5.4 Adicionar endpoints ao BudgetController
- [ ] 5.5 Testes de integracao da agregacao

## Detalhes de Implementacao

Consultar a secao **Endpoints de API** da `techspec.md` para os exemplos de response do summary. Seguir o padrao de `GetPaymentMethodsSummaryProvider` como referencia para a query SQL com JdbcTemplate.

## Criterios de Sucesso

- Valores reais calculados corretamente a partir de payment_notifications
- Categorias do planejamento sem gastos retornam actual = 0
- Totais por meio de pagamento corretos
- Percentual gasto/expectativa calculado corretamente
- Endpoint compacto retorna apenas totais (sem itens individuais)

## Testes da Tarefa

- [ ] Teste de integracao: inserir payment_notifications com categorias, criar budget com items, verificar que summary retorna actual correto
- [ ] Teste de integracao: categoria no budget sem gastos no mes retorna actual = 0
- [ ] Teste de integracao: payment_notifications com deleted_at nao sao contabilizadas
- [ ] Teste de integracao: totais por meio de pagamento corretos
- [ ] Teste de integracao: endpoint compacto /budgets/summary retorna totais

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../application/budget/application/GetBudgetSummaryProvider.kt` (novo)
- `src/main/kotlin/.../domain/budget/usecase/GetBudgetSummaryUseCase.kt` (novo)
- `src/main/kotlin/.../domain/budget/gateway/GetBudgetSummaryGateway.kt` (novo)
- `src/main/kotlin/.../application/budget/entrypoint/rest/response/BudgetSummaryResponse.kt` (novo)
- `src/test/kotlin/.../application/budget/BudgetSummaryIntegrationTest.kt` (novo)
- `src/main/kotlin/.../application/payment_methods/application/GetPaymentMethodsSummaryProvider.kt` (referencia)

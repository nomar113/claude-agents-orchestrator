# Tarefa 3.0: Modificar query do Real (substituir CASE por JOIN)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Substituir a logica de CASE do `closingDay` no SQL do `GetBudgetSummaryProvider` por um INNER JOIN com a tabela `budget_payment_periods`. Incluir os periods no response do endpoint GET /budgets.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Substituir o CASE statement no `queryActualByCategory()` por INNER JOIN com budget_payment_periods
- Aplicar a mesma logica no calculo de paymentMethodTotals
- Criar DTO `BudgetPaymentPeriodResponse` com: paymentMethodId, paymentMethodName, startDate, endDate, closingDay
- Incluir lista de periods no `BudgetSummaryResponse`
- O valor "Real" deve considerar apenas compras dentro dos ranges configurados
</requirements>

## Subtarefas

- [ ] 3.1 Criar DTO `BudgetPaymentPeriodResponse`
- [ ] 3.2 Modificar `queryActualByCategory()` — substituir CASE por JOIN com budget_payment_periods
- [ ] 3.3 Modificar calculo de `paymentMethodTotals` para usar os ranges
- [ ] 3.4 Incluir periods no `BudgetSummaryResponse` e no mapeamento do controller
- [ ] 3.5 Escrever testes

## Detalhes de Implementacao

Consultar a secao "SQL do Real (substituicao do CASE)" da techspec.md para a query atualizada.

A query usa `INNER JOIN budget_payment_periods bpp ON pn.payment_method_id = bpp.payment_method_id AND bpp.budget_id = ?` com filtro `pn.purchased_at >= bpp.start_date AND pn.purchased_at < DATE_ADD(bpp.end_date, INTERVAL 1 DAY)`.

## Criterios de Sucesso

- GET /budgets retorna campo `periods` com todos os periods do budget
- Valor "Real" por categoria reflete apenas compras dentro dos ranges
- paymentMethodTotals reflete totais filtrados
- Percentual "Planejado vs Real" recalculado corretamente
- Nenhuma regressao nos valores existentes (lazy creation garante periods)

## Testes da Tarefa

- [ ] Teste de integracao: compra dentro do range conta no Real
- [ ] Teste de integracao: compra fora do range NAO conta no Real
- [ ] Teste de integracao: paymentMethodTotals filtrado pelo range
- [ ] Teste de integracao: GET /budgets retorna periods no response
- [ ] Teste de integracao: percentual recalculado corretamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/GetBudgetSummaryProvider.kt` — Query principal (CRITICO)
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/rest/BudgetController.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/rest/dto/` — DTOs de response

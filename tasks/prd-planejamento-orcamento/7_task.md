# Tarefa 7.0: Frontend — budgetService + tipos TypeScript

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a service layer e os tipos TypeScript para consumir a API de budget no frontend. Seguir o padrao ja existente nos outros services (categoryService, paymentMethodService).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Tipos: Budget, BudgetItem, BudgetIncome, BudgetSummary, BudgetCompactSummary, BudgetItemType, PaymentMethodTotal, CreateBudgetRequest, CreateBudgetItemRequest, UpdateBudgetItemRequest, CreateBudgetIncomeRequest, UpdateBudgetIncomeRequest
- Service functions: getBudget(month), getBudgetSummary(month), createBudget(yearMonth), deleteBudget(id), duplicateBudget(id, targetMonth), createBudgetItem(budgetId, data), updateBudgetItem(budgetId, itemId, data), deleteBudgetItem(budgetId, itemId), createBudgetIncome(budgetId, data), updateBudgetIncome(budgetId, incomeId, data), deleteBudgetIncome(budgetId, incomeId)
- Usar httpRequest helper com CapacitorHttp (padrao existente)
</requirements>

## Subtarefas

- [ ] 7.1 Criar `src/types/budget.ts` com todos os tipos
- [ ] 7.2 Criar `src/services/budgetService.ts` com todas as funcoes
- [ ] 7.3 Testes unitarios do service

## Detalhes de Implementacao

Consultar a secao **Endpoints de API** da `techspec.md` para os contratos de request/response. Seguir o padrao de `src/services/categoryService.ts` e `src/services/installmentService.ts` como referencia.

## Criterios de Sucesso

- Todos os tipos TypeScript compilam sem erros
- Todas as funcoes do service mapeiam corretamente para os endpoints da API
- Testes cobrem chamadas HTTP para cada endpoint

## Testes da Tarefa

- [ ] Testes unitarios: cada funcao do service chama o endpoint correto com metodo e body esperados
- [ ] Testes unitarios: tipos TypeScript estao consistentes com os DTOs do backend

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/types/budget.ts` (novo)
- `src/services/budgetService.ts` (novo)
- `src/services/budgetService.test.ts` (novo)
- `src/services/categoryService.ts` (referencia)
- `src/services/installmentService.ts` (referencia)
- `src/types/category.ts` (referencia)

# Tarefa 4.0: Backend — REST Controller CRUD de budgets, items e incomes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o BudgetController com todos os endpoints CRUD para budgets, budget_items e budget_incomes. Inclui DTOs de request e response.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- POST /budgets — criar planejamento (body: yearMonth)
- GET /budgets?month=YYYY-MM — buscar planejamento completo (sem valores reais ainda, isso e task 5)
- DELETE /budgets/{id} — excluir planejamento
- POST /budgets/{id}/items — adicionar item
- PUT /budgets/{id}/items/{itemId} — atualizar expectativa de um item
- DELETE /budgets/{id}/items/{itemId} — remover item
- POST /budgets/{id}/incomes — adicionar receita
- PUT /budgets/{id}/incomes/{incomeId} — atualizar receita
- DELETE /budgets/{id}/incomes/{incomeId} — remover receita
- DTOs: CreateBudgetRequest, CreateBudgetItemRequest, UpdateBudgetItemRequest, CreateBudgetIncomeRequest, UpdateBudgetIncomeRequest, BudgetResponse, BudgetItemResponse, BudgetIncomeResponse
- Validacao com @Validated
- Erros: 404 quando budget/item/income nao encontrado, 409 quando yearMonth ja existe
</requirements>

## Subtarefas

- [ ] 4.1 Criar DTOs de request em `entrypoint/rest/request/`
- [ ] 4.2 Criar DTOs de response em `entrypoint/rest/response/`
- [ ] 4.3 Criar BudgetController com endpoints CRUD
- [ ] 4.4 Testes de integracao do controller

## Detalhes de Implementacao

Consultar a secao **Endpoints de API** da `techspec.md` para a lista completa de endpoints e exemplos de request/response. Seguir o padrao de `CategoryController` e `PaymentMethodController` como referencia.

## Criterios de Sucesso

- Todos os endpoints CRUD funcionam corretamente
- Validacoes retornam status codes apropriados (201, 200, 204, 404, 409)
- DTOs serializam/deserializam corretamente em JSON

## Testes da Tarefa

- [ ] Testes de integracao: criar budget, adicionar items e incomes, buscar por mes
- [ ] Testes de integracao: deletar budget e verificar que items/incomes sao removidos
- [ ] Testes de integracao: tentar criar budget duplicado retorna 409
- [ ] Testes de integracao: atualizar/deletar item e income inexistentes retorna 404

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../application/budget/entrypoint/rest/BudgetController.kt` (novo)
- `src/main/kotlin/.../application/budget/entrypoint/rest/request/` (novos)
- `src/main/kotlin/.../application/budget/entrypoint/rest/response/` (novos)
- `src/test/kotlin/.../application/budget/BudgetControllerIntegrationTest.kt` (novo)
- `src/main/kotlin/.../application/categories/entrypoint/rest/CategoryController.kt` (referencia)

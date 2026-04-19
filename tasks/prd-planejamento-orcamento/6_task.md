# Tarefa 6.0: Backend — Duplicacao de planejamento entre meses

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o endpoint de duplicacao de planejamento, que copia todos os items e incomes de um budget existente para um novo mes. Isso permite que o usuario use o planejamento do mes anterior como base sem preencher tudo do zero.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- POST /budgets/{id}/duplicate?targetMonth=YYYY-MM
- Copia todos os budget_items (mesma categoria, tipo e valor de expectativa) para o novo budget
- Copia todos os budget_incomes (mesmo label e amount) para o novo budget
- O novo budget tem IDs novos (nao e clone, e uma copia)
- Retorna erro 409 se o targetMonth ja possui um budget
- Retorna erro 404 se o budget de origem nao existe
</requirements>

## Subtarefas

- [ ] 6.1 Implementar DuplicateBudgetProvider
- [ ] 6.2 Adicionar endpoint ao BudgetController
- [ ] 6.3 Testes de integracao da duplicacao

## Detalhes de Implementacao

O DuplicateBudgetUseCase (criado na task 2) deve buscar o budget de origem com items e incomes, criar um novo Budget com o targetMonth, e salvar com os mesmos items/incomes (sem IDs, para que o banco gere novos).

## Criterios de Sucesso

- Budget duplicado com sucesso para novo mes
- Items e incomes copiados com mesmos valores mas IDs novos
- Erro 409 ao tentar duplicar para mes que ja tem budget
- Erro 404 ao tentar duplicar budget inexistente

## Testes da Tarefa

- [ ] Teste de integracao: duplicar budget, verificar que novo mes tem mesmos items e incomes
- [ ] Teste de integracao: duplicar para mes existente retorna 409
- [ ] Teste de integracao: duplicar budget inexistente retorna 404
- [ ] Teste de integracao: alterar item no budget duplicado nao afeta o original

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../application/budget/application/DuplicateBudgetProvider.kt` (novo)
- `src/main/kotlin/.../domain/budget/usecase/DuplicateBudgetUseCase.kt` (ja criado na task 2)
- `src/main/kotlin/.../domain/budget/gateway/DuplicateBudgetGateway.kt` (ja criado na task 2)
- `src/main/kotlin/.../application/budget/entrypoint/rest/BudgetController.kt` (modificar)
- `src/test/kotlin/.../application/budget/BudgetDuplicateIntegrationTest.kt` (novo)

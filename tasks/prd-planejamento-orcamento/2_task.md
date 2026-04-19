# Tarefa 2.0: Backend — Domain layer do bounded context budget

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o domain layer completo do bounded context `budget`, seguindo o padrao hexagonal ja existente no projeto (entities, use cases, gateways). Todas as entidades, enums, interfaces de gateway e use cases devem ser criados nesta tarefa.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Entidades: Budget, BudgetItem, BudgetIncome, BudgetItemType (enum), BudgetSummary, BudgetItemSummary, PaymentMethodTotal
- Use cases: SaveBudgetUseCase, FindBudgetUseCase, DeleteBudgetUseCase, DuplicateBudgetUseCase, SaveBudgetItemUseCase, UpdateBudgetItemUseCase, DeleteBudgetItemUseCase, SaveBudgetIncomeUseCase, UpdateBudgetIncomeUseCase, DeleteBudgetIncomeUseCase, GetBudgetSummaryUseCase
- Gateways: uma interface fun interface por use case
- Todos os use cases retornam Result<T> seguindo o padrao existente
</requirements>

## Subtarefas

- [ ] 2.1 Criar entidades de dominio em `domain/budget/entity/`
- [ ] 2.2 Criar enum `BudgetItemType` (EXPENSE, INVESTMENT)
- [ ] 2.3 Criar gateways em `domain/budget/gateway/`
- [ ] 2.4 Criar use cases em `domain/budget/usecase/`
- [ ] 2.5 Testes unitarios dos use cases

## Detalhes de Implementacao

Consultar a secao **Interfaces Principais** da `techspec.md` para as definicoes de entidades. Seguir o padrao de `domain/categories/` e `domain/payment_methods/` como referencia.

## Criterios de Sucesso

- Todas as entidades compilam e representam corretamente o dominio
- Use cases delegam para gateways via Result pattern
- Testes unitarios cobrem todos os use cases

## Testes da Tarefa

- [ ] Testes unitarios: cada use case com mock do gateway (padrao `UseCasesTest`)
- [ ] Testes unitarios: validar que DuplicateBudgetUseCase copia items e incomes corretamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../domain/budget/entity/Budget.kt` (novo)
- `src/main/kotlin/.../domain/budget/entity/BudgetItem.kt` (novo)
- `src/main/kotlin/.../domain/budget/entity/BudgetIncome.kt` (novo)
- `src/main/kotlin/.../domain/budget/entity/BudgetItemType.kt` (novo)
- `src/main/kotlin/.../domain/budget/entity/BudgetSummary.kt` (novo)
- `src/main/kotlin/.../domain/budget/usecase/` (novos)
- `src/main/kotlin/.../domain/budget/gateway/` (novos)
- `src/test/kotlin/.../domain/budget/BudgetUseCasesTest.kt` (novo)
- `src/main/kotlin/.../domain/categories/usecase/SaveCategoryUseCase.kt` (referencia)

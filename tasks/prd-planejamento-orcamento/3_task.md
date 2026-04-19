# Tarefa 3.0: Backend — Application layer: JPA models, repositories, providers, converters

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de aplicacao do bounded context `budget`: modelos JPA (mapeando para as tabelas V16/V17/V18), repositorios Spring Data, providers (implementacoes dos gateways) e converters entre dominio e JPA.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- JPA models: BudgetModel, BudgetItemModel, BudgetIncomeModel com anotacoes JPA
- BudgetModel deve ter @SQLRestriction se aplicavel e relacionamentos @OneToMany com items e incomes
- Repositories: BudgetRepository (com findByYearMonth), BudgetItemRepository, BudgetIncomeRepository
- Providers implementando cada gateway da task 2.0
- Converters: domain entity <-> JPA model (companion object com `from` e `toDomain`)
</requirements>

## Subtarefas

- [ ] 3.1 Criar JPA models em `application/budget/entrypoint/database/model/`
- [ ] 3.2 Criar repositories em `application/budget/entrypoint/database/repository/`
- [ ] 3.3 Criar converters entre domain entities e JPA models
- [ ] 3.4 Criar providers em `application/budget/application/`
- [ ] 3.5 Testes de integracao dos repositories e providers

## Detalhes de Implementacao

Seguir o padrao de `application/categories/` como referencia. Os JPA models devem usar `data class` com `@Entity`, `@Table`, `@Id @GeneratedValue`. O BudgetModel deve ter `@OneToMany(cascade = [CascadeType.ALL], orphanRemoval = true)` para items e incomes.

## Criterios de Sucesso

- CRUD completo de Budget com items e incomes funciona via repositories
- Providers implementam todos os gateways corretamente
- Converters preservam dados sem perda

## Testes da Tarefa

- [ ] Testes de integracao: CRUD de BudgetModel com items e incomes via repository
- [ ] Testes de integracao: findByYearMonth retorna budget com items e incomes carregados
- [ ] Testes unitarios: converters domain <-> JPA

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../application/budget/entrypoint/database/model/BudgetModel.kt` (novo)
- `src/main/kotlin/.../application/budget/entrypoint/database/model/BudgetItemModel.kt` (novo)
- `src/main/kotlin/.../application/budget/entrypoint/database/model/BudgetIncomeModel.kt` (novo)
- `src/main/kotlin/.../application/budget/entrypoint/database/repository/BudgetRepository.kt` (novo)
- `src/main/kotlin/.../application/budget/application/` (novos providers)
- `src/main/kotlin/.../application/budget/converter/` (novos converters)
- `src/test/kotlin/.../application/budget/BudgetRepositoryIntegrationTest.kt` (novo)
- `src/main/kotlin/.../application/categories/entrypoint/database/model/CategoryModel.kt` (referencia)

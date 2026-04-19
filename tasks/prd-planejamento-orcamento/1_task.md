# Tarefa 1.0: Migracoes Flyway V16/V17/V18 — tabelas budgets, budget_items, budget_incomes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar as 3 migracoes Flyway que formam a base de dados do planejamento orcamentario mensal. As tabelas devem seguir o padrao ja estabelecido no projeto (auto_increment, timestamps, soft delete onde aplicavel, FKs com constraint nomeada).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- V16: Tabela `budgets` com `year_month` VARCHAR(7) UNIQUE
- V17: Tabela `budget_items` com FK para budgets e categories, coluna `type` (EXPENSE/INVESTMENT), `expected` DECIMAL(19,2), UK (budget_id, category_id)
- V18: Tabela `budget_incomes` com FK para budgets, `label` VARCHAR(100), `amount` DECIMAL(19,2)
- Todas com ON DELETE CASCADE no FK para budgets
- Todas com created_at e updated_at
</requirements>

## Subtarefas

- [ ] 1.1 Criar `V16__create_budgets_table.sql`
- [ ] 1.2 Criar `V17__create_budget_items_table.sql`
- [ ] 1.3 Criar `V18__create_budget_incomes_table.sql`
- [ ] 1.4 Testes de integracao das migracoes

## Detalhes de Implementacao

Consultar a secao **Modelos de Dados** da `techspec.md` para o SQL exato de cada migracao. Seguir o padrao de migracoes existentes (V1-V15) no diretorio `src/main/resources/db/migration/`.

## Criterios de Sucesso

- As 3 migracoes executam sem erro no MySQL e H2
- Tabelas criadas com constraints corretas (FKs, UKs)
- Teste de integracao valida a existencia das tabelas e colunas

## Testes da Tarefa

- [ ] Teste de integracao: executar migracoes e validar schema (padrao `MigrationIntegrationTest`)
- [ ] Teste de integracao: inserir/deletar budget e verificar CASCADE em items e incomes

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/V16__create_budgets_table.sql` (novo)
- `src/main/resources/db/migration/V17__create_budget_items_table.sql` (novo)
- `src/main/resources/db/migration/V18__create_budget_incomes_table.sql` (novo)
- `src/test/kotlin/.../application/budget/BudgetMigrationIntegrationTest.kt` (novo)
- `src/main/resources/db/migration/V13__create_categories_table.sql` (referencia)

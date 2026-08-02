# Tarefa 1.0: Migration SQL + Entidade + Repositorio

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a infraestrutura de dados para armazenar os periodos de datas por meio de pagamento por orcamento. Inclui a migration SQL, a entidade de dominio, o modelo JPA e o repositorio.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Criar migration SQL para tabela `budget_payment_periods`
- Criar entidade de dominio `BudgetPaymentPeriod`
- Criar modelo JPA `BudgetPaymentPeriodModel`
- Criar repositorio `BudgetPaymentPeriodRepository`
- Tabela deve ter constraint UNIQUE(budget_id, payment_method_id)
- Foreign keys para budgets e payment_methods com CASCADE no delete do budget
</requirements>

## Subtarefas

- [x] 1.1 Criar migration SQL (nova versao V22__create_budget_payment_periods_table.sql)
- [x] 1.2 Criar entidade de dominio `BudgetPaymentPeriod` com campos: id, budgetId, paymentMethodId, startDate, endDate
- [x] 1.3 Criar modelo JPA `BudgetPaymentPeriodModel` mapeado para a tabela
- [x] 1.4 Criar repositorio `BudgetPaymentPeriodRepository` com query `findByBudgetId`
- [x] 1.5 Escrever testes

## Detalhes de Implementacao

Consultar a secao "Modelos de Dados" da techspec.md para o schema SQL completo e a definicao da entidade.

Seguir o padrao existente dos modelos JPA do projeto (ex: `BudgetModel`, `BudgetItemModel`).

## Criterios de Sucesso

- Migration roda sem erros no banco
- Entidade e repositorio funcionam com operacoes CRUD basicas
- Constraint unique impede duplicatas de (budget_id, payment_method_id)
- Deletar um budget faz cascade e remove os periods associados

## Testes da Tarefa

- [x] Teste de integracao: salvar e recuperar BudgetPaymentPeriodModel via repositorio
- [x] Teste de integracao: verificar constraint unique (budget_id, payment_method_id)
- [x] Teste de integracao: verificar cascade delete ao remover budget

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/` — Pasta de migrations existentes
- `src/main/kotlin/br/com/nomar/controlai/domain/budget/entity/Budget.kt` — Referencia de entidade
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/database/model/` — Modelos JPA existentes
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/database/repository/BudgetRepository.kt` — Referencia de repositorio

# Especificacao Tecnica: Planejamento e Orcamento Mensal

## Resumo Executivo

A funcionalidade de planejamento orcamentario mensal sera implementada como um novo bounded context `budget` no backend, com 3 novas tabelas MySQL (budgets, budget_items, budget_incomes) gerenciadas por Flyway. O backend expoe endpoints REST para CRUD do planejamento, duplicacao entre meses e calculo automatico do valor real por categoria via agregacao SQL sobre `payment_notifications`. O frontend integra o resumo diretamente na Tab1 existente (substituindo valores hardcoded) e adiciona uma nova pagina `/budget` com secoes colapsaveis para gastos, investimentos, receitas e totais por meio de pagamento. Edicao inline dos valores de expectativa segue o padrao mobile-first do app.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (novos):**
- `domain/budget/entity/` — Entidades de dominio: Budget, BudgetItem, BudgetIncome
- `domain/budget/usecase/` — Use cases: SaveBudget, FindBudget, ListBudgets, DuplicateBudget, SaveBudgetItem, SaveBudgetIncome, GetBudgetSummary
- `domain/budget/gateway/` — Gateways (interfaces): SaveBudgetGateway, FindBudgetGateway, etc.
- `application/budget/entrypoint/database/model/` — JPA models
- `application/budget/entrypoint/database/repository/` — Spring Data repositories
- `application/budget/entrypoint/rest/` — BudgetController + DTOs (request/response)
- `application/budget/application/` — Providers (implementacoes dos gateways), incluindo `GetBudgetSummaryProvider` com agregacao SQL

**Backend (modificados):**
- Nenhum componente existente precisa ser modificado. A agregacao de gastos reais e feita por query SQL direta sobre `payment_notifications`.

**Frontend (novos):**
- `services/budgetService.ts` — Service layer para API de budget
- `types/budget.ts` — Tipos TypeScript
- `pages/BudgetPage.tsx` + `BudgetPage.css` — Pagina de planejamento detalhado
- `components/BudgetSummaryCard.tsx` — Card de resumo para Tab1

**Frontend (modificados):**
- `pages/Tab1.tsx` — Substituir valores hardcoded por dados reais do planejamento
- `App.tsx` — Adicionar rota `/budget`

**Fluxo de dados:** Tab1 chama `GET /budgets/summary?month=YYYY-MM` para obter totais. BudgetPage chama `GET /budgets?month=YYYY-MM` para dados completos. O valor "Real" de cada categoria e calculado no backend via SQL SUM sobre `payment_notifications` agrupado por `category_id` e mes.

## Design de Implementacao

### Interfaces Principais

```kotlin
// Domain entities
class Budget(
    val id: Long? = null,
    val yearMonth: YearMonth,
    val items: List<BudgetItem> = emptyList(),
    val incomes: List<BudgetIncome> = emptyList(),
)

class BudgetItem(
    val id: Long? = null,
    val budgetId: Long,
    val categoryId: Long,
    val categoryName: String? = null,
    val type: BudgetItemType, // EXPENSE, INVESTMENT
    val expected: BigDecimal,
)

class BudgetIncome(
    val id: Long? = null,
    val budgetId: Long,
    val label: String, // ex: "Ramon Salario", "Aline Salario"
    val amount: BigDecimal,
)

enum class BudgetItemType { EXPENSE, INVESTMENT }

// Summary (retornado com valores reais calculados)
class BudgetSummary(
    val yearMonth: YearMonth,
    val totalExpected: BigDecimal,
    val totalActual: BigDecimal,
    val percentUsed: BigDecimal,
    val totalIncome: BigDecimal,
    val totalInvestmentExpected: BigDecimal,
    val totalInvestmentActual: BigDecimal,
    val items: List<BudgetItemSummary>,
    val incomes: List<BudgetIncome>,
    val paymentMethodTotals: List<PaymentMethodTotal>,
)

class BudgetItemSummary(
    val categoryId: Long,
    val categoryName: String,
    val type: BudgetItemType,
    val expected: BigDecimal,
    val actual: BigDecimal,
    val difference: BigDecimal, // expected - actual
)

class PaymentMethodTotal(
    val paymentMethodId: Long,
    val name: String,
    val total: BigDecimal,
)
```

### Modelos de Dados

**Migracao V16 — tabela `budgets`:**
```sql
CREATE TABLE budgets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    year_month VARCHAR(7) NOT NULL, -- 'YYYY-MM'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_budgets_year_month (year_month)
);
```

**Migracao V17 — tabela `budget_items`:**
```sql
CREATE TABLE budget_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    budget_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    type VARCHAR(15) NOT NULL, -- 'EXPENSE' ou 'INVESTMENT'
    expected DECIMAL(19,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bi_budget FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE,
    CONSTRAINT fk_bi_category FOREIGN KEY (category_id) REFERENCES categories (id),
    UNIQUE KEY uk_bi_budget_category (budget_id, category_id)
);
```

**Migracao V18 — tabela `budget_incomes`:**
```sql
CREATE TABLE budget_incomes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    budget_id BIGINT NOT NULL,
    label VARCHAR(100) NOT NULL,
    amount DECIMAL(19,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_binc_budget FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
);
```

### Endpoints de API

| Metodo | Path | Descricao |
|--------|------|-----------|
| `POST` | `/budgets` | Criar planejamento para um mes (body: yearMonth) |
| `GET` | `/budgets?month=YYYY-MM` | Buscar planejamento completo com valores reais calculados |
| `GET` | `/budgets/summary?month=YYYY-MM` | Resumo compacto (totais) para dashboard Tab1 |
| `DELETE` | `/budgets/{id}` | Excluir planejamento |
| `POST` | `/budgets/{id}/duplicate?targetMonth=YYYY-MM` | Duplicar planejamento para outro mes |
| `PUT` | `/budgets/{id}/items/{itemId}` | Atualizar valor de expectativa de um item |
| `POST` | `/budgets/{id}/items` | Adicionar item ao planejamento |
| `DELETE` | `/budgets/{id}/items/{itemId}` | Remover item do planejamento |
| `PUT` | `/budgets/{id}/incomes/{incomeId}` | Atualizar receita |
| `POST` | `/budgets/{id}/incomes` | Adicionar receita |
| `DELETE` | `/budgets/{id}/incomes/{incomeId}` | Remover receita |

**Request/Response exemplos:**

```json
// POST /budgets
{ "yearMonth": "2026-04" }

// GET /budgets?month=2026-04 (response)
{
  "id": 1,
  "yearMonth": "2026-04",
  "totalExpected": 8500.00,
  "totalActual": 6234.50,
  "percentUsed": 73.35,
  "totalIncome": 12000.00,
  "totalInvestmentExpected": 2000.00,
  "totalInvestmentActual": 1500.00,
  "items": [
    { "id": 1, "categoryId": 2, "categoryName": "Mercado", "type": "EXPENSE", "expected": 2000.00, "actual": 1834.50, "difference": 165.50 }
  ],
  "incomes": [
    { "id": 1, "label": "Ramon Salario", "amount": 7000.00 }
  ],
  "paymentMethodTotals": [
    { "paymentMethodId": 1, "name": "Nubank Ramon", "total": 3200.00 }
  ]
}

// GET /budgets/summary?month=2026-04 (response compacto)
{
  "yearMonth": "2026-04",
  "totalExpected": 8500.00,
  "totalActual": 6234.50,
  "percentUsed": 73.35,
  "totalIncome": 12000.00,
  "balance": 5765.50
}
```

**Query de agregacao do valor real (no GetBudgetSummaryProvider):**
```sql
SELECT pn.category_id, COALESCE(SUM(pn.amount), 0) AS total
FROM payment_notifications pn
WHERE pn.category_id IS NOT NULL
  AND pn.deleted_at IS NULL
  AND pn.purchased_at >= ? AND pn.purchased_at < ?
GROUP BY pn.category_id
```

**Query de totais por meio de pagamento:**
```sql
SELECT pm.id, pm.name, COALESCE(SUM(pn.amount), 0) AS total
FROM payment_notifications pn
JOIN payment_methods pm ON pn.payment_method_id = pm.id
WHERE pn.deleted_at IS NULL
  AND pn.purchased_at >= ? AND pn.purchased_at < ?
GROUP BY pm.id, pm.name
ORDER BY pm.name
```

## Pontos de Integracao

Nao ha integracoes externas. Toda a funcionalidade usa dados internos:
- Tabela `categories` existente para vincular itens do planejamento
- Tabela `payment_notifications` para calcular valores reais por categoria e por meio de pagamento
- Tabela `payment_methods` para nomes dos meios de pagamento

## Abordagem de Testes

### Testes Unitarios

- **BudgetController**: Testar cada endpoint com mocks dos use cases
- **Use cases**: Testar logica de duplicacao (copia items e incomes, muda yearMonth)
- **GetBudgetSummaryProvider**: Testar calculo de percentual, diferenca, e tratamento de categorias sem gasto

### Testes de Integracao

- **Migration tests**: Verificar criacao das tabelas V16/V17/V18 (padrao ja existente: `MigrationIntegrationTest`)
- **Repository tests**: CRUD completo de Budget com items e incomes
- **Summary aggregation**: Inserir payment_notifications com categorias e verificar que a agregacao SQL retorna totais corretos
- **Duplicacao**: Criar budget, duplicar, verificar que o novo mes tem os mesmos items/incomes mas IDs novos

### Testes E2E

- Criar planejamento, preencher expectativas, verificar que valores reais aparecem corretamente
- Duplicar planejamento de um mes para outro
- Verificar que Tab1 exibe dados reais do planejamento quando existir
- Testar edicao inline de valores de expectativa

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migracoes Flyway V16/V17/V18** — Criar as 3 tabelas. Base para tudo.
2. **Backend Domain layer** — Entities, use cases, gateways do bounded context budget.
3. **Backend Application layer** — JPA models, repositories, providers (implementacoes dos gateways).
4. **Backend REST Controller + DTOs** — Endpoints CRUD de budgets, items e incomes.
5. **Backend GetBudgetSummaryProvider** — Agregacao SQL para calcular valor real por categoria e por meio de pagamento. Endpoint de summary.
6. **Backend Duplicacao** — Endpoint POST /budgets/{id}/duplicate.
7. **Frontend service + tipos** — budgetService.ts e types/budget.ts.
8. **Frontend BudgetPage** — Tela completa com secoes colapsaveis, edicao inline.
9. **Frontend integracao Tab1** — BudgetSummaryCard substituindo valores hardcoded.
10. **Frontend roteamento** — Rota /budget no App.tsx, navegacao da Tab1 para BudgetPage.

### Dependencias Tecnicas

- Tabelas `categories` e `payment_methods` ja existem (V13, V6)
- Coluna `category_id` em `payment_notifications` ja existe (V14)
- Nenhuma dependencia externa ou de infraestrutura adicional

## Monitoramento e Observabilidade

- **Logs**: INFO ao criar/duplicar planejamento, WARN quando agregacao retorna 0 categorias para um mes com gastos
- **Metricas**: Endpoint `/actuator/health` ja existente. Nao requer metricas Prometheus adicionais para MVP
- **Performance**: A query de agregacao usa indices existentes (`idx_pn_payment_method_id`). Considerar adicionar indice `idx_pn_category_id_purchased_at` se performance degradar com volume

## Consideracoes Tecnicas

### Decisoes Principais

1. **JdbcTemplate para agregacao** (vs. JPQL): Seguindo o padrao ja estabelecido em `GetPaymentMethodsSummaryProvider`. SQL direto oferece mais controle sobre a query de agregacao e evita problemas com lazy loading.

2. **Tabela `budget_items` unica para gastos e investimentos** (vs. tabelas separadas): Usar coluna `type` (EXPENSE/INVESTMENT) simplifica o schema e a API. Investimentos sao poucos itens e seguem a mesma estrutura (expectativa + real manual).

3. **Investimentos com valor real manual** (vs. calculado): Investimentos nao tem correspondencia direta em `payment_notifications`, entao o valor real sera informado manualmente via campo no BudgetItem. Alternativa: criar categoria "Investimento" — rejeitada por misturar conceitos.

4. **Valor real apenas de payment_notifications** (vs. incluir purchase_invoices): Decisao do usuario. Simplifica a query de agregacao e evita duplicidade (notas fiscais podem gerar payment_notifications tambem).

5. **Unicidade por year_month**: Cada mes tem no maximo um planejamento. Constraint UNIQUE garante isso no banco.

### Riscos Conhecidos

- **Categorias sem gastos**: Itens do planejamento podem referenciar categorias que nao tem nenhum gasto no mes. O summary deve retornar actual=0 nesses casos (LEFT JOIN na query ou pos-processamento).
- **Despesas sem categoria**: Gastos em `payment_notifications` sem `category_id` nao serao contabilizados em nenhum item do planejamento. O summary pode incluir um totalizador "Sem categoria" para visibilidade.
- **Performance com muitos meses**: A query de agregacao e por mes, entao o volume por consulta e limitado. Nao ha risco de performance no curto prazo.

### Conformidade com Skills Padroes

- `executar-task` — Cada etapa do sequenciamento sera implementada como uma task individual
- `executar-review` — Code review apos implementacao de cada task
- `task-review` — Review automatico via task-reviewer agent
- `executar-qa` — QA com Playwright para fluxos E2E do planejamento

### Arquivos relevantes e dependentes

**Backend:**
- `src/main/resources/db/migration/` — Novas migracoes V16, V17, V18
- `src/main/kotlin/.../domain/budget/` — Novo bounded context (entities, usecases, gateways)
- `src/main/kotlin/.../application/budget/` — Novo modulo (models, repositories, providers, controller)
- `src/main/kotlin/.../domain/payment_methods/entity/PaymentMethodSummary.kt` — Referencia para padrao de agregacao
- `src/main/kotlin/.../application/payment_methods/application/GetPaymentMethodsSummaryProvider.kt` — Referencia para padrao de query SQL

**Frontend:**
- `src/pages/Tab1.tsx` — Modificar para integrar dados reais do planejamento
- `src/App.tsx` — Adicionar rota /budget
- `src/services/budgetService.ts` — Novo service
- `src/types/budget.ts` — Novos tipos
- `src/pages/BudgetPage.tsx` — Nova pagina
- `src/components/BudgetSummaryCard.tsx` — Novo componente
- `src/config/api.ts` — Referencia para base URL

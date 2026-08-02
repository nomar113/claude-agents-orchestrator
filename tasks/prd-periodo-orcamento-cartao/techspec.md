# Tech Spec: Periodo por Meio de Pagamento no Orcamento

## Resumo Executivo

A feature adiciona uma tabela `budget_payment_periods` que armazena, para cada orcamento, o range de datas (startDate/endDate) por meio de pagamento. A logica atual de CASE no SQL do `GetBudgetSummaryProvider` (que usa `closingDay` para determinar o mes de uma compra) sera **substituida** por um filtro direto usando os ranges configurados. No frontend, uma nova secao colapsavel aparece apos o "Planejado vs Real" com campos de data mascarados (dd/mm/yyyy) por meio de pagamento. Ao criar ou duplicar um orcamento, os ranges sao auto-calculados com base no `closingDay`.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (novos/modificados):**
- `BudgetPaymentPeriod` — Nova entidade de dominio para o range de datas por payment method por budget.
- `BudgetPaymentPeriodModel` — Modelo JPA para persistencia.
- `BudgetPaymentPeriodRepository` — Repositorio JPA.
- `GetBudgetSummaryProvider` — **Modificado**: substituir CASE do closingDay por JOIN com budget_payment_periods.
- `CreateBudgetProvider` — **Modificado**: ao criar budget, gerar periods automaticamente.
- `DuplicateBudgetProvider` — **Modificado**: ao duplicar, recalcular periods para o mes destino.
- `BudgetController` — **Modificado**: novo endpoint PUT para atualizar periods; incluir periods no response do GET.
- `BudgetSummaryResponse` — **Modificado**: incluir lista de periods no DTO.

**Frontend (novos/modificados):**
- `BudgetPeriodSection` — Novo componente: secao colapsavel com cards por meio de pagamento.
- `BudgetPeriodCard` — Novo componente: card individual com campos De/Ate mascarados.
- `BudgetPage.tsx` — **Modificado**: renderizar BudgetPeriodSection apos BudgetSummarySection.
- `budgetService.ts` — **Modificado**: novo endpoint para atualizar periods.
- `budget.ts` — **Modificado**: novos tipos para BudgetPaymentPeriod.

**Fluxo de dados:**
1. Criar/duplicar budget → backend calcula periods com base no closingDay → persiste.
2. GET /budgets → retorna budget com periods incluso.
3. Frontend renderiza secao com periods.
4. Usuario edita datas → PUT /budgets/{id}/periods → backend persiste e recalcula totais.
5. GET /budgets recalcula "Real" usando ranges dos periods (nao mais CASE do closingDay).

## Design de Implementacao

### Interfaces Principais

```kotlin
// Entidade de dominio
data class BudgetPaymentPeriod(
    val id: Long = 0,
    val budgetId: Long,
    val paymentMethodId: Long,
    val startDate: LocalDate,
    val endDate: LocalDate
)

// Request para atualizar periods
data class UpdateBudgetPeriodsRequest(
    val periods: List<PeriodEntry>
)

data class PeriodEntry(
    val paymentMethodId: Long,
    val startDate: LocalDate,  // formato: yyyy-MM-dd
    val endDate: LocalDate
)
```

### Modelos de Dados

**Nova tabela: `budget_payment_periods`**

```sql
CREATE TABLE budget_payment_periods (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    budget_id BIGINT NOT NULL,
    payment_method_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bpp_budget FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE,
    CONSTRAINT fk_bpp_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id),
    CONSTRAINT uq_bpp_budget_pm UNIQUE (budget_id, payment_method_id)
);
```

**Calculo auto de datas (logica no backend):**
- CREDIT_CARD com closingDay X: startDate = dia (X+1) do mes anterior, endDate = dia X do mes corrente.
- PIX (sem closingDay): startDate = dia 1 do mes, endDate = ultimo dia do mes.
- Se closingDay > dias do mes: usar ultimo dia do mes como fallback.

### Endpoints de API

- `GET /budgets?month={YYYY-MM}` — **Modificado**: response inclui campo `periods: List<BudgetPaymentPeriodResponse>` com `paymentMethodId`, `paymentMethodName`, `startDate`, `endDate`, `closingDay`.
- `PUT /budgets/{budgetId}/periods` — **Novo**: atualiza os periods de um budget. Body: `UpdateBudgetPeriodsRequest`. Validacao: endDate >= startDate.

### SQL do "Real" (substituicao do CASE)

```sql
SELECT pn.category_id, COALESCE(SUM(pn.amount), 0) AS total
FROM payment_notifications pn
INNER JOIN budget_payment_periods bpp
    ON pn.payment_method_id = bpp.payment_method_id
    AND bpp.budget_id = ?
WHERE pn.category_id IS NOT NULL
  AND pn.deleted_at IS NULL
  AND pn.purchased_at >= bpp.start_date
  AND pn.purchased_at < DATE_ADD(bpp.end_date, INTERVAL 1 DAY)
GROUP BY pn.category_id
```

O INNER JOIN com `budget_payment_periods` substitui o CASE anterior. Compras de meios de pagamento sem period configurado nao sao contabilizadas (comportamento intencional — so CREDIT_CARD e PIX tem periods).

A mesma logica se aplica ao calculo de `paymentMethodTotals`.

## Pontos de Integracao

- **PaymentMethod**: leitura do `closingDay` e `type` para auto-calculo dos periods.
- **PaymentNotification**: tabela fonte dos valores "Real", agora filtrada via JOIN com periods.
- Sem integracoes externas.

## Abordagem de Testes

### Testes Unidade

- Logica de calculo de datas: closingDay no meio do mes, no dia 1, no dia 31, mes com 28/29/30/31 dias.
- Validacao: endDate < startDate deve rejeitar.
- Calculo para PIX (sem closingDay): deve usar dia 1 a ultimo dia.

### Testes de Integracao

- Criar budget → verificar que periods foram gerados para todos CREDIT_CARD e PIX.
- Duplicar budget para outro mes → verificar que periods foram recalculados.
- Atualizar period → verificar que GET retorna valores "Real" recalculados.
- Deletar payment method → verificar cascade ou tratamento adequado.

### Testes E2E

- Navegar para orcamento → verificar secao "Periodo por Meio de Pagamento" visivel.
- Entrar em modo edicao → alterar data → salvar → verificar que totais "Real" mudaram.
- Colapsar/expandir secao.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migration SQL** — Criar tabela `budget_payment_periods`. (sem dependencias)
2. **Entidade + Repositorio** — `BudgetPaymentPeriod`, `BudgetPaymentPeriodModel`, `BudgetPaymentPeriodRepository`. (depende de 1)
3. **Auto-calculo na criacao** — Modificar `CreateBudgetProvider` para gerar periods ao criar budget. (depende de 2)
4. **Modificar query do Real** — Substituir CASE por JOIN em `GetBudgetSummaryProvider`. (depende de 2)
5. **Endpoint PUT periods** — Novo endpoint para editar periods. (depende de 2)
6. **Response do GET** — Incluir periods no `BudgetSummaryResponse`. (depende de 2)
7. **Duplicacao** — Modificar `DuplicateBudgetProvider` para recalcular periods. (depende de 3)
8. **Frontend: tipos + service** — Novos tipos e chamada API. (depende de 6)
9. **Frontend: componentes** — `BudgetPeriodSection` e `BudgetPeriodCard`. (depende de 8)
10. **Frontend: integracao** — Renderizar na BudgetPage com modo edicao. (depende de 9)

### Dependencias Tecnicas

- Nenhuma dependencia externa nova.
- Requer que todos os payment methods do tipo CREDIT_CARD tenham `closingDay` preenchido (dados existentes ja atendem).

## Monitoramento e Observabilidade

- Log level INFO ao criar periods automaticamente (budget_id, qtd periods).
- Log level WARN se payment method CREDIT_CARD nao tem closingDay (fallback para dia 1-ultimo).
- Metricas existentes do endpoint GET /budgets ja cobrem latencia.

## Consideracoes Tecnicas

### Decisoes Principais

1. **Substituir CASE por JOIN**: elimina logica complexa no SQL e da controle total ao usuario. Trade-off: se nao houver period, a compra nao entra no Real (mitigado pela criacao automatica).
2. **Input mascarado vs IonDatetime**: usuario preferiu input mascarado dd/mm/yyyy por ser mais compacto e consistente com o design existente.
3. **Recalcular ao duplicar**: garante que os periods fazem sentido para o mes destino, evitando confusao.

### Riscos Conhecidos

- **Migracao de dados**: orcamentos existentes nao terao periods. Solucao: ao carregar um budget sem periods, o backend gera automaticamente (lazy creation) e persiste.
- **closingDay no fim do mes**: meses com menos dias (fevereiro) precisam de clamping. Usar `Math.min(closingDay, yearMonth.lengthOfMonth())`.

### Conformidade com Skills Padroes

- `executar-task` — Cada task deve ter testes e passar typecheck/lint/build.
- `executar-review` — Code review completo apos implementacao.
- `task-reviewer` — Review automatico apos cada task.

### Arquivos relevantes e dependentes

**Backend:**
- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/GetBudgetSummaryProvider.kt` — SQL do Real (critico)
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/rest/BudgetController.kt` — Endpoints
- `src/main/kotlin/br/com/nomar/controlai/domain/budget/entity/Budget.kt` — Entidade
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/database/repository/BudgetRepository.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/entity/PaymentMethod.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `src/main/resources/db/migration/` — Migrations

**Frontend:**
- `src/pages/BudgetPage.tsx` — Pagina principal
- `src/components/BudgetSummarySection.tsx` — Planejado vs Real
- `src/services/budgetService.ts` — API calls
- `src/types/budget.ts` — Tipos
- `src/pages/BudgetPage.css` — Estilos
- `src/components/DuplicateMonthModal.tsx` — Referencia para IonDatetime

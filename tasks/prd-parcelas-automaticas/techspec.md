# Tech Spec: Controle de Parcelas Automatico

## Resumo Executivo

Esta especificacao tecnica detalha a implementacao do controle automatico de parcelas no ControlAi. A solucao adota uma tabela filha `installments` vinculada a `payment_notifications`, onde cada parcela futura e gerada eagerly no momento do registro da compra. O backend (Kotlin/Spring Boot) expoe endpoints para CRUD de parcelas e projecao de comprometimento futuro. O frontend (React/Ionic) adiciona campo de parcelas no formulario de entrada manual, badges de parcela nas listagens e um card de projecao na Home (Tab1).

A abordagem prioriza simplicidade: sem jobs agendados, sem scheduler, todas as parcelas sao criadas atomicamente em uma unica transacao ao registrar a compra. As datas seguem a regra "mesmo dia do mes seguinte", ajustando para o ultimo dia em meses curtos.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Novos componentes:**

- `installments` (tabela MySQL) — Armazena cada parcela individual com FK para `payment_notifications`
- `Installment` (JPA Model) — Entidade JPA mapeando a tabela `installments`
- `InstallmentRepository` (Spring Data) — Repositorio JPA para queries de parcelas
- `CreateInstallmentsProvider` (Application) — Logica de geracao das N parcelas com calculo de datas
- `InstallmentController` (REST) — Endpoints para listar, editar, cancelar parcelas
- `InstallmentResponse` (DTO) — Formato de resposta da API para parcelas
- `installmentService.ts` (Frontend) — Servico HTTP para comunicacao com API de parcelas
- `InstallmentBadge` (Componente React) — Badge visual "3/10" para listagens
- Card de projecao na Tab1 — Exibe comprometimento futuro com parcelas

**Componentes modificados:**

- `PaymentNotificationController` — `createManualNotification` passa a invocar `CreateInstallmentsProvider` quando `numberOfInstallments > 1`
- `ManualEntryPage.tsx` — Campo de numero de parcelas + preview do parcelamento
- `PurchaseList.tsx` — Exibe badge de parcela quando aplicavel
- `Tab1.tsx` — Novo card de projecao de comprometimento futuro
- `PurchaseDetail.tsx` — Secao com lista de todas as parcelas da compra
- `PurchaseRepository` — Query UNION inclui informacoes de parcela

**Fluxo de dados:**

1. Usuario registra compra com N parcelas no ManualEntryPage
2. Frontend envia POST `/payments/notifications/manual` com `numberOfInstallments: N`
3. Backend cria `payment_notification` pai e N registros em `installments` atomicamente
4. Frontend busca parcelas via GET `/installments?parentId={id}` ou endpoints de projecao
5. Tab1 busca projecao via GET `/installments/projection`

## Design de Implementacao

### Interfaces Principais

```kotlin
// Provider para geracao atomica de parcelas
class CreateInstallmentsProvider(
    private val installmentRepository: InstallmentRepository,
) {
    fun execute(
        parentId: Long,
        totalInstallments: Int,
        amount: BigDecimal,
        startDate: LocalDateTime,
    ): List<Installment>
}

// Repository Spring Data
interface InstallmentRepository : JpaRepository<Installment, Long> {
    fun findByParentIdOrderByInstallmentNumber(parentId: Long): List<Installment>
    fun findByParentIdAndCancelledAtIsNull(parentId: Long): List<Installment>
    
    @Query("""
        SELECT YEAR(i.due_date) as year, MONTH(i.due_date) as month,
               SUM(i.amount) as total, COUNT(i.id) as count
        FROM installments i
        WHERE i.cancelled_at IS NULL
          AND i.due_date >= :startDate
          AND i.due_date < :endDate
        GROUP BY YEAR(i.due_date), MONTH(i.due_date)
        ORDER BY year, month
    """, nativeQuery = true)
    fun getMonthlyProjection(
        startDate: LocalDateTime,
        endDate: LocalDateTime,
    ): List<MonthlyProjection>
}
```

```typescript
// Frontend - installmentService.ts
export async function listInstallments(parentId: number): Promise<Installment[]>;
export async function getProjection(): Promise<MonthlyProjection[]>;
export async function cancelFutureInstallments(parentId: number): Promise<void>;
export async function updateInstallment(id: number, data: UpdateInstallmentRequest): Promise<Installment>;
```

### Modelos de Dados

**Tabela `installments` (Flyway V15):**

```sql
CREATE TABLE installments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT NOT NULL,
    installment_number INT NOT NULL,
    total_installments INT NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    due_date DATE NOT NULL,
    cancelled_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_installment_parent FOREIGN KEY (parent_id)
        REFERENCES payment_notifications (id),
    UNIQUE KEY uk_parent_number (parent_id, installment_number)
);
```

**Entidade JPA:**

```kotlin
@Entity
@Table(name = "installments")
data class Installment(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "parent_id", nullable = false)
    val parentId: Long,

    @Column(name = "installment_number", nullable = false)
    val installmentNumber: Int,

    @Column(name = "total_installments", nullable = false)
    val totalInstallments: Int,

    @Column(nullable = false, precision = 19, scale = 2)
    val amount: BigDecimal,

    @Column(name = "due_date", nullable = false)
    val dueDate: LocalDate,

    @Column(name = "cancelled_at")
    val cancelledAt: LocalDateTime? = null,

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @Column(name = "updated_at", insertable = false, updatable = false)
    val updatedAt: LocalDateTime? = null,
)
```

**DTOs de resposta:**

```kotlin
data class InstallmentResponse(
    val id: Long,
    val parentId: Long,
    val installmentNumber: Int,
    val totalInstallments: Int,
    val amount: BigDecimal,
    val dueDate: LocalDate,
    val cancelled: Boolean,
) {
    companion object {
        fun from(i: Installment) = InstallmentResponse(
            id = i.id,
            parentId = i.parentId,
            installmentNumber = i.installmentNumber,
            totalInstallments = i.totalInstallments,
            amount = i.amount,
            dueDate = i.dueDate,
            cancelled = i.cancelledAt != null,
        )
    }
}

data class MonthlyProjectionResponse(
    val year: Int,
    val month: Int,
    val total: BigDecimal,
    val count: Int,
)
```

**Tipos TypeScript:**

```typescript
export interface Installment {
    id: number;
    parentId: number;
    installmentNumber: number;
    totalInstallments: number;
    amount: number;
    dueDate: string; // "2026-05-15"
    cancelled: boolean;
}

export interface MonthlyProjection {
    year: number;
    month: number;
    total: number;
    count: number;
}

export interface UpdateInstallmentRequest {
    amount?: number;
    categoryId?: number;
}
```

### Endpoints de API

| Metodo | Caminho | Descricao |
|--------|---------|-----------|
| `POST` | `/payments/notifications/manual` | (Modificado) Quando `numberOfInstallments > 1`, cria N registros em `installments` |
| `GET` | `/installments?parentId={id}` | Lista parcelas de uma compra |
| `GET` | `/installments/projection` | Projecao de comprometimento dos proximos 6 meses |
| `GET` | `/installments/active` | Lista todas as compras parceladas ativas (com parcelas pendentes) |
| `PATCH` | `/installments/{id}` | Edita valor de uma parcela futura |
| `DELETE` | `/installments/future?parentId={id}` | Cancela (soft delete) todas as parcelas futuras de uma compra |

**Detalhes do POST modificado (`/payments/notifications/manual`):**

Request body permanece o mesmo, mas quando `numberOfInstallments > 1`:
1. Cria o `payment_notification` pai (com `amount` = valor da parcela, nao total)
2. Cria N registros em `installments` com datas calculadas
3. Retorna `PaymentNotificationResponse` com campo adicional `installments: InstallmentResponse[]`

**GET `/installments/projection` Response:**

```json
[
    { "year": 2026, "month": 5, "total": 1589.23, "count": 8 },
    { "year": 2026, "month": 6, "total": 1200.00, "count": 6 },
    { "year": 2026, "month": 7, "total": 890.50, "count": 4 }
]
```

**GET `/installments/active` Response:**

```json
[
    {
        "parentId": 42,
        "merchantName": "Apple Store",
        "description": "iPhone 13",
        "amount": 589.90,
        "totalInstallments": 10,
        "currentInstallment": 3,
        "startDate": "2026-02-15",
        "endDate": "2026-11-15",
        "paymentMethodName": "Nubank",
        "categoryName": "Tecnologia",
        "totalValue": 5899.00,
        "remainingValue": 4129.30
    }
]
```

## Logica de Calculo de Datas

A data de cada parcela segue a regra "mesmo dia, mes seguinte":

```kotlin
fun calculateDueDate(startDate: LocalDate, installmentNumber: Int): LocalDate {
    val targetMonth = startDate.plusMonths((installmentNumber - 1).toLong())
    // Para dia 31 em meses com menos dias, usa ultimo dia do mes
    val dayOfMonth = minOf(startDate.dayOfMonth, targetMonth.lengthOfMonth())
    return targetMonth.withDayOfMonth(dayOfMonth)
}
```

Exemplos:
- Compra em 15/jan, 3x → 15/jan, 15/fev, 15/mar
- Compra em 31/jan, 3x → 31/jan, 28/fev (ou 29), 31/mar
- Compra em 30/mar, 2x → 30/mar, 30/abr

## Pontos de Integracao

Nao ha integracoes externas. Toda a logica e interna entre frontend e backend.

A unica integracao relevante e com o fluxo existente de `payment_notifications`:
- O campo `numberOfInstallments` ja existe na tabela e no request
- O `createManualNotification` sera modificado para invocar `CreateInstallmentsProvider`
- A transacao deve ser atomica: se falhar ao criar parcelas, o `payment_notification` pai tambem deve ser revertido

## Abordagem de Testes

### Testes de Unidade

**Backend:**
- `CreateInstallmentsProvider`: testar geracao de N parcelas com datas corretas, incluindo edge cases (dia 31, dia 29/fev, parcela unica)
- `InstallmentResponse.from()`: mapeamento correto de entidade para DTO

**Frontend:**
- `installmentService.ts`: mock de fetch/CapacitorHttp para cada endpoint
- `InstallmentBadge`: renderiza "3/10" corretamente
- Card de projecao: renderiza dados de projecao, loading state, empty state

### Testes de Integracao

**Backend (SpringBootTest + MockMvc + H2):**

1. **Criacao de parcelas**: POST manual com `numberOfInstallments: 10` → verifica 10 registros em `installments` com datas corretas
2. **Listagem por parent**: GET `/installments?parentId=X` → retorna parcelas ordenadas
3. **Projecao**: GET `/installments/projection` → retorna totais mensais corretos
4. **Cancelamento**: DELETE `/installments/future?parentId=X` → soft delete das parcelas futuras, mantendo as passadas
5. **Edicao**: PATCH `/installments/{id}` com novo valor → atualiza apenas a parcela especifica
6. **Atomicidade**: POST com categoryId invalido → nenhum registro criado (nem pai nem parcelas)

**Frontend (Vitest + @testing-library/react):**

1. ManualEntryPage com campo de parcelas: simular selecao de 3x e verificar preview
2. PurchaseList com badge de parcela
3. Tab1 com card de projecao

### Testes de E2E

Nao ha testes E2E com Playwright nesta fase. Os testes de integracao cobrem os fluxos criticos.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migracao Flyway V15**: Criar tabela `installments` (base para todo o resto)
2. **Backend: Model + Repository**: Entidade JPA `Installment` e `InstallmentRepository`
3. **Backend: CreateInstallmentsProvider**: Logica de geracao de parcelas com calculo de datas
4. **Backend: Modificar createManualNotification**: Integrar geracao de parcelas no fluxo existente
5. **Backend: InstallmentController**: Endpoints de listagem, projecao, cancelamento e edicao
6. **Frontend: installmentService + tipos**: Servico HTTP e interfaces TypeScript
7. **Frontend: Campo de parcelas no ManualEntryPage**: Input numerico + preview do parcelamento
8. **Frontend: InstallmentBadge + integracao nas listagens**: Badge "3/10" no PurchaseList e Tab2
9. **Frontend: Detalhes de parcelas no PurchaseDetail**: Secao com lista de parcelas da compra
10. **Frontend: Card de projecao na Tab1**: Card com comprometimento futuro

### Dependencias Tecnicas

- Flyway V14 (add category_id) ja aplicada — V15 e a proxima migracao disponivel
- `payment_notifications` deve existir (V1) — ja existe
- ManualEntryPage ja tem campo `numberOfInstallments` hardcoded como 1 — sera modificado
- Nenhuma dependencia de infraestrutura externa

## Monitoramento e Observabilidade

Nao ha requisitos especificos de monitoramento para esta funcionalidade. O logging padrao do Spring Boot (via SLF4J) ja cobre:

- Logs de criacao de parcelas (INFO): "Created {n} installments for notification {id}"
- Logs de cancelamento (INFO): "Cancelled {n} future installments for notification {id}"
- Logs de erro (ERROR): falhas na transacao atomica

## Consideracoes Tecnicas

### Decisoes Principais

1. **Tabela filha vs registros independentes**: Escolhida tabela filha `installments` com FK para `payment_notifications`. Evita duplicacao de dados (merchantName, category, paymentMethod ficam apenas no pai). Mais limpo para queries de agrupamento.

2. **Geracao eager vs lazy**: Todas as parcelas criadas no momento do registro. Elimina necessidade de scheduler/cron job. Simplifica projecao futura (basta consultar a tabela). Trade-off: mais registros no banco, porem o volume e insignificante (max ~60 parcelas por compra).

3. **Data: mesmo dia do mes seguinte**: Simples e alinhado com o comportamento real dos bancos brasileiros. Nao requer dados de ciclo de fatura. `LocalDate.plusMonths()` do Java trata edge cases (dia 31 em meses curtos).

4. **Soft delete para cancelamento**: `cancelled_at TIMESTAMP` em vez de DELETE fisico. Mantem historico para auditoria conforme requisito do PRD.

5. **Amount no pai = valor da parcela**: O `payment_notification.amount` armazena o valor da parcela individual (nao o total), consistente com o comportamento atual onde `amount` e o que aparece na fatura do mes.

### Riscos Conhecidos

1. **Retrocompatibilidade**: Compras existentes com `numberOfInstallments > 1` nao terao registros em `installments`. A UI deve tratar graciosamente (exibir o valor existente sem badge de parcela detalhado).

2. **Volume de dados**: Uma compra em 24x gera 24 registros. Com centenas de compras parceladas, a tabela pode crescer. Mitigacao: indice em `(parent_id, installment_number)` via UNIQUE KEY e indice em `due_date` para queries de projecao.

3. **Concorrencia**: Dois requests simultaneos criando parcelas para o mesmo parent. Mitigacao: `@Transactional` e UNIQUE KEY `(parent_id, installment_number)` previnem duplicatas.

### Conformidade com Skills Padroes

- `executar-task` — Cada tarefa sera implementada seguindo o workflow da skill
- `task-review` — Review automatico apos cada tarefa
- `executar-review` — Code review completo apos todas as tarefas

### Arquivos relevantes e dependentes

**Backend (`/Volumes/SSD480GB/projects/controlai`):**
- `src/main/resources/db/migration/V15__create_installments_table.sql` (novo)
- `src/main/kotlin/.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `src/main/kotlin/.../payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `src/main/kotlin/.../payments_notification/entrypoint/rest/request/ManualPaymentNotificationRequest.kt`
- `src/main/kotlin/.../payments_notification/entrypoint/rest/response/PaymentNotificationResponse.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt`
- Novos: `Installment.kt`, `InstallmentRepository.kt`, `InstallmentController.kt`, `InstallmentResponse.kt`, `CreateInstallmentsProvider.kt`

**Frontend (`/Volumes/SSD480GB/projects/controlai-frontend`):**
- `src/pages/ManualEntryPage.tsx`
- `src/pages/Tab1.tsx`
- `src/pages/PurchaseDetail.tsx`
- `src/components/PurchaseList.tsx`
- Novos: `src/services/installmentService.ts`, `src/types/installment.ts`, `src/components/InstallmentBadge.tsx`

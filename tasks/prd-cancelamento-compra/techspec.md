# Tech Spec — Cancelamento de Compra

## Resumo Executivo

A solucao adiciona o conceito de cancelamento como um campo `cancelled_at TIMESTAMP NULL` nas tabelas `payment_notifications` e `purchase_invoices`, seguindo o padrao ja existente de `deleted_at` e consistente com `cancelled_at` da tabela `installments`. O backend expoe endpoints dedicados `PATCH /{id}/cancel` para cada tipo de compra, e as queries de totais/orcamento passam a filtrar registros cancelados. No frontend (Ionic React), a lista migra de swipe customizado para `IonItemSliding` (suporte nativo a multiplas acoes) e adiciona long press com `IonActionSheet` para menu de contexto.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (Kotlin/Spring Boot):**

- **Migration V18** — Adiciona coluna `cancelled_at` em ambas as tabelas
- **PaymentNotification entity** — Novo campo `cancelledAt: LocalDateTime?`
- **PurchaseInvoiceModel entity** — Novo campo `cancelledAt: LocalDateTime?`
- **CancelPaymentNotificationProvider** — Use case de cancelamento de notificacao
- **CancelPurchaseInvoiceProvider** — Use case de cancelamento de invoice
- **PurchaseRepository** — Query UNION atualizada para incluir status de cancelamento
- **GetBudgetSummaryProvider** — Queries de totais atualizadas para excluir cancelados

**Frontend (Ionic React/Capacitor):**

- **PurchaseList.tsx** — Migrar para `IonItemSliding` com acoes de cancelar e excluir
- **PurchaseDetail.tsx** — Banner de cancelamento, botao "Cancelar compra", estados visuais
- **purchaseService.ts** — Novos metodos `cancelNotification(id)` e `cancelInvoice(id)`
- **Tab1.tsx** — Calculo de total filtrado exclui cancelados
- **Novos estilos CSS** — Opacidade 55%, line-through, badge amber, icone neutro

**Fluxo de dados:**
1. Usuario dispara cancelamento (botao, swipe ou long press)
2. Dialog de confirmacao exibido
3. Frontend chama `PATCH /payments/notifications/{id}/cancel` ou `PATCH /purchases/invoices/{id}/cancel`
4. Backend seta `cancelled_at = NOW()` e retorna 200
5. Frontend atualiza lista localmente (re-render com estilo cancelado)
6. Totais recalculados excluindo cancelados

## Design de Implementacao

### Interfaces Principais

```kotlin
// Domain - Gateway interface
interface CancelPurchaseGateway {
    fun cancelNotification(id: Long): Result<Unit>
    fun cancelInvoice(id: Long): Result<Unit>
}

// Application - Use Case
class CancelPaymentNotificationProvider(
    private val repository: PaymentNotificationRepository
) : CancelPaymentNotificationUseCase {
    @Transactional
    override fun execute(id: Long): Result<Unit> {
        val model = repository.findById(id)
            .orElseThrow { NoSuchElementException("PaymentNotification not found: $id") }
        if (model.cancelledAt != null) {
            return Result.failure(IllegalStateException("Already cancelled"))
        }
        repository.save(model.copy(cancelledAt = LocalDateTime.now()))
        return Result.success(Unit)
    }
}
```

```typescript
// Frontend - Service
export const cancelNotification = (id: number): Promise<void> =>
  httpClient.patch(`/payments/notifications/${id}/cancel`);

export const cancelInvoice = (id: number): Promise<void> =>
  httpClient.patch(`/purchases/invoices/${id}/cancel`);
```

### Modelos de Dados

**Migration V18:**

```sql
ALTER TABLE payment_notifications
ADD COLUMN cancelled_at TIMESTAMP NULL DEFAULT NULL;

ALTER TABLE purchase_invoices
ADD COLUMN cancelled_at TIMESTAMP NULL DEFAULT NULL;
```

**Entidade atualizada (PaymentNotification):**

```kotlin
@Entity
@Table(name = "payment_notifications")
@SQLRestriction("deleted_at IS NULL")
data class PaymentNotification(
    // ... campos existentes ...
    @Column(name = "cancelled_at")
    val cancelledAt: LocalDateTime? = null,
)
```

**Projection atualizada (PurchaseProjection):**

```kotlin
interface PurchaseProjection {
    // ... campos existentes ...
    fun getCancelledAt(): LocalDateTime?
}
```

**Response DTO:**

```kotlin
data class PaymentNotificationResponse(
    // ... campos existentes ...
    val cancelledAt: String? = null, // ISO 8601
)
```

### Endpoints de API

| Metodo | Caminho | Descricao |
|--------|---------|-----------|
| `PATCH` | `/payments/notifications/{id}/cancel` | Cancela uma notificacao de pagamento |
| `PATCH` | `/purchases/invoices/{id}/cancel` | Cancela uma nota fiscal |

**Response de sucesso:** `200 OK` (sem body)

**Responses de erro:**
- `404` — Compra nao encontrada
- `409` — Compra ja cancelada
- `422` — Compra ja excluida (deleted_at preenchido)

## Pontos de Integracao

Nenhuma integracao externa necessaria. O cancelamento e puramente interno ao app — nao se comunica com bancos ou operadoras de cartao.

## Abordagem de Testes

### Testes Unidade

- **CancelPaymentNotificationProvider**: cancelamento com sucesso, item nao encontrado, item ja cancelado, item ja excluido
- **CancelPurchaseInvoiceProvider**: mesmos cenarios
- **Budget calculation**: verificar que totais excluem `cancelled_at IS NOT NULL`

### Testes de Integracao

- **Repository tests**: Verificar que a query UNION retorna `cancelledAt` corretamente
- **Controller tests**: PATCH /cancel retorna 200, 404, 409 nos cenarios corretos
- **Budget integration**: Criar compras, cancelar algumas, verificar que totais sao recalculados

### Testes de E2E

- **Cancelar pelo detalhe**: Navegar ate detalhe > clicar "Cancelar compra" > confirmar > verificar estilo cancelado na lista
- **Cancelar por swipe**: Swipe no item > opcao cancelar > confirmar > verificar badge "CANCELADA"
- **Cancelar por long press**: Long press > action sheet > "Cancelar compra" > confirmar
- **Totais**: Verificar que total filtrado e budget excluem compra cancelada

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migration V18** — Base de dados primeiro (nao-breaking, coluna nullable)
2. **Entidades e DTOs** — Atualizar models e projections com `cancelledAt`
3. **Use cases de cancelamento** — Providers + interfaces de gateway
4. **Controllers** — Novos endpoints PATCH /cancel
5. **Queries de totais** — Atualizar budget e listagem para filtrar cancelados
6. **Testes backend** — Unitarios e integracao
7. **Service frontend** — Metodos de API no purchaseService
8. **PurchaseList (IonItemSliding)** — Migrar swipe e adicionar acao cancelar
9. **Long press + IonActionSheet** — Menu de contexto
10. **PurchaseDetail** — Banner, botao, estados visuais de cancelamento
11. **Estilos CSS** — Opacidade, line-through, badge amber, icone neutro
12. **Calculo de totais frontend** — Filtrar cancelados do total exibido
13. **Testes E2E** — Playwright cobrindo os 3 fluxos

### Dependencias Tecnicas

- Nenhuma dependencia externa bloqueante
- `react-native-gesture-handler` nao e necessario (app usa Ionic, nao React Native)
- `IonItemSliding` ja esta disponivel no Ionic 8.5 instalado

## Monitoramento e Observabilidade

- **Log INFO** ao cancelar compra: `"Purchase cancelled: type={notification|invoice}, id={id}"`
- **Log WARN** em tentativas de cancelar item ja cancelado (possivel bug no frontend)
- **Metricas**: Nao necessarias neste MVP — volume de cancelamentos pode ser extraido do banco via query simples

## Consideracoes Tecnicas

### Decisoes Principais

| Decisao | Justificativa | Alternativa rejeitada |
|---------|---------------|-----------------------|
| `cancelled_at TIMESTAMP` | Consistente com `deleted_at` e `installments.cancelled_at`. Imutavel (uma vez setado, definitivo). Sem necessidade de extensibilidade. | ENUM `status` — mais complexo, requer ALTER TABLE para novos estados |
| `PATCH /{id}/cancel` dedicado | Semantica clara. DELETE permanece como exclusao logica. Nao quebra clientes existentes. | Reutilizar DELETE com parametro — confuso semanticamente |
| `IonItemSliding` | Componente oficial Ionic. Suporte nativo a multiplas acoes em lados opostos. Melhor acessibilidade e manutencao. | Manter touch custom — mais complexidade manual, dificil suportar 2 acoes |
| `IonActionSheet` para long press | Padrao mobile nativo (iOS/Android). Familiar ao usuario. Facil de implementar. | IonPopover — menos padrao em contexto mobile |

### Riscos Conhecidos

- **Migracao em producao**: A coluna `cancelled_at` e nullable, entao o ALTER TABLE e non-blocking em MySQL. Sem risco de lock.
- **Consistencia do `@SQLRestriction`**: O filtro `deleted_at IS NULL` continuara funcionando. Compras canceladas (com `cancelled_at` preenchido mas `deleted_at` nulo) continuarao visiveis na listagem — comportamento desejado.
- **IonItemSliding migration**: Requer refatorar o componente PurchaseList. Risco moderado de regressao visual — mitigado com testes E2E.

### Conformidade com Skills Padroes

Nenhuma skill especifica encontrada nos projetos controlai ou controlai-frontend (`.claude/skills/` nao existe nesses repos). O desenvolvimento segue os padroes existentes do projeto:
- Clean Architecture (Domain > Application > Entrypoint)
- Use Case pattern com Result<T>
- Flyway migrations sequenciais
- Ionic components para UI

### Referencia Visual

Os artboards de design estao no Paper (arquivo "ControlAI"):
- **"Cancelamento — Lista"** — Estilo visual de itens cancelados na listagem (opacidade, badge, line-through)
- **"Cancelamento — Detalhe"** — Banner amber, estados do botao, icone neutro
- **"Cancelamento — Acao + Confirmacao"** — Swipe actions, action sheet e dialog de confirmacao

Esses artboards sao a referencia autoritativa para cores, espacamentos e hierarquia visual da implementacao frontend.

### Arquivos relevantes e dependentes

**Backend:**
- `src/main/resources/db/migration/` — Nova migration V18
- `src/main/kotlin/.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt`
- `src/main/kotlin/.../payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt`
- `src/main/kotlin/.../budget/application/GetBudgetSummaryProvider.kt`

**Frontend:**
- `src/components/PurchaseList.tsx`
- `src/pages/PurchaseDetail.tsx`
- `src/pages/Tab1.tsx`
- `src/services/purchaseService.ts`
- `src/pages/Tab1.css`
- `src/pages/PurchaseDetail.css`

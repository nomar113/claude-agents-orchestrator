# Tech Spec — Sugestao de Associacao Invoice <> Payment Notification

## Resumo Executivo

A solucao implementa um endpoint REST que, dado um `purchase_invoice`, busca `payment_notifications` candidatas a associacao por valor exato e proximidade temporal (+-1h), alem de uma tela mobile no app Ionic React que consome esse endpoint e exibe os resultados ao usuario.

No backend, um novo `SuggestionController` expoe `GET /purchases/invoices/{id}/suggestions`. A query utiliza um indice composto `(amount, purchased_at)` para garantir latencia <500ms. No frontend, uma nova `SuggestionsPage` acessivel via `/suggestions/:invoiceId` carrega os dados via API, exibe a lista rankeada por proximidade temporal e permite navegar ao detalhe de cada notificacao sugerida.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (controlai — Kotlin/Spring Boot):**

- **`SuggestionController`** (novo) — Controller REST dedicado. Recebe `invoiceId`, delega ao use case e retorna a lista de sugestoes.
- **`FindInvoiceSuggestionsUseCase`** (novo) — Orquestra: busca o invoice, valida existencia, chama o gateway de sugestoes.
- **`FindInvoiceSuggestionsGateway`** (nova interface) — Contrato do dominio para buscar sugestoes.
- **`FindInvoiceSuggestionsProvider`** (novo) — Implementacao do gateway. Monta a query com os parametros do invoice.
- **`PaymentNotificationRepository`** (modificado) — Novo metodo `findSuggestionsByAmountAndDateRange` com `@Query` nativa.
- **`SuggestionResponse`** (novo) — DTO de resposta com dados da payment_notification + delta temporal.
- **Migration `V__add_index_amount_purchased_at.sql`** (novo) — Indice composto para performance.

**Frontend (controlai-frontend — Ionic React):**

- **`SuggestionsPage.tsx`** (novo) — Pagina que exibe sugestoes. Usa `useParams` para obter `invoiceId`, busca invoice e sugestoes via API.
- **`SuggestionsPage.css`** (novo) — Estilos da pagina seguindo prefixo `sg-`.
- **`purchaseService.ts`** (modificado) — Nova funcao `getInvoiceSuggestions()` e tipo `SuggestionResponse`.
- **`App.tsx`** (modificado) — Nova rota `/suggestions/:invoiceId`.
- **`PurchaseDetail.tsx`** (modificado) — Botao "Associar pagamento" na tela de detalhe do invoice.

**Fluxo de dados:**
```
PurchaseDetail → (navega) → SuggestionsPage
  → getInvoiceSuggestions(invoiceId) → GET /purchases/invoices/{id}/suggestions
    → SuggestionController → FindInvoiceSuggestionsUseCase
      → PurchaseInvoiceRepository.findById(id) [valida existencia]
      → FindInvoiceSuggestionsProvider → PaymentNotificationRepository.findSuggestions(amount, dateRange)
    → List<SuggestionResponse>
  → Renderiza lista / estado vazio
  → Tap no card → navega para /purchase/notification/:notificationId
```

## Design de Implementacao

### Interfaces Principais

```kotlin
// Domain Gateway
fun interface FindInvoiceSuggestionsGateway {
    fun execute(invoiceId: Long): Result<List<PaymentNotification>>
}

// UseCase
@Component
class FindInvoiceSuggestionsUseCase(
    private val purchaseInvoiceRepository: PurchaseInvoiceRepository,
    private val findSuggestionsGateway: FindInvoiceSuggestionsGateway,
) {
    fun execute(invoiceId: Long): Result<List<PaymentNotification>> {
        return runCatching {
            val invoice = purchaseInvoiceRepository.findById(invoiceId)
                .orElseThrow { NoSuchElementException("Invoice not found: $invoiceId") }
            findSuggestionsGateway.execute(invoice.id!!).getOrThrow()
        }
    }
}
```

### Modelos de Dados

```kotlin
// Response DTO
data class SuggestionResponse(
    val id: Long,
    val cardLastDigits: String?,
    val purchasedAt: LocalDateTime,
    val amount: BigDecimal,
    val merchantName: String,
    val numberOfInstallments: Int,
    val category: String?,
    val categoryId: Long?,
    val origin: String?,
    val originType: String?,
    val timeDeltaMinutes: Long, // abs(invoice.date - notification.purchasedAt) em minutos
) {
    companion object {
        fun from(notification: PaymentNotification, invoiceDate: OffsetDateTime): SuggestionResponse
    }
}
```

```typescript
// Frontend type
export interface SuggestionResponse {
  id: number;
  cardLastDigits: string | null;
  purchasedAt: string;
  amount: number;
  merchantName: string;
  numberOfInstallments: number;
  category: string | null;
  categoryId: number | null;
  origin: string | null;
  originType: string | null;
  timeDeltaMinutes: number;
}
```

### Endpoints de API

**`GET /purchases/invoices/{id}/suggestions`**

- **Descricao**: Retorna payment_notifications candidatas a associacao com o invoice informado.
- **Path param**: `id` (Long) — ID do purchase_invoice.
- **Response 200**: `List<SuggestionResponse>` (pode ser vazio).
- **Response 404**: Invoice nao encontrado.
- **Sem paginacao**: a janela de +-1h com valor exato limita naturalmente o volume de resultados.

### Query do Repository

```kotlin
@Query(
    value = """
        SELECT * FROM payment_notifications
        WHERE deleted_at IS NULL
          AND cancelled_at IS NULL
          AND amount = :amount
          AND purchased_at BETWEEN :startDate AND :endDate
          AND id NOT IN (
              SELECT payment_notification_id FROM invoice_notification_associations
              WHERE payment_notification_id IS NOT NULL
          )
        ORDER BY ABS(TIMESTAMPDIFF(SECOND, purchased_at, :invoiceDate)) ASC
    """,
    nativeQuery = true
)
fun findSuggestionsByAmountAndDateRange(
    @Param("amount") amount: BigDecimal,
    @Param("startDate") startDate: LocalDateTime,
    @Param("endDate") endDate: LocalDateTime,
    @Param("invoiceDate") invoiceDate: LocalDateTime,
): List<PaymentNotification>
```

> **Nota**: A sub-query de exclusao de notificacoes ja associadas depende da tabela de associacao definida no PRD futuro. Enquanto essa tabela nao existir, a clausula `NOT IN` deve ser removida ou adaptada. Como alternativa temporaria, retornar todas as notificacoes que fazem match (sem filtro de associacao).

### Migration

```sql
-- V{N}__add_index_amount_purchased_at_to_payment_notifications.sql
CREATE INDEX idx_pn_amount_purchased_at
    ON payment_notifications (amount, purchased_at);
```

O indice composto coloca `amount` primeiro (equality) e `purchased_at` segundo (range), seguindo a regra leftmost prefix do MySQL para maximo aproveitamento do indice.

## Pontos de Integracao

Nenhuma integracao externa. O endpoint consulta apenas o banco de dados local.

**Dependencia futura**: a clausula de exclusao de notificacoes ja associadas depende da tabela `invoice_notification_associations` que sera criada no PRD de associacao. Ate la, a query retorna todas as notificacoes que fazem match por valor e data.

## Abordagem de Testes

### Testes Unitarios

**Backend:**
- `FindInvoiceSuggestionsUseCaseTest` — Testar: invoice nao encontrado retorna erro; gateway retorna lista; gateway retorna lista vazia.
- `SuggestionResponseTest` — Testar calculo do `timeDeltaMinutes` com diferentes deltas.

**Frontend:**
- `SuggestionsPage.test.tsx` — Testar: loading state, lista com resultados, estado vazio, navegacao ao detalhe.

### Testes de Integracao

**Backend:**
- `SuggestionControllerIntegrationTest` — Usando `@SpringBootTest` + `@AutoConfigureMockMvc` + `JdbcTemplate`:
  - Inserir invoice e notifications no banco, chamar endpoint, validar response body.
  - Cenarios: match exato, sem match (valor diferente), sem match (fora da janela temporal), notification cancelada/deletada excluida, ordenacao por proximidade.
  - Invoice inexistente retorna 404.

### Testes E2E

- Nao aplicavel nesta fase. Sera adicionado junto ao PRD de associacao quando o fluxo completo existir.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migration do indice** — Pre-requisito para performance. Sem dependencias.
2. **Gateway + Provider + Repository method** — Camada de dados. Pode ser testada isoladamente.
3. **UseCase** — Orquestracao. Depende do gateway.
4. **Controller + Response DTO** — Exposicao REST. Depende do use case.
5. **Testes de integracao backend** — Valida o fluxo completo.
6. **Service function + type frontend** — `getInvoiceSuggestions()` em `purchaseService.ts`.
7. **SuggestionsPage + CSS** — Tela completa com loading, lista e estado vazio.
8. **Rota no App.tsx + botao no PurchaseDetail** — Ponto de entrada.
9. **Testes frontend** — Testes unitarios da pagina.

### Dependencias Tecnicas

- **Nenhuma dependencia bloqueante**. O backend e frontend podem ser desenvolvidos em paralelo apos a migration.
- **Dependencia futura (nao bloqueante)**: tabela de associacao para filtrar notificacoes ja associadas.

## Monitoramento e Observabilidade

- **Logs**: log `INFO` no use case ao receber requisicao (invoiceId, quantidade de sugestoes retornadas). Log `WARN` se invoice nao encontrado.
- **Metricas**: Spring Boot Actuator ja expoe metricas HTTP. O endpoint sera automaticamente rastreado em `/actuator/metrics/http.server.requests`.
- **Latencia**: monitorar via metricas HTTP que a resposta fique <500ms. Se necessario, adicionar `@Timed` do Micrometer.

## Consideracoes Tecnicas

### Decisoes Principais

| Decisao | Escolha | Justificativa |
|---------|---------|---------------|
| Controller | Novo `SuggestionController` | Isolamento de dominio. Sugestoes sao um conceito separado de invoices/notifications. |
| Navegacao frontend | URL params + API fetch | Consistente com padrao existente. Funciona com deep links e refresh. |
| Indice | `(amount, purchased_at)` | Equality primeiro, range depois. Maximo aproveitamento do B-tree. |
| Tap no card | Navega para detalhe da notificacao | Acao util imediata sem depender do PRD de associacao. |
| Paginacao | Nenhuma | Janela temporal de 2h com valor exato limita resultados naturalmente (<10 esperados). |

### Riscos Conhecidos

- **Tipos de data inconsistentes**: `PurchaseInvoiceModel.date` e `OffsetDateTime`, `PaymentNotification.purchasedAt` e `LocalDateTime`. A conversao deve considerar timezone do servidor.
- **Tabela de associacao inexistente**: Ate o PRD de associacao ser implementado, a query nao filtra notificacoes ja associadas. Isso pode gerar sugestoes duplicadas se o usuario associar manualmente por outro meio.
- **Volume de dados**: Se houver muitas notifications com mesmo valor exato na janela de 2h (improvavel no uso real), a query pode retornar muitos resultados. Considerar LIMIT 20 como safety net.

### Conformidade com Skills Padrao

- **`executar-task`** — Cada tarefa deve seguir o fluxo: implementar, rodar testes, typecheck, build, lint.
- **`executar-review`** — Code review obrigatorio apos implementacao.
- **`task-reviewer`** — Review automatico ao concluir cada task.

### Arquivos Relevantes e Dependentes

**Backend (controlai):**
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/purchase_invoice/entrypoint/rest/PurchaseInvoiceController.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/purchase_invoice/entrypoint/database/repository/PurchaseInvoiceRepository.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/payments_notifications/model/PaymentNotification.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/purchase_invoice/model/PurchaseInvoiceModel.kt`
- `src/main/resources/db/migration/` — Flyway migrations

**Frontend (controlai-frontend):**
- `src/App.tsx` — Rotas
- `src/pages/PurchaseDetail.tsx` — Ponto de entrada (botao "Associar pagamento")
- `src/pages/PurchaseDetail.css`
- `src/services/purchaseService.ts` — Service functions e tipos
- `src/theme/variables.css` — Variaveis de tema

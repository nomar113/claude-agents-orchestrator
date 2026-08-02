# Tech Spec — Sugestão de NF a partir da Notificação de Pagamento

**PRD**: `tasks/prd-notificacao-sugestao-nf/prd.md`
**Designs (Paper — arquivo ControlAI)**:
- Tela com sugestão: artboard **"Detalhe — Notificação / Sugestão de NF"**
- Tela pós-associação: artboard **"Detalhe — Notificação / NF Associada"**

---

## Resumo Executivo

A feature implementa o fluxo inverso de associação: a partir do detalhe de uma `payment_notification`, o app exibe `purchase_invoices` candidatas e permite vinculação direta. O backend recebe dois novos endpoints em `PaymentNotificationController` — um de sugestões (busca por valor exato) e um de associação — e expõe `purchaseInvoiceId` + `associatedInvoice` no `PaymentNotificationResponse`. O frontend adiciona dois subcomponentes ao `PurchaseDetail` (`InvoiceSuggestionsSection` e `InvoiceAssociatedSection`) renderizados abaixo da seção PARCELAS somente para notificações.

---

## Arquitetura do Sistema

### Visão Geral dos Componentes

**Backend (Spring Boot / Kotlin):**

| Componente | Status | Responsabilidade |
|---|---|---|
| `PaymentNotificationController` | Modificado | +2 endpoints: sugestões e associação |
| `PaymentNotificationResponse` | Modificado | +`purchaseInvoiceId`, +`associatedInvoice` |
| `AssociatedInvoiceResponse` | Novo | DTO resumido da NF associada |
| `InvoiceSuggestionResponse` | Novo | DTO de NF candidata para sugestão |
| `FindNotificationInvoiceSuggestionsProvider` | Novo | Busca invoices com total == amount da notificação |
| `AssociateNotificationProvider` | Novo | Persiste `notification.purchaseInvoiceId` |
| `PurchaseInvoiceRepository` | Modificado | +query `findByTotalAndNotAssociated` |

**Frontend (React / Ionic / TypeScript):**

| Componente | Status | Responsabilidade |
|---|---|---|
| `purchaseService.ts` | Modificado | +tipos `InvoiceSuggestionItem`, `AssociatedInvoiceSummary`; +funções `getNotificationInvoiceSuggestions`, `associateNotificationToInvoice` |
| `PaymentNotificationDetail` | Modificado | +`purchaseInvoiceId`, +`associatedInvoice` |
| `PurchaseDetail.tsx` | Modificado | Renderiza seção de NF após PARCELAS (tipo notification) |
| `InvoiceSuggestionsSection.tsx` | Novo | Lista de NFs candidatas com botões Associar / Ignorar |
| `InvoiceAssociatedSection.tsx` | Novo | Card verde com dados da NF vinculada + link de navegação |

---

## Design de Implementação

### Interfaces Principais

**Backend — novos providers:**

```kotlin
// FindNotificationInvoiceSuggestionsProvider
fun execute(notificationId: Long): Result<List<InvoiceSuggestionResponse>>

// AssociateNotificationProvider  
fun execute(notificationId: Long, purchaseInvoiceId: Long): Result<PaymentNotificationResponse>
```

**Frontend — novos serviços:**

```typescript
getNotificationInvoiceSuggestions(notificationId: number): Promise<InvoiceSuggestionItem[]>
associateNotificationToInvoice(notificationId: number, purchaseInvoiceId: number): Promise<PaymentNotificationDetail>
```

### Modelos de Dados

**Backend — novos DTOs:**

```kotlin
data class InvoiceSuggestionResponse(
    val id: Long,
    val merchantName: String?,
    val cnpj: String?,
    val totalItems: Int?,
    val total: BigDecimal,
    val date: LocalDate,
)

data class AssociatedInvoiceResponse(
    val id: Long,
    val merchantName: String?,
    val cnpj: String?,
    val totalItems: Int?,
    val total: BigDecimal,
    val date: LocalDate,
)
```

**Backend — extensão de `PaymentNotificationResponse`:**

```kotlin
// Campos adicionados
val purchaseInvoiceId: Long? = null,
val associatedInvoice: AssociatedInvoiceResponse? = null,
```

O campo `associatedInvoice` é populado no `from(entity)` via join lazy com `PurchaseInvoiceRepository` sempre que `entity.purchaseInvoiceId != null`.

**Frontend — novos tipos:**

```typescript
export interface InvoiceSuggestionItem {
  id: number; merchantName: string | null; cnpj: string | null;
  totalItems: number | null; total: number; date: string;
}
export interface AssociatedInvoiceSummary {
  id: number; merchantName: string | null; cnpj: string | null;
  totalItems: number | null; total: number; date: string;
}
// Adicionados a PaymentNotificationDetail:
purchaseInvoiceId: number | null;
associatedInvoice: AssociatedInvoiceSummary | null;
```

### Endpoints de API

| Método | Caminho | Descrição |
|---|---|---|
| `GET` | `/payments/notifications/{id}/invoice-suggestions` | Retorna `List<InvoiceSuggestionResponse>` — invoices com `total == notification.amount`, sem associação existente, ordenadas por proximidade de data |
| `PATCH` | `/payments/notifications/{id}/associate` | Body: `{ purchaseInvoiceId: Long }`. Seta `notification.purchaseInvoiceId`. Retorna `PaymentNotificationResponse` atualizado com `associatedInvoice` populado. Erros: 404 se não encontrado, 409 se notificação já associada |

**Lógica de matching (sugestões):**
```sql
SELECT * FROM purchase_invoices pi
WHERE pi.total = :amount
  AND pi.deleted_at IS NULL
  AND pi.cancelled_at IS NULL
  AND pi.id NOT IN (
      SELECT purchase_invoice_id FROM payment_notifications
      WHERE purchase_invoice_id IS NOT NULL
  )
ORDER BY ABS(TIMESTAMPDIFF(MINUTE, pi.date, :purchasedAt))
```

---

## Pontos de Integração

Sem integrações externas novas. A feature usa exclusivamente dados internos do banco MySQL via JPA/Spring Data. O transporte continua sendo `CapacitorHttp` em nativo e `fetch` no browser (padrão do `httpClient.ts`).

---

## Abordagem de Testes

### Testes Unitários

- `FindNotificationInvoiceSuggestionsProvider`: mock de `PurchaseInvoiceRepository`; cenários — sem resultados, com múltiplos candidatos, notificação não encontrada.
- `AssociateNotificationProvider`: mock de ambos os repositories; cenários — sucesso, notificação já associada (409), notificação/invoice cancelada (404).
- `InvoiceSuggestionsSection.tsx`: mock do service; renderiza lista, chama `onAssociate` com ID correto, chama `onDismiss` ao Ignorar.
- `InvoiceAssociatedSection.tsx`: renderiza campos corretos, link navega para `/purchase/invoice/{id}`.

### Testes de Integração

- `PaymentNotificationController` (Spring MockMvc): `GET .../invoice-suggestions` com notificação existente/inexistente; `PATCH .../associate` com casos de sucesso, 404 e 409.
- Verificar que `PaymentNotificationResponse` retorna `associatedInvoice` populado após associação.

### Testes E2E (Playwright)

- Fluxo completo: abrir detalhe de notificação sem NF → seção de sugestão aparece → clicar Associar → seção vira "NF Associada" in-place.
- Fluxo pós-associação: reabrir notificação já associada → exibe seção verde diretamente.
- Ignorar: clicar Ignorar → sugestão some; reabrir → sugestão volta.

---

## Sequenciamento de Desenvolvimento

1. **Backend — DTOs e repository query** (`InvoiceSuggestionResponse`, `AssociatedInvoiceResponse`, query `findByTotalAndNotAssociated`): base para tudo.
2. **Backend — providers** (`FindNotificationInvoiceSuggestionsProvider`, `AssociateNotificationProvider`): usam os DTOs e query do passo 1.
3. **Backend — controller e response** (endpoints em `PaymentNotificationController`, extensão de `PaymentNotificationResponse`): expõe ao frontend.
4. **Frontend — tipos e service** (`purchaseService.ts`): sem dependência de UI.
5. **Frontend — componentes** (`InvoiceSuggestionsSection`, `InvoiceAssociatedSection`): podem ser desenvolvidos com mocks.
6. **Frontend — integração em `PurchaseDetail`**: conecta tudo; requer passo 3 e 5.
7. **Testes e revisão**.

### Dependências Técnicas

- A coluna `purchase_invoice_id` em `payment_notifications` já existe (migração V25) — nenhuma migration nova é necessária.
- O endpoint `PATCH /purchases/invoices/{invoiceId}/associate` existente **não é modificado** — o novo endpoint é aditivo.

---

## Monitoramento e Observabilidade

- Log `INFO` em `AssociateNotificationProvider.execute` ao persistir associação com `notificationId` e `purchaseInvoiceId`.
- Log `WARN` em caso de tentativa de associação duplicada (409) para rastreio de erros de UI.
- Nenhuma métrica Prometheus nova necessária neste escopo.

---

## Considerações Técnicas

### Decisões Principais

| Decisão | Justificativa |
|---|---|
| Novo endpoint `PATCH /payments/notifications/{id}/associate` em vez de reutilizar o da invoice | Mantém coesão: cada controller é responsável pelo seu domínio; evita lógica de branching no controller de invoices |
| Matching por valor exato | Pedido do produto; evita falsos positivos e simplifica a query sem necessidade de score/ranking |
| `dismissedInvoiceIds: Set<number>` em estado React (sessão apenas) | RF-06 exige dispensa temporária — persistência no servidor seria overhead desnecessário para um estado de UX |
| `associatedInvoice` embutido no `PaymentNotificationResponse` | Evita round-trip extra do frontend; os dados resumidos (razão social, CNPJ, total, data) são suficientes para o card |

### Riscos Conhecidos

- **Concorrência na associação**: dois usuários associando a mesma NF simultaneamente pode causar race condition. Mitigação: a constraint `UNIQUE (purchase_invoice_id)` no banco garante consistência; o backend retorna 409 no segundo request.
- **Performance da query de sugestões**: `total == amount` sem índice pode ser lento em volumes altos. Mitigação: verificar se há índice em `purchase_invoices.total`; adicionar se necessário.

### Conformidade com Skills Padrão

- **`kotlin-springboot`**: padrão Provider/UseCase/Gateway já adotado no projeto — novos providers seguem a mesma estrutura.
- **`vercel-react-best-practices`**: subcomponentes `InvoiceSuggestionsSection` e `InvoiceAssociatedSection` extraídos para manter `PurchaseDetail` com responsabilidade única.

### Arquivos Relevantes e Dependentes

**Backend:**
- `PaymentNotificationController.kt` — modificado
- `PaymentNotificationResponse.kt` — modificado
- `PaymentNotification.kt` (entidade) — leitura; `purchaseInvoiceId` já existe
- `PurchaseInvoiceRepository.kt` — modificado (+query)
- `PurchaseInvoiceModel.kt` — leitura (campos: total, date, merchantName, cnpj, totalItems)
- `AssociateInvoiceProvider.kt` — referência (padrão a seguir)
- `SearchNotificationsProvider.kt` — referência (padrão a seguir para FindNotificationInvoiceSuggestionsProvider)

**Frontend:**
- `src/services/purchaseService.ts` — modificado
- `src/pages/PurchaseDetail.tsx` — modificado
- `src/pages/PurchaseDetail.css` — modificado (estilos das novas seções)
- `src/pages/InvoiceSuggestionsSection.tsx` — novo
- `src/pages/InvoiceAssociatedSection.tsx` — novo

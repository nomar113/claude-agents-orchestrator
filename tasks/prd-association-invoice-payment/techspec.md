# Tech Spec — Associacao Invoice <-> Payment Notification

## Resumo Executivo

Implementar o fluxo completo de associacao entre `payment_notification` e `purchase_invoice`, incluindo: migration para adicionar `purchase_invoice_id` na tabela `payment_notifications`, endpoints REST (PATCH associar, DELETE desassociar, GET busca manual), modal de confirmacao inline na SuggestionsPage, e nova pagina de associacao manual com busca por valor e data. A arquitetura segue o padrao existente: Controller → UseCase → Gateway → Provider → Repository, com `@Transactional` no Provider.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (Kotlin/Spring Boot):**

- **V25 Migration** — Adiciona coluna `purchase_invoice_id` (nullable, UNIQUE FK) em `payment_notifications`
- **PaymentNotification (Model)** — Novo campo `purchaseInvoiceId` no JPA entity
- **PurchaseInvoiceController** — 3 novos endpoints: PATCH associate, DELETE associate, GET search
- **AssociateInvoiceGateway** — Interface de dominio para associacao/desassociacao
- **AssociateInvoiceProvider** — Implementacao `@Transactional` da associacao
- **SearchNotificationsGateway** — Interface de dominio para busca manual
- **SearchNotificationsProvider** — Implementacao da busca com filtros
- **AssociateInvoiceUseCase** — Orquestracao do use case de associacao
- **SearchNotificationsUseCase** — Orquestracao do use case de busca

**Frontend (React/Ionic):**

- **SuggestionsPage.tsx** — Adicionar modal de confirmacao inline (ConfirmDialog) ao selecionar sugestao
- **AssociatePage.tsx** — Nova pagina de busca manual com filtros por valor e data
- **PurchaseDetail.tsx** — Secao de pagamento associado + botao para desassociar
- **purchaseService.ts** — Novos metodos: `associateInvoice`, `disassociateInvoice`, `searchNotifications`
- **App.tsx** — Nova rota `/purchase/invoice/:id/associate`

**Fluxo de dados:**

1. PurchaseDetail → SuggestionsPage (sugestoes automaticas)
2. SuggestionsPage → modal confirmacao → PATCH associate → redirect PurchaseDetail
3. SuggestionsPage → AssociatePage (busca manual) → confirmacao → PATCH associate → redirect PurchaseDetail

## Design de Implementacao

### Interfaces Principais

```kotlin
// Gateway de associacao
fun interface AssociateInvoiceGateway {
    fun execute(invoiceId: Long, notificationId: Long): Result<AssociateInvoiceResponse>
}

// Gateway de desassociacao
fun interface DisassociateInvoiceGateway {
    fun execute(invoiceId: Long): Result<Unit>
}

// Gateway de busca manual
fun interface SearchNotificationsGateway {
    fun execute(invoiceId: Long, amount: BigDecimal?, startDate: LocalDateTime?, endDate: LocalDateTime?): Result<List<SuggestionResponse>>
}
```

```typescript
// Frontend service methods
export const associateInvoice = async (
  invoiceId: number,
  paymentNotificationId: number
): Promise<AssociateResponse> => { ... };

export const disassociateInvoice = async (
  invoiceId: number
): Promise<void> => { ... };

export const searchNotifications = async (
  invoiceId: number,
  params: { amount?: number; startDate?: string; endDate?: string }
): Promise<SuggestionResponse[]> => { ... };
```

### Modelos de Dados

**Migration V25:**

```sql
ALTER TABLE payment_notifications
  ADD COLUMN purchase_invoice_id BIGINT NULL,
  ADD CONSTRAINT fk_pn_purchase_invoice
    FOREIGN KEY (purchase_invoice_id) REFERENCES purchase_invoices(id),
  ADD CONSTRAINT uq_pn_purchase_invoice_id
    UNIQUE (purchase_invoice_id);
```

**PaymentNotification JPA Model — novo campo:**

```kotlin
@Column(name = "purchase_invoice_id", nullable = true)
var purchaseInvoiceId: Long? = null
```

**Response DTO:**

```kotlin
data class AssociateInvoiceResponse(
    val invoiceId: Long,
    val paymentNotificationId: Long,
    val associatedAt: LocalDateTime
)
```

### Endpoints de API

| Metodo | Caminho | Descricao |
|--------|---------|-----------|
| `PATCH` | `/purchases/invoices/{invoiceId}/associate` | Associa notification ao invoice. Body: `{ "paymentNotificationId": 123 }`. Retorna 200 com `AssociateInvoiceResponse` |
| `DELETE` | `/purchases/invoices/{invoiceId}/associate` | Remove associacao (seta `purchase_invoice_id = NULL`). Retorna 204 |
| `GET` | `/purchases/invoices/{invoiceId}/suggestions/search` | Busca manual. Query params: `amount`, `startDate`, `endDate`. Retorna lista de `SuggestionResponse` |

**Regras do PATCH:**
- Validar invoice existe e nao esta deletado/cancelado
- Validar notification existe e nao esta deletada/cancelada
- Se notification ja tem `purchase_invoice_id` apontando para OUTRO invoice → 409 Conflict
- Se invoice ja tem uma notification associada, substituir pela nova
- Operacao atomica via `@Transactional`

**Regras do GET search:**
- Se `amount` fornecido: filtro exato
- Se `startDate`/`endDate` fornecidos: filtro por periodo de `purchased_at`
- Se nenhum filtro: ultimos 7 dias
- Excluir notifications deletadas, canceladas ou ja associadas a outro invoice
- Limite 20 resultados, ordenado por `purchased_at DESC`

## Pontos de Integracao

Nao ha integracoes externas. Toda a comunicacao e entre frontend ↔ backend REST.

## Abordagem de Testes

### Testes Unidade

**Backend:**
- `AssociateInvoiceProvider` — cenarios: sucesso, invoice nao encontrado, notification nao encontrada, notification ja associada (409), re-associacao do mesmo invoice
- `SearchNotificationsProvider` — cenarios: busca com filtros, sem filtros (7 dias padrao), resultados vazios

**Frontend:**
- `SuggestionsPage` — modal de confirmacao abre ao tap, chama API ao confirmar, fecha ao cancelar
- `AssociatePage` — busca com filtros, selecao de notification, confirmacao
- `purchaseService` — novos metodos chamam endpoints corretos

### Testes de Integracao

- Controller tests com MockMvc para os 3 endpoints
- Validar constraint UNIQUE retorna 409
- Validar soft-delete exclui resultados da busca

### Testes de E2E

- Fluxo completo: PurchaseDetail → SuggestionsPage → selecionar sugestao → confirmar → ver associacao no PurchaseDetail
- Fluxo manual: PurchaseDetail → SuggestionsPage → "Associar manualmente" → buscar → selecionar → confirmar
- Desassociacao: PurchaseDetail → remover associacao → botao "Associar Pagamento" volta

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migration V25** — Base de dados primeiro, pois tudo depende da coluna
2. **Model + Repository** — Atualizar `PaymentNotification` JPA model e queries no repository
3. **Gateway + Provider + UseCase (associate/disassociate)** — Logica de negocio de associacao
4. **Gateway + Provider + UseCase (search)** — Logica de busca manual
5. **Controller endpoints** — Expor os 3 endpoints REST
6. **purchaseService.ts** — Metodos de API no frontend
7. **SuggestionsPage modal** — Confirmacao inline para sugestoes
8. **AssociatePage** — Pagina de busca manual com rota
9. **PurchaseDetail** — Secao de pagamento associado + desassociacao
10. **Testes** — Unit + integration + E2E

### Dependencias Tecnicas

- Migration V25 deve rodar antes de qualquer codigo backend
- Endpoints backend devem estar prontos antes do frontend consumi-los
- SuggestionsPage ja existe (PRD 3) — so modificar para adicionar modal

## Monitoramento e Observabilidade

- Logs INFO para associacao/desassociacao com invoiceId e notificationId
- Log WARN para tentativa de associacao duplicada (409)
- Log ERROR para falhas inesperadas no provider

## Consideracoes Tecnicas

### Decisoes Principais

1. **Coluna em `payment_notifications` (nao em `purchase_invoices`)** — O usuario confirmou que `payment_notification` deve ter `purchase_invoice_id`. Relacao 1:1 com UNIQUE constraint garante integridade.

2. **Rota `/purchase/invoice/:id/associate`** — Consistente com hierarquia existente (`/purchase/invoice/:id/suggestions`). Evita alterar SuggestionsPage que ja navega para essa rota.

3. **Modal inline para sugestoes, pagina separada para busca manual** — Sugestoes ja estao na tela, modal e mais rapido. Busca manual precisa de campos de filtro e listagem, justifica pagina propria.

4. **Filtros: valor + data (sem texto)** — Usuario definiu que busca manual usa valor e data como filtros.

### Riscos Conhecidos

- **Constraint UNIQUE** pode causar erro se migration rodar com dados duplicados pre-existentes (improvavel, campo novo)
- **Race condition** na associacao simultanea — mitigado por UNIQUE constraint no banco + `@Transactional`

### Conformidade com Skills Padroes

- `executar-task` — Cada task deve seguir o padrao: implementar, testar, commitar
- `executar-review` — Code review apos implementacao
- `task-review` — Review automatico ao completar cada task

### Arquivos relevantes e dependentes

**Backend (controlai):**
- `src/main/resources/db/migration/` — V25 migration (criar)
- `src/main/kotlin/.../payments_notification/entrypoint/database/model/PaymentNotification.kt` — Adicionar campo
- `src/main/kotlin/.../payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` — Novas queries
- `src/main/kotlin/.../purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt` — Novos endpoints
- `src/main/kotlin/.../suggestion/entrypoint/rest/SuggestionController.kt` — Referencia para padrao
- `src/main/kotlin/.../suggestion/entrypoint/rest/response/SuggestionResponse.kt` — Reusar no search

**Frontend (controlai-frontend):**
- `src/App.tsx` — Nova rota
- `src/pages/SuggestionsPage.tsx` — Modal de confirmacao
- `src/pages/PurchaseDetail.tsx` — Secao de pagamento associado
- `src/services/purchaseService.ts` — Novos metodos
- `src/components/ConfirmDialog.tsx` — Reusar para confirmacao
- `src/pages/AssociatePage.tsx` — Nova pagina (criar)
- `src/pages/AssociatePage.css` — Estilos (criar)

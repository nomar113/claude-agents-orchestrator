# PRD 4 — Associacao Invoice <-> Payment Notification

## Resumo

Permitir que o usuario associe um `purchase_invoice` a uma `payment_notification`, seja por selecao de sugestao automatica ou por busca manual, e persistir essa relacao no banco.

## Contexto e Motivacao

Apos o endpoint `/suggestions` (PRD 3) retornar possiveis matches, o usuario precisa de uma forma de confirmar a associacao. Quando nao ha sugestoes, deve haver um fluxo manual para buscar e selecionar a notification correta. A associacao permite rastrear qual pagamento do cartao corresponde a qual nota fiscal.

## Dependencias

- **PRD 3** deve estar implementada (migration V24 com `payment_notification_id` em `purchase_invoices` e endpoint de sugestoes)

## Arquitetura Atual (Relevante)

### Backend

- Coluna `payment_notification_id` (nullable, UNIQUE) ja existira em `purchase_invoices` (criada na PRD 3)
- Padrao: Controller -> UseCase -> Provider -> Repository
- Transacoes via `@Transactional` do Spring

### Frontend

- Pagina `SuggestionPage.tsx` ja existira (criada na PRD 3)
- Servico `purchaseService.ts` centraliza chamadas de API
- Navegacao via React Router 5 com `useHistory()`

## Requisitos Funcionais

### Backend

#### 1. Endpoint de Associacao

```
PATCH /purchases/invoices/{invoiceId}/associate
```

**Request Body:**
```json
{
  "paymentNotificationId": 123
}
```

**Response (200 OK):**
```json
{
  "invoiceId": 45,
  "paymentNotificationId": 123,
  "associatedAt": "2026-05-21T15:00:00"
}
```

**Regras de negocio:**
- Validar que o `invoiceId` existe e nao esta deletado/cancelado
- Validar que o `paymentNotificationId` existe e nao esta deletado/cancelado
- Validar que a `payment_notification` nao esta ja associada a outro invoice (UNIQUE constraint)
- Se o invoice ja tem uma associacao, substituir pela nova (permite correcao)
- Operacao atomica (`@Transactional`)

**Erros:**
- `404` — invoice ou notification nao encontrado
- `409` — notification ja associada a outro invoice
- `400` — payload invalido

#### 2. Endpoint de Desassociacao

```
DELETE /purchases/invoices/{invoiceId}/associate
```

**Response (204 No Content)**

- Remove a associacao (seta `payment_notification_id = NULL`)
- Util para corrigir associacoes erradas

#### 3. Endpoint de Busca Manual

```
GET /purchases/invoices/{invoiceId}/suggestions/search?q={merchantName}&amount={amount}
```

**Response:** mesma estrutura do `/suggestions`, mas com filtros manuais

**Regras de busca:**
- Se `q` fornecido: `payment_notifications.merchant_name LIKE %q%` (case insensitive)
- Se `amount` fornecido: `payment_notifications.amount = amount`
- Se nenhum filtro: retorna notifications dos ultimos 7 dias sem associacao
- Sempre exclui notifications deletadas, canceladas ou ja associadas
- Limite de 20 resultados
- Ordenacao por `purchased_at DESC`

### Frontend

#### 4. Acao de Associacao na SuggestionPage

Na `SuggestionPage.tsx` (criada na PRD 3):
- Ao usuario tocar em uma sugestao, exibir modal de confirmacao com detalhes lado a lado (invoice vs notification)
- Ao confirmar, chamar `PATCH /purchases/invoices/{id}/associate`
- Exibir toast de sucesso e redirecionar para `PurchaseDetail` do invoice

#### 5. Nova Pagina `ManualAssociationPage.tsx`

- Rota: `/manual-association/:invoiceId`
- Exibe resumo do invoice no topo (merchant, valor, data)
- Campo de busca por nome do estabelecimento
- Lista de `payment_notifications` filtradas
- Ao selecionar, mesmo fluxo de confirmacao da SuggestionPage
- Botao "Pular" para ignorar a associacao e ir direto ao detalhe do invoice

#### 6. Novos Metodos no Service

Em `purchaseService.ts`:

```typescript
export const associateInvoice = async (
  invoiceId: number,
  paymentNotificationId: number
): Promise<void> => {
  await fetch(`${API_BASE_URL}/purchases/invoices/${invoiceId}/associate`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ paymentNotificationId }),
  });
};

export const disassociateInvoice = async (invoiceId: number): Promise<void> => {
  await fetch(`${API_BASE_URL}/purchases/invoices/${invoiceId}/associate`, {
    method: 'DELETE',
  });
};

export const searchSuggestions = async (
  invoiceId: number,
  query?: string,
  amount?: number
): Promise<PaymentNotification[]> => {
  const params = new URLSearchParams();
  if (query) params.set('q', query);
  if (amount) params.set('amount', amount.toString());
  const response = await fetch(
    `${API_BASE_URL}/purchases/invoices/${invoiceId}/suggestions/search?${params}`
  );
  return response.json();
};
```

#### 7. Indicador de Associacao no PurchaseDetail

Em `PurchaseDetail.tsx`, quando o invoice tem `paymentNotificationId`:
- Exibir secao "Pagamento Associado" com resumo da notification (cartao, valor, data)
- Botao para ver detalhes da notification
- Botao para remover associacao (chama DELETE endpoint, com confirmacao)

Quando nao tem associacao:
- Exibir botao "Associar Pagamento" que redireciona para `/suggestions/:invoiceId`

## Arquivos a Criar

| Arquivo | Descricao |
|---------|-----------|
| `AssociateInvoiceUseCase.kt` | Interface do use case de associacao |
| `AssociateInvoiceProvider.kt` | Implementacao da associacao |
| `SearchSuggestionsUseCase.kt` | Interface do use case de busca manual |
| `SearchSuggestionsProvider.kt` | Implementacao da busca manual |
| `ManualAssociationPage.tsx` | Pagina de associacao manual |
| `AssociatedPaymentSection.tsx` | Componente de pagamento associado no detalhe |

## Arquivos a Modificar

| Arquivo | Modificacao |
|---------|-------------|
| `PurchaseInvoiceController.kt` | Endpoints PATCH e DELETE `/associate`, GET `/suggestions/search` |
| `PurchaseInvoiceModel.kt` | Mapeamento JPA do `paymentNotificationId` (se nao feito na PRD 3) |
| `purchaseService.ts` | Novos metodos `associateInvoice`, `disassociateInvoice`, `searchSuggestions` |
| `PurchaseDetail.tsx` | Secao de pagamento associado + botao de associar |
| `SuggestionPage.tsx` | Acao de selecao com confirmacao |
| `App.tsx` | Nova rota `/manual-association/:invoiceId` |

## Requisitos Nao-Funcionais

- Associacao deve ser atomica (transacao unica)
- UNIQUE constraint em `payment_notification_id` garante integridade no banco
- Endpoint de busca manual deve responder em < 500ms
- Indice em `payment_notifications(merchant_name)` para busca textual — avaliar necessidade

## Criterios de Aceite

1. `PATCH /associate` associa invoice a notification e retorna confirmacao
2. Associacao duplicada (notification ja em outro invoice) retorna `409 Conflict`
3. `DELETE /associate` remove a associacao
4. Busca manual retorna notifications filtradas por nome e/ou valor
5. Frontend permite selecionar sugestao com modal de confirmacao
6. Pagina de associacao manual funciona quando nao ha sugestoes automaticas
7. PurchaseDetail exibe pagamento associado quando existente
8. PurchaseDetail exibe botao "Associar Pagamento" quando nao ha associacao
9. Botao "Pular" permite ignorar a associacao

## Fora de Escopo

- Associacao automatica sem confirmacao do usuario
- Associacao de multiplas notifications a um unico invoice (1:1 apenas)
- Notificacao push sobre associacoes pendentes
- Relatorio de invoices sem associacao

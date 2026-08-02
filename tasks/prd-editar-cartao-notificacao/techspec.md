# Tech Spec — Edicao de Cartao em Notificacao de Pagamento

## Resumo Executivo

A funcionalidade reaproveita ao maximo o que ja existe no produto. No backend Spring Boot Kotlin, e adicionado um unico endpoint PATCH atomico (`/notifications/{id}/payment-method`) seguindo o mesmo padrao "find -> copy -> save -> retornar response" ja usado em `/description`, `/category` e `/purchased-at`. No frontend Ionic React, e estendido o componente `PaymentMethodSelector` ja existente para receber um sub-card pre-selecionado e enviar o evento de troca atraves de uma nova funcao em `purchaseService.ts`; a tela `PurchaseDetail` passa a tratar a linha "Cartao" como acao e abre o bottom sheet.

Como `installments` nao carregam `paymentMethodId/subCardId`, e os relatorios por cartao agregam via FK `parent_id` -> `payment_notifications.payment_method_id`, alterar a notificacao basta para refletir em todas as parcelas, no orcamento e na lista — sem necessidade de migracao ou batch update.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (modificados):**
- `PaymentNotificationController.kt` — adiciona endpoint `PATCH /notifications/{id}/payment-method`.
- `UpdatePaymentMethodRequest.kt` (**novo**) — DTO de request em `payments_notification/entrypoint/rest/request/`.
- `UpdateNotificationPaymentMethodProvider.kt` (**novo**) — provider em `payments_notification/application/` que orquestra carga, validacao, atualizacao e retorno.
- `PaymentNotificationRepository.kt` e `PaymentMethodRepository.kt` — reutilizados sem mudanca.

**Frontend (modificados):**
- `src/services/purchaseService.ts` — nova funcao `updatePaymentNotificationCard(id, paymentMethodId, subCardId)`.
- `src/components/PaymentMethodSelector.tsx` — recebe novas props para "edit mode": `currentPaymentMethodId`, `currentSubCardId`, modo `edit | create`, e o callback agora envia ambos os ids.
- `src/pages/PurchaseDetail.tsx` — adiciona handler `handleEditCard`, estado `isCardSheetOpen`, e converte a linha Cartao em botao tocavel.

**Frontend (novo opcional):**
- `src/components/EditCardSheet.tsx` — caso `PaymentMethodSelector` fique muito acoplado ao caso "create", extrair as variantes em wrapper especializado. Decisao final feita durante implementacao.

### Fluxo de Dados (resumido)

1. Usuario toca na linha Cartao em `PurchaseDetail` -> abre sheet com cartoes do dominio (carregados via `paymentMethodService.listPaymentMethods()`).
2. Usuario seleciona cartao. Se o cartao tem >=1 sub-cartoes, o sheet navega para a 2a tela (sub-cartao). O sub-card atual da notificacao vem pre-marcado quando pertencer ao mesmo cartao.
3. Usuario confirma sub-cartao (ou opta por "Continuar sem sub-cartao", ou cartao sem sub-cards -> confirma direto).
4. Frontend chama `PATCH /notifications/{id}/payment-method` com body `{ paymentMethodId, subCardId | null }`.
5. Backend carrega notificacao -> valida que nao esta cancelada -> valida que paymentMethodId existe -> se subCardId fornecido, valida que pertence ao paymentMethod -> atualiza `paymentMethodId`, `subCardId` e `cardLastDigits` -> salva e retorna `PaymentNotificationResponse`.
6. Frontend recebe a notificacao atualizada e refresca o estado local em `PurchaseDetail`.

## Design de Implementacao

### Interfaces Principais

**Backend — Provider (Kotlin):**

```kotlin
@Service
class UpdateNotificationPaymentMethodProvider(
    private val paymentNotificationRepository: PaymentNotificationRepository,
    private val paymentMethodRepository: PaymentMethodRepository,
) {
    fun execute(
        notificationId: Long,
        paymentMethodId: Long,
        subCardId: Long?,
    ): Result<PaymentNotification>
}
```

**Frontend — Service (TypeScript):**

```typescript
export function updatePaymentNotificationCard(
  id: number,
  paymentMethodId: number,
  subCardId: number | null,
): Promise<PaymentNotificationDetail> {
  return httpRequest(
    'PATCH',
    `/payments/notifications/${id}/payment-method`,
    { paymentMethodId, subCardId },
  );
}
```

**Frontend — Component prop extension (PaymentMethodSelector):**

```typescript
interface PaymentMethodSelectorProps {
  isOpen: boolean;
  mode?: 'create' | 'edit';
  currentPaymentMethodId?: number | null;
  currentSubCardId?: number | null;
  onClose: () => void;
  onSelect: (paymentMethodId: number, subCardId: number | null) => void;
}
```

### Modelos de Dados

Nenhuma mudanca de schema. As colunas envolvidas ja existem:

- `payment_notifications.payment_method_id` (Long?)
- `payment_notifications.sub_card_id` (Long?)
- `payment_notifications.card_last_digits` (String?)

**Request DTO (backend):**

```kotlin
data class UpdatePaymentMethodRequest(
    @field:NotNull val paymentMethodId: Long,
    val subCardId: Long? = null,
)
```

**Response:** `PaymentNotificationResponse` existente, sem alteracoes.

### Endpoints de API

- **Metodo e caminho:** `PATCH /payments/notifications/{id}/payment-method`
- **Body:** `{ "paymentMethodId": number, "subCardId": number | null }`
- **Response 200:** `PaymentNotificationResponse` completa.
- **Erros:**
  - `404 NOT_FOUND` — notificacao inexistente.
  - `409 CONFLICT` — notificacao esta cancelada (`cancelledAt != null`).
  - `400 BAD_REQUEST` — `paymentMethodId` inexistente, ou `subCardId` nao pertence ao paymentMethod indicado.
  - `500 INTERNAL_SERVER_ERROR` — falha generica de persistencia.

### Regras Centrais (definidas em clarificacao)

- **cardLastDigits:** se `subCardId` for fornecido, sobrescrever com `subCard.lastFourDigits`. Se `subCardId` for null, manter o `cardLastDigits` original da notificacao.
- **Parcelas:** nao ha update em `installments` — relatorios usam join via `parent_id` -> `payment_notifications`.
- **Idempotencia:** a operacao usa apenas update em colunas existentes; chamadas repetidas com mesmo payload sao no-op apos o primeiro save.
- **Notificacoes canceladas:** rejeitadas com 409 mesmo que o frontend nao tenha exibido a affordance.

## Pontos de Integracao

Nao ha integracoes externas adicionadas. A funcionalidade opera dentro dos limites do servico ControlAI, usando JPA/Hibernate ja em uso e MySQL como persistencia. Frontend continua usando a estrategia dual `CapacitorHttp` nativa / `fetch` web ja estabelecida no `httpRequest` helper.

## Abordagem de Testes

### Testes Unidade (Backend)

- `PaymentNotificationControllerTest` — cenarios:
  - 200 quando paymentMethodId valido sem subCardId.
  - 200 quando paymentMethodId + subCardId validos.
  - 200 quando o mesmo cartao e re-confirmado (idempotencia).
  - 400 quando paymentMethodId inexistente.
  - 400 quando subCardId nao pertence ao paymentMethod.
  - 404 quando notificationId inexistente.
  - 409 quando notificacao esta cancelada.
- `UpdateNotificationPaymentMethodProviderTest` — testa o provider isoladamente com mocks dos dois repositorios; cobre transformacao do `cardLastDigits`.

### Testes Unidade (Frontend)

- `purchaseService.test.ts` — adicionar caso para `updatePaymentNotificationCard` cobrindo path, metodo e body.
- `PaymentMethodSelector.test.tsx` — atualizar para cobrir modo `edit`: pre-selecao do cartao atual, pre-marcacao do sub-cartao quando existir, e envio do callback com `(paymentMethodId, subCardId | null)`.
- `PurchaseDetail.test.tsx` — adicionar testes:
  - Linha Cartao tocavel apenas em `type === 'notification'` e `!cancelledAt`.
  - Toque abre o sheet.
  - Confirmacao do sheet chama `updatePaymentNotificationCard` e atualiza o display.
  - Erro de rede mantem estado anterior e mostra mensagem.

### Testes de Integracao / E2E

Fora de escopo desta entrega (conforme alinhado em clarificacao). A cobertura unitaria backend + frontend e considerada suficiente para o primeiro release; um cenario Cypress pode ser adicionado depois caso a taxa de uso justifique investimento.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Backend — DTO + Provider + Controller endpoint.** Permite testar a regra de validacao isoladamente antes do frontend. Inclui testes unitarios.
2. **Frontend — service:** `updatePaymentNotificationCard` em `purchaseService.ts` + teste.
3. **Frontend — componente:** estender `PaymentMethodSelector` com `mode: edit`, pre-selecao e callback ajustado. Validar via testes existentes do componente.
4. **Frontend — pagina:** modificar `PurchaseDetail.tsx` para tornar a linha Cartao tocavel, abrir o sheet, integrar callback e atualizar estado.
5. **Verificacao manual:** rodar `ionic serve`, navegar ate uma notificacao real e testar o fluxo nas tres variantes (cartao sem sub-cards, com sub-cards, troca sem sub-cartao).
6. **Polish:** ajustes de copy e acessibilidade conforme PRD.

### Dependencias Tecnicas

- Backend deployado antes que o frontend chame o endpoint (ja e o pipeline normal do projeto via Appflow + Spring Boot).
- Nenhuma migracao SQL nova; nada bloqueante.

## Monitoramento e Observabilidade

- **Logs estruturados (backend):** adicionar log `INFO` ao final da operacao com `notificationId`, `oldPaymentMethodId`, `newPaymentMethodId`, `subCardChanged: Boolean`. Errors registrados em `ERROR` com stacktrace abreviada.
- **Metricas:** o projeto nao expoe Prometheus hoje, entao o spec apenas registra o ponto: o time pode adicionar um contador `notification_card_updates_total` no provider quando a infra de metricas chegar.
- **Telemetria de produto:** considerar enviar evento de produto (`notification.card.updated`) via fluxo existente quando houver, para medir a metrica principal de uso (% de notificacoes editadas em 7 dias).

## Consideracoes Tecnicas

### Decisoes Principais

- **Endpoint dedicado por campo (`/payment-method`)** ao inves de um PATCH generico — segue o padrao existente do dominio (`/description`, `/category`, `/purchased-at`), mantem a responsabilidade unica do controller, e permite logging/observability granular.
- **Validacao de pertinencia subCardId no backend** — evita estado inconsistente caso o frontend envie ids "soltos". Custo: uma leitura extra do `PaymentMethod`; ja necessaria para validar paymentMethodId, entao custo marginal e nulo.
- **Atualizar `cardLastDigits` apenas quando subCard for fornecido** — preserva o valor original do SMS para auditoria quando o usuario nao consegue/quer informar sub-cartao; quando ha sub-cartao, alinha o digito mostrado com o real.
- **Reusar `PaymentMethodSelector`** ao inves de criar novo componente — reduz drift visual, mas adiciona pequenas props condicionais. Caso a logica vire ifs aninhados, extrair `EditCardSheet` como wrapper.

### Riscos Conhecidos

- **Risco de cache no frontend:** se outras paginas (Tab1 lista, BudgetPage) tiverem dados em memoria, a edicao em PurchaseDetail nao se propaga ate o proximo `useIonViewWillEnter`. Mitigacao: ja existe padrao de `silent reload`; documentar nas tasks que essas telas devem recarregar ao voltar para elas.
- **Risco de regressao em PaymentMethodSelector:** o componente e usado em criacao manual de notificacao. Mitigacao: manter `mode: 'create'` como default, alterar contrato de `onSelect` para sempre receber `subCardId: number | null` (atualmente recebe `subCardId?: number`), e ajustar chamadores existentes.
- **Risco de race condition:** duas edicoes simultaneas do mesmo registro podem sobrescrever uma a outra. Probabilidade baixissima (usuario unico, sessao unica); mitigacao deferida.

### Conformidade com Skills Padroes

Skills relevantes em `/.claude/skills/` do projeto controlai-frontend:

- **clean-code** — aplicada na nova funcao do service (sem duplicacao do helper http), no provider backend (responsabilidade unica), e nos novos testes.
- **ionic-design** — bottom sheet segue padrao iOS-like ja consolidado (`drag handle`, `dim overlay`, `slide-up`, fechamento por tap fora).
- **frontend-design** / **ui-ux-pro-max** — refletida nos artboards do Paper ja produzidos: hierarquia visual, contraste AA, micro-momentos de cor com o accent rosa #FF4D6D.

Nao foram identificados desvios das skills.

### Arquivos relevantes e dependentes

**Backend (controlai):**
- `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` (modificar)
- `application/payments_notification/entrypoint/rest/request/UpdatePaymentMethodRequest.kt` (novo)
- `application/payments_notification/application/UpdateNotificationPaymentMethodProvider.kt` (novo)
- `application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` (sem mudanca)
- `application/payment_methods/.../PaymentMethodRepository.kt` (sem mudanca, leitura)

**Frontend (controlai-frontend):**
- `src/services/purchaseService.ts` (modificar — nova funcao)
- `src/services/purchaseService.test.ts` (modificar — novo caso)
- `src/components/PaymentMethodSelector.tsx` (modificar — modo edit)
- `src/components/PaymentMethodSelector.css` (possiveis ajustes para o callout "Cartao atual")
- `src/pages/PurchaseDetail.tsx` (modificar — handler + estado + UI)
- `src/pages/PurchaseDetail.css` (possivel ajuste no estilo da linha Cartao para indicar interatividade)
- `src/pages/PurchaseDetail.test.tsx` (modificar — novos testes)

**Referencias visuais (Paper file ControlAI):**
- Artboard "Detalhe — Editar Cartao (Affordance)"
- Artboard "Editar Cartao — Bottom Sheet"
- Artboard "Editar Cartao — Sub-cartoes"

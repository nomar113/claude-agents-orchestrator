# Tarefa 4.0: Backend — Endpoints e extensão do PaymentNotificationResponse

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Expor os dois novos endpoints em `PaymentNotificationController` e estender `PaymentNotificationResponse` com os campos `purchaseInvoiceId` e `associatedInvoice`. Esta tarefa é a última camada backend e torna a feature consumível pelo frontend. Depende das Tarefas 2.0 e 3.0.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — estrutura de controllers REST com Spring MVC; `@GetMapping`, `@PatchMapping`; tratamento de status HTTP via `ResponseEntity`.
</skills>

<requirements>
- Adicionar em `PaymentNotificationController`:
  - `GET /payments/notifications/{id}/invoice-suggestions` → chama `FindNotificationInvoiceSuggestionsProvider` e retorna `List<InvoiceSuggestionResponse>` com status 200.
  - `PATCH /payments/notifications/{id}/associate` → body `{ purchaseInvoiceId: Long }`; chama `AssociateNotificationProvider`; retorna `PaymentNotificationResponse` com status 200, 404 ou 409 conforme o resultado.
- Estender `PaymentNotificationResponse` com:
  - `purchaseInvoiceId: Long? = null`
  - `associatedInvoice: AssociatedInvoiceResponse? = null`
- O campo `associatedInvoice` deve ser populado no `from(entity)` via lookup no `PurchaseInvoiceRepository` sempre que `entity.purchaseInvoiceId != null`.
- O endpoint existente `PATCH /purchases/invoices/{invoiceId}/associate` NÃO deve ser modificado.
</requirements>

## Subtarefas

- [ ] 4.1 Estender `PaymentNotificationResponse.kt` com `purchaseInvoiceId` e `associatedInvoice`
- [ ] 4.2 Atualizar `from(entity)` para popular `associatedInvoice` quando `purchaseInvoiceId` não é nulo
- [ ] 4.3 Adicionar endpoint `GET .../invoice-suggestions` em `PaymentNotificationController`
- [ ] 4.4 Adicionar endpoint `PATCH .../associate` em `PaymentNotificationController`
- [ ] 4.5 Escrever testes de integração com Spring MockMvc
- [ ] 4.6 Verificar que typecheck, lint e build passam sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seção "Endpoints de API" (métodos, caminhos, body, status codes) e "Modelos de Dados" (extensão do `PaymentNotificationResponse`).

## Criterios de Sucesso

- `GET .../invoice-suggestions` retorna 200 com lista (pode ser vazia) para notificação existente.
- `GET .../invoice-suggestions` retorna 404 para notificação inexistente.
- `PATCH .../associate` retorna 200 com `associatedInvoice` populado após associação bem-sucedida.
- `PATCH .../associate` retorna 404 para notificação/invoice inexistente.
- `PATCH .../associate` retorna 409 para notificação já associada.
- `PaymentNotificationResponse` inclui `associatedInvoice` em todas as respostas onde há vínculo.

## Testes da Tarefa

- [ ] Testes de integração (MockMvc): `PaymentNotificationControllerTest`
  - `GET .../invoice-suggestions` com notificação existente sem candidatos → 200 lista vazia
  - `GET .../invoice-suggestions` com candidatos → 200 lista com campos corretos
  - `GET .../invoice-suggestions` com notificação inexistente → 404
  - `PATCH .../associate` com sucesso → 200 com `associatedInvoice` no body
  - `PATCH .../associate` com notificação/invoice inexistente → 404
  - `PATCH .../associate` com notificação já associada → 409
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../controller/PaymentNotificationController.kt` — modificado
- `src/main/kotlin/.../response/PaymentNotificationResponse.kt` — modificado
- `src/main/kotlin/.../dto/AssociatedInvoiceResponse.kt` — leitura (tarefa 1.0)
- `src/main/kotlin/.../dto/InvoiceSuggestionResponse.kt` — leitura (tarefa 1.0)
- `src/main/kotlin/.../provider/FindNotificationInvoiceSuggestionsProvider.kt` — leitura (tarefa 2.0)
- `src/main/kotlin/.../provider/AssociateNotificationProvider.kt` — leitura (tarefa 3.0)
- `src/test/kotlin/.../controller/PaymentNotificationControllerTest.kt` — novo/modificado
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência

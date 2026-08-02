# Tarefa 4.0: Controller — 3 endpoints REST

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar 3 novos endpoints ao `PurchaseInvoiceController`: PATCH para associar, DELETE para desassociar, e GET para busca manual de notifications. Inclui request DTOs e tratamento de erros HTTP.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- `PATCH /purchases/invoices/{invoiceId}/associate` — Body: `{ "paymentNotificationId": 123 }`, Response 200 com `AssociateInvoiceResponse`
- `DELETE /purchases/invoices/{invoiceId}/associate` — Response 204 No Content
- `GET /purchases/invoices/{invoiceId}/suggestions/search` — Query params: `amount`, `startDate`, `endDate`. Response 200 com lista de `SuggestionResponse`
- Tratamento de erros: 404 (not found), 409 (conflict), 400 (bad request)
- Seguir padrao do controller existente (injetar use cases, mapear Result para ResponseEntity)
</requirements>

## Subtarefas

- [x] 4.1 Criar `AssociateInvoiceRequest` DTO com campo `paymentNotificationId: Long`
- [x] 4.2 Adicionar endpoint PATCH `/associate` no controller
- [x] 4.3 Adicionar endpoint DELETE `/associate` no controller
- [x] 4.4 Adicionar endpoint GET `/suggestions/search` no controller com query params
- [x] 4.5 Mapear erros do Result para HTTP status codes (404, 409, 400)

## Detalhes de Implementacao

Consultar a secao **Endpoints de API** da `techspec.md`. Seguir o padrao do `PurchaseInvoiceController` existente e do `SuggestionController` como referencia para injecao de use cases e mapeamento de respostas.

## Criterios de Sucesso

- PATCH associa e retorna 200 com response correto
- DELETE desassocia e retorna 204
- GET busca e retorna lista de suggestions
- Erros mapeados corretamente (404, 409, 400)
- Todos os testes de integracao passam

## Testes da Tarefa

- [x] Teste integracao (MockMvc): PATCH com sucesso → 200
- [x] Teste integracao (MockMvc): PATCH com invoice inexistente → 404
- [x] Teste integracao (MockMvc): PATCH com notification ja associada → 409
- [x] Teste integracao (MockMvc): DELETE com sucesso → 204
- [x] Teste integracao (MockMvc): GET com filtros → 200 com resultados
- [x] Teste integracao (MockMvc): GET sem filtros → 200 com resultados dos ultimos 7 dias

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt` (modificar)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/request/AssociateInvoiceRequest.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/response/AssociateInvoiceResponse.kt` (ja criado na task 2)
- `src/main/kotlin/br/com/nomar/controlai/application/suggestion/entrypoint/rest/SuggestionController.kt` (referencia)

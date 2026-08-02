# Tarefa 4.0: Endpoints PATCH /cancel

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar endpoints REST dedicados para cancelamento de compras em ambos os controllers existentes.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de controllers REST existente no projeto.
</skills>

<requirements>
- `PATCH /payments/notifications/{id}/cancel` no PaymentNotificationController
- `PATCH /purchases/invoices/{id}/cancel` no PurchaseInvoiceController
- Response 200 OK (sem body) em sucesso
- Response 404 quando item nao encontrado
- Response 409 quando item ja cancelado
- Response 422 quando item ja excluido
- Injetar use cases de cancelamento nos controllers
</requirements>

## Subtarefas

- [ ] 4.1 Adicionar endpoint PATCH no `PaymentNotificationController`
- [ ] 4.2 Adicionar endpoint PATCH no `PurchaseInvoiceController`
- [ ] 4.3 Mapear exceptions para HTTP status codes adequados (ExceptionHandler ou ResponseEntity)
- [ ] 4.4 Testar endpoints manualmente via curl/Postman

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Endpoints de API"

Seguir padrao dos endpoints DELETE existentes nos mesmos controllers. Usar `@PatchMapping("/{id}/cancel")`.

## Criterios de Sucesso

- Endpoint retorna 200 ao cancelar compra valida
- Endpoint retorna 404 para ID inexistente
- Endpoint retorna 409 para compra ja cancelada
- Endpoint retorna 422 para compra ja excluida
- Nao quebra endpoints existentes

## Testes da Tarefa

- [ ] Testes de integracao: chamar PATCH /cancel e verificar response 200 + registro atualizado no banco
- [ ] Testes de integracao: verificar 404, 409, 422 nos cenarios de erro
- [ ] Testes de integracao: verificar que DELETE (soft delete) continua funcionando normalmente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt`

# Tarefa 2.0: Associate/Disassociate — Gateway, Provider, UseCase

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a logica de negocio para associar e desassociar uma `payment_notification` a um `purchase_invoice`. Inclui gateways, providers com `@Transactional` e use cases seguindo o padrao existente do projeto.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- Associacao: setar `purchase_invoice_id` na notification apontando para o invoice
- Desassociacao: setar `purchase_invoice_id = NULL` na notification
- Validar que invoice existe e nao esta deletado/cancelado (404)
- Validar que notification existe e nao esta deletada/cancelada (404)
- Se notification ja esta associada a OUTRO invoice → erro (409 Conflict)
- Se invoice ja tem uma notification associada, substituir pela nova (re-associacao)
- Operacao atomica via `@Transactional`
- Seguir padrao: `fun interface` Gateway → Provider `@Component` → UseCase `@Component`
- Retornar `Result<T>` nos use cases
</requirements>

## Subtarefas

- [ ] 2.1 Criar `AssociateInvoiceGateway` (fun interface) no dominio
- [ ] 2.2 Criar `DisassociateInvoiceGateway` (fun interface) no dominio
- [ ] 2.3 Adicionar query no `PaymentNotificationRepository` para buscar notification por `purchaseInvoiceId`
- [ ] 2.4 Criar `AssociateInvoiceProvider` com `@Transactional` — implementa validacoes e associacao
- [ ] 2.5 Criar `DisassociateInvoiceProvider` com `@Transactional` — remove associacao
- [ ] 2.6 Criar `AssociateInvoiceUseCase` que orquestra o gateway com `Result<T>`
- [ ] 2.7 Criar `DisassociateInvoiceUseCase` que orquestra o gateway com `Result<T>`
- [ ] 2.8 Criar `AssociateInvoiceResponse` DTO

## Detalhes de Implementacao

Consultar a secao **Interfaces Principais** e **Regras do PATCH** da `techspec.md`. Seguir o padrao de `SavePaymentNotificationProvider` e `CancelPurchaseInvoiceProvider` como referencia de estrutura.

## Criterios de Sucesso

- Associacao persiste `purchase_invoice_id` corretamente na notification
- Desassociacao seta `purchase_invoice_id = NULL`
- Validacoes retornam erros apropriados (404, 409)
- Re-associacao funciona (substituir notification anterior)
- Todos os testes passam

## Testes da Tarefa

- [ ] Teste unitario: associacao com sucesso
- [ ] Teste unitario: invoice nao encontrado → erro
- [ ] Teste unitario: notification nao encontrada → erro
- [ ] Teste unitario: notification ja associada a outro invoice → erro 409
- [ ] Teste unitario: re-associacao do mesmo invoice (substituir)
- [ ] Teste unitario: desassociacao com sucesso
- [ ] Teste unitario: desassociacao de invoice sem associacao → sem erro

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/gateway/AssociateInvoiceGateway.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/gateway/DisassociateInvoiceGateway.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/usecase/AssociateInvoiceUseCase.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/usecase/DisassociateInvoiceUseCase.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/application/AssociateInvoiceProvider.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/application/DisassociateInvoiceProvider.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/response/AssociateInvoiceResponse.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` (modificar)

# Tarefa 3.0: Backend — Provider de associação de NF à notificação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar `AssociateNotificationProvider`, responsável por persistir a associação entre uma `PaymentNotification` e uma `PurchaseInvoice`, retornando a notificação atualizada com o campo `associatedInvoice` populado. Depende da Tarefa 1.0.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — padrão Provider/UseCase; `Result<T>` como retorno; tratamento explícito de 404 e 409.
</skills>

<requirements>
- Criar `AssociateNotificationProvider` com método `execute(notificationId: Long, purchaseInvoiceId: Long): Result<PaymentNotificationResponse>`.
- Retornar 404 (`Result.failure`) se a notificação ou a invoice não forem encontradas.
- Retornar 409 (`Result.failure`) se a notificação já possuir uma `purchaseInvoiceId` associada.
- Ao associar com sucesso: setar `notification.purchaseInvoiceId = purchaseInvoiceId`, persistir e retornar o `PaymentNotificationResponse` atualizado com `associatedInvoice` populado.
- Seguir o padrão de `AssociateInvoiceProvider.kt` como referência.
</requirements>

## Subtarefas

- [ ] 3.1 Criar `AssociateNotificationProvider.kt`
- [ ] 3.2 Implementar lógica de validação (404 e 409) e persistência
- [ ] 3.3 Garantir que o `PaymentNotificationResponse` retornado inclui `associatedInvoice` populado
- [ ] 3.4 Escrever testes unitários com mocks dos repositories
- [ ] 3.5 Verificar que typecheck e build passam sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seções "Interfaces Principais" (assinatura do provider), "Considerações Técnicas" (risco de concorrência e constraint UNIQUE) e "Monitoramento e Observabilidade" (logs INFO e WARN).

Adicionar log `INFO` ao associar com sucesso e log `WARN` em tentativa duplicada (409).

## Criterios de Sucesso

- Provider retorna `Result.failure` com código 404 quando notificação ou invoice não existem.
- Provider retorna `Result.failure` com código 409 quando a notificação já está associada.
- Provider retorna `Result.success` com `PaymentNotificationResponse` contendo `associatedInvoice` populado após associação bem-sucedida.
- Testes unitários cobrem todos os cenários de erro e o caminho feliz.

## Testes da Tarefa

- [ ] Testes de unidade: `AssociateNotificationProviderTest`
  - Cenário: notificação não encontrada → `Result.failure` (404)
  - Cenário: invoice não encontrada → `Result.failure` (404)
  - Cenário: notificação já associada → `Result.failure` (409)
  - Cenário: associação bem-sucedida → `Result.success` com `associatedInvoice` no response
- [ ] Testes de integração: não aplicável nesta tarefa (responsabilidade da tarefa 4.0)
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../provider/AssociateNotificationProvider.kt` — novo
- `src/main/kotlin/.../provider/AssociateInvoiceProvider.kt` — referência de padrão
- `src/main/kotlin/.../repository/PaymentNotificationRepository.kt` — leitura
- `src/main/kotlin/.../repository/PurchaseInvoiceRepository.kt` — leitura
- `src/test/kotlin/.../provider/AssociateNotificationProviderTest.kt` — novo
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência

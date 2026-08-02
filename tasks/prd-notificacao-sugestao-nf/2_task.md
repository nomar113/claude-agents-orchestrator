# Tarefa 2.0: Backend — Provider de sugestões de NF

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar `FindNotificationInvoiceSuggestionsProvider`, que recebe um `notificationId`, busca a notificação, e usa a query do `PurchaseInvoiceRepository` para retornar uma lista de `InvoiceSuggestionResponse` ordenada por relevância. Depende da Tarefa 1.0.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — padrão Provider/UseCase já adotado no projeto; usar `Result<T>` como tipo de retorno; seguir estrutura de `SearchNotificationsProvider` como referência.
</skills>

<requirements>
- Criar `FindNotificationInvoiceSuggestionsProvider` no pacote de providers de notificações.
- O método `execute(notificationId: Long): Result<List<InvoiceSuggestionResponse>>` deve:
  - Buscar a `PaymentNotification` pelo ID — retornar erro se não encontrada.
  - Chamar `PurchaseInvoiceRepository.findByTotalAndNotAssociated` com `amount` e `purchasedAt` da notificação.
  - Mapear os resultados para `InvoiceSuggestionResponse`.
  - Retornar `Result.success` com a lista (pode ser vazia).
- Seguir o mesmo padrão de `SearchNotificationsProvider.kt` como referência de estrutura.
</requirements>

## Subtarefas

- [ ] 2.1 Criar `FindNotificationInvoiceSuggestionsProvider.kt`
- [ ] 2.2 Implementar lógica de busca e mapeamento para `InvoiceSuggestionResponse`
- [ ] 2.3 Escrever testes unitários com mocks dos repositories
- [ ] 2.4 Verificar que typecheck e build passam sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seção "Interfaces Principais" (assinatura do provider) e "Arquitetura do Sistema" (tabela de componentes backend).

Referência de padrão: `AssociateInvoiceProvider.kt` e `SearchNotificationsProvider.kt` no projeto.

## Criterios de Sucesso

- Provider retorna lista vazia quando não há candidatas (não é um erro).
- Provider retorna erro (`Result.failure`) quando a notificação não existe.
- Provider retorna lista ordenada por proximidade de data quando há múltiplos candidatos.
- Testes unitários cobrem todos os cenários com mocks do repository.

## Testes da Tarefa

- [ ] Testes de unidade: `FindNotificationInvoiceSuggestionsProviderTest`
  - Cenário: notificação não encontrada → `Result.failure`
  - Cenário: sem invoices candidatas → `Result.success` com lista vazia
  - Cenário: múltiplas invoices candidatas → lista ordenada por proximidade de data
- [ ] Testes de integração: não aplicável nesta tarefa (responsabilidade da tarefa 4.0)
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../provider/FindNotificationInvoiceSuggestionsProvider.kt` — novo
- `src/main/kotlin/.../repository/PurchaseInvoiceRepository.kt` — leitura (query da tarefa 1.0)
- `src/main/kotlin/.../provider/SearchNotificationsProvider.kt` — referência de padrão
- `src/main/kotlin/.../provider/AssociateInvoiceProvider.kt` — referência de padrão
- `src/test/kotlin/.../provider/FindNotificationInvoiceSuggestionsProviderTest.kt` — novo
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência

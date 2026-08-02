# Tarefa 2.0: Gateway + Provider + Repository Method para Busca de Sugestoes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar a camada de dados que busca `payment_notifications` candidatas a associacao com um invoice. Inclui a interface do gateway no dominio, o provider como implementacao, e o novo metodo no repository com query nativa.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar interface `FindInvoiceSuggestionsGateway` no dominio
- Criar `FindInvoiceSuggestionsProvider` como implementacao do gateway
- Adicionar metodo `findSuggestionsByAmountAndDateRange` no `PaymentNotificationRepository` com `@Query` nativa
- A query deve filtrar por: valor exato (`amount`), janela temporal +-1h (`purchased_at`), `deleted_at IS NULL`, `cancelled_at IS NULL`
- A query deve ordenar por proximidade temporal (menor `ABS(TIMESTAMPDIFF)` primeiro)
- A clausula `NOT IN` de exclusao de notificacoes ja associadas deve ser OMITIDA ate o PRD de associacao criar a tabela
- Testes unitarios para o provider/gateway
</requirements>

## Subtarefas

- [ ] 2.1 Criar interface `FindInvoiceSuggestionsGateway` no pacote de dominio
- [ ] 2.2 Adicionar metodo `findSuggestionsByAmountAndDateRange` no `PaymentNotificationRepository` com `@Query` nativa
- [ ] 2.3 Criar `FindInvoiceSuggestionsProvider` implementando o gateway — busca invoice, calcula janela temporal, chama repository
- [ ] 2.4 Escrever testes unitarios para o provider (mock do repository)
- [ ] 2.5 Rodar build e testes

## Detalhes de Implementacao

Consultar a secao "Query do Repository" e "Interfaces Principais" da `techspec.md` para a query SQL e assinaturas das interfaces.

**Atencao ao risco de tipos de data**: `PurchaseInvoiceModel.date` e `OffsetDateTime`, `PaymentNotification.purchasedAt` e `LocalDateTime`. A conversao deve considerar timezone do servidor.

## Criterios de Sucesso

- Gateway, provider e repository method criados seguindo o padrao do projeto
- Query nativa filtra corretamente por valor exato, janela temporal, e exclui deletadas/canceladas
- Resultados ordenados por proximidade temporal
- Testes unitarios passando

## Testes da Tarefa

- [ ] Testes unitarios do provider com mock do repository
- [ ] Verificar que build (`./gradlew build`) passa sem erros

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/payments_notifications/model/PaymentNotification.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/purchase_invoice/model/PurchaseInvoiceModel.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/purchase_invoice/entrypoint/database/repository/PurchaseInvoiceRepository.kt`

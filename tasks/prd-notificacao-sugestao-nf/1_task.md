# Tarefa 1.0: Backend — DTOs e query de sugestões no repository

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar os DTOs de resposta (`InvoiceSuggestionResponse` e `AssociatedInvoiceResponse`) e adicionar a query `findByTotalAndNotAssociated` ao `PurchaseInvoiceRepository`. Esses artefatos são a base para todos os providers e endpoints da feature.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — estrutura de DTOs (data class), padrão de repository com Spring Data JPA e queries nativas/JPQL.
</skills>

<requirements>
- Criar `InvoiceSuggestionResponse` com os campos: `id`, `merchantName`, `cnpj`, `totalItems`, `total`, `date`.
- Criar `AssociatedInvoiceResponse` com os mesmos campos de `InvoiceSuggestionResponse`.
- Adicionar método `findByTotalAndNotAssociated(amount: BigDecimal, purchasedAt: LocalDateTime): List<PurchaseInvoiceModel>` em `PurchaseInvoiceRepository`.
- A query deve filtrar invoices não canceladas, não deletadas e sem associação existente com nenhuma `payment_notification`, ordenadas por proximidade de data em relação à `purchasedAt` da notificação.
- Os DTOs devem ser criados no pacote correto seguindo a estrutura existente do projeto.
</requirements>

## Subtarefas

- [ ] 1.1 Criar `InvoiceSuggestionResponse.kt` com os campos definidos na Tech Spec
- [ ] 1.2 Criar `AssociatedInvoiceResponse.kt` com os campos definidos na Tech Spec
- [ ] 1.3 Adicionar query `findByTotalAndNotAssociated` em `PurchaseInvoiceRepository.kt`
- [ ] 1.4 Escrever testes unitários do repository (mock do datasource)
- [ ] 1.5 Verificar que typecheck e build passam sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seções "Modelos de Dados" e "Endpoints de API" (lógica SQL da query de matching).

A query de matching usa `total == amount`, filtra `deleted_at IS NULL`, `cancelled_at IS NULL`, exclui invoices já associadas a qualquer notificação, e ordena por `ABS(TIMESTAMPDIFF(MINUTE, pi.date, :purchasedAt))`.

## Criterios de Sucesso

- DTOs compilam sem erros e possuem todos os campos especificados.
- Query retorna apenas invoices elegíveis (não canceladas, não associadas).
- Query ordena resultados por proximidade de data em relação à notificação.
- Testes unitários do repository cobrem: sem resultados, múltiplos candidatos, invoice já associada (deve ser excluída).

## Testes da Tarefa

- [ ] Testes de unidade: `PurchaseInvoiceRepositoryTest` — cenários sem candidatos, com múltiplos candidatos, invoice já associada não aparece
- [ ] Testes de integração: não aplicável nesta tarefa (responsabilidade da tarefa 4.0)
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../dto/InvoiceSuggestionResponse.kt` — novo
- `src/main/kotlin/.../dto/AssociatedInvoiceResponse.kt` — novo
- `src/main/kotlin/.../repository/PurchaseInvoiceRepository.kt` — modificado
- `src/main/kotlin/.../model/PurchaseInvoiceModel.kt` — leitura (campos: total, date, merchantName, cnpj, totalItems)
- `src/test/kotlin/.../repository/PurchaseInvoiceRepositoryTest.kt` — novo
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência

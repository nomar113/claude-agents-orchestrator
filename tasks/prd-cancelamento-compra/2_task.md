# Tarefa 2.0: Entidades e DTOs

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar as entidades JPA, projections e response DTOs para incluir o campo `cancelledAt` em ambos os contextos (payment_notifications e purchase_invoices).

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de entities e DTOs existente no projeto.
</skills>

<requirements>
- Adicionar campo `cancelledAt: LocalDateTime? = null` na entity `PaymentNotification`
- Adicionar campo `cancelledAt: LocalDateTime? = null` na entity `PurchaseInvoiceModel`
- Atualizar `PurchaseProjection` para incluir `getCancelledAt(): LocalDateTime?`
- Atualizar response DTOs (`PaymentNotificationResponse`, `PurchaseInvoiceDetailResponse`) com `cancelledAt: String?` (ISO 8601)
- Manter `@SQLRestriction("deleted_at IS NULL")` inalterado (canceladas devem permanecer visiveis)
</requirements>

## Subtarefas

- [ ] 2.1 Atualizar entity `PaymentNotification.kt` com campo `cancelledAt`
- [ ] 2.2 Atualizar entity `PurchaseInvoiceModel.kt` com campo `cancelledAt`
- [ ] 2.3 Atualizar `PurchaseProjection` interface com getter `getCancelledAt()`
- [ ] 2.4 Atualizar `PaymentNotificationResponse` com campo `cancelledAt`
- [ ] 2.5 Atualizar `PurchaseInvoiceDetailResponse` com campo `cancelledAt`
- [ ] 2.6 Atualizar converters/mappers que transformam entity em response

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Modelos de Dados > Entidade atualizada" e "Projection atualizada"

O campo deve ser mapeado com `@Column(name = "cancelled_at")`. O `@SQLRestriction` NAO deve filtrar cancelados — apenas deleted.

## Criterios de Sucesso

- Entidades compilam sem erros
- Campo `cancelledAt` e serializado como ISO 8601 string (ou null) nas responses
- Registros cancelados continuam visiveis nas queries (nao filtrados pelo SQLRestriction)
- Testes existentes continuam passando (campo nullable nao quebra nada)

## Testes da Tarefa

- [ ] Testes de unidade: verificar que converters mapeiam `cancelledAt` corretamente para response
- [ ] Testes de integracao: salvar entity com `cancelledAt` preenchido e verificar que persiste e retorna corretamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt` (PurchaseProjection)
- `src/main/kotlin/.../payments_notification/entrypoint/rest/response/` (response DTOs)
- `src/main/kotlin/.../purchases_invoices/entrypoint/rest/response/PurchaseInvoiceDetailResponse.kt`

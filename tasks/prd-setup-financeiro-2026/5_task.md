# Tarefa 5.0: Backend — Vincular categorias as compras

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar os modelos JPA, requests e a query de leitura de compras para usar `category_id` (FK) em vez do campo texto livre. Inclui atualizar o `ManualPaymentNotificationRequest`, os modelos `PaymentNotification` e `PurchaseInvoice`, e o `PurchaseProjection` com JOIN na tabela `categories`.

<skills>
### Conformidade com Skills Padroes

- **`kotlin-springboot`**: JPA relationships, native queries, Spring Data projections.
- **`clean-code`**: Retrocompatibilidade sem hacks.
</skills>

<requirements>
- Atualizar `PaymentNotification` (model JPA) para incluir `categoryId: Long?`
- Atualizar `PurchaseInvoice` (model JPA) para incluir `categoryId: Long?`
- Atualizar `ManualPaymentNotificationRequest`: trocar `category: String` por `categoryId: Long`
- Atualizar controller de payment notifications para usar `categoryId`
- Atualizar `PurchaseProjection` para incluir `getCategoryName(): String?`
- Atualizar UNION query em `PurchaseRepository` com LEFT JOIN na tabela `categories`
- Atualizar responses de compras para incluir `categoryName`
- Manter retrocompatibilidade: campo `category` (texto) continua funcionando
</requirements>

## Subtarefas

- [ ] 5.1 Atualizar `PaymentNotification.kt` (model) — adicionar campo `categoryId`
- [ ] 5.2 Atualizar modelo JPA de `PurchaseInvoice` — adicionar campo `categoryId`
- [ ] 5.3 Atualizar `ManualPaymentNotificationRequest.kt` — `categoryId: Long` em vez de `category: String`
- [ ] 5.4 Atualizar `PaymentNotificationController.kt` — mapear `categoryId` no fluxo de criacao manual
- [ ] 5.5 Atualizar `PurchaseProjection.kt` — adicionar `getCategoryName()`
- [ ] 5.6 Atualizar UNION query em `PurchaseRepository.kt` — LEFT JOIN categories
- [ ] 5.7 Atualizar responses de compras para incluir `categoryName`
- [ ] 5.8 Escrever testes de integracao

## Detalhes de Implementacao

Consultar as secoes **Componentes modificados** e **Fluxo de dados** da `techspec.md`.

A UNION query precisa de LEFT JOIN em ambas as subqueries:
```sql
SELECT pn.id, ..., c.name AS categoryName
FROM payment_notifications pn
LEFT JOIN categories c ON pn.category_id = c.id
WHERE pn.deleted_at IS NULL
UNION
SELECT pi.id, ..., c.name AS categoryName
FROM purchase_invoices pi
LEFT JOIN categories c ON pi.category_id = c.id
WHERE pi.deleted_at IS NULL
```

## Criterios de Sucesso

- Registro manual de compra aceita `categoryId` e persiste corretamente
- UNION query retorna `categoryName` para compras com categoria vinculada
- Compras sem categoria (existentes) retornam `categoryName = null`
- Campo `category` (texto) continua disponivel para retrocompatibilidade
- Build e testes existentes continuam passando

## Testes da Tarefa

- [ ] Teste de integracao: criar compra manual com `categoryId` e verificar persistencia
- [ ] Teste de integracao: listar compras e verificar `categoryName` presente
- [ ] Teste de integracao: compras sem `categoryId` retornam `categoryName` null
- [ ] Teste unitario: validar que `ManualPaymentNotificationRequest` requer `categoryId`

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/.../application/payments_notification/entrypoint/rest/request/ManualPaymentNotificationRequest.kt`
- `controlai/src/main/kotlin/.../application/payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `controlai/src/main/kotlin/.../application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `controlai/src/main/kotlin/.../application/purchases_invoices/entrypoint/database/model/PurchaseProjection.kt`
- `controlai/src/main/kotlin/.../application/purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt`

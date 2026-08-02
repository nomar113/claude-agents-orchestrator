# Review: Task 2.0 - Backend - Endpoint PATCH `/payments/notifications/{id}/payment-method`

**Revisor**: AI Code Reviewer
**Data**: 2026-06-14
**Arquivo da task**: 2_task.md
**Status**: APROVADO

## Resumo

A task solicitava expor o `UpdateNotificationPaymentMethodProvider` (entregue na Task 1.0) atraves de um endpoint REST atomico em `PaymentNotificationController`, com mapeamento explicito de erros para os HTTP status `404 / 409 / 400 / 500`, retornando `PaymentNotificationResponse` no caminho feliz, e cobertura de controller test para os 7 cenarios da Tech Spec. A implementacao esta correta, segue exatamente o padrao "controller magro + getOrElse + ResponseStatusException" ja usado em `associateInvoice`, mantem o controller livre de logica de dominio, usa `@Validated @RequestBody` no estilo de `updatePurchasedAt` e `createManualNotification`, e os 7 cenarios da Tech Spec sao verificados via MockMvc com setup real de schema (Flyway). Todos os 14 testes da classe passaram com `BUILD SUCCESSFUL` (`tests="14" failures="0" errors="0"`). Nao foram encontrados problemas criticos nem major.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` | OK | 0 |
| `src/test/kotlin/br/com/nomar/controlai/application/payments_notification/PaymentNotificationControllerTest.kt` | OK | 2 (minor) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**m1 - `type = "CREDIT"` no helper `insertPaymentMethod` nao corresponde ao enum do dominio**
- **Arquivo**: `src/test/.../PaymentNotificationControllerTest.kt:38`
- **Descricao**: O default `type: String = "CREDIT"` no helper `insertPaymentMethod` nao corresponde a nenhum valor do enum `br.com.nomar.controlai.domain.payment_methods.entity.PaymentMethodType` (`CREDIT_CARD`, `PIX`, `CASH`). O `PaymentMethodModel.type` e modelado como `String` (e o schema usa `VARCHAR(20)`), entao o teste passa, mas o valor diverge do dominio real. O `PurchaseCategoryIntegrationTest` ja inserido no projeto usa `'CREDIT_CARD'`.
- **Impacto**: Nulo no comportamento. O `UpdateNotificationPaymentMethodProvider` nao le `paymentMethod.type`, apenas localiza a entidade e itera `subCards`. Funcionalmente irrelevante para a cobertura da Task 2.0.
- **Sugestao**:
  ```kotlin
  private fun insertPaymentMethod(
      holderId: Long,
      name: String = "Cartao Teste",
      type: String = "CREDIT_CARD",
  ): Long
  ```
  Mantem coerencia com o restante da suite e com o enum de dominio.

**m2 - `type = "FISICO"` no helper `insertSubCard` nao corresponde ao enum `SubCardType`**
- **Arquivo**: `src/test/.../PaymentNotificationControllerTest.kt:48`
- **Descricao**: Mesmo padrao do m1 para o `SubCardModel.type` (`VARCHAR(30)` como `String` na entidade). O enum existente nao foi consultado para extrair o valor "canonico" para fixture.
- **Impacto**: Nulo. `UpdateNotificationPaymentMethodProvider` so usa `subCard.id` e `subCard.lastFourDigits`. Nao bloqueia a cobertura.
- **Sugestao**: usar um valor do enum `SubCardType` correspondente (por exemplo `PHYSICAL` ou o que estiver vigente), checando o arquivo `src/main/kotlin/.../SubCardType.kt`, para manter os fixtures alinhados com o dominio.

## Destaques Positivos

1. **Controller magro 100% delegante**: o handler `updatePaymentMethod` (linhas 173-189) reusa exatamente o padrao de `associateInvoice` (linhas 115-127) — chama `provider.execute(...).getOrElse { ... }`, mapeia tres tipos de excecao + fallback `500`, e retorna `PaymentNotificationResponse.from(notification)`. Zero logica de dominio vazada para o controller.
2. **Mapeamento de erros aderente a Tech Spec**:
   - `NoSuchElementException` -> `404 NOT_FOUND` (notificacao inexistente);
   - `IllegalStateException` -> `409 CONFLICT` (notificacao cancelada);
   - `IllegalArgumentException` -> `400 BAD_REQUEST` (paymentMethod ausente OU subCard nao pertence);
   - demais -> `500 INTERNAL_SERVER_ERROR`.
   Exatamente o que a Tech Spec lista em "Endpoints de API" e o que a Task 1.0 deixou disponivel via `runCatching` no provider.
3. **`@Validated @RequestBody UpdatePaymentMethodRequest`** no mesmo estilo de `updatePurchasedAt` e `createManualNotification` — habilita o `@field:NotNull paymentMethodId` do DTO da Task 1.0.
4. **Injecao via construtor primario**: `updateNotificationPaymentMethodProvider` foi adicionado como o ultimo parametro, sem reordenar dependencias pre-existentes; estilo idiomatico Spring + Kotlin.
5. **Cobertura completa dos 7 cenarios da Tech Spec/Task**:
   - 200 sem `subCardId` (linhas 185-201, verifica `cardLastDigits` preservado em "1234");
   - 200 com `subCardId` valido (linhas 203-220, verifica `cardLastDigits` sobrescrito para "9876");
   - 200 idempotencia (linhas 222-245, dispara duas chamadas com mesmo body);
   - 400 `paymentMethodId` inexistente (linhas 247-257);
   - 400 `subCardId` de outro `paymentMethod` (linhas 259-273);
   - 404 `notificationId` inexistente (linhas 275-286);
   - 409 notificacao cancelada (linhas 288-300, helper `insertCancelledNotification` com `cancelled_at` preenchido).
6. **Teste de pertinencia do subCard cria explicitamente dois `payment_methods`** (linhas 261-263) e usa o `subCardId` "estrangeiro" — cobre a validacao de pertinencia que o provider faz via `paymentMethod.subCards.firstOrNull`.
7. **Asserts confirmam a regra de `cardLastDigits`** — sem subCard preserva `"1234"`, com subCard sobrescreve para `"9876"`, exatamente como o provider implementa em `subCard?.lastFourDigits ?: notification.cardLastDigits`.
8. **`cleanUp()` cobre as 6 tabelas relevantes** (`installments`, `payment_notifications`, `purchase_invoices`, `sub_cards`, `payment_methods`, `holders`), respeitando a ordem de FK (filhos antes de pais). Garante isolamento entre testes.
9. **Helpers `insertHolder/insertPaymentMethod/insertSubCard/insertCancelledNotification` adicionados de forma incremental** sem quebrar os 7 testes pre-existentes de `invoice-suggestions` e `associate` — todos os 14 continuam passando.
10. **Reuso de schema real via Flyway no `@SpringBootTest`** — valida que o endpoint integra com o modelo persistido (FK `holder_id`, `payment_method_id`, `payment_notifications`), nao apenas com mocks.
11. **Sem logging extra adicionado no controller** — atende explicitamente o requirement "controller nao adiciona logging extra alem do padrao do projeto" (o log estruturado vive no provider, conforme Task 1.0).
12. **`@Validated @RequestBody` com DTO Bean Validation** — caso `paymentMethodId` venha ausente do JSON, o `@field:NotNull` ja produz `400` sem precisar logica extra.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (kotlin-springboot) | OK |
| Clean Code (controller magro, sem duplicacao, sem logica de dominio) | OK |
| REST/HTTP (mapeamento de status corretos) | OK |
| Aderencia a Tech Spec (path, body, response, codigos de erro) | OK |
| Aderencia a Task (requirements + 3 subtarefas) | OK |
| Cobertura de Testes (7 cenarios + 1 idempotencia) | OK |
| Execucao dos Testes (14 / 0 failures / 0 errors) | OK |
| Isolamento do controller em relacao ao dominio | OK |
| Logging (delegado ao provider, sem ruido extra) | OK |

## Verificacao de Execucao

- `./gradlew test --tests "br.com.nomar.controlai.application.payments_notification.PaymentNotificationControllerTest" --rerun-tasks` -> **BUILD SUCCESSFUL** em ~26s.
- Relatorio JUnit XML: `tests="14" skipped="0" failures="0" errors="0"` (`build/test-results/test/TEST-...PaymentNotificationControllerTest.xml`).
- Os 7 cenarios `PATCH payment-method` aparecem todos como passou no XML; os 7 cenarios pre-existentes (`invoice-suggestions` e `associate`) continuam verdes, confirmando que as alteracoes em `cleanUp()` e nos helpers nao causaram regressao.

## Recomendacoes

1. **Opcional (minor m1/m2)**: alinhar os defaults `type` dos helpers `insertPaymentMethod` e `insertSubCard` com os enums de dominio (`PaymentMethodType`, `SubCardType`). Reduz acoplamento implicito a strings "magicas" e segue o padrao ja adotado em `PurchaseCategoryIntegrationTest`.
2. **Opcional**: adicionar uma assertion extra no caso "200 sem subCardId" verificando o campo `merchantName` ou outro alem de `id/paymentMethodId/subCardId/cardLastDigits`, para fortalecer o contrato "retorna `PaymentNotificationResponse` completa" mencionado no requirement. Nao bloqueante — a serializacao ja entrega todos os campos do DTO via `PaymentNotificationResponse.from`.
3. **Manter** o estilo atual do controller — esta canonicamente igual ao `associateInvoice` e nao precisa de `@ControllerAdvice` (o projeto opta por `ResponseStatusException` por handler).
4. **Observabilidade**: o log INFO continua vivendo no `UpdateNotificationPaymentMethodProvider` (conforme Task 1.0), com `notificationId / oldPaymentMethodId / newPaymentMethodId / subCardChanged`. Nenhuma acao adicional necessaria nesta task.

## Veredito

A implementacao da Task 2.0 esta **correta, integralmente alinhada ao PRD e a Tech Spec**, e segue rigorosamente os padroes do projeto (kotlin-springboot + clean-code) e o estilo dos endpoints irmaos (`/description`, `/category`, `/purchased-at`, `/associate`). Os 7 cenarios obrigatorios da Tech Spec sao cobertos por testes de controller integrados que rodam contra schema real (Flyway), e os 14 testes da suite passaram sem failures. As duas observacoes minor sao apenas higiene de fixture (valores de `type` que nao batem com os enums do dominio) e nao afetam o comportamento avaliado. A task esta **aprovada** e pode ser considerada concluida. Proximo passo natural: Task 3.0 (frontend service `updatePaymentNotificationCard` em `purchaseService.ts`).

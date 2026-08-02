# Review: Task 2.0 - Associate/Disassociate -- Gateway, Provider, UseCase

**Revisor**: AI Code Reviewer
**Data**: 2026-05-23
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task 2.0 implementou corretamente os gateways, providers e use cases para associacao e desassociacao de invoices com payment notifications. A estrutura segue fielmente o padrao do projeto (fun interface Gateway, Provider @Component com @Transactional, UseCase @Component com Result). Os 10 testes de integracao cobrem os cenarios principais e passam com sucesso. Ha dois problemas major relacionados a validacoes ausentes e uma inconsistencia de persistencia, alem de observacoes menores.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/.../gateway/AssociateInvoiceGateway.kt` | OK | 0 |
| `domain/.../gateway/DisassociateInvoiceGateway.kt` | OK | 0 |
| `application/.../response/AssociateInvoiceResponse.kt` | OK | 0 |
| `application/.../application/AssociateInvoiceProvider.kt` | Problemas | 2 |
| `application/.../application/DisassociateInvoiceProvider.kt` | Problemas | 2 |
| `domain/.../usecase/AssociateInvoiceUseCase.kt` | OK | 0 |
| `domain/.../usecase/DisassociateInvoiceUseCase.kt` | OK | 0 |
| `application/.../repository/PaymentNotificationRepository.kt` | OK | 0 |
| `test/.../AssociateInvoiceProviderTest.kt` | Problemas | 1 |
| `test/.../DisassociateInvoiceProviderTest.kt` | Problemas | 2 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1. Validacao de `deletedAt` ausente no AssociateInvoiceProvider**
- **Arquivo**: `src/main/kotlin/.../application/AssociateInvoiceProvider.kt`, linhas 20-31
- **Descricao**: O requisito da task e claro: "Validar que invoice existe e nao esta deletado/cancelado (404)" e "Validar que notification existe e nao esta deletada/cancelada (404)". A implementacao valida apenas `cancelledAt`, mas nao valida `deletedAt`. Ambas as entidades possuem o campo `deletedAt: LocalDateTime?`. Um invoice ou notification soft-deleted sera tratado como valido, o que e incorreto.
- **Correcao sugerida**:
```kotlin
if (invoice.deletedAt != null) {
    throw NoSuchElementException("PurchaseInvoice is deleted: $invoiceId")
}

if (notification.deletedAt != null) {
    throw NoSuchElementException("PaymentNotification is deleted: $notificationId")
}
```

**M2. Validacao de `deletedAt` e `cancelledAt` ausente no DisassociateInvoiceProvider**
- **Arquivo**: `src/main/kotlin/.../application/DisassociateInvoiceProvider.kt`, linhas 17-27
- **Descricao**: O provider de desassociacao valida que o invoice existe (via `findById`), mas nao verifica se o invoice esta deletado ou cancelado. Por consistencia com as regras de negocio e com o AssociateInvoiceProvider, deveria validar ambos os campos.
- **Correcao sugerida**:
```kotlin
val invoice = purchaseInvoiceRepository.findById(invoiceId)
    .orElseThrow { NoSuchElementException("PurchaseInvoice not found: $invoiceId") }

if (invoice.deletedAt != null) {
    throw NoSuchElementException("PurchaseInvoice is deleted: $invoiceId")
}

if (invoice.cancelledAt != null) {
    throw NoSuchElementException("PurchaseInvoice is cancelled: $invoiceId")
}
```

**M3. Testes ausentes para cenarios de `deletedAt`**
- **Arquivo**: `src/test/kotlin/.../AssociateInvoiceProviderTest.kt` e `DisassociateInvoiceProviderTest.kt`
- **Descricao**: Nao ha testes para validar que invoices ou notifications com `deletedAt` preenchido sao rejeitados. Apos corrigir M1 e M2, testes correspondentes devem ser adicionados.

### Problemas Minor

**m1. Inconsistencia entre `saveAndFlush` e `save` no DisassociateInvoiceProvider**
- **Arquivo**: `src/main/kotlin/.../application/DisassociateInvoiceProvider.kt`, linha 25
- **Descricao**: O `AssociateInvoiceProvider` usa `saveAndFlush` para persistir as alteracoes, enquanto o `DisassociateInvoiceProvider` usa `save`. Dentro de uma `@Transactional`, ambos funcionam corretamente, mas a inconsistencia pode confundir futuros desenvolvedores. Recomenda-se padronizar.
- **Correcao sugerida**: Trocar `save` por `saveAndFlush` no `DisassociateInvoiceProvider` para manter consistencia com o `AssociateInvoiceProvider`.

**m2. Duplo `runCatching` nos UseCases**
- **Arquivo**: `AssociateInvoiceUseCase.kt` linha 11, `DisassociateInvoiceUseCase.kt` linha 10
- **Descricao**: Os use cases envolvem a chamada ao gateway em `runCatching { gateway.execute(...).getOrThrow() }`. O gateway ja retorna `Result<T>`. O `getOrThrow()` desembrulha o Result do gateway, e o `runCatching` do use case re-embrulha em um novo Result. Isso e funcionalmente correto e segue o padrao existente do projeto (ex: `CancelPurchaseInvoiceUseCase`), portanto e consistente. Porem, adiciona uma camada de wrapping desnecessaria. Observacao informativa apenas -- nao requer mudanca dado que e padrao do projeto.

**m3. Teste de `DisassociateInvoiceProviderTest` nao valida cenario de invoice cancelado**
- **Arquivo**: `src/test/kotlin/.../DisassociateInvoiceProviderTest.kt`
- **Descricao**: Nao ha teste para verificar que a desassociacao falha quando o invoice esta cancelado. O `AssociateInvoiceProviderTest` tem esse cenario (linha 170), mas o `DisassociateInvoiceProviderTest` nao. Apos corrigir M2, adicionar esse teste.

## Destaques Positivos

1. **Padrao arquitetural seguido fielmente**: A cadeia Gateway -> Provider -> UseCase esta correta e consistente com o restante do projeto (`CancelPurchaseInvoiceProvider`, `SavePurchaseInvoiceProvider`).

2. **Logica de re-associacao bem implementada**: O cenario de substituir uma notification existente (linhas 38-42 do AssociateInvoiceProvider) desassocia a anterior antes de associar a nova, garantindo integridade.

3. **Deteccao correta de conflito 409**: A validacao de notification ja associada a outro invoice (linha 34 do AssociateInvoiceProvider) usa `IllegalStateException` de forma adequada, permitindo que o controller mapeie para 409.

4. **Testes de integracao com @SpringBootTest**: Os testes usam o contexto real do Spring com banco de dados, validando o fluxo completo incluindo transacionalidade. A estrategia de cleanup com `@AfterEach` e `JdbcTemplate` e solida.

5. **Cobertura de cenarios**: 7 testes para associacao e 3 para desassociacao cobrem os cenarios positivos e negativos mais importantes, incluindo re-associacao e idempotencia.

6. **Desassociacao resiliente**: O `DisassociateInvoiceProvider` trata graciosamente o caso em que nao ha notification associada (retorna sucesso via `return@runCatching`), evitando erros desnecessarios.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| Arquitetura (Gateway/Provider/UseCase) | OK |
| @Transactional | OK |
| Result<T> | OK |
| Testes | Problemas |

## Recomendacoes

1. **[Major]** Adicionar validacao de `deletedAt` no `AssociateInvoiceProvider` para invoice e notification.
2. **[Major]** Adicionar validacao de `deletedAt` e `cancelledAt` no `DisassociateInvoiceProvider`.
3. **[Major]** Criar testes para os cenarios de `deletedAt` em ambos os providers e para `cancelledAt` no `DisassociateInvoiceProvider`.
4. **[Minor]** Padronizar uso de `saveAndFlush` vs `save` entre os dois providers.

## Veredito

A implementacao esta bem estruturada, segue os padroes do projeto e cobre a maioria dos cenarios. Porem, a ausencia de validacao de `deletedAt` em ambos os providers e de `cancelledAt` no DisassociateInvoiceProvider representa lacunas nas regras de negocio explicitamente definidas nos requisitos da task ("nao esta deletado/cancelado"). Recomendo corrigir essas validacoes e adicionar os testes correspondentes antes de prosseguir para a task seguinte.

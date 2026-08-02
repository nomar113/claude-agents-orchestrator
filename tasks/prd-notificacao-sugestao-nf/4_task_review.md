# Review: Task 4 - Controller Layer — Sugestão de NF a partir de Notificação de Pagamento

**Revisor**: AI Code Reviewer
**Data**: 2026-05-24
**Arquivo da task**: 4_task.md (descrito no contexto da revisão)
**Status**: APROVADO COM OBSERVACOES

---

## Resumo

A task implementou corretamente a camada de controller backend para a feature de sugestão e associação de NF a partir de notificações de pagamento. Foram adicionados dois endpoints ao `PaymentNotificationController` (`GET /invoice-suggestions` e `PATCH /associate`), o `PaymentNotificationResponse` foi estendido com os campos `purchaseInvoiceId` e `associatedInvoice`, e uma suíte de 7 testes de integração com Spring MockMvc foi criada.

O código está funcional, bem estruturado e segue os padrões do projeto. Os testes cobrem todos os cenários especificados. Foram identificados dois problemas minor e um ponto de melhoria relacionado a consistência semântica — nenhum de caráter crítico ou bloqueador.

---

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/payments_notification/entrypoint/rest/request/AssociateNotificationRequest.kt` | OK | 0 |
| `application/payments_notification/entrypoint/rest/response/PaymentNotificationResponse.kt` | OK | 0 |
| `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` | Problemas | 2 |
| `application/payments_notification/PaymentNotificationControllerTest.kt` | Problemas | 1 |

---

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

---

### Problemas Major

Nenhum problema major encontrado.

---

### Problemas Minor

**[MINOR-1] Controller — `AssociateNotificationProvider` quebra o princípio Query/Mutation**

Arquivo: `PaymentNotificationController.kt`, linha 117
Arquivo do provider: `AssociateNotificationProvider.kt`, linhas 47-53

O `AssociateNotificationProvider.execute` persiste a associação (mutação) e em seguida constrói e retorna um `PaymentNotificationResponse` populado com `AssociatedInvoiceResponse` via `.copy()` (consulta + montagem de DTO). Esse acúmulo de responsabilidades não é problema critico no contexto do projeto — o padrão já existe em outros providers — mas vale registrar como oportunidade de melhoria futura: separar a construção do response em um método `from(entity, invoice)` já existente no `PaymentNotificationResponse` (evitando o `.copy()` extra após salvar).

Situação atual:
```kotlin
PaymentNotificationResponse.from(saved).copy(
    associatedInvoice = AssociatedInvoiceResponse.from(invoice),
)
```

Alternativa mais limpa (usando o `from` com dois argumentos já definido no response):
```kotlin
PaymentNotificationResponse.from(saved, invoice)
```

O método `from(entity, invoice)` já existe em `PaymentNotificationResponse` e faz exatamente isso.

---

**[MINOR-2] Controller — Falta `@Validated` no body do endpoint PATCH /associate**

Arquivo: `PaymentNotificationController.kt`, linha 115

O `AssociateNotificationRequest` não possui anotações de validação (`@NotNull`, `@Positive`) no campo `purchaseInvoiceId`. Caso o cliente envie `null` ou um valor negativo/zero, o controller passa o valor inválido diretamente ao provider, que vai lançar um `NoSuchElementException` com mensagem técnica interna ("PurchaseInvoice not found: 0") em vez de retornar um `400 Bad Request` claro.

Comparação com outros endpoints do mesmo controller que usam `@Validated`:
```kotlin
// Linha 163 — updatePurchasedAt usa @Validated
@Validated @RequestBody request: UpdatePurchasedAtRequest
```

Sugestão:
```kotlin
// AssociateNotificationRequest.kt
import jakarta.validation.constraints.Positive

data class AssociateNotificationRequest(
    @field:Positive
    val purchaseInvoiceId: Long,
)

// PaymentNotificationController.kt — linha 115
@Validated @RequestBody request: AssociateNotificationRequest,
```

---

**[MINOR-3] Teste — Helper `insertNotification` usa SQL com interpolação de string**

Arquivo: `PaymentNotificationControllerTest.kt`, linhas 47-53

O método `insertNotification` constrói a query SQL concatenando valores via interpolação de string Kotlin. Embora seja código de teste e os valores sejam controlados pelo próprio teste, o padrão recomendado é usar `PreparedStatement` com parâmetros posicionais para consistência e segurança:

Situação atual:
```kotlin
jdbcTemplate.update(
    "INSERT INTO payment_notifications " +
        "(...) VALUES ('1234', '2024-06-15 10:00:00', $amount, 'Loja Test', 1, 'NUBANK', 'HTTP_REQUEST', $invoiceIdSql)"
)
```

Sugestão:
```kotlin
jdbcTemplate.update(
    "INSERT INTO payment_notifications (card_last_digits, purchased_at, amount, merchant_name, " +
        "number_of_installments, origin, origin_type, purchase_invoice_id) " +
        "VALUES ('1234', '2024-06-15 10:00:00', ?, 'Loja Test', 1, 'NUBANK', 'HTTP_REQUEST', ?)",
    amount, purchaseInvoiceId
)
```

O mesmo padrão se aplica ao helper `insertInvoice`.

---

## Destaques Positivos

- **Tratamento de erros consistente**: O pattern `getOrElse { ex -> when(ex) { ... } }` com mapeamento semântico (`NoSuchElementException → 404`, `IllegalStateException → 409`) está correto e alinhado com outros endpoints do controller.
- **Assinatura do `from(entity, invoice)` bem projetada**: A extensão do `PaymentNotificationResponse` com parâmetro opcional `invoice: PurchaseInvoiceModel? = null` é elegante — mantém compatibilidade com todas as chamadas existentes sem nenhuma quebra.
- **Cobertura de testes completa**: Os 7 cenários cobrem exatamente o que foi especificado — lista vazia, lista com candidato, 404 no GET, 200/404/404/409 no PATCH. A separação visual com comentários de bloco (`// --- GET invoice-suggestions ---`) facilita a leitura.
- **`AssociateNotificationProvider` detecta cancelamento**: A validação de `cancelledAt` tanto na notificação quanto na invoice antes de persistir a associação é uma proteção correta e alinhada com o domínio.
- **Log de auditoria no provider**: O `logger.info` de sucesso e `logger.warn` na duplicação seguem a especificação de observabilidade da Tech Spec.
- **`InvoiceSuggestionResponse` e `AssociatedInvoiceResponse` com estrutura idêntica**: A duplicação intencional dos dois DTOs é a decisão correta de design — cada um tem semântica própria e podem evoluir independentemente.

---

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (naming, tamanho, nesting) | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP (status codes, verbos) | OK |
| Logging | OK |
| Testes (cobertura, nomenclatura) | Problemas |

---

## Recomendacoes

1. **(Menor esforço, maior impacto)** Corrigir o `AssociateNotificationProvider` para usar `PaymentNotificationResponse.from(saved, invoice)` em vez de `.copy(associatedInvoice = ...)`. O método já existe e tem a assinatura correta.
2. Adicionar `@field:Positive` em `AssociateNotificationRequest.purchaseInvoiceId` e `@Validated` no parâmetro do controller para validação antecipada com resposta `400` adequada.
3. Refatorar os helpers `insertNotification` e `insertInvoice` nos testes para usar parâmetros posicionais no `JdbcTemplate.update`.

---

## Veredito

A implementação cumpre todos os critérios de sucesso da task: os dois endpoints funcionam corretamente, os status codes estão mapeados, o `PaymentNotificationResponse` foi estendido conforme especificado e os 7 testes passam. Nenhum problema bloqueador foi identificado.

**Status: APROVADO COM OBSERVACOES** — recomenda-se aplicar as correções minor (especialmente MINOR-1 e MINOR-2) antes do próximo ciclo de code review da branch completa.

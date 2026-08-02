# Review: Task 1.0 - Backend — DTOs e query de sugestões no repository

**Revisor**: AI Code Reviewer
**Data**: 2026-05-24
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVACOES

---

## Resumo

A implementacao entregou os dois DTOs (`InvoiceSuggestionResponse` e `AssociatedInvoiceResponse`), a query nativa `findByTotalAndNotAssociated` no `PurchaseInvoiceRepository` e uma suíte de 6 testes de integração. A estrutura geral esta alinhada com os requisitos da Tech Spec. Build e todos os testes passam com sucesso.

Os principais pontos de atencao sao: (1) duplicacao de codigo entre os dois DTOs que sao identicos estruturalmente; (2) o tipo de teste implementado e de integração com `@SpringBootTest`, enquanto a task especificava testes unitários com mock do datasource — isso nao e um bloqueador pois os testes entregam cobertura maior, mas diverge do especificado; (3) a query nativa inclui explicitamente `deleted_at IS NULL` enquanto o modelo ja possui `@SQLRestriction("deleted_at IS NULL")`, criando redundância segura mas desnecessária em queries nativas.

---

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `payments_notification/entrypoint/rest/response/InvoiceSuggestionResponse.kt` | Problemas | 2 |
| `payments_notification/entrypoint/rest/response/AssociatedInvoiceResponse.kt` | Problemas | 2 |
| `purchases_invoices/entrypoint/database/repository/PurchaseInvoiceRepository.kt` | OK | 1 (minor) |
| `test/.../purchases_invoices/PurchaseInvoiceRepositoryTest.kt` | OK | 1 (minor) |

---

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

---

### Problemas Major

**MAJOR-01 — Duplicacao estrutural completa entre `InvoiceSuggestionResponse` e `AssociatedInvoiceResponse`**

Arquivo: `InvoiceSuggestionResponse.kt` e `AssociatedInvoiceResponse.kt` (linhas 7–25 em ambos)

Os dois DTOs sao estruturalmente identicos: mesmos campos, mesmos tipos, mesmo factory method `from(invoice: PurchaseInvoiceModel)`. A Tech Spec define ambos explicitamente como classes separadas (para suportar evolucao independente futura), mas o padrao atual viola o principio DRY sem nenhuma diferenca semantica presente.

A escolha de manter como classes separadas e valida arquiteturalmente. Porem, o factory method duplicado introduz risco de divergencia silenciosa se um dos dois for alterado. O ideal e tornar o factory method `from` em uma funcao de extensao compartilhada ou uma funcao privada interna ao pacote que ambos invocam.

Correcao sugerida:
```kotlin
// Opcao A: funcao de extensao interna ao pacote (arquivo InvoiceResponseMapper.kt)
internal fun PurchaseInvoiceModel.toInvoiceSuggestionResponse() = InvoiceSuggestionResponse(
    id = id!!,
    merchantName = merchantName,
    cnpj = cnpj,
    totalItems = totalItems,
    total = total ?: BigDecimal.ZERO,
    date = date.toLocalDate(),
)

// Opcao B: manter factory method mas delegar para funcao compartilhada
// InvoiceSuggestionResponse.from() e AssociatedInvoiceResponse.from()
// delegam para buildInvoiceResponseFields(invoice) que retorna os campos comuns
```

Se a decisao arquitetural for manter DTOs separados com evolucao independente (justificada pelo PRD), ao menos documente a razao para evitar confusao futura.

---

**MAJOR-02 — Tipo de teste diverge do especificado na task**

Arquivo: `PurchaseInvoiceRepositoryTest.kt` (linha 18)

A task especifica na secao "Subtarefas" (item 1.4): "Escrever **testes unitários** do repository (mock do datasource)". A secao "Testes da Tarefa" reafirma: "Testes de unidade: cenários sem candidatos, com múltiplos candidatos, invoice já associada não aparece". O que foi implementado sao **testes de integração** com `@SpringBootTest` e banco de dados real (MySQL via Testcontainers ou configuracao de teste).

Testes de integracao tem valor maior para validar queries nativas, mas a divergencia com o especificado deve ser explicitamente registrada. Queries nativas de fato sao mais bem testadas com banco real, o que torna a escolha tecnicamente justificavel.

Acao recomendada: documentar no PR/commit a decisao de usar integração em vez de unidade, ou criar um comentario no arquivo explicando que queries nativas requerem integração para validacao correta.

---

### Problemas Minor

**MINOR-01 — Redundancia de `deleted_at IS NULL` na query nativa**

Arquivo: `PurchaseInvoiceRepository.kt` (linha 22)

O modelo `PurchaseInvoiceModel` ja possui `@SQLRestriction("deleted_at IS NULL")`. Esta anotacao e aplicada automaticamente em queries JPQL/HQL gerenciadas pelo Hibernate. Porem, em **queries nativas** (`nativeQuery = true`), a `@SQLRestriction` **nao e aplicada automaticamente**. Portanto, manter o `deleted_at IS NULL` explicito na query nativa e tecnicamente correto e necessario.

A "redundância" aparente e, na verdade, uma protecao necessaria para queries nativas. O codigo esta correto. Recomenda-se adicionar um comentario explicando o motivo:

```kotlin
@Query(
    value = """
        SELECT * FROM purchase_invoices pi
        WHERE pi.total = :amount
          -- deleted_at explicito: @SQLRestriction nao se aplica a native queries
          AND pi.deleted_at IS NULL
          AND pi.cancelled_at IS NULL
          ...
    """,
    nativeQuery = true
)
```

---

**MINOR-02 — Valor padrao `BigDecimal.ZERO` para campo `total` nullable pode mascarar dados corrompidos**

Arquivo: `InvoiceSuggestionResponse.kt` (linha 21) e `AssociatedInvoiceResponse.kt` (linha 21)

```kotlin
total = invoice.total ?: BigDecimal.ZERO,
```

O campo `total` em `PurchaseInvoiceModel` e nullable (`BigDecimal?`). O DTO `InvoiceSuggestionResponse` declara `total: BigDecimal` como nao-nullable. O fallback para `BigDecimal.ZERO` silencia o caso onde `total` esta nulo no banco — uma NF candidata com `total = null` nunca seria retornada pela query (pois o filtro `WHERE pi.total = :amount` exclui NULLs por definicao SQL), portanto o fallback nunca sera ativado na pratica.

O padrao e seguro em producao dado o filtro SQL, mas semanticamente ambiguo. Considere usar `total = invoice.total!!` para deixar explícita a expectativa de que o campo nao sera nulo quando a query retornar resultados, ou tratar o caso com lancamento de excecao descritiva.

---

**MINOR-03 — Ausencia de filtro por merchantName nos asserts do teste de ordenacao**

Arquivo: `PurchaseInvoiceRepositoryTest.kt` (linhas 89–113)

O teste `should return multiple candidates ordered by date proximity` cria 3 invoices e filtra por `merchantName == "Loja Teste Repository"` (linha 108), o que e correto para isolar dados de outros testes. Porem os demais testes que verificam `result.isEmpty()` ou `result.none { ... }` usam filtros inconsistentes: alguns usam `.none { it.merchantName == "..." }` (linha 73) enquanto outros usam `.filter { it.merchantName == "..." }.isEmpty()` (linhas 139, 155). O comportamento e equivalente, mas a inconsistencia de estilo reduz a legibilidade.

Padronize todos os asserts usando o mesmo estilo:
```kotlin
// Padrao consistente
val filteredResult = result.filter { it.merchantName == "Loja Teste Repository" }
assertTrue(filteredResult.isEmpty())
```

---

## Destaques Positivos

- **Cobertura de cenarios**: os 6 testes cobrem todos os casos de borda relevantes da query — sem resultados, candidato unico, multiplos candidatos ordenados por proximidade, invoice associada excluida, invoice cancelada excluida, e todos os candidatos associados. Cobertura acima do minimo especificado.

- **Alinhamento com a Tech Spec**: a assinatura do metodo `findByTotalAndNotAssociated(amount: BigDecimal, purchasedAt: LocalDateTime)` e a query SQL correspondem exatamente ao especificado na Tech Spec, incluindo o `ABS(TIMESTAMPDIFF(MINUTE, pi.date, :purchasedAt))` para ordenacao por proximidade de data.

- **Factory methods no companion object**: o padrao `from(invoice: PurchaseInvoiceModel)` segue o convencao estabelecida no projeto (ver `AssociatedPaymentResponse`, `PurchaseItemResponse`), mantendo consistencia arquitetural.

- **Posicionamento do pacote**: os DTOs foram criados no pacote correto `payments_notification/entrypoint/rest/response/`, respeitando a separacao de responsabilidades do modulo que os consumira.

- **Query SQL correta**: a subquery `NOT IN (SELECT purchase_invoice_id FROM payment_notifications WHERE purchase_invoice_id IS NOT NULL)` e tecnicamente correta e segura — o `IS NOT NULL` evita que valores NULL na subquery tornem o `NOT IN` sempre falso (armadilha classica de SQL).

---

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas |
| Kotlin/Spring Boot | OK |
| REST/HTTP | N/A |
| Logging | N/A |
| Testes | Problemas |

---

## Recomendacoes

1. **(MAJOR-01)** Eliminar a duplicacao do factory method entre `InvoiceSuggestionResponse` e `AssociatedInvoiceResponse`. Criar uma funcao de extensao compartilhada no pacote ou documentar explicitamente a intencao de manutencao independente.

2. **(MAJOR-02)** Registrar formalmente no PR a decisao de usar testes de integracao em vez de unitarios para o repository, justificando que queries nativas requerem banco real para validacao.

3. **(MINOR-01)** Adicionar comentario na query nativa explicando por que `deleted_at IS NULL` e mantido mesmo com `@SQLRestriction` no modelo.

4. **(MINOR-02)** Substituir `invoice.total ?: BigDecimal.ZERO` por `invoice.total!!` no factory method, tornando explicito que o campo e esperado nao-nulo quando retornado pela query.

5. **(MINOR-03)** Padronizar o estilo de asserts nos testes de repositorio para melhorar legibilidade e consistencia.

---

## Veredito

A task esta **APROVADA COM OBSERVACOES**. Os entregaveis principais estao corretos, o build compila sem erros e todos os 6 testes de integracao passam. Os problemas major encontrados (duplicacao de DTOs e divergencia no tipo de teste) nao bloqueiam o progresso para a Task 2.0, pois nao introduzem bugs nem riscos de runtime. Recomenda-se resolver o MAJOR-01 antes da integracao final (Task 6.0) para evitar divergencia silenciosa entre os dois DTOs durante o desenvolvimento das tarefas intermediarias.

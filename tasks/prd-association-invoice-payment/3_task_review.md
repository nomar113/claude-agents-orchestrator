# Review: Task 3.0 - Search Notifications -- Gateway, Provider, UseCase

**Revisor**: AI Code Reviewer
**Data**: 2026-05-23
**Arquivo da task**: 3_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task 3.0 implementou a busca manual de payment notifications para associacao a um invoice. A estrutura segue fielmente o padrao do projeto (fun interface Gateway, Provider @Component, UseCase @Component com Result), reusa o `SuggestionResponse` conforme exigido, e os 7 testes de integracao cobrem os cenarios definidos na task e passam com sucesso. A query nativa esta funcional, porem possui uma logica de filtros que cria um efeito colateral nao especificado (busca por amount sem datas e silenciosamente limitada aos ultimos 7 dias), alem de lacunas conhecidas da Task 2 (validacao do invoice, tratamento de erros) ainda nao endereçadas neste provider.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/.../gateway/SearchNotificationsGateway.kt` | OK | 0 |
| `domain/.../usecase/SearchNotificationsUseCase.kt` | OK | 0 |
| `application/.../application/SearchNotificationsProvider.kt` | Problemas | 2 |
| `application/.../repository/PaymentNotificationRepository.kt` (metodo `searchNotifications`) | Problemas | 2 |
| `test/.../SearchNotificationsProviderTest.kt` | Problemas | 2 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado. Os testes passam (7/7) e o build esta verde.

### Problemas Major

**M1. Filtro de amount sem datas e limitado aos ultimos 7 dias (divergencia do PRD/TechSpec)**
- **Arquivo**: `src/main/kotlin/.../repository/PaymentNotificationRepository.kt`, linhas 127-144 (metodo `searchNotifications`)
- **Descricao**: A clausula `CASE WHEN :startDate IS NOT NULL AND :endDate IS NOT NULL THEN ... ELSE purchased_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) END` aplica o fallback de 7 dias **sempre que startDate ou endDate forem nulos**, inclusive quando `amount` foi fornecido. O resultado pratico: uma busca por `amount = 150.00` sem datas so retornara notifications dos ultimos 7 dias.
- **Divergencia**: Tanto o PRD ("Se `amount` fornecido: filtro exato"; "Se nenhum filtro: ultimos 7 dias") quanto a TechSpec ("Se `amount` fornecido: filtro exato"; "Se nenhum filtro: ultimos 7 dias") indicam que a janela de 7 dias e o fallback para o caso de **nenhum filtro**, nao para o caso "amount sem data". Os requisitos da propria task (`3_task.md`, linhas 16-22) confirmam: "Sem filtros: retorna ultimos 7 dias".
- **Impacto**: Casos de uso reais (usuario lembra do valor mas a compra e antiga) falham silenciosamente, retornando lista vazia em vez de encontrar o pagamento.
- **Correcao sugerida**: Aplicar o fallback de 7 dias apenas quando *todos* os filtros (amount, startDate, endDate) forem nulos:
```sql
AND (
    (:amount IS NOT NULL OR (:startDate IS NOT NULL AND :endDate IS NOT NULL))
    OR purchased_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
)
AND (
    (:startDate IS NULL OR :endDate IS NULL)
    OR purchased_at BETWEEN :startDate AND :endDate
)
```
Ou, mais limpo, fazer o tratamento no Provider (computar a janela default em Kotlin e passar sempre `startDate`/`endDate` nao-nulos para o repository).

**M2. Validacao do invoice ausente no Provider**
- **Arquivo**: `src/main/kotlin/.../application/SearchNotificationsProvider.kt`, linhas 15-27
- **Descricao**: O provider recebe `invoiceId` mas nao verifica se o invoice existe, esta deletado ou cancelado antes de executar a busca. O parametro e usado apenas como filtro na query (`purchase_invoice_id IS NULL OR purchase_invoice_id = :invoiceId`). Se um invoice inexistente for passado, a busca executa normalmente e retorna notifications nao associadas, mascarando o erro.
- **Divergencia**: A TechSpec (regras do PATCH, secao "Regras do GET search") nao exige explicitamente esta validacao no search, mas a consistencia com `AssociateInvoiceProvider` e `DisassociateInvoiceProvider` sugere que seria saudavel validar. Repete-se aqui o mesmo gap apontado nos problemas Major do Review da Task 2.0.
- **Correcao sugerida**: Carregar o invoice via `purchaseInvoiceRepository.findById(invoiceId)` e validar `deletedAt`/`cancelledAt` antes da query, lancando `NoSuchElementException` no caso negativo. Alternativamente, deixar a validacao para a camada de Controller/UseCase, mas isso precisa ser uma decisao explicita do time.

### Problemas Minor

**m1. `timeDeltaMinutes = 0` hardcoded perde semantica do campo**
- **Arquivo**: `src/main/kotlin/.../application/SearchNotificationsProvider.kt`, linha 41
- **Descricao**: O campo `timeDeltaMinutes` foi pensado para sugestoes automaticas (`SuggestionResponse.from(...)` calcula a distancia entre `notification.purchasedAt` e a data do invoice). Na busca manual, fixa-lo em `0` significa que toda notification aparece como "match perfeito de tempo" no frontend, o que e enganoso se o componente usar este campo para badging/ordenacao. Aceitavel como estado inicial, mas merece atencao.
- **Correcao sugerida (opcional)**:
  1. Tornar `timeDeltaMinutes: Long?` no `SuggestionResponse` e usar `null` quando nao aplicavel; ou
  2. Carregar o `invoice` (ja sugerido em M2) e calcular o delta real via `SuggestionResponse.from(notification, invoice.date)`, reaproveitando a fabrica existente.

**m2. Filtros parcialmente fornecidos (apenas `startDate` ou apenas `endDate`) caem silenciosamente no fallback de 7 dias**
- **Arquivo**: `src/main/kotlin/.../repository/PaymentNotificationRepository.kt`, linhas 134-138; `src/main/kotlin/.../application/SearchNotificationsProvider.kt`
- **Descricao**: O `CASE` no WHERE so considera `startDate`/`endDate` se **ambos** forem nao-nulos. Se o cliente enviar apenas um deles, o resultado e o fallback de 7 dias, silenciosamente. Nao ha validacao no Provider/UseCase nem documentacao deste contrato.
- **Correcao sugerida**: Validar no Provider/UseCase que `startDate` e `endDate` sao fornecidos juntos (ou nenhum), lancando `IllegalArgumentException` no caso invalido. Validar tambem `startDate <= endDate`.

**m3. Use case com duplo `runCatching`**
- **Arquivo**: `domain/.../usecase/SearchNotificationsUseCase.kt`, linha 19
- **Descricao**: Mesmo padrao apontado no Review da Task 2.0 (m2). O `runCatching { gateway.execute(...).getOrThrow() }` desembrulha e re-embrulha o `Result`. E o padrao do projeto, portanto consistente -- observacao informativa apenas.

**m4. Cobertura de testes nao cobre o bug de M1**
- **Arquivo**: `src/test/kotlin/.../SearchNotificationsProviderTest.kt`
- **Descricao**: O teste `should filter by amount when provided` (linha 100) usa `purchasedAt = LocalDateTime.now()` (default do helper `createNotification`), o que mantem a notification dentro dos 7 dias e mascara o problema M1. Faltam tambem: (a) teste para busca por amount com notification fora dos 7 dias; (b) teste para apenas `startDate` ou apenas `endDate`; (c) teste para `startDate > endDate`; (d) teste explicito para `startDate`/`endDate` cobrindo uma janela alem de 7 dias atras (o teste atual usa `minusDays(2)`, dentro da janela default).
- **Correcao sugerida**:
```kotlin
@Test
fun `should filter by amount without date filters even beyond 7 days`() {
    val invoice = createInvoice()
    val oldTarget = createNotification(
        amount = BigDecimal("150.00"),
        purchasedAt = LocalDateTime.now().minusDays(30),
    )
    val result = provider.execute(invoice.id!!, BigDecimal("150.00"), null, null)
    val ids = result.getOrThrow().map { it.id }
    assertTrue(ids.contains(oldTarget.id))
}
```

**m5. Inclusao da notification ja associada ao proprio invoice nao esta documentada**
- **Arquivo**: `src/main/kotlin/.../repository/PaymentNotificationRepository.kt`, linha 131 (`purchase_invoice_id IS NULL OR purchase_invoice_id = :invoiceId`)
- **Descricao**: A query inclui notifications ja associadas ao **proprio** invoice, alem das nao associadas. Isso e razoavel (permite reexibir a associacao atual no resultado), mas nao esta explicito nem na task, nem no PRD, nem na TechSpec, que afirmam apenas excluir as ja associadas a OUTRO invoice. O teste cobre o comportamento (linha 205), portanto o time deve apenas confirmar se essa e a intencao e documenta-la.

## Destaques Positivos

1. **Padrao arquitetural seguido fielmente**: Gateway (fun interface no dominio retornando `Result<T>`) -> Provider (@Component implementando o gateway via `runCatching`) -> UseCase (@Component) -- identico a `AssociateInvoiceProvider`, `DisassociateInvoiceProvider` e `FindInvoiceSuggestionsProvider`.

2. **Reuso do `SuggestionResponse`**: Atende ao requisito da task e mantem o contrato de API consistente com `/suggestions`, facilitando o consumo no frontend.

3. **Query nativa correta nos pontos centrais**: Exclusao de `deleted_at IS NOT NULL`, `cancelled_at IS NOT NULL` e `purchase_invoice_id` apontando para outro invoice, ordem `purchased_at DESC` e `LIMIT 20` estao todos corretos. Detalhe importante: como a query e nativa, o `@SQLRestriction("deleted_at IS NULL")` do `PaymentNotification` nao seria aplicado -- o autor corretamente incluiu o filtro manualmente.

4. **Testes de integracao com `@SpringBootTest`**: Banco real, cleanup robusto via `JdbcTemplate` no `@AfterEach`, helpers (`createInvoice`, `createNotification`) bem fatorados e expressivos. O detalhe de usar `jdbcTemplate.update` para forcar `deleted_at` (linhas 90-96) e necessario porque o `@SQLRestriction` impediria a leitura posterior, e foi bem tratado.

5. **Cobertura dos 7 cenarios da task**: Todos os testes da subsecao "Testes da Tarefa" (linhas 47-53 de `3_task.md`) estao presentes e passam, incluindo o caso vazio.

6. **Teste de limite robusto**: O teste `should limit results to 20` (linha 210) cria 25 notifications variando `purchasedAt` por minuto, validando tanto o `LIMIT 20` quanto a ordenacao por `purchased_at DESC`.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| Arquitetura (Gateway/Provider/UseCase) | OK |
| `fun interface` no dominio retornando `Result<T>` | OK |
| `@Component` no Provider/UseCase | OK |
| `runCatching` no Provider e UseCase | OK |
| Testes de integracao com cleanup via JdbcTemplate | OK |
| Aderencia ao PRD/TechSpec | Problemas (M1) |
| Validacao defensiva de entradas | Problemas (M2, m2) |

## Recomendacoes

1. **[Major]** Corrigir M1: aplicar o fallback de 7 dias somente quando nenhum filtro (amount, startDate, endDate) for fornecido. Preferencialmente, mover a logica de fallback para o Provider (em Kotlin) e simplificar a query nativa.
2. **[Major]** Decidir e implementar a politica de validacao do `invoiceId` (M2). Recomendo carregar e validar no Provider, em linha com `AssociateInvoiceProvider`. Se a decisao for validar no Controller/UseCase, criar issue/comentario explicito.
3. **[Minor]** Adicionar validacao de `startDate`/`endDate` (ambos juntos; `startDate <= endDate`) no Provider ou UseCase.
4. **[Minor]** Adicionar testes que cubram: (a) amount + sem datas + notification antiga (>7 dias); (b) apenas um dos extremos de data; (c) intervalo invertido; (d) janela explicita superior a 7 dias.
5. **[Minor]** Decidir sobre `timeDeltaMinutes` na busca manual: tornar nullable ou calcular usando a data do invoice (combinavel com a melhoria de M2).
6. **[Minor]** Documentar no codigo (KDoc na query ou no Provider) o comportamento de incluir a notification ja associada ao proprio invoice.

## Veredito

A implementacao esta bem estruturada, segue fielmente o padrao do projeto e os 7 testes da task passam. Porem, o filtro de fallback de 7 dias e aplicado em situacoes nao previstas no PRD/TechSpec (M1), o que pode causar "no results" silencioso para um caso de uso central (buscar por valor sem informar data). A ausencia de validacao do `invoiceId` repete a lacuna ja apontada na Task 2.0 (M2). Recomendo corrigir M1 (com teste correspondente) antes de prosseguir e alinhar com o time sobre M2. As demais observacoes (m1-m5) sao melhorias incrementais e nao bloqueiam.

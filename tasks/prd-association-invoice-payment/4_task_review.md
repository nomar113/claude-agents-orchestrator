# Review: Task 4.0 - Controller -- 3 endpoints REST

**Revisor**: AI Code Reviewer
**Data**: 2026-05-23
**Arquivo da task**: 4_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Task 4.0 expoe corretamente os 3 endpoints REST da feature de associacao
(`PATCH/DELETE /invoices/{id}/associate` e `GET /invoices/{id}/suggestions/search`),
respeitando o padrao do projeto (Controller injeta UseCase, executa `getOrElse`
e mapeia o `Throwable` para `ResponseStatusException`). O DTO de request,
a injecao dos novos use cases e o tratamento dos status 200/204/400/404/409
estao alinhados com PRD e TechSpec. O teste de integracao
(`AssociateInvoiceControllerIntegrationTest`) cobre 11 cenarios e a suite
relacionada (98 testes em purchases_invoices + suggestion + payments_notification)
passa 100% sem regressao. As observacoes sao todas Minor: catch generico no
parser de data, ausencia de validacao Bean Validation no body do PATCH, lacuna
de testes para 400 com body invalido e para o filtro `startDate+endDate`, e
uma divergencia de localizacao (endpoint de search vivendo no
`PurchaseInvoiceController` em vez do `SuggestionController`).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/.../rest/PurchaseInvoiceController.kt` (modificado) | OK com Minors | 4 |
| `application/.../rest/request/AssociateInvoiceRequest.kt` (novo) | OK com Minor | 1 |
| `application/.../rest/response/AssociateInvoiceResponse.kt` (Task 2) | OK | 0 |
| `test/.../AssociateInvoiceControllerIntegrationTest.kt` (novo) | OK com Minors | 3 |
| `test/.../PurchaseInvoiceControllerTest.kt` (modificado) | OK | 0 |
| `application/.../payments_notification/.../PaymentNotification.kt` (modificado) | OK | 0 |
| `application/.../payments_notification/.../PaymentNotificationRepository.kt` (modificado) | OK | 0 |

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Padroes de Codigo (Kotlin/Spring) | OK | Imports ordenados, naming idiomatico, sem warnings de compilacao |
| Arquitetura (Controller -> UseCase -> Gateway/Provider) | OK | `associateInvoiceUseCase`, `disassociateInvoiceUseCase`, `searchNotificationsUseCase` injetados via construtor |
| Mapeamento Result -> HTTP | OK | `getOrElse { throw mapAssociationError(it) }` consistente nos 3 endpoints |
| Resposta com `ResponseEntity`/anotacoes | OK | `@ResponseStatus(NO_CONTENT)` no DELETE; default 200 nos demais |
| Padrao de error mapping inline (`when (ex)`) | OK com observacao | O helper `mapAssociationError` extrai o `when` inline -- excelente refatoracao, mas nao reaproveita o helper nos endpoints existentes (ex.: `cancelInvoice` continua com `when` duplicado) |
| Bean Validation no body | NOK | `AssociateInvoiceRequest` nao usa `@Validated`/`@NotNull`/`@Positive`. Spring/Jackson ainda gera 400 quando o campo nao-nulavel `paymentNotificationId: Long` falta, mas a validacao deveria ser explicita |
| Testes presentes e passando | OK | 11 cenarios no integration test; 98/98 testes do escopo passam |

## Aderencia a TechSpec

| Decisao Tecnica | Implementado | Observacoes |
|-----------------|--------------|-------------|
| `PATCH /purchases/invoices/{invoiceId}/associate` retorna `AssociateInvoiceResponse` 200 | SIM | OK |
| `DELETE /purchases/invoices/{invoiceId}/associate` retorna 204 | SIM | OK |
| `GET /purchases/invoices/{invoiceId}/suggestions/search?amount&startDate&endDate` retorna `List<SuggestionResponse>` | SIM | OK -- filtros `amount`, `startDate`, `endDate` propagados ao UseCase |
| Erros 404/409/400 mapeados | SIM | `NoSuchElementException`->404, `IllegalStateException`->409, `IllegalArgumentException`->400, demais->500 |
| `parseDateTimeParam` valida formato ISO | SIM | Retorna 400 quando string nao parseavel |
| Reuso de `SuggestionResponse` (TechSpec linha 214) | SIM | OK |
| Injecao dos 3 use cases no Controller existente | SIM | OK |
| Endpoint de search vive em `PurchaseInvoiceController` | SIM (e divergencia) | TechSpec lista o arquivo nas modificacoes, mas ja existe um `SuggestionController` com path `/purchases/invoices/{id}/suggestions`. Ter dois controllers servindo `/purchases/invoices/{id}/suggestions*` e funcional porem inconsistente |

## Aderencia ao PRD

| Criterio de Aceite | Status | Observacoes |
|--------------------|--------|-------------|
| 1. PATCH associa e retorna confirmacao | OK | Teste cobre, persiste corretamente |
| 2. 409 em notification ja associada a outro invoice | OK | Teste cobre |
| 3. DELETE remove associacao | OK | Teste cobre e valida estado no BD |
| 4. Busca manual filtra por nome/valor | PARCIAL | TechSpec definiu somente `amount/startDate/endDate` (sem `q`/nome). A divergencia esta na TechSpec, nao no Controller. Apontar pro time |
| Erro 400 com payload invalido | NAO TESTADO | Implementado (vide `mapAssociationError` + Jackson), mas sem teste explicito |
| Erro 404 com invoice/notification inexistente | OK | Cobertos |

## Tasks Verificadas

| Subtask | Status | Observacoes |
|---------|--------|-------------|
| 4.1 Criar `AssociateInvoiceRequest` DTO | COMPLETA | `paymentNotificationId: Long` |
| 4.2 Endpoint PATCH `/associate` | COMPLETA | `getOrElse` + `mapAssociationError` |
| 4.3 Endpoint DELETE `/associate` | COMPLETA | `@ResponseStatus(NO_CONTENT)` |
| 4.4 Endpoint GET `/suggestions/search` com query params | COMPLETA | `amount: BigDecimal?`, `startDate/endDate: String?` parseados |
| 4.5 Mapear erros do Result para HTTP status codes | COMPLETA | 404/409/400/500 via helper |

| Teste declarado na tarefa | Implementado | Arquivo |
|---------------------------|--------------|---------|
| PATCH 200 com sucesso | SIM | `AssociateInvoiceControllerIntegrationTest.kt:95` |
| PATCH 404 invoice inexistente | SIM | `:118` |
| PATCH 409 notification ja associada | SIM | `:142` |
| DELETE 204 | SIM | `:156`, `:172` |
| GET com filtros 200 | SIM | `:186` (filtro amount) |
| GET sem filtros 200 (ultimos 7 dias) | SIM | `:202` |
| (extras) PATCH 404 notification inexistente | SIM | `:129` |
| (extras) DELETE 404 invoice inexistente | SIM | `:180` |
| (extras) GET 400 startDate invalido | SIM | `:219` |
| (extras) GET 404 invoice inexistente | SIM | `:230` |

## Testes

- Total de testes no escopo (purchases_invoices + suggestion + payments_notification): **98**
- Passando: **98**
- Falhando: **0**
- Pulados: **0**
- Cobertura especifica do controller novo: 11 cenarios (`AssociateInvoiceControllerIntegrationTest`)
- Falhas pre-existentes fora do escopo da Task 4 (declaradas pelo autor: Budget, BudgetMigration, PaymentNotificationFilter, PurchaseCategory) -- nao bloqueiam o review desta task

## Problemas Encontrados

### Problemas Criticos

Nenhum.

### Problemas Major

Nenhum.

### Problemas Minor

**m1. `parseDateTimeParam` captura `Exception` em vez de `DateTimeParseException`**
- **Arquivo**: `PurchaseInvoiceController.kt`, linhas 203-210
- **Descricao**: O `catch (e: Exception)` engole qualquer falha (inclusive `NullPointerException` ou `OutOfMemoryError` quando proxado por algum aspect). O contrato real e somente formato invalido de data.
- **Correcao sugerida**:
```kotlin
private fun parseDateTimeParam(name: String, value: String?): LocalDateTime? {
    if (value.isNullOrBlank()) return null
    return try {
        LocalDateTime.parse(value)
    } catch (e: java.time.format.DateTimeParseException) {
        throw ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Invalid $name format. Expected ISO LocalDateTime (yyyy-MM-ddTHH:mm:ss)",
        )
    }
}
```

**m2. `AssociateInvoiceRequest` sem Bean Validation**
- **Arquivo**: `AssociateInvoiceRequest.kt`
- **Descricao**: O DTO declara `paymentNotificationId: Long` (nao-nulavel) e o controller usa `@RequestBody` sem `@Validated`. Hoje, body vazio ou `null` no campo gera 400 via Jackson, mas valores invalidos (ex.: `0`, `-1`) chegam ao Provider. Padronizar com Bean Validation deixa o contrato explicito.
- **Correcao sugerida**:
```kotlin
data class AssociateInvoiceRequest(
    @field:Positive(message = "paymentNotificationId must be positive")
    val paymentNotificationId: Long,
)
```
E `@Validated @RequestBody request: AssociateInvoiceRequest` no controller (mesmo padrao usado em `enqueuePurchaseInvoice`).

**m3. Endpoint de search localizado fora do `SuggestionController`**
- **Arquivo**: `PurchaseInvoiceController.kt`, linhas 188-201
- **Descricao**: O `SuggestionController` ja existe (`@RequestMapping("/purchases/invoices")`) e expoe `GET /{id}/suggestions`. O novo `GET /{id}/suggestions/search` foi alocado no `PurchaseInvoiceController`. O resultado: dois controllers diferentes servindo o mesmo "sub-namespace" de suggestions. Funcional, mas dificulta a descoberta. A TechSpec mencionou o arquivo, mas a Task 4 nao proibe reorganizar.
- **Correcao sugerida**: Mover o `searchSuggestions` para `SuggestionController` (mantendo o nome do path). Os use cases `SearchNotificationsUseCase`/`AssociateInvoiceUseCase`/`DisassociateInvoiceUseCase` ficariam todos no controller correto. Alternativamente, manter onde esta e adicionar KDoc justificando.

**m4. Falta teste explicito para 400 com body invalido no PATCH**
- **Arquivo**: `AssociateInvoiceControllerIntegrationTest.kt`
- **Descricao**: O requisito explicito da task (linha 19 do `4_task.md`) menciona "400 (bad request)". Ha teste para 400 quando `startDate` e invalido no GET, mas nenhum para PATCH com body invalido (ex.: `{}`, `{"paymentNotificationId": null}`, `{"paymentNotificationId": "abc"}`).
- **Correcao sugerida**:
```kotlin
@Test
fun `PATCH associate should return 400 when paymentNotificationId is missing`() {
    val invoiceId = insertInvoice()
    mockMvc.perform(
        patch("/purchases/invoices/$invoiceId/associate")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""{}""")
    ).andExpect(status().isBadRequest)
}
```

**m5. Falta teste de cenario `startDate+endDate` validos no GET**
- **Arquivo**: `AssociateInvoiceControllerIntegrationTest.kt`
- **Descricao**: Ha testes para "amount", "sem filtros (7 dias)" e "startDate invalido", mas nenhum cenario positivo cobrindo `startDate+endDate` no Controller (o cenario existe no `SearchNotificationsProviderTest`, porem nao garante o parsing de string -> LocalDateTime no Controller).
- **Correcao sugerida**: Adicionar teste com `param("startDate", "2026-05-01T00:00:00").param("endDate", "2026-05-31T23:59:59")`.

**m6. Helper de data nos testes e fragil (`toString().replace("T", " ")`)**
- **Arquivo**: `AssociateInvoiceControllerIntegrationTest.kt`, linhas 205, 209
- **Descricao**: `LocalDateTime.now().toString()` pode retornar `2026-05-23T21:00:00.123456789`, e o `replace("T", " ")` deixa nanossegundos que alguns drivers MySQL/MariaDB nao aceitam em coluna `DATETIME`. Funciona hoje porque o teste passa, mas e dependente de configuracao do driver.
- **Correcao sugerida**: Usar formatter explicito:
```kotlin
private val sqlDateTime = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
val recent = insertNotification(
    purchasedAt = LocalDateTime.now().minusDays(2).format(sqlDateTime),
    merchantName = "Recent",
)
```

**m7. `mapAssociationError` propaga `ex.message` ao cliente**
- **Arquivo**: `PurchaseInvoiceController.kt`, linhas 212-217
- **Descricao**: A mensagem do `Throwable` (que pode conter ids internos como `"PaymentNotification not found: 999999"` ou inclusive stack-trace de excecoes inesperadas) e enviada como `reason` do `ResponseStatusException`, vazando detalhes para o cliente. Padrao existente do projeto (vide `cancelInvoice`), portanto consistente -- aceitavel mas merece atencao em futura padronizacao de error handler global.
- **Correcao sugerida (opcional)**: Para excecoes nao mapeadas (`else -> 500`), trocar `ex.message` por uma mensagem generica e logar o original. Idealmente, criar um `@ControllerAdvice` global.

## Pontos Positivos

1. **Padrao arquitetural impecavel**: injecao por construtor, `getOrElse { throw ... }` em todos os endpoints, anotacoes `@PatchMapping`/`@DeleteMapping`/`@GetMapping` corretas, status codes via `@ResponseStatus`. Identico ao restante do projeto.

2. **Refatoracao para `mapAssociationError`**: extrair o `when (ex)` em um helper privado e uma melhoria clara de qualidade. Mantem os endpoints com 3 linhas. Recomendo evoluir e aplicar nos endpoints existentes (`cancelInvoice`, `deleteInvoice`).

3. **`parseDateTimeParam` reutilizavel e descritivo**: a mensagem de erro inclui o nome do parametro e o formato esperado, ajudando o cliente. Boa pratica de DX.

4. **Cobertura de cenarios solida (11 testes)**: ultrapassou os 6 cenarios obrigatorios, incluindo edge cases como "DELETE sem associacao previa retorna 204" (idempotencia) e "PATCH 404 quando notification nao existe" (positivo extra).

5. **Validacao do estado no banco apos cada mutacao**: o teste de PATCH verifica `purchase_invoice_id` na tabela, e o DELETE verifica que ficou `NULL`. Boa pratica de teste de integracao -- nao confia apenas no body de resposta.

6. **Cleanup robusto**: `@BeforeEach` + `@AfterEach` com `JdbcTemplate`, na ordem correta (filhos antes dos pais, com `UPDATE ... SET fk = NULL` antes do `DELETE` na tabela com FK). Evita poluicao de estado entre testes.

7. **Test util `stubOf` no `PurchaseInvoiceControllerTest`**: o autor manteve o stub Proxy existente e adicionou os tres novos use cases sem quebrar o padrao -- minima invasao no teste pre-existente.

8. **Mudancas minimas e focadas**: o diff e enxuto (+104 linhas, sem alteracoes desnecessarias em codigo nao-relacionado).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Arquitetura Controller/UseCase/Gateway | OK |
| Mapeamento `Result` -> `ResponseEntity` | OK |
| Cobertura de testes (cenarios da task) | OK |
| Aderencia ao PRD/TechSpec | OK |
| Bean Validation | Problemas (m2) |
| Tratamento de excecoes (catch especifico) | Problemas (m1) |
| Organizacao de controllers por bounded context | Problemas (m3) |

## Recomendacoes

1. **[Minor]** Trocar `catch (e: Exception)` por `catch (e: DateTimeParseException)` no `parseDateTimeParam` (m1).
2. **[Minor]** Adicionar `@Validated` + `@field:Positive` no `AssociateInvoiceRequest` (m2).
3. **[Minor]** Considerar mover o `searchSuggestions` para o `SuggestionController` para evitar a duplicacao do sub-namespace `/suggestions` em dois controllers (m3) -- ou justificar com KDoc.
4. **[Minor]** Adicionar testes para: (a) PATCH 400 com body invalido; (b) GET com `startDate+endDate` validos e resultados na janela (m4, m5).
5. **[Minor]** Padronizar a montagem de `LocalDateTime` nos helpers de teste usando `DateTimeFormatter` (m6).
6. **[Minor/Opcional]** Reaproveitar o helper `mapAssociationError` nos endpoints `cancelInvoice` e `deleteInvoice` para reduzir duplicacao. Trabalho de limpeza fora do escopo desta task.
7. **[Opcional]** Avaliar criacao de `@ControllerAdvice` global para mapear `NoSuchElementException`/`IllegalStateException`/`IllegalArgumentException`, eliminando o helper por completo e centralizando o tratamento (m7).

## Conclusao

**APROVADO COM OBSERVACOES.**

A Task 4.0 cumpre integralmente as 5 subtarefas declaradas, os 6 cenarios de
teste exigidos (com 5 extras), o contrato de API definido no PRD/TechSpec, e
o padrao arquitetural do projeto. A suite de 98 testes do escopo
(purchases_invoices + suggestion + payments_notification) passa 100% sem
regressao. O diff e enxuto, a refatoracao do `mapAssociationError` e bem-feita,
e a cobertura no integration test inclui validacao de estado pos-mutacao.

As 7 observacoes Minor sao todas de polimento (catch especifico, Bean
Validation, organizacao de controllers, mais 2 testes, helper de data nos
testes, e padronizacao de error handler). Nenhuma bloqueia a entrega da
feature. Recomendo endereca-las em uma task de limpeza dedicada ou como
parte da proxima task (5.0) se houver oportunidade.

A Task 4.0 esta pronta para seguir para a Task 5.0.

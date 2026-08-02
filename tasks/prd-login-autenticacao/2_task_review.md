# Review: Task 2.0 - Backend — Tenancy: group_id, backfill e isolamento de dados

**Revisor**: AI Code Reviewer
**Data**: 2026-08-01
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

---

## Resumo

A Task 2.0 adicionou multi-tenancy ao ControlAI via `group_id` em todas as 7 tabelas raiz. A implementacao cobre migrations Flyway em 3 passos (V28, V29, V30), atualizacao dos modelos JPA, dos repositorios Spring Data e de todos os providers de acesso a dados. A arquitetura e correta: filtro explicito por `groupId` nos gateways (nao usa Hibernate Filter global), o `JwtRequestContext` extrai o `groupId` do JWT e o injeta nos providers via `RequestContext`. O isolamento de dados esta funcionalmente correto na grande maioria dos fluxos. Dois problemas de seguranca de nivel minor/major foram encontrados, mais lacunas nos testes que sao pre-requisito da task.

---

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/main/resources/db/migration/V28__add_group_id_to_root_tables.sql` | OK | 0 |
| `src/main/resources/db/migration/V29__backfill_tenancy_data.sql` | OK | 0 |
| `src/main/resources/db/migration/V30__make_group_id_not_null.sql` | OK | 0 |
| `src/main/kotlin/.../config/JwtRequestContext.kt` | OK | 0 |
| `src/main/kotlin/.../domain/auth/RequestContext.kt` | OK | 0 |
| `src/main/kotlin/.../auth/application/CreateUserWithPersonalGroupProvider.kt` | OK | 0 |
| `src/main/kotlin/.../auth/application/SeedDefaultCategoriesProvider.kt` | OK | 0 |
| `src/main/kotlin/.../auth/application/TokenIssuer.kt` | OK | 0 |
| `src/main/kotlin/.../categories/entrypoint/database/model/CategoryModel.kt` | OK | 0 |
| `src/main/kotlin/.../categories/entrypoint/database/repository/CategoryRepository.kt` | OK | 0 |
| `src/main/kotlin/.../categories/application/ListCategoriesProvider.kt` | OK | 0 |
| `src/main/kotlin/.../categories/application/FindCategoryProvider.kt` | OK | 0 |
| `src/main/kotlin/.../categories/application/SaveCategoryProvider.kt` | OK | 0 |
| `src/main/kotlin/.../categories/application/DeleteCategoryProvider.kt` | OK | 0 |
| `src/main/kotlin/.../categories/application/UpdateCategoryProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/entrypoint/database/model/HolderModel.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/entrypoint/database/model/PaymentMethodModel.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/entrypoint/database/repository/HolderRepository.kt` | Problemas | 1 |
| `src/main/kotlin/.../payment_methods/entrypoint/database/repository/PaymentMethodRepository.kt` | Problemas | 1 |
| `src/main/kotlin/.../payment_methods/application/ListHoldersProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/application/ListPaymentMethodsProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/application/SaveHolderProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/application/SavePaymentMethodProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/application/FindPaymentMethodProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payment_methods/application/UpdatePaymentMethodProvider.kt` | OK | 0 |
| `src/main/kotlin/.../budget/entrypoint/database/model/BudgetModel.kt` | OK | 0 |
| `src/main/kotlin/.../budget/entrypoint/database/repository/BudgetRepository.kt` | OK | 0 |
| `src/main/kotlin/.../budget/application/FindBudgetProvider.kt` | OK | 0 |
| `src/main/kotlin/.../budget/application/SaveBudgetProvider.kt` | OK | 0 |
| `src/main/kotlin/.../budget/application/BudgetPeriodResolver.kt` | OK | 0 |
| `src/main/kotlin/.../budget/application/GetBudgetSummaryProvider.kt` | Problemas | 1 |
| `src/main/kotlin/.../budget/application/ReplicateBudgetPeriodsToFutureProvider.kt` | Problemas | 1 |
| `src/main/kotlin/.../payments_notification/entrypoint/database/model/PaymentNotification.kt` | OK | 0 |
| `src/main/kotlin/.../payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` | OK | 0 |
| `src/main/kotlin/.../payments_notification/entrypoint/rest/PaymentNotificationController.kt` | Critico | 1 |
| `src/main/kotlin/.../payments_notification/application/CancelPaymentNotificationProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payments_notification/application/DeactivatePaymentNotificationProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payments_notification/application/FindInvoiceSuggestionsProvider.kt` | OK | 0 |
| `src/main/kotlin/.../payments_notification/application/FindNotificationInvoiceSuggestionsProvider.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseInvoiceRepository.kt` | Problemas | 1 |
| `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/application/SavePurchaseInvoiceProvider.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/application/CancelPurchaseInvoiceProvider.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/application/DeactivatePurchaseInvoiceProvider.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/application/ListPurchasesProvider.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/application/AssociateInvoiceProvider.kt` | OK | 0 |
| `src/main/kotlin/.../purchases_invoices/application/SearchNotificationsProvider.kt` | OK | 0 |
| `src/main/kotlin/.../installments/entrypoint/database/model/Installment.kt` | OK | 0 |
| `src/main/kotlin/.../installments/entrypoint/database/repository/InstallmentRepository.kt` | OK | 0 |
| `src/main/kotlin/.../installments/entrypoint/rest/InstallmentController.kt` | OK | 0 |
| `src/main/kotlin/.../installments/application/CreateInstallmentsProvider.kt` | OK | 0 |
| `src/main/kotlin/.../domain/payments_notifications/usecase/FindInvoiceSuggestionsUseCase.kt` | Critico | 1 |
| `src/test/kotlin/.../config/TestAuthMockMvcConfig.kt` | OK | 0 |
| `src/test/kotlin/.../purchases_invoices/PurchaseInvoiceRepositoryTest.kt` | OK | 0 |
| `src/test/kotlin/.../payments_notification/AssociateNotificationProviderTest.kt` | OK | 0 |

---

## Problemas Encontrados

### Problemas Criticos

#### CRITICO-1: `FindInvoiceSuggestionsUseCase` usa `findById` sem filtro de `groupId`

**Arquivo**: `src/main/kotlin/br/com/nomar/controlai/domain/payments_notifications/usecase/FindInvoiceSuggestionsUseCase.kt`
**Linha**: 21

O use case busca uma `PurchaseInvoice` pelo ID sem validar o `groupId`, permitindo que um usuario de um grupo acesse metadados de notas fiscais de outro grupo. Embora este use case seja acionado a partir de uma notificacao de pagamento que ja passou pelo filtro de grupo, a dependencia direta no repositorio sem `groupId` e uma violacao explicita do requisito RF-4.1.

```kotlin
// ANTES (vulneravel)
val invoice = purchaseInvoiceRepository.findById(invoiceId)
    .orElseThrow { NoSuchElementException("Invoice not found: $invoiceId") }
```

**Correcao sugerida**:
```kotlin
// DEPOIS (correto)
val invoice = purchaseInvoiceRepository.findByIdAndGroupId(invoiceId, requestContext.groupId)
    ?: throw NoSuchElementException("Invoice not found: $invoiceId")
```

O `FindInvoiceSuggestionsUseCase` precisa receber `RequestContext` injetado ou o `groupId` deve ser passado como parametro.

---

#### CRITICO-2: `PaymentNotificationController.getNotification` usa `purchaseInvoiceRepository.findById` sem `groupId`

**Arquivo**: `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`
**Linha**: 113

Apos buscar a notificacao com `findByIdAndGroupId` (correto), o controller usa `purchaseInvoiceRepository.findById(it)` sem filtrar pelo `groupId` do grupo atual para carregar a invoice associada. Isso pode expor dados de uma nota fiscal de outro grupo se houver um `purchaseInvoiceId` apontando para um registro de outro grupo (cenario teorico, mas viola o principio de defesa em profundidade).

```kotlin
// ANTES (vulneravel)
val invoice = notification.purchaseInvoiceId
    ?.let { purchaseInvoiceRepository.findById(it).orElse(null) }
```

**Correcao sugerida**:
```kotlin
// DEPOIS (correto)
val invoice = notification.purchaseInvoiceId
    ?.let { purchaseInvoiceRepository.findByIdAndGroupId(it, requestContext.groupId) }
```

---

### Problemas Major

#### MAJOR-1: Metodos de repositorio sem escopo de grupo ainda existem nas interfaces

**Arquivos**:
- `src/main/kotlin/.../categories/entrypoint/database/repository/CategoryRepository.kt` — linha 7: `findAllByOrderByNameAsc()`
- `src/main/kotlin/.../payment_methods/entrypoint/database/repository/HolderRepository.kt` — linha 7: `findAllByOrderByNameAsc()`
- `src/main/kotlin/.../payment_methods/entrypoint/database/repository/PaymentMethodRepository.kt` — linhas 8-9: `findAllByOrderByNameAsc()` e `findAllByHolderIdOrderByNameAsc()`
- `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseInvoiceRepository.kt` — linha 16: `findAllByOrderByDateDesc()`

Estes metodos nao sao chamados em nenhum ponto da producao apos a refatoracao, mas permanecem como superficie de ataque se forem usados por engano no futuro. A presenca de metodos de busca sem `groupId` em interfaces Spring Data e especialmente perigosa porque o Spring pode gera-los automaticamente sem nenhuma aviso em tempo de compilacao.

**Correcao sugerida**: Remover todos os metodos de listagem sem filtro de `groupId` que nao sao mais usados. Se algum for necessario para testes de migracao, mover para uma interface separada `@Repository` interna ao modulo de testes.

---

#### MAJOR-2: `ReplicateBudgetPeriodsToFutureProvider` usa `budgetRepository.findAll()` com filtro em memoria

**Arquivo**: `src/main/kotlin/.../budget/application/ReplicateBudgetPeriodsToFutureProvider.kt`
**Linha**: 28

```kotlin
// Ineficiente e perigoso de manter
val futureBudgets = budgetRepository.findAll()
    .filter { it.groupId == groupId && ... }
```

Esta abordagem carrega todos os orcamentos de todos os grupos da base de dados em memoria e filtra em codigo. Alem da ineficiencia, e um anti-padrao que viola a decisao arquitetural da techspec de manter filtros explicitos nos gateways. O filtro em memoria e correto funcionalmente hoje, mas pode causar problemas de performance e seguranca com crescimento dos dados.

**Correcao sugerida**:
```kotlin
// Adicionar ao BudgetRepository:
fun findAllByGroupId(groupId: Long): List<BudgetModel>

// No provider:
val futureBudgets = budgetRepository.findAllByGroupId(groupId)
    .filter { runCatching { YearMonth.parse(it.yearMonth) > currentYearMonth }.getOrDefault(false) }
    .sortedBy { it.yearMonth }
```

---

#### MAJOR-3: Subtarefas de teste 2.7 e 2.8 nao foram implementadas

**Subtarefa 2.7**: Teste parametrizado de seguranca varrendo o mapping do MVC — todo endpoint de dados deve retornar 401 sem token — **nao implementado**.

**Subtarefa 2.8**: Testes de isolamento entre grupos (usuario de grupo A nao le nem escreve dados de grupo B, retorna 404) — **nao implementado**.

A task define explicitamente: "SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA". As subtarefas 2.7 e 2.8 estao marcadas como pendentes no texto do enunciado e nao existem arquivos de teste correspondentes no repositorio.

Os criterios de sucesso da task incluem:
- "Matriz de seguranca: 100% dos endpoints de dados retornam 401 sem token"
- "Usuario de um grupo nao le nem escreve dados de outro grupo (404)"

Sem esses testes, nao ha garantia automatizada de que as regras de isolamento funcionam corretamente.

---

### Problemas Minor

#### MINOR-1: `GetBudgetSummaryProvider.queryCategoryInfo` nao filtra por `group_id`

**Arquivo**: `src/main/kotlin/.../budget/application/GetBudgetSummaryProvider.kt`
**Linha**: 172-179

```kotlin
// Sem filtro de group_id
val rows = jdbcTemplate.queryForList(
    "SELECT id, name, icon FROM categories WHERE id IN ($placeholders)",
    *categoryIds.toTypedArray(),
)
```

Os `categoryId` vem dos `BudgetItemModel` que ja pertencem ao budget correto do grupo, entao o risco pratico e baixo. Porem, em teoria, um `categoryId` incorreto poderia revelar o nome de uma categoria de outro grupo. Como a query e interna (retorna apenas `name` e `icon`), o impacto e limitado ao metadata.

**Correcao sugerida**:
```kotlin
val rows = jdbcTemplate.queryForList(
    "SELECT id, name, icon FROM categories WHERE id IN ($placeholders) AND group_id = ?",
    *categoryIds.toTypedArray(), groupId,
)
```

---

#### MINOR-2: Valor `groupId = 1` hardcoded como default em `PaymentNotification`

**Arquivo**: `src/main/kotlin/.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
**Linha**: 22

```kotlin
// Default 1 (legacy group) keeps the SQS path working until Task 3 wires the API key.
@Column(name = "group_id", nullable = false)
val groupId: Long = 1,
```

O comentario documenta a intencao, mas o valor `1` e um numero magico. A convencao da task (e da techspec) e usar constantes nomeadas. Alem disso, ao criar uma notificacao manual via `POST /payments/notifications/manual`, o controller corretamente usa `requestContext.groupId`. O default `= 1` e especificamente para o path SQS (sem autenticacao), que e escopo da Task 3.

**Correcao sugerida**: Enquanto a Task 3 nao chega, extrair para constante:
```kotlin
companion object {
    const val LEGACY_GROUP_ID = 1L
}

val groupId: Long = LEGACY_GROUP_ID,
```

---

#### MINOR-3: `UpdateCategoryProvider` lanca excecao com mensagem em portugues

**Arquivo**: `src/main/kotlin/.../categories/application/UpdateCategoryProvider.kt`
**Linha**: 19

```kotlin
throw NoSuchElementException("Categoria nao encontrada: ${category.id}")
```

A convencao do projeto (registrada em memoria: "Comentarios em ingles") se aplica tambem a mensagens de excecao emitidas em codigo. Os demais providers usam mensagens em ingles (ex: "Category not found", "PaymentMethod not found").

Os mesmos problemas existem em:
- `FindCategoryProvider` linha 19: `"Categoria nao encontrada: $id"`

**Correcao sugerida**:
```kotlin
throw NoSuchElementException("Category not found: ${category.id}")
```

---

## Destaques Positivos

- **Migracao em 3 passos bem estruturada**: A separacao em V28 (ADD NULL), V29 (backfill) e V30 (NOT NULL + FK + indices) e a abordagem correta e segura para producao com dados legados. Nenhum risco de "lock" na adicao inicial.

- **`JwtRequestContext` limpo e correto**: A extracao do `groupId` do JWT em uma classe `@RequestScope` e elegante. O `throw IllegalStateException` para claims ausentes e comportamento fail-fast correto.

- **TokenIssuer integra groupId corretamente**: O `groupId` e buscado do `group_members` no momento do login e embedado no JWT, garantindo que o contexto de grupo nunca depende do banco a cada request.

- **Todos os providers de escrita usam `.copy(groupId = requestContext.groupId)`**: O padrao de substituir o groupId na conversao (em vez de confiar no modelo de entrada) e defensivo e correto.

- **`SeedDefaultCategoriesProvider` como `fun interface`**: Uso elegante de functional interface do Kotlin para o gateway de seed, facilitando mock nos testes.

- **`CreateUserWithPersonalGroupProvider` usa `TransactionTemplate`**: A criacao atomica do usuario + grupo + membro + seed de categorias dentro de uma transacao e correta.

- **Testes unitarios existentes atualizados corretamente**: Os testes em `AssociateNotificationProviderTest` e `PurchaseInvoiceRepositoryTest` ja usam `findByIdAndGroupId` com `groupId=1L` e mock de `RequestContext`.

- **`TestAuthMockMvcConfig` injeta `groupId` no JWT de teste**: A configuracao embute o claim `groupId: 1L` nos tokens de teste, permitindo que todos os testes de integracao existentes continuem funcionando sem alteracao.

---

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas (mensagens de excecao em portugues em 2 arquivos) |
| Kotlin/Spring Boot | OK |
| REST/HTTP (retorno 404 para outro grupo) | Problemas (depende de MAJOR-3 ser testado) |
| Seguranca / Isolamento de grupo | Critico (CRITICO-1, CRITICO-2) |
| Migracao de banco | OK |
| Testes | Critico (MAJOR-3: subtarefas 2.7 e 2.8 ausentes) |

---

## Recomendacoes

1. **[URGENTE] Corrigir `FindInvoiceSuggestionsUseCase`** para usar `findByIdAndGroupId` (CRITICO-1).
2. **[URGENTE] Corrigir `PaymentNotificationController.getNotification`** para usar `findByIdAndGroupId` ao carregar a invoice associada (CRITICO-2).
3. **[ALTA] Implementar os testes das subtarefas 2.7 e 2.8** (MAJOR-3) — sem eles os criterios de sucesso nao podem ser verificados automaticamente.
4. **[MEDIA] Remover metodos de repositorio sem filtro de `groupId`** das interfaces (MAJOR-1) para evitar regressoes futuras.
5. **[MEDIA] Substituir `budgetRepository.findAll()` por `findAllByGroupId`** em `ReplicateBudgetPeriodsToFutureProvider` (MAJOR-2).
6. **[BAIXA] Adicionar filtro `group_id` na `queryCategoryInfo`** do `GetBudgetSummaryProvider` (MINOR-1).
7. **[BAIXA] Extrair `1L` para constante `LEGACY_GROUP_ID`** em `PaymentNotification` (MINOR-2).
8. **[BAIXA] Corrigir mensagens de excecao em portugues** em `UpdateCategoryProvider` e `FindCategoryProvider` (MINOR-3).

---

## Veredito

A implementacao demonstra boa arquitetura e cobre corretamente a grande maioria dos fluxos de isolamento de dados. As migrations Flyway estao corretas, o `RequestContext` e bem integrado em todos os providers e a abordagem de filtro explicito (sem Hibernate Filter global) e a decisao certa para visibilidade e testabilidade.

Contudo, existem **dois problemas criticos de seguranca** (`FindInvoiceSuggestionsUseCase` e `PaymentNotificationController.getNotification`) que permitem acesso a dados de outros grupos em caminhos especificos, e as **subtarefas de teste 2.7 e 2.8 nao foram implementadas**, violando o criterio de sucesso explicito da task.

Os itens CRITICO-1, CRITICO-2 e MAJOR-3 devem ser resolvidos antes que esta task seja considerada concluida. Os demais itens podem ser tratados em iteracao subsequente.

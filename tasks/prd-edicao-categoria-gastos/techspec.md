# Tech Spec — Edicao de Categoria em Gastos

## Resumo Executivo

Esta spec descreve a implementacao da edicao de categoria em payment_notifications. A abordagem utiliza um endpoint PATCH separado no backend (seguindo o padrao existente de `/description`), um bottom sheet modal no frontend para selecao de categorias (IonModal com breakpoints), e verificacao de vinculo com orcamento via API existente com criacao automatica de budget item quando a categoria nao consta no orcamento do mes.

A arquitetura aproveita componentes e padroes ja existentes: CategoryChips para renderizacao, CategoryRepository para validacao, e BudgetController para verificacao/criacao de itens orcamentarios.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (Kotlin/Spring Boot):**

- `PaymentNotificationController` (modificado) — Novo endpoint `PATCH /payments/notifications/{id}/category`
- `UpdateCategoryRequest` (novo) — Request DTO com campo `categoryId: Long?`
- `CategoryRepository` (existente) — Usado para validar que a categoria existe antes de salvar
- `BudgetController` (existente) — Endpoint `POST /budgets/{id}/items` ja disponivel para criacao de budget items

**Frontend (React/Ionic):**

- `CategoryBottomSheet` (novo) — Componente IonModal com lista de categorias, opcao "Nenhuma", e indicador de selecao atual
- `PurchaseDetail.tsx` (modificado) — Campo "Categoria" vira clicavel, abre CategoryBottomSheet, exibe aviso de orcamento
- `PurchaseList.tsx` (modificado) — Exibe badge de categoria em cada item, toque abre CategoryBottomSheet
- `Tab1.tsx` (modificado) — Tipo PaymentNotification expandido com `categoryId` e `category`
- `purchaseService.ts` (modificado) — Nova funcao `updatePaymentNotificationCategory`
- `budgetService.ts` (modificado) — Nova funcao para verificar se categoria existe no budget do mes e criar budget item

## Design de Implementacao

### Interfaces Principais

**Backend — Controller endpoint:**

```kotlin
// PaymentNotificationController.kt
@PatchMapping("/notifications/{id}/category")
fun updateCategory(
    @PathVariable id: Long,
    @RequestBody request: UpdateCategoryRequest,
): PaymentNotificationResponse
```

```kotlin
// UpdateCategoryRequest.kt
data class UpdateCategoryRequest(
    val categoryId: Long?,
)
```

**Frontend — Service functions:**

```typescript
// purchaseService.ts
export function updatePaymentNotificationCategory(
  id: number,
  categoryId: number | null,
): Promise<PaymentNotificationDetail>

// budgetService.ts
export function checkCategoryInBudget(
  month: string, // YYYY-MM
  categoryId: number,
): Promise<boolean>

export function addBudgetItem(
  budgetId: number,
  categoryId: number,
  expected: number, // 0 por padrao
  type: string, // "EXPENSE"
): Promise<BudgetItem>
```

### Modelos de Dados

**Nenhuma alteracao de schema necessaria.** O modelo `PaymentNotification` ja possui:

```
payment_notifications
├── category_id  BIGINT NULLABLE  -- FK para categories.id
└── category     VARCHAR(50) NULLABLE  -- campo legado (string)
```

**Tipo frontend expandido em Tab1.tsx:**

```typescript
type PaymentNotification = {
  id: number;
  cardLastDigits: string;
  purchasedAt: string;
  amount: number;
  merchantName: string;
  numberOfInstallments: number;
  description: string | null;
  categoryId: number | null;    // novo
  category: string | null;      // novo
};
```

### Endpoints de API

**Novo endpoint:**

| Metodo | Caminho | Descricao |
|--------|---------|-----------|
| `PATCH` | `/payments/notifications/{id}/category` | Atualiza categoryId de um payment_notification |

**Request body:**
```json
{ "categoryId": 5 }
```
ou para remover:
```json
{ "categoryId": null }
```

**Response:** `PaymentNotificationResponse` completo (mesmo formato do GET).

**Validacoes:**
- `id` deve existir e nao estar soft-deleted → 404
- `categoryId` (quando nao-null) deve corresponder a uma categoria existente → 400 com mensagem "Category not found"

**Logica de compatibilidade:** Ao salvar, o campo legado `category` (string) deve ser atualizado com `categoryModel.name` quando `categoryId` nao e null, ou `null` quando `categoryId` e null.

**Endpoints existentes utilizados:**

| Metodo | Caminho | Uso |
|--------|---------|-----|
| `GET` | `/categories` | Listar categorias para o seletor |
| `GET` | `/budgets?month=YYYY-MM` | Obter budget do mes (inclui items com categoryId) |
| `POST` | `/budgets/{id}/items` | Criar budget item para categoria nao presente |

## Pontos de Integracao

**Budget Summary (impacto indireto):**
- `GetBudgetSummaryProvider.queryActualByCategory()` faz `SUM(amount) GROUP BY category_id` em payment_notifications
- Alterar o `categoryId` de uma notification afeta imediatamente os totais do budget summary
- Nenhuma alteracao necessaria no provider — o calculo e dinamico

**Verificacao de vinculo com orcamento (frontend):**
1. Apos selecionar categoria, frontend faz `GET /budgets?month=YYYY-MM` (mes do gasto)
2. Verifica se `budget.items` contem item com `categoryId` igual ao selecionado
3. Se nao contem: exibe banner com CTA "Adicionar ao orcamento"
4. CTA executa `POST /budgets/{budgetId}/items` com `{ categoryId, expected: 0, type: "EXPENSE" }`
5. Se budget nao existe para o mes: nao exibe aviso (sem budget = sem planejamento)

## Abordagem de Testes

### Testes Unitarios

**Backend:**
- `PaymentNotificationController.updateCategory()`:
  - Atualizar com categoryId valido → 200, retorna notification atualizada com categoryId e category (string) preenchidos
  - Atualizar com categoryId null → 200, retorna notification com campos de categoria nulos
  - categoryId inexistente → 400
  - notification id inexistente → 404
  - notification soft-deleted → 404

**Frontend:**
- `CategoryBottomSheet`: renderiza categorias, destaca selecionada, emite onSelect ao clicar, emite null ao clicar "Nenhuma"
- `purchaseService.updatePaymentNotificationCategory`: chamada HTTP correta

### Testes de Integracao

**Backend:**
- Fluxo completo: criar notification sem categoria → PATCH com categoria → GET verifica categoryId e category string
- Impacto no budget: criar notification → categorizar → verificar que budget summary reflete o valor

### Testes E2E

**Playwright:**
- Abrir detalhe de notification sem categoria → tocar em "Sem categoria" → selecionar categoria no bottom sheet → verificar que campo atualiza
- Na listagem: tocar em badge de categoria → selecionar nova categoria → verificar atualizacao inline
- Fluxo de orcamento: categorizar gasto com categoria fora do budget → verificar banner → clicar CTA → verificar que item foi adicionado ao budget

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Backend: Request DTO + Endpoint PATCH** — Base para todo o resto. Criar `UpdateCategoryRequest`, adicionar endpoint no controller com validacao de categoria via `CategoryRepository.findById()`, e logica de sync do campo legado `category`.

2. **Frontend: Service function** — `updatePaymentNotificationCategory` em `purchaseService.ts`. Testavel isoladamente.

3. **Frontend: CategoryBottomSheet** — Novo componente com IonModal, lista de categorias (reutilizando `listCategories`), opcao "Nenhuma", destaque da categoria selecionada.

4. **Frontend: Integracao PurchaseDetail** — Campo "Categoria" clicavel, abre CategoryBottomSheet, salva via service, atualiza estado local.

5. **Frontend: Integracao Tab1/PurchaseList** — Expandir tipo, exibir badge de categoria, tocar abre bottom sheet, salvar e atualizar item na lista.

6. **Frontend: Verificacao de orcamento + CTA** — Apos selecao, verificar budget do mes, exibir banner se necessario, CTA cria budget item via API.

7. **Testes E2E** — Fluxos completos com Playwright.

### Dependencias Tecnicas

- Nenhuma dependencia externa ou de infraestrutura nova
- Todos os endpoints e componentes base ja existem
- A feature e incremental sobre a arquitetura atual

## Monitoramento e Observabilidade

**Logs (backend):**
- `INFO` ao atualizar categoria: `"Category updated for notification {id}: {oldCategoryId} -> {newCategoryId}"`
- `WARN` ao tentar atualizar com categoria inexistente: `"Category {categoryId} not found"`

**Metricas observaveis:**
- Monitorar via queries SQL: percentual de notifications com `category_id IS NOT NULL` ao longo do tempo
- Budget summary ja reflete automaticamente os gastos categorizados

## Consideracoes Tecnicas

### Decisoes Principais

| Decisao | Escolha | Justificativa |
|---------|---------|---------------|
| Endpoint de categoria | PATCH separado (`/category`) | Consistencia com padrao existente (`/description`). Evita complexidade de partial update generico |
| Componente de selecao | IonModal bottom sheet | Padrao nativo mobile, suporta scroll para muitas categorias, nao polui o layout da pagina |
| Sync campo legado | Atualizar `category` (string) junto com `categoryId` | Compatibilidade retroativa — telas que ainda usam o campo string continuam funcionando |
| CTA de orcamento | Criar budget item via API (expected=0) | Minima friccao — usuario nao sai da tela. Valor esperado pode ser ajustado depois na BudgetPage |
| Verificacao de budget | Frontend-side via GET existente | Evita novo endpoint. Budget summary e leve e ja inclui items com categoryId |

### Riscos Conhecidos

| Risco | Mitigacao |
|-------|-----------|
| Campo legado `category` divergir de `categoryId` se atualizado por outro fluxo | Centralizar a logica de sync em um metodo privado no controller |
| Budget nao existir para o mes do gasto | Nao exibir aviso — sem budget significa que o usuario nao planejou aquele mes |
| Categorias com icone null | Renderizar fallback (icone generico ou apenas nome) no bottom sheet |
| Latencia ao abrir bottom sheet (load de categorias) | Cachear categorias no frontend apos primeiro load — lista muda raramente |

### Conformidade com Skills Padroes

- `executar-task` — Implementacao seguira o fluxo de tasks incrementais
- `task-review` — Cada task sera revisada via task-reviewer agent
- `executar-review` — Code review completo apos todas as tasks

### Arquivos relevantes e dependentes

**Backend:**
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/request/UpdateDescriptionRequest.kt` (referencia de padrao)
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/response/PaymentNotificationResponse.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/categories/entrypoint/database/repository/CategoryRepository.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/categories/entrypoint/database/model/CategoryModel.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/rest/BudgetController.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/GetBudgetSummaryProvider.kt`

**Frontend:**
- `src/services/purchaseService.ts`
- `src/services/budgetService.ts`
- `src/services/categoryService.ts`
- `src/pages/PurchaseDetail.tsx`
- `src/pages/Tab1.tsx`
- `src/components/PurchaseList.tsx`
- `src/components/CategoryChips.tsx` (referencia de padrao)
- `src/types/category.ts`
- `src/types/budget.ts`

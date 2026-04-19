# Review: Tasks 1-10 - Planejamento e Orcamento Mensal

**Revisor**: AI Code Reviewer
**Data**: 2026-04-16
**Arquivo da task**: 1_task.md a 10_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

Implementacao completa do bounded context `budget` no backend (Kotlin/Spring Boot) e no frontend (React/Ionic/Capacitor). A arquitetura hexagonal foi seguida corretamente com 3 migracoes Flyway, entidades de dominio, use cases, gateways, providers, JPA models, controller REST com 11 endpoints, e frontend com pagina de planejamento, card resumo e roteamento.

A qualidade geral e boa: o codigo compila sem erros em ambos os lados, testes unitarios passam, e a estrutura segue os padroes do projeto. No entanto, existem problemas que precisam de atencao, incluindo um bug funcional na edicao inline e lacunas de cobertura de teste no frontend.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| V16/V17/V18 migracoes SQL | OK | 0 |
| domain/budget/entity/* (5 arquivos) | OK | 0 |
| domain/budget/gateway/* (11 arquivos) | OK | 0 |
| domain/budget/usecase/* (11 arquivos) | OK | 0 |
| application/budget/entrypoint/database/model/* (3 arquivos) | OK | 0 |
| application/budget/entrypoint/database/repository/* (3 arquivos) | OK | 0 |
| application/budget/converter/BudgetConverter.kt | OK | 0 |
| application/budget/application/* (11 providers) | Problemas | 1 |
| application/budget/entrypoint/rest/BudgetController.kt | Problemas | 2 |
| application/budget/entrypoint/rest/request/* (5 DTOs) | OK | 0 |
| application/budget/entrypoint/rest/response/* (5 DTOs) | OK | 0 |
| BudgetUseCasesTest.kt | OK | 0 |
| BudgetConverterTest.kt | OK | 0 |
| BudgetMigrationIntegrationTest.kt | OK | 0 |
| src/types/budget.ts | OK | 0 |
| src/services/budgetService.ts | Problemas | 1 |
| src/pages/BudgetPage.tsx | Critico | 3 |
| src/pages/BudgetPage.css | OK | 0 |
| src/components/BudgetSummaryCard.tsx | OK | 0 |
| src/pages/Tab1.tsx | OK | 0 |
| src/pages/Tab3.tsx | Problemas | 1 |
| src/App.tsx | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

**C1. Bug funcional: edicao inline de expectativa esta quebrada (BudgetPage.tsx, linhas 76-89)**

A funcao `handleSaveItem` chama `updateBudgetItem(0, item.categoryId, ...)` com `budgetId = 0` (hardcoded) e `itemId = item.categoryId` (errado -- deveria ser o ID do item). O BudgetSummary nao retorna o `id` do item nem o `budgetId`, impossibilitando a chamada correta. Alem disso, todo o mecanismo de edicao inline (estados `editingItem`, `editValue`, `setEditingItem`) e declarado mas nunca renderizado no JSX -- nenhum input de edicao aparece na interface.

Correcao sugerida: (1) Incluir `id` e `budgetId` no `BudgetItemSummaryResponse` e no tipo `BudgetItemSummary` do frontend; (2) Renderizar o input de edicao inline nos item rows; (3) Usar os IDs corretos na chamada `updateBudgetItem`.

```kotlin
// BudgetItemSummaryResponse.kt - adicionar id
data class BudgetItemSummaryResponse(
    val id: Long?,        // NOVO
    val budgetId: Long,   // NOVO
    val categoryId: Long,
    ...
)
```

```tsx
// BudgetPage.tsx - renderizar input de edicao
<div className="budget-item-col-value budget-neutral" onClick={() => { setEditingItem(item.categoryId); setEditValue(String(item.expected)); }}>
  {editingItem === item.categoryId
    ? <input value={editValue} onChange={e => setEditValue(e.target.value)} onBlur={() => void handleSaveItem(item)} autoFocus />
    : fmt(item.expected)}
</div>
```

**C2. Codigo morto: funcao `parseYearMonth` nunca utilizada (BudgetPage.tsx, linhas 14-17)**

A funcao `parseYearMonth` e declarada mas nunca chamada em nenhum lugar do arquivo. Codigo morto deve ser removido.

### Problemas Major

**M1. Task 10 incompleta: link "Orcamento" nao adicionado na Tab3 (Tab3.tsx)**

A task 10 exige explicitamente: "Adicionar link 'Orcamento' na Tab3 (Config) para 'Orcamento Mensal' (mesmo padrao dos links existentes para Cartoes e Categorias)". A Tab3.tsx atual so tem links para Cartoes e Categorias -- o link para Orcamento nao foi implementado.

Correcao sugerida:

```tsx
// Tab3.tsx - adicionar apos o link de Categorias
<button className="t3-item" onClick={() => history.push('/budget')}>
  <div className="t3-item-icon">
    <IonIcon icon={walletOutline} />
  </div>
  <div className="t3-item-info">
    <p className="t3-item-name">Orcamento Mensal</p>
    <p className="t3-item-desc">Planejar receitas e gastos por categoria</p>
  </div>
  <IonIcon icon={chevronForwardOutline} className="t3-chevron" />
</button>
```

**M2. Ausencia total de testes no frontend (tasks 7, 8, 9, 10)**

Nenhum teste unitario ou de componente foi criado para o frontend. As tasks 7, 8, 9 e 10 exigem explicitamente testes (`budgetService.test.ts`, `BudgetPage.test.tsx`, `BudgetSummaryCard.test.tsx`). Nenhum desses arquivos existe.

**M3. UpdateBudgetItemProvider sobrescreve categoryId e type com valores dummy (UpdateBudgetItemProvider.kt + BudgetController.kt, linhas 108-117)**

No `BudgetController.updateItem`, o BudgetItem e construido com `categoryId = 0` e `type = BudgetItemType.EXPENSE` (valores hardcoded) porque o `UpdateBudgetItemRequest` so tem `expected`. Porem, o `UpdateBudgetItemProvider` copia esses valores para o item atualizado (`categoryId = item.categoryId`, `type = item.type.name`), sobrescrevendo os valores reais do banco com `categoryId = 0` e `type = EXPENSE`.

Correcao sugerida: o `UpdateBudgetItemProvider` deve preservar os campos originais e so atualizar `expected`:

```kotlin
// UpdateBudgetItemProvider.kt
val updated = existing.copy(expected = item.expected)
```

**M4. DuplicateBudgetProvider nao valida se o targetMonth ja existe (DuplicateBudgetProvider.kt)**

A duplicacao conta com o constraint UNIQUE do banco para rejeitar meses duplicados. Embora funcione, a excecao que chega ao controller sera uma `DataIntegrityViolationException` e nao uma `IllegalStateException`, e o `when` no controller testa `is NoSuchElementException` -- qualquer outra excecao cai no `else` (CONFLICT). Isso funciona por acidente, mas a mensagem de erro ao usuario pode conter detalhes do banco. Seria mais robusto validar antes do save.

**M5. httpRequest duplicada no budgetService.ts (linhas 16-46)**

A funcao `httpRequest` foi reescrita dentro do `budgetService.ts` em vez de importar a versao ja existente usada nos outros services. Isso viola DRY e pode causar inconsistencia de comportamento se a logica de HTTP for atualizada em um lugar mas nao no outro.

### Problemas Minor

**m1. BudgetSummaryResponse.items nao inclui `id` do item (BudgetSummaryResponse.kt)**

O `BudgetItemSummaryResponse` nao inclui o `id` do item original nem o `budgetId`. Isso e necessario para a edicao inline (apontado em C1) e para futuras operacoes de delete inline.

**m2. Mensagens de erro em portugues nas excecoes do backend**

Todas as mensagens de excecao estao em portugues ("Planejamento nao encontrado", "Item nao encontrado", etc.). Embora funcione, mensagens de erro internas devem estar em ingles para consistencia do codigo. Mensagens ao usuario devem ser tratadas no frontend.

**m3. GetBudgetSummaryProvider faz N+1 query para nomes de categorias (GetBudgetSummaryProvider.kt, linha 117-123)**

A funcao `queryCategoryName` e chamada uma vez por item do budget, causando N queries adicionais. Para um planejamento com 20 categorias, sao 20 queries extras. Seria mais eficiente trazer os nomes em uma unica query ou fazer JOIN na query principal.

**m4. Secao "Meios de Pagamento" reutiliza classes CSS de income (BudgetPage.tsx, linhas 283-289)**

Os elementos de meio de pagamento usam `className="budget-income"` e `className="budget-income-label"`, que sao semanticamente incorretos. Deveria ter classes proprias como `budget-payment-method`.

**m5. monthNames com "Marco" sem acento (BudgetPage.tsx, linha 12)**

O mes de marco esta escrito sem acento: `'Marco'` em vez de `'Marco'`. Considerando que o app e em portugues, deveria ser corrigido para exibicao correta, embora acentos em nomes de meses possam ser uma decisao consciente para evitar problemas de encoding.

## Destaques Positivos

1. **Arquitetura hexagonal consistente**: O bounded context `budget` segue fielmente o padrao ja estabelecido no projeto, com separacao clara entre domain, application e entrypoint.

2. **Migracoes SQL bem estruturadas**: As 3 migracoes seguem o padrao existente com constraints nomeadas, FKs, UKs e ON DELETE CASCADE.

3. **Testes unitarios do domain layer abrangentes**: O `BudgetUseCasesTest.kt` cobre todos os 11 use cases com cenarios de sucesso e falha, incluindo teste de duplicacao com verificacao de items/incomes copiados.

4. **Converter com testes**: O `BudgetConverter` tem testes que cobrem conversao bidirecional, incluindo edge cases de listas vazias.

5. **Testes de integracao de migracoes completos**: O `BudgetMigrationIntegrationTest.kt` valida schema, constraints UNIQUE, CASCADE DELETE e timestamps.

6. **Frontend types 100% alinhados com backend DTOs**: Os tipos TypeScript em `budget.ts` mapeiam corretamente todos os DTOs do backend.

7. **BudgetSummaryCard bem integrado**: A integracao na Tab1 substitui corretamente os valores hardcoded e implementa estados de loading/erro.

8. **CSS bem organizado com design system consistente**: O BudgetPage.css segue o dark theme e tipografia (IBM Plex) do app existente.

9. **Controller com tratamento de erros adequado**: Status codes corretos (201, 200, 204, 404, 409) com distincao entre tipos de excecao na duplicacao.

10. **GetBudgetSummaryProvider com queries SQL corretas**: As queries de agregacao por categoria e por meio de pagamento seguem o padrao do `GetPaymentMethodsSummaryProvider` e filtram corretamente por `deleted_at IS NULL`.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas (codigo morto, mensagens em PT no backend, httpRequest duplicada) |
| Kotlin/Spring Boot | OK |
| REST/HTTP | OK |
| React/Ionic | Problemas (edicao inline nao funcional, link Tab3 ausente) |
| Testes | Critico (zero testes no frontend, tasks 7-10 exigem testes) |

## Recomendacoes

1. **[CRITICO] Corrigir edicao inline**: Adicionar `id` e `budgetId` ao `BudgetItemSummaryResponse`, ajustar o tipo TS, renderizar o input no JSX, e corrigir a chamada `updateBudgetItem` com IDs corretos.

2. **[CRITICO] Corrigir `UpdateBudgetItemProvider`**: Preservar `categoryId` e `type` originais no update, atualizando apenas `expected`.

3. **[MAJOR] Adicionar link "Orcamento" na Tab3**: Conforme exigido pela task 10.

4. **[MAJOR] Criar testes do frontend**: Ao menos testes basicos para `budgetService.ts`, `BudgetPage.tsx`, `BudgetSummaryCard.tsx`.

5. **[MAJOR] Extrair `httpRequest` para modulo compartilhado**: Remover a copia local em `budgetService.ts` e importar de um utilitario comum.

6. **[MINOR] Resolver N+1 de nomes de categorias**: Buscar nomes em uma unica query em `GetBudgetSummaryProvider`.

7. **[MINOR] Remover funcao `parseYearMonth` nao utilizada**: Codigo morto em `BudgetPage.tsx`.

8. **[MINOR] Padronizar mensagens de excecao em ingles no backend**.

## Veredito

A implementacao cobre os requisitos do PRD de forma substancial, com backend bem estruturado e frontend funcional para visualizacao. No entanto, a funcionalidade de **edicao inline** -- que e um requisito central do PRD ("Edicao inline dos valores de expectativa") -- esta incompleta/quebrada. Alem disso, a ausencia de link na Tab3, o bug no `UpdateBudgetItemProvider`, e a falta total de testes no frontend precisam ser resolvidos antes de considerar a feature completa.

**Proximos passos**:
1. Corrigir os 2 problemas criticos (edicao inline + UpdateBudgetItemProvider)
2. Corrigir os 4 problemas major (Tab3, testes frontend, DRY httpRequest, validacao de duplicacao)
3. Opcional: resolver os 5 problemas minor

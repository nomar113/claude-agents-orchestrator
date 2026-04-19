# Tarefa 11.0: [BUGFIX CRITICO] Corrigir edicao inline de expectativa e UpdateBudgetItemProvider

<critical>Ler os arquivos de prd.md, techspec.md e review_all_tasks.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Corrigir dois bugs criticos identificados na review (C1 e M3): a funcionalidade de edicao inline de expectativa esta completamente quebrada — o handler usa IDs hardcoded/errados e o input de edicao nunca e renderizado no JSX. Alem disso, o `UpdateBudgetItemProvider` sobrescreve `categoryId` e `type` com valores dummy.

<skills>
### Conformidade com Skills Padroes

- `executar-bugfix` — Seguir o procedimento completo de correcao de bugs
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Corrigir `handleSaveItem` em BudgetPage.tsx para usar os IDs corretos (budgetId e itemId reais)
- Adicionar `id` e `budgetId` ao `BudgetItemSummaryResponse.kt` e ao tipo TypeScript `BudgetItemSummary`
- Renderizar o input de edicao inline no JSX do BudgetPage.tsx (estados `editingItem`, `editValue`, `setEditingItem` ja existem mas nao sao usados)
- Corrigir `UpdateBudgetItemProvider.kt` para preservar `categoryId` e `type` originais, atualizando apenas `expected`
- Corrigir o controller para nao passar valores dummy de `categoryId` e `type`
- Remover funcao `parseYearMonth` nao utilizada (codigo morto - C2)
</requirements>

## Subtarefas

- [ ] 11.1 Adicionar `id` e `budgetId` ao `BudgetItemSummaryResponse.kt` e popular no `GetBudgetSummaryProvider`
- [ ] 11.2 Atualizar tipo TypeScript `BudgetItemSummary` com `id` e `budgetId`
- [ ] 11.3 Corrigir `UpdateBudgetItemProvider.kt` para preservar campos originais (`existing.copy(expected = item.expected)`)
- [ ] 11.4 Corrigir `BudgetController.updateItem` para nao passar `categoryId = 0` e `type = EXPENSE`
- [ ] 11.5 Renderizar input de edicao inline no JSX do BudgetPage.tsx
- [ ] 11.6 Corrigir `handleSaveItem` para usar `item.id` e `item.budgetId` corretos
- [ ] 11.7 Remover funcao `parseYearMonth` nao utilizada
- [ ] 11.8 Testar edicao inline end-to-end (alterar valor, salvar, verificar persistencia)

## Detalhes de Implementacao

### Backend - UpdateBudgetItemProvider.kt
```kotlin
// ANTES (bugado): copia categoryId e type do input (que sao dummy)
val updated = BudgetItem(id = existing.id, budgetId = existing.budgetId, categoryId = item.categoryId, type = item.type, expected = item.expected)

// DEPOIS (correto): preserva campos originais, so atualiza expected
val updated = existing.copy(expected = item.expected)
```

### Backend - BudgetItemSummaryResponse.kt
```kotlin
data class BudgetItemSummaryResponse(
    val id: Long?,        // NOVO
    val budgetId: Long,   // NOVO
    val categoryId: Long,
    // ... demais campos
)
```

### Frontend - BudgetPage.tsx
```tsx
// Renderizar input de edicao ao clicar no valor
<div className="budget-item-col-value" onClick={() => { setEditingItem(item.categoryId); setEditValue(String(item.expected)); }}>
  {editingItem === item.categoryId
    ? <input value={editValue} onChange={e => setEditValue(e.target.value)} onBlur={() => void handleSaveItem(item)} autoFocus />
    : fmt(item.expected)}
</div>
```

## Criterios de Sucesso

- Edicao inline funciona: clicar no valor abre input, ao sair salva o novo valor
- `UpdateBudgetItemProvider` preserva `categoryId` e `type` originais
- Backend compila e testes existentes continuam passando
- Frontend compila sem erros
- Funcao `parseYearMonth` removida

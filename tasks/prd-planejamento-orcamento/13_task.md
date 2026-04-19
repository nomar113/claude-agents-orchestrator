# Tarefa 13.0: [BUGFIX MAJOR] Validacao de duplicacao e testes do frontend

<critical>Ler os arquivos de prd.md, techspec.md e review_all_tasks.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Corrigir dois problemas major: (M4) o `DuplicateBudgetProvider` nao valida se o `targetMonth` ja existe antes de tentar salvar, dependendo de exception do banco, e (M2) nenhum teste foi criado para o frontend (tasks 7-10 exigem testes).

<skills>
### Conformidade com Skills Padroes

- `executar-bugfix` — Seguir o procedimento completo de correcao de bugs
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Adicionar validacao explicita no `DuplicateBudgetProvider` verificando se o targetMonth ja existe antes do save
- Retornar erro claro (ex: IllegalStateException) em vez de depender de DataIntegrityViolationException do banco
- Criar testes unitarios para `budgetService.ts`
- Criar testes de componente para `BudgetPage.tsx`
- Criar testes de componente para `BudgetSummaryCard.tsx`
</requirements>

## Subtarefas

- [ ] 13.1 Adicionar verificacao `findByYearMonth(targetMonth)` no `DuplicateBudgetProvider` antes de duplicar
- [ ] 13.2 Lancar `IllegalStateException` com mensagem clara se o mes ja existir
- [ ] 13.3 Criar `budgetService.test.ts` com testes para os principais endpoints (get, create, update, delete, duplicate)
- [ ] 13.4 Criar `BudgetPage.test.tsx` com testes de renderizacao e interacao basica
- [ ] 13.5 Criar `BudgetSummaryCard.test.tsx` com testes de renderizacao e estados (loading, erro, dados)

## Detalhes de Implementacao

### DuplicateBudgetProvider.kt
```kotlin
// Adicionar validacao antes de salvar
val existing = budgetRepository.findByYearMonth(targetMonth)
if (existing != null) {
    throw IllegalStateException("Budget for month $targetMonth already exists")
}
// ... prosseguir com duplicacao
```

### Testes Frontend
Seguir o padrao de testes ja existente no projeto. Usar mocks para o budgetService nos testes de componente. Cobrir ao menos:
- **budgetService.test.ts**: chamadas HTTP corretas para cada endpoint, tratamento de erros
- **BudgetPage.test.tsx**: renderizacao inicial, navegacao entre meses, exibicao de categorias
- **BudgetSummaryCard.test.tsx**: estado de loading, estado de erro, exibicao de dados corretos

## Criterios de Sucesso

- `DuplicateBudgetProvider` valida existencia do mes antes de duplicar
- Todos os testes do frontend passam
- Backend compila e testes existentes continuam passando
- Cobertura minima dos cenarios principais de cada componente/service

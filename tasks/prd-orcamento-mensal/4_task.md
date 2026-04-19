# Tarefa 4.0: Frontend — Modo Edicao + CRUD de Itens

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o modo edicao inline no `BudgetPage.tsx` com estado `isEditing`. Quando ativo: valores planejados viram inputs editaveis, botoes de adicionar (+) e remover (x) aparecem nas secoes de Gastos e Investimentos. Criar `AddItemModal.tsx` com seletor de categoria filtrado (sem categorias ja adicionadas) e tipo (EXPENSE/INVESTMENT). Cada acao CRUD e salva em real-time no backend.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- RF-09: Botao "Editar" no rodape ativa modo edicao; muda para "Salvar" ao ativar
- RF-10: Em modo edicao, valores planejados ficam editaveis (input numerico)
- RF-11: Em modo edicao, botoes de adicionar (+) e remover (x) aparecem nas secoes
- RF-12: Ao clicar "Salvar", tela volta ao modo visualizacao (alteracoes ja salvas em real-time)
- RF-13: Adicionar item: seletor de categoria + tipo + valor planejado
- RF-14: Editar item: alterar valor planejado inline
- RF-15: Remover item: botao remover visivel no modo edicao, com confirmacao (IonAlert)
- RF-16: Validacao: nao permitir adicionar mesma categoria duas vezes (filtrar no seletor)
</requirements>

## Subtarefas

- [ ] 4.1 Adicionar estado `isEditing` ao `BudgetPage.tsx`
- [ ] 4.2 Implementar botoes "Editar"/"Salvar" no rodape (provisorio — layout final na Task 7)
- [ ] 4.3 Atualizar `BudgetCategoryCard.tsx` para aceitar props `isEditing`, `onUpdateExpected`, `onDelete`
- [ ] 4.4 Em modo edicao: valor planejado vira input numerico com `inputMode="decimal"`, salva via `onBlur`/`Enter`
- [ ] 4.5 Em modo edicao: botao X (remover) aparece no card, com IonAlert de confirmacao
- [ ] 4.6 Criar `AddItemModal.tsx` com: seletor de categoria (filtrado), tipo (EXPENSE/INVESTMENT), input de valor
- [ ] 4.7 Buscar categorias via `GET /categories` e filtrar removendo `existingCategoryIds`
- [ ] 4.8 Integrar `createBudgetItem()`, `updateBudgetItem()`, `deleteBudgetItem()` do `budgetService.ts`
- [ ] 4.9 Adicionar toast de feedback para operacoes CRUD (sucesso/erro)
- [ ] 4.10 Adicionar loading state por item durante chamadas de rede
- [ ] 4.11 Escrever e executar testes

## Detalhes de Implementacao

Consultar secao "Interfaces Principais" e "Decisoes Principais" da techspec.md.

**Fluxo de edicao (real-time):**
1. Usuario clica "Editar" → `isEditing = true`
2. Cards exibem input no lugar do valor planejado + botao X
3. Botao + aparece abaixo de cada secao
4. Ao editar valor: `onBlur` → `updateBudgetItem(budgetId, itemId, { expected })` → `load()`
5. Ao remover: IonAlert confirmacao → `deleteBudgetItem(budgetId, itemId)` → `load()`
6. Ao adicionar: modal → preencher → `createBudgetItem(budgetId, { categoryId, type, expected })` → `load()`
7. Usuario clica "Salvar" → `isEditing = false` (nao ha batch — tudo ja foi salvo)

**Service de categorias (frontend):** Verificar se `categoryService.ts` existe ou criar funcao `getCategories()` que chama `GET /categories`.

## Criterios de Sucesso

- Botao Editar/Salvar alterna o modo corretamente
- Itens editaveis em modo edicao, somente leitura fora dele
- Adicionar item abre modal com categorias filtradas
- Remover item exige confirmacao antes de deletar
- Todas as operacoes CRUD persistem no backend em real-time
- Toast de feedback exibido apos cada acao

## Testes da Tarefa

- [ ] Teste unitario: `BudgetCategoryCard` em modo edicao exibe input e botao remover
- [ ] Teste unitario: `BudgetCategoryCard` fora do modo edicao nao exibe input nem botao remover
- [ ] Teste unitario: `AddItemModal` filtra categorias ja existentes no budget
- [ ] Teste unitario: `AddItemModal` nao permite submit sem categoria e valor
- [ ] Teste de integracao: Criar item via modal → verificar que aparece na lista
- [ ] Teste de integracao: Editar valor inline → verificar persistencia
- [ ] Teste de integracao: Remover item com confirmacao → verificar que desaparece

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai-frontend`

- `src/pages/BudgetPage.tsx` (modificar — estado isEditing, integracao CRUD)
- `src/components/BudgetCategoryCard.tsx` (modificar — props isEditing, onUpdateExpected, onDelete)
- `src/components/AddItemModal.tsx` (novo)
- `src/services/budgetService.ts` (ja tem createBudgetItem, updateBudgetItem, deleteBudgetItem)
- `src/services/categoryService.ts` (verificar se existe ou criar getCategories)
- `src/pages/BudgetPage.css` (modificar — estilos do modo edicao)

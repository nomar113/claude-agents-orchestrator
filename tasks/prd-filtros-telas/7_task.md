# Tarefa 7.0: Frontend - Integracao de filtros na Tab1 (Home)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar `MonthSelector` e `CategoryFilterBar` na Tab1 (Home), conectando ao `FilterContext`. Ao mudar o mes, todos os dados da tela (CardStack, BudgetSummaryCard, lista de compras) devem atualizar. O filtro de categoria deve ser aplicado localmente sobre as notificacoes carregadas, recalculando o total.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-1.3: Alterar mes atualiza CardStack, BudgetSummaryCard, lista de compras e projecao de parcelas.
- RF-2.2: Selecionar categoria filtra lista localmente.
- RF-2.5: Filtragem por categoria e local no frontend.
- RF-2.6: Total exibido reflete itens filtrados.
- RF-2.7: Estado vazio quando filtro nao retorna resultados.
- MonthSelector posicionado abaixo do header, sticky no topo ao rolar.
- CategoryFilterBar abaixo do MonthSelector, com scroll horizontal.
- Loading state ao trocar de mes.
- Usar `getNotifications(month)` do service (task 6) em vez de fetch direto.
- Usar `getPaymentMethodsSummary(month)` e `getBudgetCompactSummary(month)` com mes do FilterContext.
</requirements>

## Subtarefas

- [ ] 7.1 Consumir `useFilter()` na Tab1 para obter `tab1.month` e `tab1.selectedCategory`.
- [ ] 7.2 Adicionar `MonthSelector` abaixo do header, conectado a `tab1.month` / `updateTab1`.
- [ ] 7.3 Substituir `getCurrentMonth()` hardcoded por `tab1.month` em todas as chamadas (loadCards, loadNotifications, BudgetSummaryCard).
- [ ] 7.4 Refatorar `loadNotifications` para usar `getNotifications(month)` do service.
- [ ] 7.5 Adicionar `CategoryFilterBar` abaixo do MonthSelector, extraindo categorias unicas das notificacoes carregadas.
- [ ] 7.6 Filtrar `notifications` localmente por `tab1.selectedCategory` antes de passar ao `PurchaseList`.
- [ ] 7.7 Recalcular `monthlyTotal` baseado nos itens filtrados (nao todos).
- [ ] 7.8 Adicionar CSS para sticky position do MonthSelector + CategoryFilterBar.
- [ ] 7.9 Escrever testes.

## Detalhes de Implementacao

Consultar `techspec.md` secoes:
- "Fluxo de dados" — sequencia de interacao.
- "Pontos de Integracao" — servicos que ja aceitam month.

**Logica de filtragem local:**
```typescript
const categories = [...new Set(notifications.map(n => n.category).filter(Boolean))];
const filtered = tab1.selectedCategory
  ? notifications.filter(n => n.category === tab1.selectedCategory)
  : notifications;
const monthlyTotal = filtered.reduce((acc, n) => acc + n.amount, 0);
```

**Re-fetch ao mudar mes:** Usar `useEffect` com dependencia em `tab1.month` para disparar reload de notifications, cards e budget summary.

## Criterios de Sucesso

- Trocar mes no MonthSelector atualiza CardStack, BudgetSummaryCard e lista de compras.
- Selecionar categoria filtra lista e recalcula total.
- "Todas" mostra todos os dados do mes.
- Loading spinner aparece ao trocar de mes.
- Estado vazio quando categoria selecionada nao tem itens.
- MonthSelector e CategoryFilterBar ficam fixos no topo ao rolar.

## Testes da Tarefa

- [ ] Teste unitario: Tab1 renderiza MonthSelector com mes do FilterContext.
- [ ] Teste unitario: Tab1 renderiza CategoryFilterBar com categorias extraidas dos dados.
- [ ] Teste unitario: filtro de categoria filtra lista e recalcula total.
- [ ] Teste unitario: selecionar "Todas" mostra todos os itens.
- [ ] Teste unitario: estado vazio exibido quando filtro nao retorna resultados.
- [ ] Teste de integracao: trocar mes dispara nova chamada ao backend com month correto.
- [ ] Teste de integracao: MonthSelector + CategoryFilterBar + PurchaseList integrados.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/pages/Tab1.tsx`
- `/controlai-frontend/src/pages/Tab1.css`
- `/controlai-frontend/src/components/MonthSelector.tsx` (task 4)
- `/controlai-frontend/src/components/CategoryFilterBar.tsx` (task 5)
- `/controlai-frontend/src/context/FilterContext.tsx` (task 3)
- `/controlai-frontend/src/services/purchaseService.ts` (task 6)
- `/controlai-frontend/src/components/CardStack.tsx`
- `/controlai-frontend/src/components/BudgetSummaryCard.tsx`
- `/controlai-frontend/src/components/PurchaseList.tsx`

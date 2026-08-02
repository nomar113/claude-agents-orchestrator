# Tarefa 9.0: Frontend - Persistencia de filtros entre tabs e botao Limpar Filtros

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Validar que a persistencia de filtros por tela funciona corretamente ao navegar entre tabs, e adicionar botao/acao "Limpar Filtros" visivel quando algum filtro estiver ativo. Garantir que ao fechar e reabrir o app, os filtros resetam.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
- `executar-qa` — QA com Playwright MCP para validar fluxo completo.
</skills>

<requirements>
- RF-4.1: Filtros persistem ao sair e retornar a uma tela na mesma sessao.
- RF-4.2: Filtros resetam ao fechar/reabrir o app.
- RF-4.3: Persistencia independente entre telas.
- RF-5.1: Acao visivel para limpar filtros quando algum filtro estiver ativo.
- RF-5.2: Limpar restaura: mes corrente, categoria "Todas", modo "Mes" (Tab2).
- O botao "Limpar Filtros" so aparece quando o estado difere do padrao.
</requirements>

## Subtarefas

- [ ] 9.1 Implementar logica `isFiltered` que compara estado atual com estado padrao (mes corrente + categoria null + mode "month").
- [ ] 9.2 Adicionar botao "Limpar Filtros" na Tab1, visivel apenas quando `isFiltered` e true.
- [ ] 9.3 Adicionar botao "Limpar Filtros" na Tab2, visivel apenas quando `isFiltered` e true.
- [ ] 9.4 Conectar botao a `resetTab1()` / `resetTab2()` do FilterContext, e disparar re-fetch dos dados.
- [ ] 9.5 Validar persistencia: navegar Tab1 → Tab2 → Tab1, filtros da Tab1 devem estar mantidos.
- [ ] 9.6 Validar independencia: filtros da Tab1 nao afetam Tab2 e vice-versa.
- [ ] 9.7 Estilizar botao "Limpar Filtros" (discreto, mas visivel).
- [ ] 9.8 Escrever testes E2E com Playwright.

## Detalhes de Implementacao

**Logica isFiltered:**
```typescript
const now = new Date();
const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
const isFiltered = tab.month !== currentMonth || tab.selectedCategory !== null || tab.mode !== 'month';
```

**Posicao do botao:** Proximo ao MonthSelector/CategoryFilterBar, como um link/texto pequeno "Limpar filtros" alinhado a direita, ou como um chip "X" ao lado dos filtros ativos.

**Ionic tabs behavior:** O Ionic mantem tabs montadas em background (`IonRouterOutlet` com `IonTabs`). O FilterContext como provider acima das tabs garante que o estado sobrevive naturalmente.

## Criterios de Sucesso

- Tab1 com filtro de mes alterado → navegar para Tab2 → voltar para Tab1 → mes alterado ainda esta selecionado.
- Tab1 com categoria "Supermercado" → Tab2 mostra "Todas" (independente).
- Botao "Limpar Filtros" aparece apenas quando algum filtro difere do padrao.
- Clicar "Limpar Filtros" restaura mes corrente, categoria "Todas" e recarrega dados.
- Ao abrir o app, filtros estao no estado padrao (sem persistencia entre sessoes).

## Testes da Tarefa

- [ ] Teste E2E: Tab1 → alterar mes → ir para Tab2 → voltar Tab1 → mes mantido.
- [ ] Teste E2E: Tab1 → selecionar categoria → ir para Tab2 → Tab2 mostra "Todas".
- [ ] Teste E2E: Tab1 → alterar filtro → botao "Limpar" visivel → clicar → dados resetam.
- [ ] Teste E2E: Tab2 → modo periodo → selecionar datas → limpar → volta para modo mes corrente.
- [ ] Teste unitario: `isFiltered` retorna false no estado padrao.
- [ ] Teste unitario: `isFiltered` retorna true quando mes difere do corrente.
- [ ] Teste unitario: `isFiltered` retorna true quando categoria nao e null.
- [ ] Teste unitario: botao "Limpar Filtros" nao renderiza quando `isFiltered` e false.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/pages/Tab1.tsx`
- `/controlai-frontend/src/pages/Tab2.tsx`
- `/controlai-frontend/src/context/FilterContext.tsx` (task 3)
- `/controlai-frontend/src/App.tsx` (estrutura de tabs)

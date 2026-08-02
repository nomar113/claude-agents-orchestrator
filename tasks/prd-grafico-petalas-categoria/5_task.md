# Tarefa 5.0: `ByCategoryPage` — rota, cabecalho, resumo, lista, navegacao de meses e estados vazios

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a pagina `src/pages/ByCategoryPage.tsx` na rota `/by-category?month=YYYY-MM` (default: mes corrente). A pagina orquestra: leitura do query param, `getBudgetSummary(month)`, cabecalho com titulo/mes/voltar, card de resumo (total gasto, nº de categorias, badge "N acima do limite"), `CategoryConsumptionList`, navegacao de meses via `MonthSelector` com `maxMonth` e estados vazios. Entrega funcional sem o grafico — o bloco de petalas entra na Tarefa 7.0. Depende das Tarefas 3.0 e 4.0.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` / `frontend-design` — `IonPage`, `IonBackButton`, dark theme, feedback imediato de carregamento na troca de mes.
- `vercel-react-best-practices` — derivacoes do summary via `useMemo`; busca disparada por mudanca de `month` via `useEffect` com dependencias corretas.
- `clean-code` — regras de calculo do resumo nomeadas e colocalizadas.
</skills>

<requirements>
- PRD 1.1: cabecalho com titulo "Por categoria", mes/ano selecionado (ex.: "JUNHO · 2026") e botao de voltar.
- PRD 1.2–1.4: card de resumo com total gasto (Σ `actual` dos itens EXPENSE), quantidade de categorias com gasto (`count(actual > 0)`) e badge "N acima do limite" (`count(actual > expected)`, exibido quando N > 0); tudo recalculado ao trocar de mes.
- PRD 3.5: lista com exatamente as mesmas categorias do grafico (`EXPENSE && expected > 0 && actual > 0`) — filtro aplicado na pagina.
- PRD 5.1–5.4: navegacao de meses com `maxMonth` = mes corrente; mes sempre visivel no cabecalho; recalculo completo na troca.
- PRD 7.1: estado vazio (sem gastos em categorias com orcamento ou mes sem orcamento) no lugar do grafico/lista, mantendo cabecalho e navegacao de meses. Meses sem orcamento retornam erro do `GET /budgets` — distinguir por status e tratar como estado vazio, nao como erro de rede.
- Techspec: query param `?month=` lido via `useLocation`; rota `<Route exact path="/by-category">` em `App.tsx`.
</requirements>

## Subtarefas

- [x] 5.1 Criar `ByCategoryPage.tsx` + `.css` com leitura de `?month=` (default mes corrente) e registro da rota em `App.tsx`.
- [x] 5.2 Implementar cabecalho (titulo, mes/ano, `IonBackButton`) e integracao do `MonthSelector` com `maxMonth`.
- [x] 5.3 Implementar card de resumo (total, nº categorias, badge "N acima do limite") derivado do `BudgetSummary`.
- [x] 5.4 Integrar `CategoryConsumptionList` com itens filtrados e handler `onCategoryClick` (abre o sheet na Tarefa 6.0; por ora, estado local preparado).
- [x] 5.5 Implementar estados vazios (7.1) e tratamento de erro de mes sem orcamento vs. erro de rede (`console.warn` defensivo).
- [x] 5.6 Testes de unidade (Vitest, mock de `budgetService`): resumo correto; badge so quando ha estouro; recalculo ao trocar mes; bloqueio alem do mes corrente; leitura de `?month=` da URL; estado vazio sem orcamento e sem gastos.

## Detalhes de Implementacao

Ver techspec.md, secoes "Visao Geral dos Componentes", "Fluxo de dados", "Modelos de Dados" e "Riscos Conhecidos" (meses sem orcamento). Nota da techspec: o total da tela (Σ categorias com orcamento) pode diferir do `totalActual` da Tab1, que inclui compras sem categoria — comportamento esperado e documentado.

## Criterios de Sucesso

- Rota `/by-category` acessivel, com deep-link por `?month=` sobrevivendo a refresh.
- Numeros do resumo batem com o `BudgetSummary` (mesma fonte do widget e do Orcamento Mensal).
- Troca de mes atualiza resumo e lista com feedback de carregamento.
- Estados vazios corretos mantendo cabecalho e navegacao.
- Testes da pagina verdes.

## Testes da Tarefa

- [x] Testes de unidade
- [x] Testes de integracao (pagina + `MonthSelector` + `CategoryConsumptionList` renderizados juntos)
- [ ] Testes E2E (nao aplicavel nesta tarefa)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/ByCategoryPage.tsx|.css|.test.tsx` (novos)
- `controlai-frontend/src/App.tsx` (nova rota)
- `controlai-frontend/src/components/MonthSelector.tsx` (Tarefa 3.0)
- `controlai-frontend/src/components/CategoryConsumptionList.tsx` (Tarefa 4.0)
- `controlai-frontend/src/services/budgetService.ts`, `src/types/budget.ts` (consultados)

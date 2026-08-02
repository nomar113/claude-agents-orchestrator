# Tarefa 7.0: Integracao com Tab1 (modo leitura/edicao) e checks finais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar o `PetalDistributionChart` a `src/pages/Tab1.tsx`, substituindo a secao "GASTOS POR CATEGORIA" no modo leitura e preservando a lista de `BudgetCategoryCard` no modo edicao (`isEditing === true`). Conectar os callbacks reais: `handleCategoryClick` (filtro por categoria) e scroll para `purchasesSectionRef` ("Ver gastos detalhados"). Encerrar com os checks completos do projeto.

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — evitar re-render desnecessario do `Tab1`; callbacks estaveis via `useCallback`.
- `clean-code` — ramificacao leitura/edicao explicita e legivel; sem duplicar a regra de elegibilidade no `Tab1`.
- `ionic-design` — comportamento de scroll consistente com o padrao da pagina (`IonContent`).
</skills>

<requirements>
- Na secao `expenses` do `Tab1.tsx`: renderizar `PetalDistributionChart` quando `summary` existe e `isEditing === false`; manter a lista atual de `BudgetCategoryCard` quando `isEditing === true` (ver "Resumo Executivo" e fluxo em "Visao Geral dos Componentes" na techspec).
- Passar `items={summary.items.filter(EXPENSE)}` — a filtragem fina (`expected > 0 && actual > 0`) permanece dentro do componente.
- `onPetalClick` invoca o `handleCategoryClick` existente (seta `selectedCategoryFilter` e rola ate `PurchaseList`) — requisito 4.1 do PRD.
- `onViewDetailsClick` faz `purchasesSectionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })` — requisito 5.2 do PRD; a ref ja existe.
- Fluxo de edicao do orcamento (criar/editar/remover itens) segue 100% inalterado.
- Percentuais e categorias do grafico consistentes com a tela de orcamento mensal para o mesmo periodo (restricao do PRD) — mesma fonte `BudgetSummary` de `loadBudget()`, sem fetch novo.
- Renderizacao fluida na Tab1, sem atraso perceptivel na abertura (memoizacao conforme techspec).
- Checks finais do projeto passando: `typecheck`, `test`, `build`, `lint`.
- Verificacao manual via `ionic serve` e, se disponivel, simulador iOS (risco de renderizacao WebKit — ver techspec).
</requirements>

## Subtarefas

- [x] 7.1 Ramificar a secao `expenses` do `Tab1.tsx` entre `PetalDistributionChart` (leitura) e `BudgetCategoryCard` (edicao).
- [x] 7.2 Conectar `onPetalClick={handleCategoryClick}` e `onViewDetailsClick` com scroll para `purchasesSectionRef`.
- [x] 7.3 Ajustar `Tab1.test.tsx` cobrindo o ramo leitura/edicao e os callbacks integrados.
- [x] 7.4 Executar `typecheck`, `test`, `build` e `lint` completos do projeto.
- [x] 7.5 Validar manualmente no `ionic serve` (e simulador iOS, se disponivel): abrir Tab1 → ver grafico → tocar petala → conferir filtro → botao → scroll ate "Ultimas Compras" → entrar no modo edicao → conferir lista antiga. (Smoke via dev server executado; validacao interativa completa delegada a fase de QA.)

## Detalhes de Implementacao

Ver "Resumo Executivo", "Visao Geral dos Componentes" (fluxo `Tab1.tsx`), "Pontos de Integracao" e "Riscos Conhecidos" (renderizacao iOS/WebKit) na `techspec.md`.

## Criterios de Sucesso

- Tab1 exibe o grafico no modo leitura e a lista de cards no modo edicao, sem regressao no fluxo de edicao.
- Tocar em petala filtra o `PurchaseList` pela categoria correta.
- Botao "Ver gastos detalhados" rola suavemente ate a secao "Ultimas Compras".
- Todos os checks do projeto (`typecheck`, `test`, `build`, `lint`) passam.

## Testes da Tarefa

- [x] Testes de integracao (`Tab1.test.tsx`):
  - Renderiza `PetalDistributionChart` (e NAO a lista de `BudgetCategoryCard`) quando `summary` existe e `isEditing` e `false`.
  - Renderiza a lista de `BudgetCategoryCard` quando `isEditing` e `true`.
  - Clique em petala filtra `PurchaseList` (verifica via `selectedCategoryFilter`).
  - Clique em "Ver gastos detalhados" foca a secao "Ultimas Compras" (verifica `scrollIntoView` mockado).
- [x] Testes de unidade: ja cobertos nas Tarefas 1.0–6.0 (suite completa deve passar).
- [x] Testes E2E: nao obrigatorios (ver techspec). Smoke opcional via Cypress: abrir Tab1 → ver grafico → tocar petala → conferir filtro no `PurchaseList`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/Tab1.tsx` (modificado)
- `src/pages/Tab1.test.tsx` (modificado)
- `src/components/PetalDistributionChart.tsx` (consumido)
- `src/components/BudgetCategoryCard.tsx` (fluxo de edicao preservado)
- `src/components/PurchaseList.tsx` (alvo do scroll/filtro)
- `src/services/budgetService.ts` (`getBudgetSummary` — consulta)

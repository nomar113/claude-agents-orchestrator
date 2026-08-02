# Review: Task 7 - Integracao com Tab1 (modo leitura/edicao) e checks finais

**Revisor**: AI Code Reviewer
**Data**: 2026-07-19
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task integra o `PetalDistributionChart` a `Tab1.tsx` exatamente conforme o fluxo prescrito na techspec: a secao "GASTOS POR CATEGORIA" agora ramifica por `isEditing` — no modo leitura renderiza o grafico com `items={expenseItems}`, `onPetalClick={handleCategoryClick}` e `onViewDetailsClick={handleViewDetailsClick}`; no modo edicao preserva a lista de `BudgetCategoryCard`, o botao "Adicionar Gasto" e a linha "Total Gastos" sem nenhuma alteracao de props ou handlers. Nao ha fetch novo — o grafico consome o mesmo `BudgetSummary` de `loadBudget()`, cumprindo a restricao de consistencia do PRD. `expenseItems` ganhou `useMemo` (com comentario justificando a identidade estavel para a memoizacao interna do grafico) e os dois callbacks foram estabilizados com `useCallback`, como pedido pelas skills `vercel-react-best-practices` e pela propria task. A filtragem fina (`expected > 0 && actual > 0`) permanece dentro do componente — nenhuma regra de elegibilidade vazou para a `Tab1`.

Os 5 testes de integracao novos em `Tab1.test.tsx` sao verdadeiros testes de integracao: `PetalDistributionChart` e `BudgetCategoryCard` NAO sao mockados, e o clique na petala e verificado ponta-a-ponta ate o refetch de `getNotifications` com `categoryId = 10` — mais forte do que apenas inspecionar estado. A task tambem aproveitou para limpar debito: mocks de `IonAlert`/`IonSelect`/`IonSelectOption` deixaram de usar `any` (que este checklist classifica como critico) e quatro simbolos mortos foram removidos de `Tab1.tsx`. A recomendacao 1 da review da Task 6 (`pointer-events: none` no `__center-disc`) foi aplicada.

Verificacoes revalidadas de forma independente nesta review: 399/399 testes na suite completa (37 arquivos), `tsc --noEmit` limpo, ESLint com 0 erros nos arquivos da task (resta 1 warning pre-existente de `exhaustive-deps` em `Tab1.tsx:126` sobre `updateTab1`, padrao ja usado na pagina) e `npm run build` concluido com sucesso.

Foram encontrados apenas problemas minor, nenhum bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/pages/Tab1.tsx` | OK | 2 minor |
| `src/pages/Tab1.test.tsx` | OK | 1 minor |
| `src/components/PetalDistributionChart.tsx` (consumido, nao alterado) | OK | 0 |
| `7_task.md` (checklist) | OK | 1 minor (ver minor #4) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`Element.prototype.scrollIntoView` mutado globalmente sem restauracao** — `Tab1.test.tsx:324-325`. O teste do botao "Ver gastos detalhados" atribui o mock diretamente ao prototype (`Element.prototype.scrollIntoView = scrollIntoViewMock`) e nunca restaura. Como e o ultimo teste do arquivo e cada arquivo roda em worker isolado no Vitest, nao ha vazamento pratico hoje — mas o teste fica dependente da posicao no arquivo: qualquer teste adicionado depois herdara o mock silenciosamente. Correcao simples e local:

   ```tsx
   it('clicking "Ver gastos detalhados" scrolls to the purchases section', async () => {
     // jsdom does not implement scrollIntoView.
     const scrollIntoViewMock = vi.fn();
     const original = Element.prototype.scrollIntoView;
     Element.prototype.scrollIntoView = scrollIntoViewMock;
     try {
       // ... render + assertions
     } finally {
       Element.prototype.scrollIntoView = original;
     }
   });
   ```

2. **Identidade de `handleCategoryClick` muda a cada alternancia de filtro** — `Tab1.tsx:391-398`. O `useCallback` depende de `selectedCategoryFilter` (lido para decidir `isDeselecting`), entao cada toque em petala gera um novo callback e re-renderiza o `PetalDistributionChart`. O custo real e baixo — a geometria interna do grafico e memoizada por `items`, que segue estavel — portanto nao ha impacto perceptivel. Registrado apenas como limitacao conhecida: a alternativa (mover a leitura de `prev` para dentro do functional updater) exigiria efeito colateral (`scrollToBottom`) dentro do updater, que deve ser puro; a implementacao atual e o trade-off correto.

3. **Contador do header pode divergir do numero de petalas visiveis** — `Tab1.tsx:529`. O header exibe `{expenseItems.length} itens` (todos os itens EXPENSE do orcamento), enquanto o grafico so desenha petalas para itens com `expected > 0 && actual > 0`. Um orcamento com 6 categorias das quais 2 sem gasto no mes mostrara "6 itens" sobre uma flor de 4 petalas. E comportamento pre-existente do header e a filtragem interna e exatamente o que a techspec prescreve ("sem vazar a regra para o Tab1"), entao nao e bug — mas se a divergencia confundir na pratica, o rotulo pode passar a se referir explicitamente ao orcamento (ex.: "6 categorias no orcamento") em iteracao futura.

4. **Subtarefa 7.5 com validacao interativa delegada a fase de QA** — `7_task.md:35`. O smoke via dev server foi executado, mas a validacao manual completa (toque em petala filtrando `PurchaseList`, Tab + Enter/Space com foco visivel, leitor de tela, e o risco de renderizacao WebKit no simulador iOS apontado na techspec) foi explicitamente delegada ao QA. A pendencia e declarada no proprio checklist — postura correta — e acumula as pendencias homologas das Tasks 5 e 6. Registrado para garantir que a fase de QA (`executar-qa`) cubra esses fluxos de fato.

## Destaques Positivos

- **Ramificacao leitura/edicao literal a techspec** (`Tab1.tsx:531-563`): o ternario `isEditing ? (cards + adicionar + total) : (chart)` reproduz o fluxo do diagrama da techspec; o bloco de edicao foi movido sem alterar uma unica prop ou handler — o fluxo de criar/editar/remover itens segue 100% intacto, como exige o requisito da task.
- **Reuso maximo, estado novo zero**: `onPetalClick` reusa `handleCategoryClick` (requisito 4.1 do PRD) e `onViewDetailsClick` reusa a `purchasesSectionRef` ja existente com `scrollIntoView({ behavior: 'smooth', block: 'start' })` (requisito 5.2) — nenhum estado ou ref novo foi introduzido na pagina.
- **Consistencia de dados garantida por construcao**: o grafico recebe os itens do mesmo `BudgetSummary` de `loadBudget()`, sem fetch paralelo — os percentuais coincidem com a tela de orcamento por compartilharem a fonte, nao por coincidencia (restricao do PRD atendida na raiz).
- **`useMemo` de `expenseItems` com comentario de justificativa** (`Tab1.tsx:383-388`): explica que a identidade estavel existe para que a geometria memoizada do grafico so seja recalculada quando o summary muda — exatamente o requisito de renderizacao fluida da task.
- **Guard `if (isEditing) return` preservado** em `handleCategoryClick` (`Tab1.tsx:392`), mantendo o comportamento defensivo original agora que o callback e compartilhado entre cards e petalas.
- **Testes de integracao reais**: `PetalDistributionChart` e `BudgetCategoryCard` nao sao mockados no `Tab1.test.tsx` — os testes exercitam o DOM real do grafico (`data-testid="petal"`, `aria-label` do PRD, botao "Ver gastos detalhados") montado dentro da pagina real.
- **Clique em petala verificado ponta-a-ponta** (`Tab1.test.tsx:307-320`): em vez de inspecionar `selectedCategoryFilter`, o teste assevera que `getNotifications` foi rechamado com `categoryId = 10` — cobre o caminho completo petala → filtro → refetch da lista de compras.
- **Relogio fixado com precisao cirurgica** (`Tab1.test.tsx:145-148`): `vi.useFakeTimers({ toFake: ['Date'] })` pina apenas `Date` (comentario explica que `waitFor` continua em timers reais), eliminando flakiness dos asserts de `'2026-05'` na virada de mes sem quebrar a espera assincrona; `afterEach` restaura os timers.
- **Teste bonus alem do checklist**: "restores the chart after cancelling edit mode" cobre o ciclo completo Editar → Cancelar → grafico de volta, que nao estava listado na task.
- **Limpeza de debito junto com a task**: mocks Ionic tipados sem `any` (`Tab1.test.tsx:19-21`) e remocao de quatro simbolos mortos (`closeCircleOutline`, `tab1`, `preserveScrollRef`, `selectedCategoryName`) — o ESLint dos arquivos da task fechou em 0 erros.
- **Recomendacao 1 da review da Task 6 aplicada**: `pointer-events: none` no `__center-disc` (`PetalDistributionChart.css:53-55`), com comentario explicando o porque.
- Comentarios em ingles, seguindo a convencao dos repos controlai.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (ramificacao explicita, nomes claros, callbacks nomeados com verbo, sem numeros magicos novos) |
| TypeScript/Node.js | OK (`tsc --noEmit` limpo; `any` dos mocks de teste substituido por tipos explicitos) |
| REST/HTTP | N/A (nenhum endpoint novo — reuso de `getBudgetSummary`) |
| Logging | OK (nenhum log novo) |
| React | OK (`useMemo` para derivacao, `useCallback` nos dois callbacks com deps corretas, ref reutilizada; 1 warning pre-existente de `exhaustive-deps` fora do escopo da task) |
| Testes | OK (399/399 na suite completa; 5 testes de integracao novos cobrindo os 4 casos do checklist + 1 bonus) |

## Recomendacoes

1. Restaurar `Element.prototype.scrollIntoView` ao final do teste de scroll (minor #1) — uma linha de `finally`, pode entrar em qualquer proxima task que toque o arquivo.
2. Na fase de QA (`executar-qa`), executar a validacao interativa pendente da subtarefa 7.5 (minor #4): toque em petala e legenda filtrando o `PurchaseList`, deselecao ao tocar de novo, Tab + Enter/Space com foco visivel, leitor de tela anunciando categoria/percentual/estouro, scroll suave do botao "Ver gastos detalhados" e renderizacao no simulador iOS (risco WebKit da techspec).
3. Se a divergencia entre "N itens" do header e o numero de petalas gerar confusao real (minor #3), ajustar o rotulo do contador em iteracao futura — sem mover a regra de elegibilidade para a `Tab1`.
4. Manter as recomendacoes em aberto das reviews anteriores (legenda como `<button>` dentro do `<li>`, clamp lateral dos overlays) para um refactor futuro do componente.

## Veredito

**APROVADO COM OBSERVACOES.** Todos os requisitos da task foram implementados e testados: o grafico substitui a secao "GASTOS POR CATEGORIA" no modo leitura, a lista de `BudgetCategoryCard` permanece intacta no modo edicao, tocar em petala filtra o `PurchaseList` pela categoria correta (verificado ate o refetch), o botao "Ver gastos detalhados" rola ate "Ultimas Compras", e o grafico consome a mesma fonte `BudgetSummary` sem fetch novo. Os quatro checks do projeto (`typecheck`, `test`, `build`, `lint` nos arquivos da task) passam e foram revalidados de forma independente nesta review. Os quatro apontamentos sao minor e nao bloqueiam a conclusao da feature. Proximos passos: fase de review de branch (`executar-review`) e QA (`executar-qa`), garantindo que o QA execute a validacao interativa pendente (recomendacao 2).

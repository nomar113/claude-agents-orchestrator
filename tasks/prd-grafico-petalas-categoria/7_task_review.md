# Review: Task 7.0 - Integracao do `PetalDistributionChart` na `ByCategoryPage`

**Revisor**: AI Code Reviewer
**Data**: 2026-07-19
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task integra o `PetalDistributionChart` (feature `prd-grafico-petalas-distribuicao`) na `ByCategoryPage`, alimentado pelo mesmo array filtrado da lista (`EXPENSE && expected > 0 && actual > 0`), com petala e legenda abrindo o `CategoryDetailSheet` pelo mesmo handler das linhas da lista (`openCategory`), e o estado vazio ocultando o bloco do grafico (PRD 7.1). O contrato de props do componente (`items`, `onPetalClick`, `onViewDetailsClick`) foi respeitado sem alteracoes — o componente permanece puro e reutilizavel entre Tab1 e a tela, exatamente como a techspec exige para evitar divergencia visual.

Implementacao enxuta e correta: o bloco `.bcp-chart` entra entre o card de resumo e a lista dentro do mesmo gate `showContent`, garantindo por construcao que grafico e lista nunca divergem em categorias ou visibilidade. Os 6 novos testes cobrem todos os cenarios da subtarefa 7.3. Verificacoes: suite completa 405/405 verde, `npm run build` (tsc + vite) ok, ESLint sem issues nos arquivos tocados.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| src/pages/ByCategoryPage.tsx | OK | 0 |
| src/pages/ByCategoryPage.css | OK | 0 |
| src/pages/ByCategoryPage.test.tsx | Problemas | 2 (minor) |
| src/components/PetalDistributionChart.tsx (consultado, nao alterado) | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`ByCategoryPage.test.tsx:428` — stub global de `scrollIntoView` sem restauracao.** O teste atribui `Element.prototype.scrollIntoView = scrollIntoView` diretamente no prototype. `vi.restoreAllMocks()` no `afterEach` nao desfaz atribuicao direta (so mocks criados via `vi.spyOn`), entao o stub vaza para os testes seguintes do mesmo arquivo. Hoje e inocuo (o jsdom nem implementa `scrollIntoView` e nenhum teste posterior depende dele), mas e higiene fragil. Correcao sugerida:

   ```ts
   const scrollIntoView = vi.fn();
   const original = Element.prototype.scrollIntoView;
   Element.prototype.scrollIntoView = scrollIntoView;
   try {
     // ... assertions
   } finally {
     Element.prototype.scrollIntoView = original;
   }
   ```

2. **`ByCategoryPage.test.tsx:435-436` — o teste de scroll nao verifica o elemento alvo.** Como o stub esta no prototype, qualquer elemento satisfaria o assert. Vale conferir que o scroll ocorreu na lista:

   ```ts
   expect(scrollIntoView.mock.instances[0]).toBe(
     document.querySelector('.bcp-list'),
   );
   ```

3. **`ByCategoryPage.tsx:131-133` — `scrollToList` e uma decisao de design nao documentada na techspec.** A techspec define o `onViewDetailsClick` apenas para a Tab1 (redirect para `/by-category`); na propria pagina, o botao "Ver gastos detalhados" (obrigatorio no contrato do componente) rola ate a lista. A decisao e sensata — na tela, a lista abaixo E o detalhamento, e redirecionar seria circular — e o comentario no codigo explica o racional. Sugestao apenas de registrar a decisao na techspec ou no PRD para futuras features que integrem o chart.

## Destaques Positivos

- **Contrato do `PetalDistributionChart` intocado** — o componente segue puro por `items`, exatamente o risco que a techspec pedia para mitigar ("Divergencia visual Tab1 vs. tela").
- **Consistencia por construcao**: `items={listItems}` usa o mesmo `useMemo` da lista; o filtro interno do chart (`filterEligible`) e idempotente sobre ele, entao categorias, cores (indice estavel) e visibilidade sao identicos entre petala, legenda e linha sem sincronizacao manual.
- **Um unico handler (`openCategory`) para os tres caminhos** (petala, legenda, linha), com `useCallback` e dependencias corretas — cobre PRD 2.3 e 3.4 sem duplicacao.
- **Estado vazio correto**: o bloco do grafico esta dentro do gate `showContent`, e o teste `hides the chart in the empty state` confirma que nem o titulo "DISTRIBUIÇÃO" renderiza (PRD 7.1).
- **Testes cobrem integralmente a subtarefa 7.3**: itens filtrados no chart, titulo/indicador/legenda (PRD 2.2), petala → sheet, legenda → sheet (com asserts nos valores do summary no sheet — valida a categoria correta), troca de mes atualiza o chart, estado vazio, e scroll do botao de detalhes.
- **Ajuste inteligente do teste pre-existente**: a troca de `getByText` por testids `ccl-row-*` resolve a ambiguidade nome-na-legenda vs. nome-na-lista sem enfraquecer o assert.
- **CSS minimo e intencional**: `scroll-margin-top` na `.bcp-list` para o scroll suave, e comentario explicando por que o chart nao tem card de fundo (continuidade visual com a Tab1).
- Comentarios em ingles, seguindo a convencao do repositorio.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (funcoes nomeadas com verbo, sem magic numbers novos, early returns; comentarios em ingles explicam "porques" — padrao ja aceito no repo) |
| TypeScript/Node.js | OK (`tsc` limpo, sem `any`, tipos derivados de `BudgetItemSummary`) |
| React | OK (`useMemo`/`useCallback` com dependencias corretas, guard `cancelled` no efeito, sheet resetado na troca de mes) |
| Testes | OK (405/405 verdes; 2 observacoes minor de higiene no teste de scroll) |

## Recomendacoes

1. (Minor 1 e 2) Trocar a atribuicao direta de `Element.prototype.scrollIntoView` por stub com restauracao e assertar o elemento alvo do scroll — pode ser feito junto com a Task 8.0.
2. (Minor 3) Registrar na techspec a decisao "botao de detalhes na propria pagina rola ate a lista".
3. Nenhuma acao bloqueante.

## Veredito

**APROVADO COM OBSERVACOES.** A integracao cumpre todos os requisitos da task (PRD 2.1, 2.2, 2.3, 3.5 e 7.1), preserva o contrato do componente compartilhado e chega com cobertura de testes completa e verificacoes verdes (405/405, build, lint). Os tres apontamentos sao minor, nao bloqueantes, e podem ser absorvidos na proxima task. Pode seguir para a Task 8.0 (pontos de entrada Tab1/BudgetPage).

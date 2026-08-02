# Review: Task 4.0 - `CategoryConsumptionList` — lista de categorias com ordenacao

**Revisor**: AI Code Reviewer
**Data**: 2026-07-04
**Arquivo da task**: 4_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task cria o componente puro `src/components/CategoryConsumptionList.tsx` (projeto `controlai-frontend`), que renderiza a lista de categorias da futura `ByCategoryPage`: por linha, indicador de cor, nome, "R$ gasto · de R$ limite", percentual, barra de progresso proporcional e badge "Estourou" quando `actual > expected`, com seletor de ordenacao "% do limite" (padrao, desc) | "Valor gasto" (desc). A implementacao segue fielmente o contrato da techspec (`CategoryConsumptionListProps`, ordenacao interna `'percent' | 'amount'`) e os calculos exigidos (`Math.round((actual / expected) * 100)`, formatacao via `utils/currency`).

A task tambem criou `src/utils/categoryColors.ts` **antecipando o contrato da techspec da feature de distribuicao** (`getCategoryColor(categoryId, index)` deterministico, paleta de 12 cores, `getOverflowColor()` → `#FF6B6B`). A decisao e correta e bem executada: como a cor e chaveada por `categoryId` (e nao pelo indice), a lista — que reordena os itens — exibira exatamente a mesma cor que a futura petala/legenda (que recebe os itens na ordem original), atendendo o PRD 3.1 por construcao.

Todas as verificacoes passaram nesta review (testes da task 15/15, typecheck, lint, build implicito via `tsc`). Restam apenas observacoes minor, nenhuma bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/CategoryConsumptionList.tsx` (novo) | Problemas | 2 minor |
| `src/components/CategoryConsumptionList.css` (novo) | OK | 0 |
| `src/components/CategoryConsumptionList.test.tsx` (novo) | Problemas | 1 minor (comentario) |
| `src/utils/categoryColors.ts` (novo) | Problemas | 2 minor |
| `src/utils/categoryColors.test.ts` (novo) | OK | 0 |

Observacao de escopo: o working tree tambem contem alteracoes em `src/components/MonthSelector.tsx|.css|.test.tsx` e `src/services/purchaseService.ts|.test.ts`, pertencentes as tasks 2.0 e 3.0 (ja revisadas). Nao fazem parte do escopo desta review.

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **Comentarios em portugues — recorrencia de feedback das reviews 2.0/3.0.** O padrao do projeto exige codigo (incluindo comentarios) em ingles, e o restante do codebase segue ingles (o proprio `MonthSelector.tsx` foi corrigido apos a review 3.0). Ocorrencias novas: `CategoryConsumptionList.tsx:8`, `categoryColors.ts:6-7` e `:23-24`, `CategoryConsumptionList.test.tsx:22`. Correcao sugerida:

   ```ts
   // CategoryConsumptionList.tsx:8
   items: BudgetItemSummary[]; // pre-filtered (EXPENSE, expected > 0, actual > 0)

   // categoryColors.ts:6-7
   // Fixed palette for the dark theme (#0D1028–#0E1832). #FF6B6B is reserved
   // for the overflow state and is not part of the palette.

   // categoryColors.ts:23-24
   // Keyed by categoryId (stable across months and reorderings); index is
   // only a fallback for invalid ids, keeping the function total.

   // CategoryConsumptionList.test.tsx:22
   // jsdom normalizes hex colors to rgb() in the style attribute
   ```

2. **`CategoryConsumptionList.tsx:69` e `:80` — `getCategoryColor` chamado duas vezes por linha.** A linha 69 ja calcula a cor (usada na barra), mas a linha 80 recalcula para o dot. Alem do custo duplicado (trivial), a leitura fica ambigua — nao e obvio que dot e barra divergem de proposito quando ha estouro. Correcao sugerida, que tambem nomeia a intencao:

   ```tsx
   const overLimit = isOverLimit(item);
   const categoryColor = getCategoryColor(item.categoryId, index);
   const barColor = overLimit ? getOverflowColor() : categoryColor;
   // dot: categoryColor.base (identity, matches petal/legend — PRD 3.1)
   // bar: barColor.base (alert style when over — PRD 3.2)
   ```

3. **`categoryColors.ts:27` — colisao de paleta para `categoryId`s congruentes modulo 12.** Duas categorias com ids `2` e `14` no mesmo mes recebem a mesma cor. E uma limitacao aceita pelo contrato da techspec de distribuicao (paleta fixa de 12 cores, funcao deterministica por id) e nao deve ser "corrigida" agora — deduplicar pelo conjunto visivel quebraria a consistencia de cor entre lista, petala e legenda. Fica registrado como limitacao conhecida para o caso de o app ultrapassar ~12 categorias ativas com ids esparsos.

4. **`CategoryConsumptionList.tsx:19-21` — sem guarda para `expected <= 0` (defensivo, opcional).** `consumptionRatio` retornaria `Infinity` e o `aria-label` exibiria "Infinity% do limite". O contrato da techspec diz explicitamente que os itens chegam pre-filtrados (`expected > 0 && actual > 0`, responsabilidade da pagina — Tarefa 5.0), entao nao e bug; mas o componente-irmao `BudgetCategoryCard.tsx` adota guarda defensiva (`if (expected <= 0) return 0`). Vale alinhar quando a Tarefa 5.0 integrar os dois.

## Destaques Positivos

- **Contrato da techspec seguido a risca**: props `{ items, onCategoryClick }`, ordenacao interna `'percent'` (default) | `'amount'`, percentual `Math.round((actual / expected) * 100)` identico a distribuicao, formatacao via `fmtBRL` — e o componente nao filtra nada (teste dedicado "renders exactly the items received").
- **Decisao de antecipar `categoryColors.ts` foi certeira**: chavear a cor por `categoryId` (indice apenas como fallback total para ids invalidos) e o unico esquema que garante "mesma cor da petala/legenda" (PRD 3.1) dado que a lista reordena os itens e o grafico nao. O contrato da techspec de distribuicao foi respeitado integralmente (assinaturas, 12 cores distintas, `#FF6B6B` reservado ao estouro e fora da paleta), com testes proprios cobrindo determinismo, ciclo da paleta e fallback.
- **Acessibilidade acima da media** (PRD): `aria-label` por linha no formato exato do PRD (verificado com valor quebrado `896.12` → "112% do limite, acima do limite"); estouro comunicado por badge textual + classe, nunca so por cor; seletor com `role="group"`, `aria-label="Ordenar por"` e `aria-pressed`; dot decorativo com `aria-hidden`; linhas como `<button>` nativo (foco e teclado de graca).
- **Leitura correta e sutil do PRD 3.1 + 3.2**: o dot mantem a cor de identidade da categoria mesmo em estouro (e o elo com a petala/legenda), enquanto barra e percentual mudam para o estilo de alerta — e a barra e capada em 100% (`Math.min`) para permanecer proporcional.
- **`vercel-react-best-practices`**: ordenacao derivada via `useMemo` com dependencias corretas; sort imutavel (`[...items].sort`); zero estado redundante. Detalhe fino: a ordenacao por percentual usa o `ratio` nao arredondado, evitando empates artificiais entre percentuais exibidos iguais.
- **`clean-code`**: regras de calculo nomeadas e colocalizadas (`consumptionRatio`, `consumptionPercent`, `isOverLimit`, `progressPct`, `rowAriaLabel`, `sortItems`), todas funcoes puras de uma acao; componente com responsabilidade unica.
- **Ionic/mobile**: tap targets ≥ 44px (botoes de ordenacao `min-height: 44px`, linhas `min-height: 64px`); dark theme com os mesmos tokens do app (`#FF6B6B`, `#4F8BFF`, alphas de branco); `-webkit-tap-highlight-color` tratado; nomes de classe `ccl-*` seguem a convencao abreviada existente (`cat-card-*`, `category-bs-*`).
- **Testes cobrem 100% da subtarefa 4.4** e alem: linha completa, badge so quando `actual > expected` (incluindo o caso limite `actual === expected` → sem badge), ordenacao padrao e alternancia com estado ativo (visual + `aria-pressed`), `aria-label` exato, callback com `categoryId`, arredondamento, cor compartilhada com a paleta e ausencia de filtro interno.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas (minor: comentarios em portugues — recorrencia) |
| TypeScript/Node.js | OK (`npx tsc --noEmit` sem erros; sem `any`) |
| React | OK (componente funcional puro, `useMemo`, props tipadas, keys estaveis por `categoryId`) |
| Ionic/Mobile UI | OK (tap targets ≥ 44px, dark theme, contraste dos tons de alerta) |
| Testes | OK (15/15 da task; 2 falhas da suite sao pre-existentes e nao relacionadas) |
| Lint | OK (`npx eslint` sem issues nos 4 arquivos novos) |

## Verificacoes Executadas pelo Revisor

- `npx vitest run src/components/CategoryConsumptionList.test.tsx src/utils/categoryColors.test.ts` → **15 passed, 0 failed**.
- `npx vitest run` (suite completa) → **310 passed, 2 failed** (312 total). As 2 falhas sao em `Tab1.test.tsx` ("loads data on initial mount" e "silent refresh via useIonViewWillEnter does not show loading skeleton") — **as mesmas ja documentadas como pre-existentes nas reviews 2.0 e 3.0** (mock do filter store fixa `'2026-05'` sem `vi.setSystemTime`; mes corrente e `2026-07`). Confirmado que `Tab1.tsx`/`Tab1.test.tsx` nao referenciam nenhum arquivo desta task.
- `npx tsc --noEmit` → **sem erros**.
- `npx eslint` nos 4 arquivos novos → **sem issues**.

## Recomendacoes

1. Traduzir para ingles os comentarios novos (Minor 1) — terceira review consecutiva com este apontamento; vale um ajuste unico agora para encerrar o padrao.
2. Refatorar o calculo de cor da linha para uma unica chamada de `getCategoryColor` com nomes que expressem a divergencia intencional dot vs. barra (Minor 2) — pode ser feito junto com a Tarefa 5.0.
3. Ao implementar a feature de distribuicao (`PetalDistributionChart`), **reutilizar este `categoryColors.ts` sem recria-lo** — o arquivo ja cumpre o contrato e os testes daquela techspec; recriar geraria conflito.
4. (Reiterada das reviews 2.0/3.0, fora do escopo) Corrigir os 2 testes de `Tab1.test.tsx` dependentes do mes corrente com `vi.setSystemTime` — continuam poluindo o sinal da suite.

## Veredito

**APROVADO COM OBSERVACOES.** A implementacao atende integralmente aos requisitos PRD 3.1–3.4 e de acessibilidade, ao contrato da techspec (`CategoryConsumptionListProps`, formulas de calculo) e aos criterios de sucesso da task: a lista exibe exatamente os itens recebidos, as duas ordenacoes funcionam com estado ativo visivel e acessivel, o rotulo de leitor de tela segue o formato exato do PRD, e os 15 testes da task passam. Nenhum item bloqueante — os 4 minors (comentarios em portugues, dupla chamada de `getCategoryColor`, limitacao documentada da paleta e guarda defensiva opcional) podem ser resolvidos junto com a Tarefa 5.0 (`ByCategoryPage`), que e a proxima etapa e consumira este componente.

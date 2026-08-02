# Review: Task 5.0 - `ByCategoryPage` — rota, cabecalho, resumo, lista, navegacao de meses e estados vazios

**Revisor**: AI Code Reviewer
**Data**: 2026-07-04
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task cria a pagina `src/pages/ByCategoryPage.tsx` (projeto `controlai-frontend`) na rota `/by-category?month=YYYY-MM`, registrada em `App.tsx` com `<Route exact>` conforme a techspec. A pagina orquestra exatamente o que a task pede: le `?month=` via `useLocation` (default mes corrente, validado por regex), busca `getBudgetSummary(month)` via `useEffect` com dependencia correta e guarda de race (`cancelled`), renderiza cabecalho (titulo "Por categoria", "MES · ANO", `IonBackButton`), card de resumo derivado por `useMemo` (total = Σ `actual` EXPENSE, contagem `actual > 0`, badge `count(actual > expected)` so quando N > 0), integra `MonthSelector` com `maxMonth` e `CategoryConsumptionList` com o filtro do grafico (`EXPENSE && expected > 0 && actual > 0`), e implementa os dois estados vazios do PRD 7.1 distinguindo mes sem orcamento (HTTP 4xx) de erro de rede.

Decisao de arquitetura acertada: o mes vive **apenas na URL** (`history.replace` na troca) — deep-link e refresh funcionam por construcao, o botao voltar retorna a origem sem atravessar os meses navegados (PRD 6.3), e nao ha estado duplicado mes-na-URL vs. mes-no-estado. Destaque adicional: as pendencias minor da review 4.0 (comentarios em portugues e dupla chamada de `getCategoryColor`) foram resolvidas nesta task, como recomendado.

Todas as verificacoes passaram nesta review (testes da task 15/15, typecheck, lint; suite 325/327 com as 2 falhas pre-existentes de `Tab1.test.tsx`). Restam apenas observacoes minor, nenhuma bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/pages/ByCategoryPage.tsx` (novo) | Problemas | 3 minor |
| `src/pages/ByCategoryPage.css` (novo) | OK | 0 |
| `src/pages/ByCategoryPage.test.tsx` (novo) | OK | 0 |
| `src/App.tsx` (modificado: import + rota) | OK | 0 |

Observacao de escopo: o working tree tambem contem `CategoryConsumptionList.*`, `MonthSelector.*`, `categoryColors.*` e `purchaseService.*`, pertencentes as tasks 2.0–4.0 (ja revisadas). As unicas alteracoes verificadas nesses arquivos durante esta task foram as correcoes recomendadas pela review 4.0 (ver Destaques).

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`ByCategoryPage.tsx:37-40` — `isMissingBudgetError` trata qualquer 4xx como "sem orcamento", mas o backend sinaliza especificamente 404.** O `BudgetController.getBudget` (controlai) lanca `ResponseStatusException(HttpStatus.NOT_FOUND)` para mes sem orcamento — 404 e o unico status que significa isso. Um 400/409 (ou um futuro 401/403 quando houver auth) seria mascarado como "Sem orcamento para {Mes Ano}" em vez de aparecer como erro. O risco pratico hoje e baixo (o `month` e validado por regex antes da chamada e o app nao tem auth), por isso minor e nao major. Correcao sugerida:

   ```ts
   function isMissingBudgetError(error: unknown): boolean {
     const match = error instanceof Error ? error.message.match(/^HTTP (\d{3})/) : null;
     return match !== null && match[1] === '404';
   }
   ```

2. **`ByCategoryPage.tsx:19-22` — deep-link para mes futuro nao e clampado ao mes corrente.** `?month=2099-12` passa na validacao de formato e dispara a busca; o resultado e gracioso (404 → estado vazio, botao "proximo" desabilitado pois `month >= maxMonth`), mas o espirito do PRD 5.1 ("nao ha navegacao para meses futuros") sugere normalizar tambem a entrada por URL. Correcao sugerida em `monthFromSearch`:

   ```ts
   function monthFromSearch(search: string): string {
     const param = new URLSearchParams(search).get('month');
     const current = currentYearMonth();
     if (!param || !/^\d{4}-(0[1-9]|1[0-2])$/.test(param)) return current;
     return param > current ? current : param; // clamp future months (PRD 5.1)
   }
   ```

3. **`ByCategoryPage.tsx:144-150` — estados dinamicos sem semantica para leitor de tela.** `bcp-loading` nao tem `role="status"`/`aria-live` e `bcp-error` nao tem `role="alert"`, entao a troca de mes e falhas de carga nao sao anunciadas. O PRD exige feedback imediato de carregamento e a feature tem barra alta de acessibilidade nas demais superficies (lista da task 4.0). Correcao de uma linha em cada:

   ```tsx
   {loading && <div className="bcp-loading" role="status">Carregando...</div>}
   {!loading && loadError && (
     <div className="bcp-error" role="alert" data-testid="bcp-error">…</div>
   )}
   ```

Registro sem numeracao (nao conta como problema): o comentario da linha 24 usa a abreviacao portuguesa "Ex.:" (preferir "e.g.") — o restante dos comentarios esta em ingles, encerrando de fato a recorrencia das reviews 2.0–4.0. A mensagem do `console.warn` em portugues segue o precedente do repo (`ScannerPage.tsx:117`), portanto nao e desvio.

## Destaques Positivos

- **Pendencias da review 4.0 resolvidas junto com esta task, como recomendado**: comentarios de `CategoryConsumptionList.tsx`, `categoryColors.ts` e testes traduzidos para ingles (fim da recorrencia de 3 reviews), e o calculo de cor da linha refatorado para uma unica chamada de `getCategoryColor` com intencao nomeada (`categoryColor` vs. `barColor` + comentario explicando dot = identidade, barra = alerta).
- **URL como fonte unica do mes**: `monthFromSearch` (validacao + default) e `history.replace` na troca eliminam estado duplicado; deep-link e refresh atendem o criterio de sucesso por construcao, e o voltar retorna a origem sem atravessar o historico de meses (PRD 6.3). `IonBackButton` com `defaultHref="/tab1"` cobre o caso de entrada direta pela URL — desvio consciente do padrao `history.goBack()` do repo, justificado e mais robusto.
- **Tratamento de erro segue exatamente o risco mapeado na techspec** ("Meses sem orcamento... distinguir por status"): 4xx → estado vazio com copy acionavel ("Configure o orcamento mensal..."), outros erros → `console.warn` defensivo (unico ponto de observabilidade previsto) + mensagem de erro. Os dois caminhos tem testes dedicados, incluindo a assercao de que o warn NAO dispara no caso 4xx.
- **`clean-code`**: regras de calculo nomeadas e colocalizadas (`isExpense`, `hasSpending`, `isOverLimit`, `visibleCategories`, `isMissingBudgetError`, `formatMonthHeading`), todas puras; os tres estados de exibicao reduzidos a booleanos nomeados (`showNoBudgetEmpty`, `showNoSpendingEmpty`, `showContent`) mutuamente exclusivos e faceis de auditar.
- **`vercel-react-best-practices`**: derivacoes encadeadas via `useMemo` com dependencias corretas (`expenseItems` → `totalSpent`/`categoriesWithSpending`/`overLimitCount`/`listItems`); `useEffect` com cleanup `cancelled` prevenindo race na troca rapida de meses; zero estado redundante.
- **Estados vazios acima do pedido**: alem do "sem orcamento" (7.1), ha o estado distinto "Sem gastos em categorias com orcamento" para orcamento existente sem movimento — ambos mantendo cabecalho e navegacao de meses, com testes verificando a permanencia dos controles.
- **Testes excelentes (15/15)**: cobrem 100% da subtarefa 5.6 e alem — mes malformado caindo no default, singular/plural do rotulo ("1 categoria" vs. "2 categorias"), INVESTMENT excluido de todos os numeros, feedback de carregamento com promise pendente controlada, bloqueio do avanco alem do mes corrente com asserto de que `history.replace` nao dispara, e a simulacao correta do ciclo URL → rerender → refetch.
- **Ionic/mobile**: tap target do voltar 44×44px, `env(safe-area-inset-top)` no header, dark theme com os mesmos tokens do app (`#FF6B6B` no badge de alerta, alphas de branco, gradiente de fundo identico ao padrao `oklch` ja usado em `BudgetPage.css`).
- **Preparacao limpa para a Task 6.0**: `selectedCategoryId` ja plugado no `onCategoryClick`, exposto por `data-selected-category` apenas como gancho de teste temporario.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (codigo e comentarios em ingles; funcoes puras nomeadas; sem magic numbers) |
| TypeScript/Node.js | OK (`npx tsc --noEmit` sem erros; sem `any`; `error: unknown` tratado com type guard) |
| React | OK (`useMemo`/`useEffect` com deps corretas; cleanup de race; estado minimo) |
| Ionic/Mobile UI | OK (IonPage/IonContent/IonBackButton; safe-area; tap targets ≥ 44px; dark theme) |
| Acessibilidade | Problemas (minor 3: loading/erro sem `role="status"`/`role="alert"`) |
| Testes | OK (15/15 da task; 2 falhas da suite sao pre-existentes e nao relacionadas) |
| Lint | OK (`npx eslint` sem issues em `ByCategoryPage.tsx|.test.tsx` e `App.tsx`) |

## Verificacoes Executadas pelo Revisor

- `npx vitest run src/pages/ByCategoryPage.test.tsx` → **15 passed, 0 failed**.
- `npx vitest run` (suite completa) → **325 passed, 2 failed** (327 total). As 2 falhas sao "Tab1 loads data on initial mount" e "Tab1 silent refresh via useIonViewWillEnter does not show loading skeleton" — **as mesmas documentadas como pre-existentes nas reviews 2.0–4.0** (mock fixa `'2026-05'` sem `vi.setSystemTime`). Nenhuma referencia aos arquivos desta task.
- `npx tsc --noEmit` → **sem erros**.
- `npx eslint src/pages/ByCategoryPage.tsx src/pages/ByCategoryPage.test.tsx src/App.tsx` → **sem issues**.
- Verificado no backend (`controlai/BudgetController.kt:44`) que mes sem orcamento retorna especificamente **404** — base do minor 1.

## Recomendacoes

1. Restringir `isMissingBudgetError` a `404` (minor 1) — mudanca de um caractere no predicado, alinhada ao contrato real do backend; pode entrar junto com a Task 6.0.
2. Clampar mes futuro vindo da URL ao mes corrente (minor 2) — fecha a ultima brecha do PRD 5.1.
3. Adicionar `role="status"` ao loading e `role="alert"` ao erro (minor 3) — mantem a barra de acessibilidade da feature.
4. Ao implementar a Task 6.0, remover o gancho `data-selected-category` quando o `CategoryDetailSheet` assumir o consumo de `selectedCategoryId` (incluindo um caminho de limpeza no dismiss).
5. (Oportunistico, fora do escopo) Extrair `monthNames` — agora duplicado em 5 arquivos (`MonthSelector`, `Tab1`, `BudgetPage`, `DuplicateMonthModal`, `ByCategoryPage`) — e o helper de mes corrente (3 ocorrencias) para um `src/utils/monthLabels.ts`. Divida pre-existente que esta task apenas herda.
6. (Reiterada das reviews 2.0–4.0, fora do escopo) Corrigir os 2 testes de `Tab1.test.tsx` dependentes do mes corrente com `vi.setSystemTime`.

## Veredito

**APROVADO COM OBSERVACOES.** A implementacao atende integralmente aos requisitos PRD 1.1–1.4 (cabecalho e card de resumo com badge condicional), 3.5 (filtro identico ao do grafico aplicado na pagina), 5.1–5.4 (navegacao com `maxMonth`, mes sempre visivel, recalculo completo na troca) e 7.1 (dois estados vazios mantendo cabecalho e navegacao), ao contrato da techspec (query param via `useLocation`, rota `exact`, derivacoes do `BudgetSummary`, distincao de erro por status) e a todos os criterios de sucesso da task. Os 3 minors (404 estrito, clamp de mes futuro na URL e roles ARIA nos estados dinamicos) sao pequenos e podem ser resolvidos junto com a Task 6.0 (`CategoryDetailSheet`), que e a proxima etapa e ja tem o estado `selectedCategoryId` preparado nesta pagina.

# Review: Task 6.0 - `CategoryDetailSheet` — bottom sheet de detalhe da categoria

**Revisor**: AI Code Reviewer
**Data**: 2026-07-07
**Arquivo da task**: 6_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task cria o componente `src/components/CategoryDetailSheet.tsx` (projeto `controlai-frontend`) — `IonModal` sheet com `breakpoints={[0, 0.75, 1]}` e `initialBreakpoint={0.75}`, exatamente como especificado na techspec (o `CategoryBottomSheet` existente nao foi tocado, conforme exigido). O sheet implementa todos os requisitos: cabecalho com nome da categoria, "N compras · Mes Ano" (singular/plural corretos, contagem via `totalElements` — correta mesmo com paginacao) e botao de fechar (PRD 4.1); badge "Estourou em R$ X" calculado por `actual - expected` via `fmtBRL` e exibido apenas quando `actual > expected` (PRD 4.2); card gasto/limite com percentual, barra de progresso e estilo de alerta acima de 100% usando `getOverflowColor()` (PRD 4.3), com valores vindos do `BudgetItemSummary` da pagina (consistencia por construcao); item de compra com descricao/estabelecimento, "Nubank Ramon · **** 4521" para cartoes ou so o nome do metodo para PIX/CASH via join client-side de `listPaymentMethods()` cacheado no estado (PRD 4.4); abas Recentes | Maiores com refetch por `sort` (PRD 4.5); filtro por cartao (apenas `CREDIT_CARD`) com refetch por `paymentMethodId` e estado ativo indicado por classe + `aria-pressed` (PRD 4.6); dismiss por botao e por gesto (`breakpoints` com `0` + `onDidDismiss`) (PRD 4.7); e estado "nenhuma compra" mantendo o filtro visivel (PRD 7.2). A integracao com a `ByCategoryPage` fecha o funil de 2 toques: linha da lista → sheet com as compras, com o mes limpando o sheet ao trocar (evita dados de outro mes).

Destaque estrutural desta task: **todas as 4 recomendacoes da review 5.0 foram implementadas** (404 estrito, clamp de mes futuro na URL, roles ARIA nos estados dinamicos, remocao do gancho `data-selected-category`), e a recorrencia das reviews 2.0–5.0 sobre os 2 testes quebrados de `Tab1.test.tsx` foi finalmente resolvida na raiz (relogio fixado com `vi.useFakeTimers({ toFake: ['Date'] })`) — a suite completa esta **347/347 verde pela primeira vez na feature**. Restam apenas observacoes minor, nenhuma bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/CategoryDetailSheet.tsx` (novo) | Problemas | 3 minor |
| `src/components/CategoryDetailSheet.css` (novo) | OK | 0 |
| `src/components/CategoryDetailSheet.test.tsx` (novo) | OK | 0 |
| `src/pages/ByCategoryPage.tsx` (modificado: integracao + minors da review 5.0) | Problemas | 1 minor (compartilhado) |
| `src/pages/ByCategoryPage.test.tsx` (modificado: 4 testes novos) | OK | 0 |
| `src/pages/Tab1.test.tsx` (correcao de suite pre-existente) | OK | 0 |
| `src/services/purchaseService.test.ts` (mock completado p/ typecheck) | OK | 0 |

Observacao de escopo: o working tree contem tambem os arquivos das tasks 2.0–5.0 (ja revisados). As unicas mudancas atribuiveis a esta task nesses arquivos sao as correcoes recomendadas pela review 5.0 em `ByCategoryPage.tsx` (ver Destaques) e os dois ajustes de suporte declarados (`Tab1.test.tsx`, `purchaseService.test.ts`).

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`CategoryDetailSheet.tsx:144-156` — `loadMore` sem guarda de corrida nem trava de requisicao em voo.** O `useEffect` principal tem o guard `cancelled`, mas o `loadMore` nao: (a) se o usuario toca "Carregar mais" e troca ordenacao/filtro antes da resposta, o refetch substitui a lista e, quando a pagina 2 antiga resolve, `setPurchases(prev => [...prev, ...result.content])` anexa itens da ordenacao anterior a lista nova (dados visivelmente errados ate o proximo refetch); (b) dois toques rapidos disparam duas buscas da mesma `nextPage` (o estado `page` ainda nao atualizou), duplicando itens e keys. Gatilho exige categoria com >100 compras no mes (`PAGE_SIZE = 100`) + timing preciso — improvavel no uso real do casal, por isso minor. Correcao sugerida com um id de requisicao compartilhado:

   ```ts
   const requestIdRef = useRef(0);
   // in the main effect: const requestId = ++requestIdRef.current;
   // and in every .then: if (requestId !== requestIdRef.current) return;
   const loadMore = () => {
     if (categoryId === null || loadingMore) return;
     const requestId = requestIdRef.current;
     setLoadingMore(true);
     getNotifications(month, page + 1, PAGE_SIZE, categoryId, null, paymentMethodId, sort)
       .then(result => {
         if (requestId !== requestIdRef.current) return; // sort/filter changed meanwhile
         setPurchases(prev => [...prev, ...result.content]);
         // ...
       })
       .finally(() => setLoadingMore(false));
   };
   ```

2. **`CategoryDetailSheet.tsx:98-103` — reset de `sort`/`paymentMethodId` na abertura gera um fetch desperdicado e um flash da lista anterior.** O efeito de reset e o efeito de busca rodam no mesmo commit quando `isOpen` vira `true`: a busca dispara primeiro com os valores antigos (ex.: `sort='amount'` da sessao anterior), e cancelada pelo cleanup e refeita com `'recent'` — correto no resultado final (o guard `cancelled` salva), mas com uma requisicao a mais na rede. Alem disso, `purchases`/`totalPurchases` nao sao limpos no fechamento; ao reabrir outra categoria, a lista da categoria anterior aparece por ~1 frame antes de `loading` ligar. Correcao sugerida — resetar quando o sheet FECHA, em vez de quando abre:

   ```ts
   useEffect(() => {
     if (isOpen) return;
     setSort('recent');
     setPaymentMethodId(null);
     setPurchases([]);
     setTotalPurchases(0);
   }, [isOpen]);
   ```

3. **`CategoryDetailSheet.tsx:50-56` — `consumptionRatio` divide por `item.expected` sem guarda para zero.** Hoje o componente so recebe itens do filtro `visibleCategories` (`expected > 0`), entao nao ha bug observavel; mas o contrato da prop aceita qualquer `BudgetItemSummary` e a **Task 7.0 vai instancia-lo a partir das linhas do `BudgetPage`**, onde a garantia pode nao existir — `expected = 0` produziria `Infinity%` no percentual e no `aria-label`. Guarda de uma linha evita a armadilha antes da proxima task:

   ```ts
   function consumptionRatio(item: BudgetItemSummary): number {
     return item.expected > 0 ? item.actual / item.expected : 0;
   }
   ```

4. **Duplicacoes que crescem com a feature.** `monthNames` + `monthLongLabel` agora existem em `ByCategoryPage.tsx:13,34` E `CategoryDetailSheet.tsx:28,31` (alem das 5 copias pre-existentes mapeadas na review 5.0); `fmtDateTime` (`CategoryDetailSheet.tsx:39`) reimplementa o `fmtDate` local de `PurchaseList.tsx:51` (o comentario ate declara "Same date/time display used by PurchaseList"); `isOverLimit` esta duplicado entre a pagina e o sheet. Nenhuma divergencia de comportamento hoje, mas o custo de extrair `src/utils/monthLabels.ts` (+ formatador de data/hora) ja se paga — recomendacao 5 da review 5.0, reiterada.

Registro sem numeracao (nao conta como problema): o estado de erro (`cds-error`) diz "Tente novamente" mas nao oferece botao de retry — o usuario recupera trocando a ordenacao ou reabrindo o sheet, o que e aceitavel para um caminho defensivo; e os nomes de teste em portugues em `purchaseService.test.ts` (minor 1 da review 2.0) permanecem — o arquivo foi tocado nesta task (mock completado), teria sido a oportunidade de padronizar.

## Destaques Positivos

- **Todas as recomendacoes da review 5.0 implementadas junto com a task, como sugerido**: `isMissingBudgetError` restrito a `404` (`ByCategoryPage.tsx:41-44`), clamp de mes futuro na URL com teste dedicado ("clamps a future ?month=", PRD 5.1), `role="status"`/`role="alert"` nos estados dinamicos, e o gancho temporario `data-selected-category` removido (grep confirma zero ocorrencias) — substituido pelo consumo real de `selectedItem` com caminho de limpeza no dismiss E na troca de mes (comentario justificando: "a sheet left open would show data from another month").
- **Recorrencia das reviews 2.0–5.0 encerrada na raiz**: os 2 testes de `Tab1.test.tsx` sensiveis a data real foram corrigidos com `vi.useFakeTimers({ now, toFake: ['Date'] })` — fake apenas de `Date`, preservando timers reais para o `waitFor` (comentario no codigo explica exatamente isso). Suite completa **347/347** pela primeira vez na feature.
- **Consistencia de numeros por construcao** (criterio de sucesso da task): gasto, limite, percentual e estouro vem do mesmo `BudgetItemSummary` exibido na lista da pagina — o teste de integracao verifica que o sheet abre com `R$ 896,12` / `R$ 800,00` / `Estourou em R$ 96,12` identicos aos da linha tocada.
- **Contrato da techspec seguido a risca**: props (`isOpen`, `month`, `item`, `onDismiss`), estado interno `sort`/`paymentMethodId`, `breakpoints={[0, 0.75, 1]}` + `initialBreakpoint={0.75}`, chamada `getNotifications(month, 0, PAGE_SIZE, categoryId, null, paymentMethodId, sort)` e `aria-labelledby` via `htmlAttributes` apontando para `#cds-title`.
- **Risco da techspec mitigado como previsto**: join client-side de metodos com cache em estado (`methods !== null` evita refetch entre reaberturas — com teste dedicado "caches the payment methods between reopenings"), lookup O(1) via `Map` memoizado, e degradacao graciosa dupla: falha em `listPaymentMethods` → filtro oculto e compras caem no fallback `**** {digits}`; metodo nao encontrado → mesmo fallback.
- **Acessibilidade acima da barra**: `aria-pressed` nas abas e chips, `role="group"` com `aria-label` descritivo nos dois grupos de controle, `aria-label` agregado no card ("R$ X de R$ Y, N% do limite"), `role="status"`/`role="alert"` nos estados, botao fechar 44×44px e abas/chips/load-more com `min-height: 44px` (tap targets ≥ 44px verificados no CSS).
- **Alem do pedido**: paginacao real com "Carregar mais" (a task so exigia a busca paginada), subtitulo usa `totalElements` (contagem correta com paginas parciais) e mostra so o periodo durante o loading (evita contagem obsoleta), guarda `!isOpen` impede qualquer fetch com o sheet fechado (com teste), e `vercel-react-best-practices` aplicado (efeitos com deps corretas + cleanup `cancelled` no caminho principal, `useMemo` para mapas derivados).
- **Testes fortes (18 no componente + 17 na pagina = 35/35)**: cobrem 100% da subtarefa 6.6 (incluindo assercoes de argumentos exatos de `sort`/`paymentMethodId` via `toHaveBeenLastCalledWith`), PRD 7.2 com o filtro permanecendo visivel e ativo, PIX excluido das opcoes de filtro, singular/plural, fallback descricao→estabelecimento, e casos extras (load more, cache, erro com `console.warn`). Truques documentados em comentarios (normalizacao hex→rgb do jsdom, non-breaking space do `fmtBRL`).
- **Retrocompatibilidade de `getNotifications` testada** (`purchaseService.test.ts`): params omitidos preservam a URL antiga (`toMatch(/...size=100$/)`), novos params entram na query so quando informados.
- **Convencao do repo respeitada**: todos os comentarios dos arquivos novos em ingles; mensagens de `console.warn` em portugues seguem o precedente do repo (registrado na review 5.0).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (comentarios em ingles; funcoes puras nomeadas e colocalizadas; `PAGE_SIZE`/`SORT_OPTIONS` como constantes) |
| TypeScript/Node.js | OK (`npx tsc --noEmit` sem erros; sem `any` nos arquivos da task; `error: unknown` nos catches) |
| React | OK (deps corretas; cleanup `cancelled` no efeito principal; estado minimo — minors 1 e 2 sao lacunas pontuais, nao padrao) |
| Ionic/Mobile UI | OK (`IonModal` sheet com gesto; dark theme com tokens do app; `safe-area-inset-bottom`; tap targets ≥ 44px) |
| Acessibilidade | OK (`aria-labelledby`, `aria-pressed`, `role=group/status/alert`, card com `aria-label`) |
| Testes | OK (35/35 da task; suite completa 347/347 — zero falhas pre-existentes restantes) |
| Lint | OK nos arquivos da feature (3 `@typescript-eslint/no-explicit-any` em `Tab1.test.tsx:19-21` sao pre-existentes no HEAD, fora do diff desta task) |

## Verificacoes Executadas pelo Revisor

- `npx vitest run src/components/CategoryDetailSheet.test.tsx src/pages/ByCategoryPage.test.tsx` → **35 passed, 0 failed**.
- `npx vitest run` (suite completa) → **347 passed, 0 failed** — as 2 falhas pre-existentes de `Tab1.test.tsx` documentadas nas reviews 2.0–5.0 foram corrigidas nesta task.
- `npx tsc --noEmit` → **sem erros**.
- `npx eslint` nos 6 arquivos da task → **0 issues nos arquivos da feature**; 3 `no-explicit-any` em `Tab1.test.tsx` confirmados como pre-existentes (`git diff` da task nao contem `any`; ocorrencias ja no commit `6e24bb8`).
- Conferido que `CategoryBottomSheet.tsx` nao foi alterado (restricao explicita da task) e que `data-selected-category` foi removido do codigo.

## Recomendacoes

1. Adicionar guarda de corrida/trava em voo ao `loadMore` (minor 1) — pode entrar junto com a Task 7.0.
2. Mover o reset de `sort`/`paymentMethodId` (e limpeza de `purchases`) para o fechamento do sheet (minor 2) — elimina o fetch desperdicado na reabertura e o flash da lista anterior.
3. Proteger `consumptionRatio` contra `expected = 0` (minor 3) — **fazer antes da Task 7.0**, que passara itens do `BudgetPage` sem o filtro da pagina.
4. (Reiterada da review 5.0, fora do escopo) Extrair `monthNames`/`monthLongLabel` e o formatador "d mmm, HH:mm" para `src/utils/` — a duplicacao subiu para 7 e 2 copias respectivamente (minor 4).
5. (Reiterada da review 2.0, oportunistica) Padronizar em ingles os nomes de teste de `getNotifications` em `purchaseService.test.ts`.
6. (Opcional) Botao de retry no estado de erro do sheet, reaproveitando o refetch existente.
7. Na Task 9.0 (smoke/verificacao manual), validar o gesto de arrastar e o scroll interno do sheet no simulador iOS — risco "Sheet + IonModal em iOS (WebKit)" da techspec, nao verificavel em jsdom.

## Veredito

**APROVADO COM OBSERVACOES.** A implementacao atende integralmente aos requisitos PRD 4.1–4.7 (cabecalho, estouro condicional em reais, card com alerta, exibicao cartao/PIX por compra, ordenacoes e filtro com refetch no backend, dismiss por botao e gesto) e 7.2 (estado vazio mantendo o filtro), ao contrato da techspec (props, estado interno, breakpoints, `aria-labelledby`, join client-side cacheado) e a todos os criterios de sucesso da task — incluindo o funil de 2 toques verificado por teste de integracao. As verificacoes estao todas verdes (35/35 da task, suite 347/347, typecheck, lint), e a task ainda quitou as pendencias das reviews anteriores (minors da 5.0 e os testes quebrados de Tab1). Os 4 minors (guarda no `loadMore`, reset no fechamento, guarda de divisao por zero e duplicacoes de formatadores) nao bloqueiam; recomenda-se resolver os minors 1–3 junto com a Task 7.0 (pontos de entrada Tab1/BudgetPage), que e a proxima etapa e reutilizara este componente fora do filtro protetor da `ByCategoryPage`.

## Resolucao Pos-Review

Minors 1–3 corrigidos na propria task (antes da finalizacao), com testes novos em `CategoryDetailSheet.test.tsx`:

1. **Minor 1 (corrida no `loadMore`)** — adicionados `requestSeqRef` (bump a cada fetch de pagina 0; resultado obsoleto e descartado) e trava `loadingMore` (duplo toque ignorado). Testes: "ignores a second tap...", "discards a pending load more result...".
2. **Minor 2 (reset na abertura)** — reset de `sort`/`paymentMethodId` e limpeza de `purchases`/`totalPurchases`/`hasMore` movidos para o fechamento (`!isOpen`); reabertura parte do estado padrao sem fetch desperdicado nem flash da lista anterior. Teste: "reopens with the default sort and no card filter".
3. **Minor 3 (divisao por zero)** — `consumptionRatio` retorna 0 quando `expected <= 0` (preparo para a Task 7.0/BudgetPage). Teste: "guards against a zero limit...".
4. **Minor 4 (duplicacoes de formatadores)** — mantido para refactor transversal junto das Tasks 7.0/9.0, conforme recomendacao.

Verificacao apos as correcoes: suite completa **351 passed / 0 failed**; `npm run build` (tsc + vite) OK; eslint 0 issues nos arquivos da feature.

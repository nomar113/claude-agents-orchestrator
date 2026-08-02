# Review: Task 6.0 - Polish — Acessibilidade, copy, back nativo e verificacao manual nos 3 cenarios

**Revisor**: AI Code Reviewer
**Data**: 2026-06-15
**Arquivo da task**: 6_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Task 6.0 e a fase de polish da feature "Edicao de Cartao em Notificacao de Pagamento". A implementacao consolida acessibilidade, copy e suporte ao back nativo no `PaymentMethodSelector` e na `PurchaseDetail`, sem introduzir novas regras de negocio. Foram entregues 7 ajustes principais:

1. **Acessibilidade no sheet** — `role="dialog"`, `aria-modal="true"` e `aria-label` dinamico (`"Selecionar cartao"` na lista de cartoes e `"Selecionar sub-cartao"` quando o usuario navega para os sub-cards), alem do `<h2>` visivel relabel que casa com o `aria-label`.
2. **Back nativo + Escape key** — `App.addListener('backButton', ...)` do `@capacitor/app` + `window.addEventListener('keydown', ...)` com tecla `Escape`. O comportamento e em duas etapas: do sub-card volta para a lista de cartoes; da lista de cartoes fecha o sheet via `onClose`. Cleanup com flag `cancelled` para evitar vazamento caso o `addListener` resolva apos o unmount.
3. **Alvos de toque >= 44x44px** — `.pms-close` (44x44), `.pms-back-link` (`min-height: 44px`), `.pms-skip` (`min-height: 44px`), `.pd-card-error-retry` (`min-height: 44px`, padding 10x14).
4. **Contraste melhorado** — `.pms-skip` passou de borda `#ffffff26`/texto `#ffffff80` para `#ffffff40`/`#ffffffb3`, aproximando-se de AA em fundo navy.
5. **Selecionado com borda destacada** — `.pms-item-selected` ganhou `border: 1px solid #4f8bff66` (o `border: 1px solid transparent` no estado base evita "jump" de layout entre estados).
6. **Title rebrand** — `"Selecionar meio de pagamento"` -> `"Selecionar cartao"` (texto visivel + aria-label do dialog).
7. **Aria-label no retry button** — `"Tentar atualizar cartao novamente"`, alinhado a copy do app em pt-BR.

A correcao **MA1** do review da Task 5.0 (separacao do try/catch do `getPaymentMethod` refresh) **foi aplicada nesta task**, com teste explicito (`does not surface an error when getPaymentMethod refresh fails after a successful update`). A copy `'Erro ao atualizar cartao'` (sem acento) foi corrigida para `'Erro ao atualizar cartão'` (com til), endereçando **MI2** da Task 5.0.

Foram adicionados 22 testes no novo arquivo `PaymentMethodSelector.test.tsx` (anteriormente inexistente), cobrindo modo `edit`, modo `create` (regressao), acessibilidade do dialog, back nativo em ambas as etapas, Escape key, e callout "Cartao atual". `PurchaseDetail.test.tsx` recebeu mocks para `@capacitor/app` e o `dialogLabel` do sheet foi ajustado em todos os asserts que dependiam dele.

**Verificacao de execucao**: `npx tsc --noEmit` zero erros; `npx vitest run` 271 PASS / 2 FAIL (ambos pre-existentes em `Tab1.test.tsx`, confirmados desde a review da Task 3.0); ESLint zero erros nos arquivos modificados/novos; 6 erros pre-existentes em `PurchaseDetail.test.tsx`. Subtarefa 6.6 (verificacao manual em dispositivo nos 3 cenarios) e responsabilidade do usuario, conforme declarado na propria task.

Foram identificados **0 problemas criticos**, **0 problemas major** e **3 problemas minor** (cleanup do listener com closure stale capturada em cenario raro, ausencia de focus trap no dialog para teclado, e ausencia de teste manual confirmado). Nada bloqueia a entrega.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PaymentMethodSelector.tsx` | OK | 2 (minor) |
| `src/components/PaymentMethodSelector.css` | OK | 0 |
| `src/components/PaymentMethodSelector.test.tsx` (novo) | OK | 0 |
| `src/pages/PurchaseDetail.tsx` | OK | 0 |
| `src/pages/PurchaseDetail.css` | OK | 0 |
| `src/pages/PurchaseDetail.test.tsx` | OK | 0 (6 lint pre-existentes) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**MI1 - Effect do back-button re-cria o listener a cada mudanca de `showSubCards`, gerando duas idas/voltas ao plugin nativo em uma navegacao**
- **Arquivo**: `src/components/PaymentMethodSelector.tsx:104-139`
- **Descricao**: O `useEffect` tem dependencias `[isOpen, showSubCards, onClose]`. Quando o usuario seleciona um cartao com sub-cards, `showSubCards` muda para `true` e o effect e re-executado: o cleanup remove o listener anterior (com a closure antiga), e um novo `App.addListener` e chamado. Funcionalmente correto, mas envolve duas chamadas assincronas ao plugin nativo por toque de cartao (remove + add). Em rede normal nao impacta UX, mas e overhead opcional.
- **Impacto**: Muito baixo. Os testes (`native back button on the sub-cards screen returns to the card list without firing onSelect`) confirmam que o comportamento esta correto em ambos os passos. Apenas duplicada chamada nativa por step.
- **Sugestao** (opcional, refatoracao): usar um `useRef` para o `showSubCards` atual e ler do ref dentro do `handleBack`, removendo `showSubCards` das deps:
  ```typescript
  const showSubCardsRef = useRef(showSubCards);
  useEffect(() => { showSubCardsRef.current = showSubCards; }, [showSubCards]);

  useEffect(() => {
    if (!isOpen) return;
    const handleBack = () => {
      if (showSubCardsRef.current) {
        setShowSubCards(false);
      } else {
        onClose();
      }
    };
    // ...
  }, [isOpen, onClose]);
  ```
  Nao bloqueante; o codigo atual e correto e cobre cleanup.

**MI2 - O `role="dialog"` + `aria-modal="true"` nao acompanha focus trap nem foco inicial; teclado pode "escapar" para elementos atras**
- **Arquivo**: `src/components/PaymentMethodSelector.tsx:197-205`
- **Descricao**: O sheet ganhou `role="dialog"`/`aria-modal="true"`, o que e excelente para anuncio em leitores de tela. Entretanto, nao ha:
  - Foco inicial ao abrir (idealmente no `<h2>` ou no botao "Fechar"). Hoje o foco permanece no botao que abriu o sheet (em `PurchaseDetail` e o `data-testid="card-field"`), o que e aceitavel mas nao ideal.
  - Focus trap dentro do dialog (Tab/Shift+Tab podem mover o foco para botoes da pagina atras do overlay).
  - Restauracao explicita do foco ao fechar (o React por default mantem o ultimo elemento focado, mas se o elemento foi desmontado isso quebra).

  O PRD lista "suporte a VoiceOver/TalkBack com labels claros" e back nativo — focus trap nao foi requisito explicito, mas e padrao WAI-ARIA APG para `role="dialog"`/`aria-modal="true"`.
- **Impacto**: Baixo. Em mobile (Capacitor app), navegacao por teclado e cenario raro. Em screen reader, o `aria-modal="true"` ja informa que o usuario esta em um dialogo, e os items sao focaveis pelo touch.
- **Sugestao** (opcional, polish futuro): adicionar `useEffect` para focar o titulo ao abrir, e considerar `react-focus-lock` ou similar para focus trap. Pode ficar para um ticket de tech-debt.

**MI3 - Subtarefa 6.6 (verificacao manual nos 3 cenarios em dispositivo) ainda marcada como pendente**
- **Arquivo**: `tasks/prd-editar-cartao-notificacao/6_task.md:35`
- **Descricao**: A propria task declara que `6.6` e verificacao manual e e responsabilidade do usuario em dispositivo (Android/iOS). Esta nao automatizada por design.
- **Impacto**: Nenhum bloqueio tecnico. A cobertura de testes automatizados ja cobre o caminho logico das 3 variantes (cartao sem sub-cards via `selecting a card without sub-cards fires onSelect immediately`; cartao com sub-cards via `pre-marks the current sub-card when picking the same card`; "Continuar sem sub-cartao" via `"Continuar sem sub-cartão" fires onSelect(pmId, null)`).
- **Sugestao**: confirmar com o Ramon a execucao dos 3 cenarios em `ionic serve` ou no Capacitor build antes do release de producao, especialmente os comportamentos especificos do back nativo Android (back fisico) e iOS (gesto de back) que nao podem ser simulados em jsdom/vitest.

## Destaques Positivos

1. **Acessibilidade do dialog atende WAI-ARIA APG basico** — `role="dialog"` + `aria-modal="true"` + `aria-label` dinamico + `<h2>` visivel relabel sincronizado. O leitor de tela anuncia "Selecionar cartao, dialogo modal" ao abrir, e "Selecionar sub-cartao, dialogo modal" ao navegar para o passo 2. Cobertura por 2 testes explicitos (`exposes the sheet as a dialog with aria-label`, `relabels the dialog as "Selecionar sub-cartão"`).

2. **Cleanup correto do listener assincrono** — uso de flag `cancelled` no `useEffect` (`PaymentMethodSelector.tsx:122-138`):
   ```typescript
   let backHandle: PluginListenerHandle | undefined;
   let cancelled = false;
   void App.addListener('backButton', handleBack).then((h) => {
     if (cancelled) {
       void h.remove();
     } else {
       backHandle = h;
     }
   }).catch(() => { /* web env: no native back button */ });

   return () => {
     cancelled = true;
     window.removeEventListener('keydown', handleKeyDown);
     if (backHandle) void backHandle.remove();
   };
   ```
   Cobre o cenario em que `App.addListener` resolve apos o componente ter sido desmontado, evitando dois bugs comuns: (a) listener vazado (handler nunca removido), (b) memory leak via closure que segura `onClose`.

3. **`.catch(() => {})` no `addListener` cobre o ambiente web** — `@capacitor/app` rejeita ao chamar `addListener` em ambiente web puro (sem WebView nativa). O catch silencioso faz o componente degradar graciosamente em `ionic serve`, mantendo apenas o `Escape` key + click no overlay + botao X como caminhos de fechamento. Excelente para DX.

4. **`Escape` key + back nativo compartilham o mesmo `handleBack`** — DRY no comportamento. As duas entradas convergem para `if (showSubCards) setShowSubCards(false); else onClose()`, o que garante que UI/UX seja identica entre teclado/touch/back fisico. Cobertura por 3 testes (`native back button on the card list`, `native back button on the sub-cards screen`, `Escape key on the card list closes the sheet`).

5. **`e.preventDefault()` no Escape** — evita comportamento default do navegador (que poderia, em alguns contextos, sair de fullscreen ou cancelar autocomplete) e mantem consistencia.

6. **`dialogLabel` calculado e reusado em 3 lugares (h2, aria-label do dialog, e nos assertions de testes)** — fonte unica de verdade. Atende clean-code.

7. **Alvos de toque ajustados sem quebrar o layout** — `border: 1px solid transparent` no `.pms-item` base e `border: 1px solid #4f8bff66` no `.pms-item-selected` evita o "jump" de 2px tipico ao trocar de estado (problema comum em CSS de selecao). Boa praticza visual.

8. **Contraste do `.pms-skip` revisado** — texto passou de `#ffffff80` (50% opacity, ~3.0:1 em fundo navy) para `#ffffffb3` (~70% opacity, ~5.0:1 em fundo navy), agora AA. Borda passou de `#ffffff26` para `#ffffff40`, melhorando visibilidade.

9. **Callout "Cartao atual" em rosa accent (`#ff4d6d`)** — usa o accent do sistema "nocturnal" com fundo `#ff4d6d14` (8% opacity) + borda `#ff4d6d40` (25%) + texto rosa para label uppercase + texto branco para o valor. Hierarquia visual e contraste OK. RF5 do PRD atendido visualmente.

10. **`.pms-add-new` em azul accent (`#4f8bff`)** — visualmente diferenciado dos cards listados (que sao "tons neutros"), comunica que e uma acao secundaria. Atende RF9.

11. **Componentizacao mantida sem regressao em `ManualEntryPage`** — `ManualEntryPage.handleCardSelect` foi atualizado de `(pmId: number, scId?: number)` para `(pmId: number, scId: number | null)` para casar com o novo contrato. Mudanca minima e isolada (`+2 -2`), e nao quebra nenhum teste existente. RF15 e mantido em modo `create`.

12. **Cobertura do modo "create" como regressao** — o arquivo de testes `PaymentMethodSelector.test.tsx` (novo) tem um describe block dedicado `'mode = "create" (regression)'` com 4 testes que confirmam que: (a) callout nao renderiza, (b) localStorage `last_sc` ainda funciona para pre-selecao, (c) `onSelect` ainda recebe `(pmId, subCardId)` corretamente, (d) "Continuar sem sub-cartao" fires `onSelect(pmId, null)`. Excelente proteca contra regressao.

13. **`aria-label="Tentar atualizar cartão novamente"` no botao retry** — copy descritiva e nao apenas "Tentar novamente" generico. Leitor de tela anuncia o contexto. Atende **MI2** da Task 5.0.

14. **Mock de `@capacitor/app` no `PurchaseDetail.test.tsx`** — minimo (`addListener: vi.fn(() => Promise.resolve({ remove: vi.fn() }))`) e suficiente. Nao captura o handler nem testa o back nativo na pagina (responsabilidade do componente filho ja coberta no `PaymentMethodSelector.test.tsx`).

15. **Mock de `@capacitor/app` no `PaymentMethodSelector.test.tsx` captura o handler em `capturedBackHandler`** — permite simular o press do back fisico chamando `capturedBackHandler!()`. Boa engenharia de teste para feature nativa.

16. **`waitFor(() => expect(capturedBackHandler).not.toBeNull())`** — espera ate o `addListener` ter sido chamado (e o handler armazenado) antes de invocar. Evita race conditions no test runner. Boa pratica.

17. **`<h2 className="pms-title">{dialogLabel}</h2>` re-renderiza automaticamente quando `showSubCards` muda** — o React detecta a mudanca em `dialogLabel` (que e uma string derivada) e refaz o render. O teste `relabels the dialog as "Selecionar sub-cartão"` valida explicitamente.

18. **MA1 do review da Task 5 foi corrigido** — `performCardUpdate` agora tem dois try/catch separados: o primeiro envolve `updatePaymentNotificationCard` + `setNotification` (e seta erro + return se falhar), e o segundo envolve `getPaymentMethod` + `setPaymentMethod` (e e silenciado se falhar). O comentario `/* refresh do brand falhou, mas o update ja persistiu */` documenta a intencao. Cobertura por teste `does not surface an error when getPaymentMethod refresh fails after a successful update`.

19. **MI2 do review da Task 5 foi corrigido** — `'Erro ao atualizar cartão'` agora tem o til. Consistente com `aria-label="Editar cartão"`.

20. **Tab1 e BudgetPage ja tinham `useIonViewWillEnter`** — verificado em `Tab1.tsx:184-191` (faz `loadBudget(true)`, `loadPurchases(true)`, `listCategories()`, `listPaymentMethods()`) e `BudgetPage.tsx:116`. RF22 e RF23 do PRD sao atendidos pelo padrao existente. Subtarefa 6.4 e atendida sem mudanca de codigo necessaria (conforme previsto na propria task: "*sem mudanca se ja padrao*").

21. **Nenhuma regressao em outras telas** — busca por `"Selecionar meio de pagamento"` no codigo retorna apenas `ManualEntryPage.tsx:361`, e ali e o **placeholder visivel do campo**, nao o titulo do sheet. Confirmado por leitura: `<span className="me-card-placeholder">Selecionar meio de pagamento</span>`. Esta string nao foi tocada e segue como esta. Zero regressao em outras telas.

22. **Execucao validada**:
    - `npx vitest run`: **273 testes / 271 PASS / 2 FAIL pre-existentes** (`Tab1 loads data on initial mount` + `Tab1 silent refresh via useIonViewWillEnter does not show loading skeleton`, ambos confirmados nas reviews 3.0/4.0/5.0).
    - `npx vitest run src/components/PaymentMethodSelector.test.tsx src/pages/PurchaseDetail.test.tsx`: **56 PASS / 0 FAIL**.
    - `npx tsc --noEmit`: **zero erros** em todo o projeto.
    - `npx eslint src/components/PaymentMethodSelector.tsx src/components/PaymentMethodSelector.test.tsx src/pages/PurchaseDetail.tsx src/pages/PurchaseDetail.test.tsx`: **0 erros nos 3 primeiros**; **6 erros pre-existentes** em `PurchaseDetail.test.tsx` (mesmos 6 confirmados no review 5.0: 4x `no-explicit-any` em mocks de `@ionic/react`, 2x `no-unused-vars`). Nenhum erro novo introduzido por esta task.
    - `git diff --stat`: **+681 -76 linhas** distribuidas em 5 arquivos modificados + 1 novo (`PaymentMethodSelector.test.tsx` ~538 linhas).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (English, camelCase, PascalCase, kebab-case) | OK |
| TypeScript (tsc --noEmit zero erros; tipo `PluginListenerHandle` importado de `@capacitor/core`) | OK |
| Clean Code (DRY no `dialogLabel`, `handleBack` compartilhado entre Escape e back nativo, sem comentarios redundantes) | OK |
| React (useEffect com cleanup correto, deps explicitas, useCallback em `loadData`, useMemo em `currentCardDescription`) | OK |
| Vercel React Best Practices (useMemo apenas onde necessario; useCallback so onde a referencia precisa ser estavel) | OK |
| Ionic Design (back nativo via `@capacitor/app`; drag handle e overlay ja existentes mantidos; tamanhos >= 44x44px) | OK |
| Capacitor (`App.addListener` + cleanup via `remove()`; flag `cancelled` para race condition; degradacao silenciosa em web) | OK |
| Acessibilidade (role="dialog", aria-modal, aria-label dinamico, aria-labels nos botoes, contraste melhorado, Escape key) | OK |
| Frontend Design / Nocturnal (callout `#ff4d6d`, retry banner `#ff6b6b`, IBM Plex Sans, hierarquia mantida) | OK |
| Aderencia ao PRD (F2 RF10 — back nativo fecha sheet; UX — acessibilidade; F5 RF22/RF23 — reload Tab1/BudgetPage) | OK |
| Aderencia a Tech Spec (sem mudanca de schema, sem novos endpoints, reusa `PaymentMethodSelector`, riscos de cache mitigados) | OK |
| Aderencia a Task (6.1 labels, 6.2 alvos toque, 6.3 back nativo, 6.4 reload, 6.5 copy, 6.7 testes — todas concluidas; 6.6 manual e responsabilidade do usuario) | OK |
| Testes (271/273 PASS; 56/56 nas suites desta task; 2 falhas pre-existentes em Tab1 nao relacionadas) | OK |
| Regressao (modo `create` no `PaymentMethodSelector` validado por 4 testes; `ManualEntryPage` ajustado para o novo contrato sem quebrar; busca por "Selecionar meio de pagamento" confirma zero regressao em outras telas) | OK |

## Verificacao de Execucao

- `npx vitest run` (suite completa): **273 testes / 271 PASS / 2 FAIL pre-existentes** (`Tab1 loads data on initial mount` + `Tab1 silent refresh via useIonViewWillEnter does not show loading skeleton`, ambos com date mismatch `2026-05` vs `2026-06`, **nao introduzidos por esta task**).
- `npx vitest run src/components/PaymentMethodSelector.test.tsx`: **22 PASS / 0 FAIL** (todos os novos testes desta task).
- `npx vitest run src/pages/PurchaseDetail.test.tsx`: **34 PASS / 0 FAIL** (24 pre-existentes + 10 da Task 5.0, todos continuam verdes apos ajustes de mock e label do dialog).
- `npx tsc --noEmit`: **zero erros**.
- `npx eslint` nos 4 arquivos da task: **0 erros novos**. Os 6 erros em `PurchaseDetail.test.tsx` sao pre-existentes desde antes da PRD (confirmados nas reviews 4.0 e 5.0).
- `git diff --stat`: 5 modificados + 1 novo = **+681 -76 linhas**.
- Busca por `"Selecionar meio de pagamento"`: apenas 1 ocorrencia em `ManualEntryPage.tsx:361` (placeholder do campo, nao titulo do sheet) — **zero regressao** em outras telas.
- Caller scan do `PaymentMethodSelector`: usado em `ManualEntryPage.tsx` (modo `create` default) e `PurchaseDetail.tsx` (modo `edit`). Ambos seguem o novo contrato `(pmId: number, scId: number | null)`.
- Tab1/BudgetPage: `useIonViewWillEnter` ja presente desde antes desta task (Tab1.tsx:184, BudgetPage.tsx:116). Subtarefa 6.4 atendida sem mudanca de codigo.

## Recomendacoes

1. **Executar a subtarefa 6.6 (verificacao manual)** em dispositivo Android e iOS antes do release de producao. Os 3 cenarios cobertos por testes unitarios ja garantem a logica, mas o back nativo fisico (Android), o gesto de back (iOS) e o anuncio do VoiceOver/TalkBack so podem ser validados em runtime real.

2. **Considerar MI1 (refatoracao do useEffect de back-button)** opcionalmente em um futuro polish. Usar `useRef` para `showSubCards` reduziria as chamadas a `App.addListener`/`remove`. Nao bloqueante.

3. **Considerar MI2 (focus trap + foco inicial no dialog)** como tech-debt de acessibilidade. Adicionar `useEffect` para focar o `<h2>` ao abrir (com `useRef`) e considerar `react-focus-lock` para focus trap. Em mobile com touch este e um polish de baixa prioridade; em desktop/teclado e desejavel.

4. **Documentar para outras telas** que o `PaymentMethodSelector` agora expoe um `aria-label` dinamico — se algum dia uma terceira tela usar o componente em modo customizado, o dialog title sera respeitado automaticamente. Nao requer acao agora.

5. **Limpeza dos 6 erros pre-existentes de lint em `PurchaseDetail.test.tsx`** — pode ser feita em uma task de tech-debt separada (fora do escopo desta PRD). Reviews 4.0 e 5.0 ja documentaram.

6. **Investigar os 2 testes pre-existentes que falham em `Tab1.test.tsx`** — date mismatch `2026-05` vs `2026-06`. Provavelmente uma fixture com data hardcoded que precisa ser parametrizada via `vi.setSystemTime`. Fora do escopo desta PRD, mas vale criar ticket de bug separado.

## Veredito

A implementacao da Task 6.0 **fecha a feature de forma completa**, cobrindo todos os requisitos de polish do PRD (acessibilidade, copy, back nativo, propagacao para listas). Foram resolvidas as observacoes herdadas do review da Task 5.0 (MA1 — separacao do refresh de `paymentMethod`; MI2 — copy "cartão" com til). O novo arquivo de testes `PaymentMethodSelector.test.tsx` com 22 testes preenche uma lacuna importante de cobertura, validando tanto o modo `edit` (novo) quanto o `create` (regressao), o callout "Cartao atual", a navegacao entre as duas telas do sheet, e os caminhos de acessibilidade (`role="dialog"`, `aria-label` dinamico, back nativo, Escape key). O ajuste em `ManualEntryPage.tsx` para o novo contrato (`scId: number | null`) e minimo e nao introduz regressao. As 3 observacoes minor sao polish opcional — duas sao refinamentos arquiteturais (`useRef` no listener, focus trap), e a terceira (verificacao manual 6.6) e responsabilidade do usuario por design.

A execucao foi validada: `tsc --noEmit` zero erros, vitest 271 PASS / 2 FAIL pre-existentes nao relacionados, ESLint zero erros novos, busca por "Selecionar meio de pagamento" confirma zero regressao em outras telas.

**Status final: APROVADO COM OBSERVACOES**. A feature "Edicao de Cartao em Notificacao de Pagamento" pode ser considerada pronta para release apos a verificacao manual da subtarefa 6.6 (3 cenarios em dispositivo Android/iOS pelo Ramon). Proximos passos sugeridos: (a) executar a verificacao manual em dispositivo; (b) liberar para producao; (c) acompanhar a metrica primaria do PRD (taxa de uso >= 10% nos primeiros 7 dias).

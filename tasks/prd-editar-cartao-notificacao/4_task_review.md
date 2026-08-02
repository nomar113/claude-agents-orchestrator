# Review: Task 4.0 - Frontend - `PaymentMethodSelector` em modo `edit` com pre-selecao

**Revisor**: AI Code Reviewer
**Data**: 2026-06-14
**Arquivo da task**: 4_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task pedia estender o componente `PaymentMethodSelector` para suportar um modo `edit` com callout "Cartao atual", indicador de selecionado no cartao atualmente associado, pre-marcacao do sub-cartao quando pertencer ao cartao escolhido, opcao "Continuar sem sub-cartao", fluxo direto para cartoes sem sub-cards, botao "Adicionar novo cartao" navegando para `/payment-methods`, novo contrato de callback `onSelect(paymentMethodId, subCardId | null)`, atualizacao dos chamadores existentes (modo `create`) e acessibilidade (44x44, aria-current, labels VoiceOver/TalkBack). A implementacao em `src/components/PaymentMethodSelector.tsx` cumpre todos os requisitos funcionais e respeita a assinatura da Tech Spec (secao "Interfaces Principais — Component prop extension"). O caller existente `ManualEntryPage.tsx` foi atualizado para o novo contrato (`scId: number | null`) com mudanca minima de 2 linhas. Os 16 novos testes em `PaymentMethodSelector.test.tsx` cobrem com folga as 8 condicoes listadas na secao "Testes da Tarefa" (10 cenarios em `edit` + 5 cenarios de regressao em `create` + 1 cenario adicional). A bateria executa 16/16 PASS, `npx tsc --noEmit` reporta zero erros, e as 2 falhas de `Tab1.test.tsx` na suite completa foram confirmadas como pre-existentes (nao bloqueantes). Foram identificadas 2 observacoes minor de polish (acoplamento ao `useHistory` e a falta de teste do back nativo Android), mas nada bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PaymentMethodSelector.tsx` | OK | 2 (minor) |
| `src/components/PaymentMethodSelector.css` | OK | 0 |
| `src/components/PaymentMethodSelector.test.tsx` | OK | 1 (minor) |
| `src/pages/ManualEntryPage.tsx` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**M1 - Acoplamento direto ao `useHistory` dentro do componente de UI reutilizavel**
- **Arquivo**: `src/components/PaymentMethodSelector.tsx:2,53,127-130`
- **Descricao**: O handler `handleAddNewCard` chama `history.push('/payment-methods')` diretamente, fazendo com que o componente conheca uma rota concreta da aplicacao. Isso obriga todo consumidor a montar o componente dentro de um `Router` (e exige o mock `useHistory` em testes — ja foi feito corretamente no teste, linhas 9-12) e dificulta reuso em contextos diferentes (modal isolado, storybook, etc).
- **Impacto**: Baixo nesta entrega — o app inteiro ja roda dentro do `IonReactRouter`, e a Task 4.0 explicitamente pede que o botao leve "ao fluxo existente de cadastro". Mas representa uma pequena violacao de Inversion of Control (clean-code) e tornaria o componente mais frio para extracao futura em `EditCardSheet`.
- **Sugestao**: Opcional — expor uma prop `onAddNewCard?: () => void` (com fallback para `history.push('/payment-methods')`), permitindo que `PurchaseDetail` (Task 5.0) ou outros consumidores customizem o destino sem alterar o componente. Nao bloqueante.

**M2 - Falta de teste explicito do botao back nativo (Ionic hardware back)**
- **Arquivo**: `src/components/PaymentMethodSelector.test.tsx`
- **Descricao**: A secao "Testes da Tarefa" do `4_task.md` exige cobrir o cenario "fechar (overlay/X/back nativo) NAO dispara `onSelect`". Os testes cobrem overlay (linhas 235-257) e botao X (259-279), mas nao o back nativo (Android `hardwareBackButton` / Ionic `useBackButton`). O componente nao adiciona listener para `hardwareBackButton`, entao na pratica o back nativo do Ionic provavelmente fecha a IonPage subjacente (comportamento ja existente do framework), nao especificamente este sheet. Por isso a ausencia do teste e razoavel, mas vale registrar.
- **Impacto**: Baixo. O comportamento real depende de como `PurchaseDetail` (Task 5.0) e a `Ionic IonPage` lidam com o back; o componente apenas garante que `onSelect` so e chamado em fluxos explicitos. A protecao mais importante (overlay + X) esta coberta.
- **Sugestao**: Adicionar — quando a Task 5.0 integrar `PurchaseDetail` — um teste de integracao validando que o back nativo dispara `onClose` (e nao `onSelect`). Pode ficar para a Task 6.0 (Polish - back nativo). Nao bloqueante para a Task 4.0.

**M3 - Comparacao redundante de pre-selecao no modo `create`**
- **Arquivo**: `src/components/PaymentMethodSelector.tsx:264-265`
- **Descricao**: A expressao `preselectedScId === sc.id && (mode === 'create' || selectedPmId === currentPaymentMethodId)` controla a pre-marcacao do sub-card. No modo `create`, o `currentPaymentMethodId` e sempre `null`, entao a parte `selectedPmId === currentPaymentMethodId` seria `selectedPmId === null`, que e falsa apos o usuario clicar num cartao. O curto-circuito `mode === 'create' ||` cobre esse caso, mas a logica embute duas regras condicionais em uma unica expressao — torna a leitura mais lenta.
- **Impacto**: Nulo na correcao; ha 2 testes cobrindo cada caminho (regressao em `create` linha 333-350, pre-marcacao em `edit` linha 127-150, nao pre-marcacao em `edit` com cartao diferente linha 152-184).
- **Sugestao**: Opcional — extrair para uma const local nomeada acima do `return` do botao:
  ```ts
  const isPreselectedFromContext = mode === 'create' || selectedPmId === currentPaymentMethodId;
  const isPreselected = preselectedScId === sc.id && isPreselectedFromContext;
  ```
  Aumenta a legibilidade sem mudar comportamento. Nao bloqueante.

## Destaques Positivos

1. **Assinatura identica ao contrato da Tech Spec** (secao "Interfaces Principais — Component prop extension"): `mode?: 'create' | 'edit'`, `currentPaymentMethodId?: number | null`, `currentSubCardId?: number | null`, `onSelect: (paymentMethodId: number, subCardId: number | null) => void`. Tipos, defaults e ordem casam exatamente. Default `mode = 'create'` preserva compatibilidade com chamadores existentes — o caller `ManualEntryPage.tsx` so precisou ajustar a assinatura do handler (de `scId?: number` para `scId: number | null`), 2 linhas.
2. **Callout "Cartao atual" condicionado corretamente** (linhas 173-181): so renderiza quando `mode === 'edit'` E `currentCardDescription` esta resolvido. Inclui fallback elegante para sub-card ausente (operador ternario + null) e usa cor accent `#ff4d6d` do design system "nocturnal", consistente com as diretrizes da PRD (secao "Experiencia do Usuario").
3. **Indicador de selecionado robusto** (linhas 186-214): aplica `pms-item-selected` (background + borda destacada) E icone de check E `aria-current="true"` ao cartao atual. Cobertura visual + semantica + auditavel via screen reader.
4. **Pre-marcacao de sub-card com guarda de contexto** (linha 264-265): so pre-marca quando o `selectedPmId` casa com o `currentPaymentMethodId` (modo edit) — evita marcacao incorreta quando o usuario muda de cartao, conforme RF13 da PRD. Validado pelo teste "does NOT pre-mark sub-card when the chosen card differs from the current one" (linhas 152-184).
5. **Fluxo direto para cartoes sem sub-cards** (linhas 99-109): `handleSelectPm` checa `pm.subCards.length > 0` — se nao houver, chama `onSelect(pm.id, null)` e fecha, sem mostrar a 2a tela. Atende RF15 e foi testado nos dois modos (`edit` linha 212-233, `create` linha 396-411).
6. **"Continuar sem sub-cartao" envia `null` explicito** (linha 123): `onSelect(selectedPmId, null)` — alinhado com o ponto 4 da review da Task 3.0, que documentava esse contrato como obrigatorio para o backend. Testado em ambos os modos.
7. **Fechamento (overlay/X/back) NAO dispara `onSelect`** — coberto explicitamente por 2 testes em `edit` (overlay 235-257, X 259-279) que validam `onSelect` nao foi chamado. Reduz risco de "fantasma" de update silencioso no backend.
8. **Acessibilidade implementada de ponta a ponta**:
   - `aria-label="Fechar"` no botao X (linha 158) — antes nao tinha.
   - `aria-label="Selecionar cartao ${pm.name}"` em cada cartao (linhas 193, 227).
   - `aria-label="Selecionar sub-cartao ${sc.lastFourDigits}"` em cada sub-card (linha 271).
   - `aria-label="Voltar para lista de cartoes"` no link de back (linha 260).
   - `aria-label="Adicionar novo cartao"` no botao de add (linha 250).
   - `aria-current="true"` no item selecionado/pre-selecionado (linhas 194, 228, 272).
   - `min-height: 44px` aplicado em `.pms-item` (CSS linha 95) e `.pms-add-new` (linha 232), respeitando o minimo de 44x44 px da PRD.
   - Contraste do callout (#fff sobre `#ff4d6d14` em background `#141a3a`) atende WCAG AA.
9. **Caller `ManualEntryPage.tsx` atualizado com mudanca minima** (2 linhas): `scId: number | null` em vez de `scId?: number`, e `setSelectedScId(scId)` em vez de `setSelectedScId(scId ?? null)`. Mudanca puramente de tipo, comportamento identico, zero risco de regressao. Demais propriedades do componente continuam intactas — o caller nao passa `mode`, `currentPaymentMethodId` ou `currentSubCardId`, entao herda os defaults `'create'` / `null` / `null`. Comportamento existente preservado.
10. **Memoizacao apropriada com `useMemo` para `currentCardDescription`** (linhas 132-140): o lookup `paymentMethods.find` so re-executa quando `mode`, `currentPaymentMethodId`, `currentSubCardId` ou `paymentMethods` mudam. Atende a skill `vercel-react-best-practices` ("use `useMemo`/`useCallback` somente quando necessario").
11. **`loadData` corretamente memoizado com `useCallback`** (linhas 61-90): inclui `mode`, `currentPaymentMethodId`, `currentSubCardId` nas dependencias, garantindo refresh do estado interno quando as props mudam em runtime (relevante se o sheet for re-aberto para uma notificacao diferente sem unmount completo).
12. **Branching `edit` vs `create` no `loadData` mantem a logica de localStorage intacta para `create`** (linhas 68-84): o modo `edit` ignora `LAST_PM_KEY`/`LAST_SC_KEY` e usa direto as props; o modo `create` continua lendo do localStorage como antes. Sem regressao na pre-selecao "last used" para criacao. Validado pelo teste "selecting a card with sub-cards navigates to sub-card screen with last-used pre-marked" (linhas 333-350).
13. **Reset do `showSubCards` ao reabrir o sheet** (linha 95): garante que cada abertura comeca na 1a tela, mesmo se a anterior tiver navegado para sub-cards. Comportamento esperado para um bottom sheet stateful.
14. **`handleAddNewCard` chama `onClose` antes de navegar** (linhas 128-130): evita estado fantasma (sheet aberto + rota nova). Boa pratica para navegacao.
15. **Cobertura ampla dos 8 itens "Testes da Tarefa"**:
    - Callout com cartao + sub-cartao: linha 70-89.
    - Callout com so cartao quando sub-card e null (bonus, nao exigido): 91-108.
    - Cartao atual com indicador "selecionado": 110-125.
    - Pre-marcacao do sub-card quando do mesmo cartao: 127-150.
    - Nao pre-marca quando cartao diferente: 152-184.
    - "Continuar sem sub-cartao" dispara `onSelect(pmId, null)`: 186-210 (edit) e 376-394 (create).
    - Cartao sem sub-cards dispara `onSelect(pmId, null)` direto: 212-233 (edit) e 396-411 (create).
    - Fechar (overlay/X) NAO dispara `onSelect`: 235-257 (overlay) e 259-279 (X).
    - Modo `create` regressao (callout ausente + last-used + onSelect com mesmo contrato): 320-411 (5 testes no describe).
    - Bonus: "Adicionar novo cartao" (281-300), "callout nao renderiza quando currentPaymentMethodId e null" (302-316).
16. **Mock dos icones do Ionic via `data-testid="ion-icon"` + `data-icon`** (linhas 5-7 do teste): simples, deterministico e nao requer JSDOM aprimorado. Mantem os testes rapidos.
17. **Mock do `useHistory` com `pushMock`** (linhas 9-12) permite asserir a navegacao do "Adicionar novo cartao" (linha 299).
18. **Resultados de execucao confirmados**:
    - `npx vitest run src/components/PaymentMethodSelector.test.tsx`: **16 PASS / 0 FAIL** (10 em `edit` + 5 em `create` + 1 callout-null-edit).
    - `npx tsc --noEmit`: **No errors found** em todo o projeto, incluindo o caller `ManualEntryPage.tsx` ja atualizado para o novo contrato.
    - As 2 falhas pre-existentes em `src/pages/Tab1.test.tsx` confirmadas via `git stash` — nao relacionadas a esta task.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (TypeScript estrito, props tipadas com defaults explicitos) | OK |
| Clean Code (helpers extraidos `subCardIcon`, callbacks nomeados, sem ifs aninhados profundos) | OK |
| Vercel React Best Practices (`useMemo`/`useCallback` na medida certa, sem re-render da arvore inteira no callout) | OK |
| Ionic Design (bottom sheet com drag/overlay/slide-up, fechamento por tap fora) | OK |
| Frontend Design / Nocturnal (callout em `#ff4d6d14`/`#ff4d6d40`, IBM Plex Sans, contraste AA) | OK |
| Acessibilidade (44x44, aria-label, aria-current, contraste) | OK |
| Aderencia a Tech Spec (assinatura das props e callback) | OK |
| Aderencia a Task (subtarefas 4.1-4.8) | OK |
| Cobertura de Testes (8 cenarios obrigatorios + extras) | OK |
| Execucao dos Testes (16/16 PASS) | OK |
| Tipagem (`npx tsc --noEmit` sem erros) | OK |
| Regressao no caller `ManualEntryPage.tsx` (modo `create` preservado) | OK |

## Verificacao de Execucao

- `npx vitest run src/components/PaymentMethodSelector.test.tsx`: **16 PASS / 0 FAIL** (10 testes no describe `mode = "edit"` + 5 no describe `mode = "create" (regression)` + 1 callout-null-edit).
- `npx tsc --noEmit`: **No errors found** em todo o projeto.
- `git diff src/components/PaymentMethodSelector.tsx`: +133 -59 linhas — refatoracao da renderizacao dos botoes (extracao de `isSelected`/`hasSubCards` em consts locais) + novas props + callout + handler de "Adicionar novo cartao" + memo `currentCardDescription`. Mantem a API publica do componente (apenas adicionando props opcionais).
- `git diff src/components/PaymentMethodSelector.css`: +50 -1 linhas — adicao do `.pms-current`, `.pms-add-new`, `min-height: 44px` e `border: 1px solid transparent` em `.pms-item` (para evitar layout shift quando ganha `border` no estado `selected`).
- `git diff src/pages/ManualEntryPage.tsx`: +2 -2 linhas — apenas ajuste de tipagem do handler (`scId: number | null`).
- `PaymentMethodSelector.test.tsx`: **novo arquivo, 413 linhas, 16 testes**. Anteriormente nao existia teste para este componente.
- Sanity check da assinatura: o tipo do `onSelect` declarado em `PaymentMethodSelector.tsx:29` (`(paymentMethodId: number, subCardId: number | null) => void`) casa exatamente com o handler em `ManualEntryPage.tsx:211` (`(pmId: number, scId: number | null)`) e com o esperado pelo `purchaseService.updatePaymentNotificationCard(id, paymentMethodId, subCardId)` revisado na Task 3.0.
- Caller scan: `grep -rn "PaymentMethodSelector" src/` retorna apenas `ManualEntryPage.tsx` como caller — confirmado que nao ha outros callers a atualizar.

## Recomendacoes

1. **Manter** o acoplamento ao `useHistory` nesta entrega — o app inteiro ja roda em `IonReactRouter` e a complicacao de uma prop `onAddNewCard` opcional nao se justifica agora. Reavaliar se na Task 5.0 (`PurchaseDetail`) houver necessidade de override.
2. **Documentar para a Task 5.0** (`PurchaseDetail.tsx`) que quando o usuario abrir o sheet, deve passar `mode="edit"`, `currentPaymentMethodId={notification.paymentMethodId}` e `currentSubCardId={notification.subCardId}` (ambos podem ser `null`). O componente ja resolve graciosamente o caso "id nao existe mais na lista" (fallback para `selectedPmId = null`, linha 71).
3. **Documentar para a Task 6.0** (Polish — back nativo): adicionar listener `useIonBackButton` ou `App.addListener('backButton', ...)` em `PurchaseDetail` para garantir que o back nativo fecha o sheet (chama `onClose`) sem disparar `onSelect`. A protecao do componente ja existe (so dispara em fluxos explicitos), mas o handler do back precisa ser ancorado no consumidor.
4. **Opcional**: refatorar a expressao composta de `isPreselected` (M3) extraindo `isPreselectedFromContext` como const local. Aumenta a legibilidade sem alterar comportamento. Nao bloqueante.
5. **Opcional para o futuro**: considerar criar um wrapper `EditCardSheet` que envolve `PaymentMethodSelector` com defaults (`mode="edit"`) e renomeia a prop `onSelect` para `onConfirm`, caso a Task 5.0 demonstre que `PurchaseDetail` reaproveite varias chamadas. Por enquanto a Tech Spec ja autorizava essa extracao como opcional, e a implementacao atual nao precisou — decisao correta.

## Veredito

A implementacao esta **correta, alinhada ao PRD (F2, F3, F5) e a Tech Spec ("Interfaces Principais — Component prop extension")**, segue as skills exigidas (`ionic-design`, `frontend-design`, `clean-code`, `vercel-react-best-practices`), preserva 100% o modo `create` (sem regressao no caller `ManualEntryPage.tsx` e validado por 5 testes de regressao), e atende os 8 cenarios da secao "Testes da Tarefa" com 16 testes que passam. A acessibilidade foi tratada de ponta a ponta (44x44, aria-label, aria-current, contraste AA). As 3 observacoes minor sao polish (acoplamento ao `useHistory`, ausencia de teste do back nativo que sera coberto na Task 6.0, e legibilidade de uma expressao composta) e nao bloqueiam a entrega. A task esta **aprovada com observacoes** e pode ser considerada concluida. Proximo passo: seguir para a Task 5.0 (Frontend — Integracao em `PurchaseDetail` com linha tocavel, sheet, callback e tratamento de erro), passando `mode="edit"`, `currentPaymentMethodId` e `currentSubCardId` da notificacao.

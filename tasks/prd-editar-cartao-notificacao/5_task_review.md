# Review: Task 5.0 - Frontend - Integracao em `PurchaseDetail` (linha tocavel, sheet, callback, erro)

**Revisor**: AI Code Reviewer
**Data**: 2026-06-15
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task pedia integrar o fluxo de edicao de cartao na pagina `PurchaseDetail`: tornar a linha "Cartao" tocavel apenas quando `type === 'notification'` && `!cancelledAt`, abrir o `PaymentMethodSelector` em modo `edit` com os ids atuais da notificacao, chamar `updatePaymentNotificationCard`, atualizar o estado local (brand badge, nome, ultimos digitos) sem pull-to-refresh, gerenciar loading visivel, tratar erro mantendo o estado anterior com opcao de retry preservando a selecao do usuario, e garantir idempotencia. A implementacao cumpre todos os requisitos funcionais (RF1, RF2, RF3, RF4, RF19, RF20, RF21 do PRD) e segue exatamente o contrato definido na Tech Spec (secao "Fluxo de Dados", passos 1-6). Foram adicionados 4 estados (`isCardSheetOpen`, `isUpdatingCard`, `cardUpdateError`, `lastCardSelection`), um `useCallback` `performCardUpdate` que centraliza a transacao, dois handlers (`handleCardSelect` e `handleRetryCardUpdate`), uma derivacao `canEditCard`, e a UI da linha foi bifurcada entre `button` (tocavel) e `div` (readonly) com `data-testid` distintos para facilitar os testes. O banner de erro inclui `role="alert"` para acessibilidade e botao "Tentar novamente" com `disabled` durante o re-fetch. Os 10 novos testes em `PurchaseDetail.test.tsx` cobrem os 8 cenarios obrigatorios da task + 2 cenarios adicionais (retry com sucesso + integracao end-to-end com o `PaymentMethodSelector` real). Resultados: **PurchaseDetail.test.tsx: 34/34 PASS**, **suite completa: 265 PASS / 2 FAIL pre-existentes em `Tab1.test.tsx`** (confirmadas como nao introduzidas pela task), **`npx tsc --noEmit`: zero erros**, **ESLint: 6 erros no `PurchaseDetail.test.tsx` (todos pre-existentes — eram 7 antes, a task removeu 1)**. Foram identificadas 1 observacao major (consistencia em caso de falha do `getPaymentMethod` apos sucesso do update) e 3 observacoes minor (timing de `setLastCardSelection`, falta de `currentCardDescription` quando paymentMethod ainda nao foi carregado, copy do erro sem acento). Nenhuma observacao bloqueia a entrega.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/pages/PurchaseDetail.tsx` | OK | 1 (major) + 2 (minor) |
| `src/pages/PurchaseDetail.css` | OK | 0 |
| `src/pages/PurchaseDetail.test.tsx` | OK | 1 (minor) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**MA1 - `performCardUpdate` trata falha do `getPaymentMethod` (refresh do brand/nome) como falha da operacao inteira, exibindo erro enganoso ao usuario quando o backend ja persistiu o novo cartao**
- **Arquivo**: `src/pages/PurchaseDetail.tsx:341-356`
- **Descricao**: O bloco try faz duas chamadas sequenciais:
  ```ts
  const updated = await updatePaymentNotificationCard(numId, paymentMethodId, subCardId); // 1. backend persiste
  setNotification(updated);                                                                // 2. estado local atualizado
  const pm = await getPaymentMethod(paymentMethodId);                                      // 3. refresh do brand/nome
  setPaymentMethod(pm);
  setLastCardSelection(null);
  ```
  Se a chamada (3) falhar (rede instavel, 404 em um cartao recem-criado em outro device, etc), o `catch` trata como `cardUpdateError`. Resultado:
  - `notification` ja foi atualizada para `paymentMethodId/subCardId` novos
  - `paymentMethod` mantem o antigo (porque o `setPaymentMethod(pm)` nao executou)
  - A UI exibe banner de erro + botao "Tentar novamente"
  - `lastCardSelection` continua setado, entao o retry vai re-disparar a operacao completa (que sera idempotente no backend — OK)
  - Ao retry, se `getPaymentMethod` continuar falhando, o usuario fica preso em um loop de erro que **nao corresponde a realidade do backend** (ja persistido).
  - Pior: ao silent-refresh (sair e voltar para a tela), o backend retorna a notificacao com o novo cartao, e o paymentMethod sera re-buscado pelo `load()` normal — o estado "real" e o do backend, nao o que a UI ainda esta exibindo como "erro".
- **Impacto**: Medio. A operacao primaria (a transacao do PRD/RF16-18) **foi persistida com sucesso**, entao em terminos de integridade dos dados nao ha problema. Mas a UX e enganosa: o usuario ve um erro vermelho e um botao retry que, na verdade, nao precisa ser acionado. Probabilidade de ocorrencia e baixa (depende do `getPaymentMethod` falhar isoladamente apos sucesso de `updatePaymentNotificationCard`), mas o cenario e plausivel em rede 4G/3G instavel.
- **Sugestao**: Separar o refresh do `paymentMethod` em try/catch interno e nao bloquear o sucesso da operacao caso ele falhe. Manter o `setLastCardSelection(null)` no fluxo de sucesso da chamada principal:
  ```ts
  try {
    const updated = await updatePaymentNotificationCard(numId, paymentMethodId, subCardId);
    setNotification(updated);
    setLastCardSelection(null);
    try {
      const pm = await getPaymentMethod(paymentMethodId);
      setPaymentMethod(pm);
    } catch { /* refresh failed; useIonViewWillEnter on next visit will sync */ }
  } catch (e) {
    setCardUpdateError(e instanceof Error ? e.message : 'Erro ao atualizar cartao');
  } finally {
    setIsUpdatingCard(false);
  }
  ```
  Alternativa: fazer o backend ja retornar o `paymentMethod` completo no response do PATCH (mas isso mexeria no contrato definido na Tech Spec e na Task 1.0/2.0 backend).

### Problemas Minor

**MI1 - Timing de `setLastCardSelection({...})` antes do try expoe brevemente o botao retry caso a 1a falha aconteca enquanto o usuario abre outra UI**
- **Arquivo**: `src/pages/PurchaseDetail.tsx:344`
- **Descricao**: `setLastCardSelection({ paymentMethodId, subCardId })` ocorre na linha 344, antes do try. Como o React batches state updates, na pratica isso so e visivel apos o render seguinte. Mas semanticamente o "last selection" so faz sentido se houve uma tentativa real. Se um erro raro no fetch (e.g. AbortError) for lancado antes de qualquer request, o estado `lastCardSelection` ja esta setado e a UI exibira o retry. Pequena questao de modelagem de estado.
- **Impacto**: Muito baixo. Em pratica nao causa bug — o retry funcionara corretamente. Apenas mistura "intencao" com "estado de erro".
- **Sugestao**: Opcional — mover o `setLastCardSelection({...})` para dentro do `catch`:
  ```ts
  try {
    const updated = await updatePaymentNotificationCard(...);
    ...
  } catch (e) {
    setLastCardSelection({ paymentMethodId, subCardId });
    setCardUpdateError(...);
  }
  ```
  Mais limpo, mas requer ajuste no `handleRetryCardUpdate` para limpar `lastCardSelection` apos sucesso do retry (que ja acontece via fluxo normal). Nao bloqueante.

**MI2 - Mensagem de erro padrao "Erro ao atualizar cartao" sem acento (cartão) inconsistente com o resto da copy em pt-BR**
- **Arquivo**: `src/pages/PurchaseDetail.tsx:352`
- **Descricao**: A string `'Erro ao atualizar cartao'` usa "cartao" sem til. O restante do app usa "Cartão" com til (exemplos: `aria-label="Editar cartão"` linha 499, `<span className="pd-info-key">Cartão</span>` linha 502, `aria-label="Atualizando"` linha 509, "Adicionar descrição..." linha 482). Pequena inconsistencia visual.
- **Impacto**: Cosmetico. So aparece quando a excecao nao traz uma `message` propria (o que e raro — `fetch`/`CapacitorHttp` normalmente lancam `Error` com message).
- **Sugestao**: Trocar para `'Erro ao atualizar cartão'`. Mudanca de 1 char.

**MI3 - Teste "renders card field as tappable button..." nao valida visibilidade do icone de edicao (lapis)**
- **Arquivo**: `src/pages/PurchaseDetail.test.tsx:718-724`
- **Descricao**: O teste verifica que o `card-field` e um `<button>` mas nao valida que o icone `createOutline` aparece dentro dele (requisito RF1/RF2 do PRD: "icone de lapis alinhado a direita"). Como os mocks de `ionicons/icons` retornam apenas strings e o `IonIcon` mock renderiza um `<span>`, nao da pra asserir por `aria-label="Editar cartão"` (mock substitui pelo `data-icon`). Cobertura do icone fica implicita.
- **Impacto**: Baixo. O comportamento do icone esta presente no codigo (linha 511) e e visivel manualmente; o lint/tsc validam que `createOutline` existe e e usado. Mas um teste explicito reduziria risco de regressao se alguem remover o icone acidentalmente.
- **Sugestao**: Opcional — adicionar um teste:
  ```ts
  it('shows pencil icon when card field is editable', async () => {
    vi.mocked(purchaseService.getPaymentNotification).mockResolvedValue({ ...baseNotification });
    render(<PurchaseDetail />);
    const field = await screen.findByTestId('card-field');
    // Pencil icon (createOutline) must be visible (not spinner)
    expect(field.querySelector('.pd-edit-icon')).not.toBeNull();
    expect(field.querySelector('.pd-card-spinner')).toBeNull();
  });
  ```
  Nao bloqueante; o teste de erro (`keeps previous state and shows error message`) ja exercita o caminho de re-render onde o spinner desaparece e o icone volta.

## Destaques Positivos

1. **Bifurcacao da linha "Cartao" entre `<button>` (canEditCard) e `<div>` (readonly) com testids distintos** (`card-field` / `card-field-readonly`) — torna a affordance semantica clara para HTML/aria, e facilita os testes sem usar query por papel ou texto. Atende RF1, RF2 e RF3 do PRD com cobertura 100% por testes.

2. **Derivacao `canEditCard = type === 'notification' && !cancelledAt`** (linha 339) — uma unica fonte de verdade para a affordance, evita repeticao da regra em multiplos lugares. Atende a skill `clean-code` (DRY).

3. **`useCallback` em `performCardUpdate` com dependencia `[numId]`** (linha 356) — minimiza re-criacao da funcao a cada render. O `numId` e derivado de `useParams`, entao a callback so muda quando a rota muda. Atende a skill `vercel-react-best-practices`.

4. **Sheet so renderiza quando `notification` esta carregada** (linhas 816-825) — guarda condicional `type === 'notification' && notification && (...)` previne render do `PaymentMethodSelector` com `currentPaymentMethodId` indefinido durante o loading inicial. Bom estado robusto.

5. **Banner de erro com `role="alert"` e `data-testid="card-update-error"`** (linha 528) — acessivel para screen readers (anuncia o erro automaticamente quando aparece) e testavel sem depender de copy.

6. **Botao "Tentar novamente" so renderiza quando ha `lastCardSelection`** (linha 531) — previne tentativa de retry com dados indefinidos. Defensive coding correto.

7. **Botao "Tentar novamente" `disabled={isUpdatingCard}`** (linha 535) — bloqueia cliques duplos durante o re-fetch. Atende RF20 e a UX do PRD ("Feedback de loading visivel").

8. **`disabled={isUpdatingCard}` no proprio `<button>` da linha Cartao** (linha 498) — bloqueia tap durante a operacao. Combinado com o spinner inline na linha (509), da feedback visual + comportamental ao usuario.

9. **Spinner inline animado** (`.pd-card-spinner` no CSS linha 230-242) — usa borda dupla com `border-top-color: #ff4d6d` (accent rosa do sistema "nocturnal") + animacao CSS `pd-card-spin` de 0.8s. Visualmente consistente com o design system, sem dependencia de novas libs.

10. **Banner de erro alinhado ao design system** — fundo `rgba(255, 107, 107, 0.08)`, borda `rgba(255, 107, 107, 0.2)`, texto `rgba(255, 255, 255, 0.8)`, botao retry com `min-height: 32px` (proximo do alvo 44x44 — aceitavel para um link de acao secundaria), `cursor: not-allowed` quando disabled. Contraste AA mantido.

11. **`PaymentMethodSelector` integrado com `mode="edit"` e ambos os ids** (linhas 816-825):
    ```tsx
    <PaymentMethodSelector
      isOpen={isCardSheetOpen}
      mode="edit"
      currentPaymentMethodId={notification.paymentMethodId}
      currentSubCardId={notification.subCardId}
      onClose={() => setIsCardSheetOpen(false)}
      onSelect={handleCardSelect}
    />
    ```
    Casa exatamente com o contrato da Task 4.0 (revisado e aprovado no 4_task_review.md).

12. **Idempotencia preservada** — o teste "re-confirming the same card does not surface an error and calls API once" (linhas 863-881) valida explicitamente RF21. Como o backend usa apenas update em colunas existentes (conforme Tech Spec), e o frontend nao impede a chamada, o ciclo e seguro e o usuario nao ve erro.

13. **Cobertura completa dos 8 cenarios obrigatorios** + 2 extras (`retries with the same selection` + `keeps suggestions service untouched and integrates the real PaymentMethodSelector end-to-end`):
    - tocavel quando `notification` && `!cancelledAt`: linhas 718-724
    - readonly quando `cancelledAt`: 726-734
    - nao renderiza em `invoice`: 736-762
    - abre sheet ao tocar: 764-769
    - chama `updatePaymentNotificationCard` com ids corretos: 771-787
    - sucesso atualiza display (brand + nome + digits): 789-812
    - erro mantem estado anterior + exibe mensagem: 814-832
    - idempotencia: 863-881
    - retry com sucesso (bonus): 834-861
    - integracao end-to-end com `PaymentMethodSelector` real (bonus): 883-904

14. **Teste de integracao usa o `PaymentMethodSelector` real, nao mock** (linhas 883-904) — atende exatamente o `Testes da Tarefa` da task 5.0 ("Testes de integracao - montagem da pagina com `PaymentMethodSelector` real (sem mockar o componente filho)"). Valida que o `listHolders` e `listPaymentMethods` sao chamados, e que apos selecionar um cartao sem sub-cards o display e atualizado e o sheet fecha. Excelente cobertura.

15. **Mocks dos servicos sao isolados via `vi.mock` no topo do arquivo** (linhas 64-104) — segue o padrao ja usado no resto do `PurchaseDetail.test.tsx`. Helper `paymentMethodService.getPaymentMethod` retorna por id (linhas 711-715), facilitando todos os testes que precisam refrescar o `paymentMethod` apos sucesso.

16. **CSS extras (`.pd-card-spinner`, `.pd-card-error*`) localizados em uma secao dedicada** (linhas 229-285) com comentario `/* ── Card edit ── */` no inicio. Mantem a organizacao do arquivo CSS pre-existente.

17. **Brand badge sobrevive ao update via re-fetch do `paymentMethod`** — apos sucesso, `getPaymentMethod(paymentMethodId)` e chamado e o `setPaymentMethod(pm)` atualiza o estado, o que faz o `paymentMethod.brand` (linha 504) re-renderizar com o novo valor (ex.: `MASTERCARD` -> `VISA`). Validado pelo teste "updates display (brand, name, digits)..." (linhas 789-812).

18. **Cancelados nao recebem affordance E nao recebem banner de erro tampouco** — quando `cancelledAt` esta setado, o `canEditCard` e false, entao nem o `<button>` nem o erro inline aparecem (esse ultimo so renderiza se houver `cardUpdateError`, que nao pode existir se nunca houve interacao). Atende RF3 estritamente.

19. **Execucao validada**:
    - `npx vitest run src/pages/PurchaseDetail.test.tsx`: **34 PASS / 0 FAIL** (24 pre-existentes + 10 novos)
    - `npx vitest run` (suite completa): **265 PASS / 2 FAIL** — as 2 falhas estao em `Tab1.test.tsx` (`Tab1 loads data on initial mount` + `Tab1 silent refresh via useIonViewWillEnter does not show loading skeleton`), pre-existentes e confirmadas nas reviews 3.0 e 4.0 como nao relacionadas.
    - `npx tsc --noEmit`: **zero erros** em todo o projeto.
    - `npx eslint src/pages/PurchaseDetail.test.tsx`: 6 erros — **TODOS pre-existentes**. Validacao via `git stash`: pre-existente tinha **7 erros**, a task **removeu 1** (o `paymentMethodService` deixou de ser unused). Os outros 6 (`any` em mocks dos modulos do Ionic, `installmentService` unused, `icon` unused na destruturacao) ja estavam la antes.
    - `npx eslint src/pages/PurchaseDetail.tsx`: **zero erros**.

20. **Mudanca minima e cirurgica no arquivo principal** — `git diff src/pages/PurchaseDetail.tsx`: **+90 -7 linhas**. O `-7` se refere apenas a refatoracao da `<div className="pd-info-row">` antiga para a versao bifurcada `canEditCard ? <button> : <div>`. Nenhum efeito colateral em outras secoes do componente (description, date, category, installments, suggestions, etc).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (TypeScript estrito, props tipadas, callbacks nomeados) | OK |
| Clean Code (DRY no `canEditCard`, separacao de logica/UI/transport em `performCardUpdate` + handlers) | OK |
| TypeScript (tsc --noEmit zero erros, tipos discriminados em `lastCardSelection`) | OK |
| React (useCallback com deps corretas, useState minimo, sem efeitos colaterais desnecessarios) | OK |
| Vercel React Best Practices (useCallback apenas onde necessario, sem useMemo prematuro) | OK |
| Ionic Design (sem novos componentes Ionic novos; usa `IonIcon` no spinner-icon; reusa `useIonViewWillEnter` pre-existente) | OK |
| Frontend Design / Nocturnal (`#ff4d6d` no spinner, `rgba(255,107,107,...)` no banner de erro consistente com sistema, IBM Plex Sans, contraste AA) | OK |
| Acessibilidade (`aria-label="Editar cartão"`, `aria-label="Atualizando"` no spinner, `role="alert"` no banner, `disabled` em estados ocupados) | OK |
| REST/HTTP (nao aplicavel diretamente — usa servico ja revisado na Task 3.0) | OK |
| Aderencia ao PRD (F1, F4, F5 — RF1, RF2, RF3, RF4, RF19, RF20, RF21) | OK |
| Aderencia a Tech Spec (Fluxo de Dados passos 1-6; uso do `PaymentMethodSelector` em modo `edit` com `currentPaymentMethodId`/`currentSubCardId`) | OK |
| Aderencia a Task (subtarefas 5.1-5.6) | OK |
| Cobertura de Testes (8 cenarios obrigatorios + 2 extras) | OK |
| Execucao dos Testes (34/34 PASS no arquivo, suite global 265/267 com 2 pre-existentes) | OK |
| Regressao (zero — nenhuma quebra em testes pre-existentes; `Tab2`, `Tab3`, `BudgetPage`, `PaymentMethodsPage` continuam verdes) | OK |

## Verificacao de Execucao

- `npx vitest run src/pages/PurchaseDetail.test.tsx`: **34 PASS / 0 FAIL**.
- `npx vitest run` (suite completa): **267 testes / 265 PASS / 2 FAIL pre-existentes** (confirmados como `Tab1 loads data on initial mount` + `Tab1 silent refresh via useIonViewWillEnter does not show loading skeleton`).
- `npx tsc --noEmit`: **No errors found** em todo o projeto.
- `npx eslint src/pages/PurchaseDetail.tsx`: 0 erros / 0 warnings.
- `npx eslint src/pages/PurchaseDetail.test.tsx`: 6 erros pre-existentes (eram 7 antes — 1 foi removido pela task). Nenhum erro novo introduzido.
- `git diff src/pages/PurchaseDetail.tsx`: **+90 -7 linhas** (refatoracao da linha "Cartao" + estado + handlers + sheet + banner de erro).
- `git diff src/pages/PurchaseDetail.css`: **+58 -0 linhas** (apenas adicao da secao "Card edit").
- `git diff src/pages/PurchaseDetail.test.tsx`: novo describe block "PurchaseDetail - Card editing" com 10 testes + ajustes em mocks (descomenta `paymentMethodService.getPaymentMethod` para test setup).
- Caller scan: nenhuma outra pagina importa diretamente o estado/handler de `PurchaseDetail`, entao zero risco de regressao downstream.

## Recomendacoes

1. **Aplicar a correcao MA1** antes do release — separar o re-fetch de `getPaymentMethod` em um try/catch interno para nao bloquear o sucesso da operacao principal. Diff e pequeno (~5 linhas) e elimina o cenario de "erro fantasma" quando o backend ja persistiu o cartao. Idealmente como parte desta task ou como hotfix na Task 6.0 (Polish).

2. **Aplicar MI2 (acento em "cartão")** — mudanca de 1 caractere, alinha copy ao restante do app.

3. **Considerar MI1 (timing de `setLastCardSelection`)** — refatoracao opcional para clareza semantica. Pode ficar para a Task 6.0 ou um polish posterior.

4. **Documentar para a Task 6.0** (Polish — cache de outras paginas):
   - Adicionar invalidacao/refetch na `Tab1.tsx` quando o usuario voltar do `PurchaseDetail` apos edicao bem-sucedida (RF22 do PRD).
   - Considerar atualizar a `BudgetPage` similar (RF23).
   - Adicionar listener `useIonBackButton` em `PurchaseDetail` para fechar o sheet sem disparar `onSelect`.

5. **Considerar MI3 (teste do icone de edicao)** — opcional; o comportamento esta verificado via teste de "atualiza display apos sucesso", mas um teste explicito ajudaria a documentar a affordance visual.

6. **Limpeza de lint pre-existente** (fora do escopo desta task) — os 6 erros em `PurchaseDetail.test.tsx` (`@typescript-eslint/no-explicit-any` nos mocks de `@ionic/react` e `ionicons/icons`, `installmentService` e `icon` unused) sao pre-existentes desde antes da PRD. Vale criar uma task de tech-debt para limpar.

## Veredito

A implementacao esta **correta, alinhada ao PRD (F1, F4, F5) e a Tech Spec (Fluxo de Dados, passos 1-6)**, segue todas as skills exigidas (`ionic-design`, `frontend-design`/`ui-ux-pro-max`, `clean-code`, `vercel-react-best-practices`), preserva 100% do comportamento existente do `PurchaseDetail` (categoria, descricao, data, parcelas, sugestoes de invoice, cancel, delete continuam funcionando — validado pelos 24 testes pre-existentes que continuam verdes), e atende os 8 cenarios obrigatorios da `Testes da Tarefa` com 10 testes que passam, incluindo o teste de integracao end-to-end com o `PaymentMethodSelector` real (sem mock do filho), conforme exigido. A acessibilidade foi tratada (`aria-label`, `role="alert"`, `disabled` em estados ocupados, contraste AA, 44x44 implicito via padding do `.pd-info-row`). A observacao **MA1** (consistencia em caso de falha do `getPaymentMethod` apos sucesso do update) e a unica que merece atencao maior — nao bloqueia o release porque a operacao primaria continua integra no backend (o estado real esta sempre certo, apenas a UI exibe erro enganoso em um cenario raro de rede instavel) — mas e recomendado corrigir antes de liberar para producao. As 3 observacoes minor sao polish (timing de state, copy, teste extra). A task esta **aprovada com observacoes** e pode ser considerada concluida. Proximo passo: Task 6.0 (Polish — invalidacao de cache em Tab1/BudgetPage + back nativo do Android no sheet), conforme `Riscos Conhecidos` da Tech Spec.

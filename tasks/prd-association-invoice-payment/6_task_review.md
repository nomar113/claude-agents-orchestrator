# Review: Task 6.0 - SuggestionsPage - Modal de Confirmacao

**Revisor**: AI Code Reviewer
**Data**: 2026-05-23
**Arquivo da task**: 6_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Task 6.0 altera corretamente o fluxo da `SuggestionsPage`: o tap em
uma sugestao deixa de navegar para `/purchase/invoice/:id/associate` e
passa a abrir um modal de confirmacao inline reusando o `ConfirmDialog`
existente. O componente `ConfirmDialog` foi estendido de forma
nao-breaking com 3 props opcionais (`children`, `loading`, `error`) que
permitem renderizar o resumo lado-a-lado do invoice e da notification,
exibir mensagem de erro e desabilitar os botoes durante a chamada
assincrona. O handler `handleConfirmAssociation` chama
`associateInvoice(invoiceId, notificationId)`, trata erros 409 com
mensagem especifica ("Pagamento ja associado a outra nota"), os demais
com mensagem generica, e em caso de sucesso redireciona para
`/purchase/invoice/{id}`. O botao "Associar manualmente" segue
navegando para a pagina de busca conforme requisito da Task 6.5.

A cobertura de testes e excelente: 6 cenarios novos cobrindo abertura
do modal, renderizacao do resumo lado-a-lado, cancelamento, sucesso
(IDs corretos + redirect), erro 409 e erro generico. A correcao do
mock de `useParams` (de `invoiceId` para `id`) ja consertou um bug
latente no setup de testes do arquivo, e o test do "Associar
manualmente" foi atualizado para refletir o payload reduzido (sem dados
de notification, que agora ficam no modal).

`npx vitest run src/pages/SuggestionsPage.test.tsx` retorna 20/20, os
consumidores do `ConfirmDialog` (`CategoriesPage`, `PaymentMethodsPage`,
`PurchaseList`) seguem 18/18 verde, `npx tsc --noEmit` retorna 0 e
`npx vite build` conclui com sucesso. As 6 falhas em `Tab2.test.tsx`
foram confirmadas como pre-existentes via `git stash` (mock incompleto
de `cancelInvoice`, sem qualquer relacao com esta task).

As observacoes sao todas Minor: pequenos detalhes de polimento na UX
do modal (sem fechamento por ESC ou clique no overlay durante loading
ja esta certo, mas falta foco inicial), reuso de tokens de cor
(`#ff6b6b` aparece hardcoded em 3 lugares novos quando ja existe no
botao confirm do dialog), parsing fragil do codigo HTTP 409 via
`message.includes('409')` (que matcharia tambem `Error 4090` ou
`HTTP 1409`, hipotetico), e ausencia de teste para o estado
`loading`/`disabled` durante a chamada.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/ConfirmDialog.tsx` (modificado, +24 -3) | OK com Minor | 1 |
| `src/components/ConfirmDialog.css` (modificado, +19) | OK | 0 |
| `src/pages/SuggestionsPage.tsx` (modificado, +77 -15) | OK com Minors | 3 |
| `src/pages/SuggestionsPage.css` (modificado, +61) | OK com Minor | 1 |
| `src/pages/SuggestionsPage.test.tsx` (modificado, +124 -16) | OK com Minor | 1 |

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Padroes de Codigo (TypeScript) | OK | camelCase, PascalCase, kebab-css respeitados; sem `any` no codigo de producao; sem magic numbers materiais |
| Reuso do `ConfirmDialog` em vez de criar dialog customizado | OK | Decisao certa -- estender o componente compartilhado com props opcionais mantem a UX consistente com `CategoriesPage`, `PaymentMethodsPage`, `PurchaseList` |
| Backward compatibility | OK | As 3 novas props sao opcionais (`children?`, `loading?`, `error?`); os 4 outros call sites do ConfirmDialog nao precisaram ser tocados e seus testes (18/18) seguem passando |
| Tipos TypeScript explicitos | OK | `ReactNode` importado como `type`, props com tipos explicitos |
| Naming consistente de classes CSS | OK | Prefixo `cd-` para novas classes do dialog e `sg-confirm-*` para o conteudo proprio da pagina -- segue o padrao prefixo-por-componente ja usado no arquivo |
| Sem comentarios desnecessarios | OK | Apenas `// RF20: ...` e `// RF22: ...` (rastreabilidade ao PRD) e um comentario explicativo no teste sobre dupla renderizacao do merchant name |
| Imports em ordem | OK | `associateInvoice` adicionado na ordem alfabetica no import existente; `ConfirmDialog` importado apos os imports de servicos |
| Testes presentes e passando | OK | 6 cenarios novos, 20/20 testes do arquivo passando |

## Aderencia a TechSpec

| Decisao Tecnica | Implementado | Observacoes |
|-----------------|--------------|-------------|
| Modal inline para sugestoes (linha 191 techspec) | SIM | `ConfirmDialog` renderizado dentro do `IonContent` da `SuggestionsPage` |
| Reusar `ConfirmDialog.tsx` existente (linha 221 techspec) | SIM | Componente existente estendido em vez de criar `SuggestionConfirmDialog` novo |
| Chamada `associateInvoice(invoiceId, paymentNotificationId)` | SIM | Linha 143: `await associateInvoice(numId, selectedSuggestion.id)` |
| Sucesso -> redirect para PurchaseDetail | SIM | Linha 146: `history.push('/purchase/invoice/' + numId)` |
| Erro 409 -> mensagem adequada | SIM | "Pagamento ja associado a outra nota" |
| Manter rota `/purchase/invoice/:id/associate` para botao "Associar manualmente" | SIM | `handleManualAssociation` (linha 159) preserva o `history.push` original |

## Aderencia ao PRD

| Criterio | Status | Observacoes |
|----------|--------|-------------|
| 4. Tocar em sugestao exibe modal com detalhes lado a lado (invoice vs notification) | OK | Grid de 2 colunas com divider central; cada coluna mostra merchant, valor, data, e a coluna do pagamento adiciona o `cardLastDigits` |
| 4. Confirmar chama `PATCH /associate` | OK | `associateInvoice` (que ja foi validado na Task 5) faz o PATCH |
| 4. Sucesso: redireciona para PurchaseDetail | OK | `/purchase/invoice/{id}` |
| 4. Toast de sucesso | NAO | O PRD pede "toast de sucesso e redirecionar" mas a implementacao apenas redireciona, sem toast. Ver Minor m1 |
| 5. PRD originalmente mencionava `ManualAssociationPage` em `/manual-association/:invoiceId` | DIVERGE | A TechSpec (linha 189) refinou para `/purchase/invoice/:id/associate`. A implementacao seguiu a TechSpec, que e o documento mais recente -- correto |

## Tasks Verificadas

| Subtask | Status | Observacoes |
|---------|--------|-------------|
| 6.1 Adicionar state para controlar modal: `selectedSuggestion`, `showConfirm`, `isAssociating`, `associateError` | COMPLETA | Linhas 81-84 com tipos explicitos |
| 6.2 Modificar `handleSuggestionTap` para abrir modal em vez de navegar | COMPLETA | Linhas 126-130; armazena selecao, limpa erro, abre modal |
| 6.3 Renderizar `ConfirmDialog` com resumo lado-a-lado | COMPLETA | Linhas 297-332; usa `children` do dialog |
| 6.4 Implementar `handleConfirmAssociation` -- chama API, trata sucesso/erro | COMPLETA | Linhas 138-157; try/catch com setIsAssociating, mensagem especifica para 409 |
| 6.5 Manter `handleManualAssociation` navegando para `/purchase/invoice/:id/associate` | COMPLETA | Linhas 159-167; navega apenas com dados de invoice (sem dados de notification, que agora ficam no modal) |

| Teste declarado na tarefa | Implementado | Arquivo |
|---------------------------|--------------|---------|
| Tap em sugestao abre modal | SIM | `SuggestionsPage.test.tsx:211` |
| Confirmar chama `associateInvoice` com IDs corretos | SIM | `SuggestionsPage.test.tsx:266` |
| Cancelar fecha modal | SIM | `SuggestionsPage.test.tsx:248` |
| Erro 409 exibe mensagem | SIM | `SuggestionsPage.test.tsx:286` |
| "Associar manualmente" navega para /associate | SIM | `SuggestionsPage.test.tsx:334` |
| (extra) Resumo lado-a-lado exibe dados corretos | SIM | `SuggestionsPage.test.tsx:227` |
| (extra) Erro generico em falhas nao-409 | SIM | `SuggestionsPage.test.tsx:310` |

## Testes

- Total de testes em `src/pages/SuggestionsPage.test.tsx`: **20**
- Passando: **20**
- Falhando: **0**
- Pulados: **0**
- Cenarios novos: **6** (Confirm modal: 6) + 1 atualizado (Navigation/Associar manualmente, payload reduzido)
- Consumidores do `ConfirmDialog` revalidados: `CategoriesPage.test.tsx`, `PaymentMethodsPage.test.tsx`, `PurchaseList.test.tsx` -- **18/18 verde** (sem regressao)
- `npx tsc --noEmit`: exit 0 (sem erros de tipo)
- `npx vite build`: OK em 5.80s
- Suite completa: **190/196 verde**; 6 falhas em `Tab2.test.tsx` confirmadas como pre-existentes via `git stash` (mesmas 6 falham sem as mudancas desta task -- erro de mock `cancelInvoice` nao relacionado)

Comandos executados:
```bash
npx vitest run src/pages/SuggestionsPage.test.tsx                                       # 20/20 PASS
npx vitest run src/pages/CategoriesPage.test.tsx \
              src/pages/PaymentMethodsPage.test.tsx \
              src/components/PurchaseList.test.tsx                                      # 18/18 PASS
npx tsc --noEmit                                                                        # exit 0
npx vite build                                                                          # OK
git stash && npx vitest run src/pages/Tab2.test.tsx; git stash pop                      # 0/6 FAIL (pre-existente)
```

## Problemas Encontrados

### Problemas Criticos

Nenhum.

### Problemas Major

Nenhum.

### Problemas Minor

**m1. Falta toast de sucesso apos associacao (divergencia menor com PRD)**
- **Arquivo**: `src/pages/SuggestionsPage.tsx`, linha 144-146
- **Descricao**: O PRD secao 4 pede "Exibir toast de sucesso e redirecionar para PurchaseDetail". A implementacao apenas redireciona. A Task 6 nao explicita o toast em "Criterios de Sucesso" nem em "Subtarefas", entao tecnicamente esta dentro do escopo da task -- mas o PRD pede. Como o fechamento do modal + redirect imediato ja sinalizam sucesso (e PurchaseDetail mostrara o pagamento associado), o impacto na UX e baixo.
- **Correcao sugerida**: Considerar adicionar `IonToast` na PurchaseDetail (lendo flag via `history.push('/purchase/invoice/' + numId, { justAssociated: true })`) ou na SuggestionsPage antes do redirect. Tambem pode ser tratado em uma task de polimento de UX futura.

**m2. Parsing fragil do codigo HTTP via `message.includes('409')`**
- **Arquivo**: `src/pages/SuggestionsPage.tsx`, linha 149
- **Descricao**: `if (message.includes('409'))` matcharia mensagens como `"HTTP 4090"`, `"Error code 1409"`, ou qualquer texto contendo `409`. Como o backend usa `httpRequest` que joga `Error('HTTP 409: ...')` (formato `HTTP {status}: {body}`), o risco real e baixo, mas o pattern e fragil. O codigo de erro do backend nao esta sendo extraido de forma estruturada.
- **Correcao sugerida (opcional)**: usar regex ancorado, ou melhor, evoluir `httpRequest` para lancar um erro tipado:
```ts
// helper compartilhado
class HttpError extends Error {
  constructor(public status: number, message: string) { super(message); }
}
// no consumer
if (err instanceof HttpError && err.status === 409) { ... }
```
Pattern fica:
```ts
if (/\bHTTP 409\b/.test(message)) { ... }
```
Como o `httpRequest` ja existe em outras paginas com o mesmo pattern (`message.includes('XXX')`), uma evolucao do helper resolveria todos os call sites de uma vez -- fora do escopo desta task.

**m3. Cor de destaque `#ff6b6b` repetida hardcoded em 3 lugares novos do CSS**
- **Arquivo**: `src/pages/SuggestionsPage.css`, linha 390 + `src/components/ConfirmDialog.css`, linhas 43-44
- **Descricao**: A cor `#ff6b6b` (vermelho de "valor a pagar") agora aparece em:
  1. `.cd-error` (novo, linha 43 do ConfirmDialog.css)
  2. `.cd-error` background (linha 44, `rgba(255, 107, 107, 0.1)` -- mesmo valor em rgba)
  3. `.sg-confirm-col-amount` (novo, linha 390)
  4. Ja existia em `.cd-btn-confirm` (background) e em outros `sg-*-amount` do mesmo arquivo
- O projeto nao usa CSS custom properties para tokens de cor, entao essa duplicacao e consistente com o padrao existente -- mas vale registrar como divida tecnica.
- **Correcao sugerida (opcional)**: introduzir tokens em um `:root` global:
```css
:root {
  --color-danger: #ff6b6b;
  --color-danger-soft: rgba(255, 107, 107, 0.1);
}
```
Como exigiria refatoracao de varios arquivos CSS, e melhor tratar em uma task dedicada de design tokens.

**m4. Falta teste cobrindo o estado `loading`/`disabled` durante a chamada API**
- **Arquivo**: `src/pages/SuggestionsPage.test.tsx`
- **Descricao**: Os 6 cenarios novos cobrem abertura, conteudo, cancelamento, sucesso, erro 409 e erro generico. Falta um cenario que valida o comportamento durante a chamada assincrona: o botao "Confirmar" deve mostrar "Aguarde...", ambos os botoes devem ficar `disabled`, e o clique no overlay nao deve fechar o modal (`onClick={loading ? undefined : onCancel}` na linha 25 do ConfirmDialog). Esse comportamento e a funcionalidade-chave que justifica a prop `loading` adicionada -- mas nao tem teste.
- **Correcao sugerida**:
```ts
it('disables buttons and shows "Aguarde..." while API call is in-flight', async () => {
  // controlled promise to keep API pending
  let resolveApi!: (v: any) => void;
  vi.mocked(purchaseService.associateInvoice).mockReturnValue(
    new Promise((resolve) => { resolveApi = resolve; }),
  );

  const user = userEvent.setup();
  render(<SuggestionsPage />);

  await waitFor(() => expect(screen.getByText('Loja Alpha')).toBeInTheDocument());
  await user.click(screen.getByText('Loja Alpha'));
  await user.click(screen.getByText('Confirmar'));

  // While in-flight
  expect(screen.getByText('Aguarde...')).toBeInTheDocument();
  expect(screen.getByText('Cancelar').closest('button')).toBeDisabled();
  expect(screen.getByText('Aguarde...').closest('button')).toBeDisabled();

  // Resolve and verify final state
  resolveApi({ invoiceId: 42, paymentNotificationId: 101, associatedAt: '...' });
  await waitFor(() => {
    expect(mockPush).toHaveBeenCalledWith('/purchase/invoice/42');
  });
});
```

**m5. Modal nao limpa `selectedSuggestion` no error path do `handleConfirmAssociation`**
- **Arquivo**: `src/pages/SuggestionsPage.tsx`, linhas 138-157
- **Descricao**: No caminho de erro, `selectedSuggestion` permanece setado (intencional, para o modal continuar mostrando o resumo do pagamento que falhou). Esta correto e ate desejavel -- o usuario ve qual selecao falhou e pode tentar novamente ou cancelar. So nao ha teste validando que clicar em "Cancelar" apos erro limpa todos os estados corretamente. O `handleCancelConfirm` ja faz isso (`setSelectedSuggestion(null)`, `setAssociateError(null)`), mas seria bom ter cobertura.
- **Correcao sugerida (opcional)**:
```ts
it('cancelling after an error resets selection and error', async () => {
  vi.mocked(purchaseService.associateInvoice).mockRejectedValue(
    new Error('HTTP 409: ...'),
  );
  const user = userEvent.setup();
  render(<SuggestionsPage />);
  await waitFor(() => expect(screen.getByText('Loja Alpha')).toBeInTheDocument());
  await user.click(screen.getByText('Loja Alpha'));
  await user.click(screen.getByText('Confirmar'));
  await waitFor(() => {
    expect(screen.getByText('Pagamento ja associado a outra nota')).toBeInTheDocument();
  });
  await user.click(screen.getByText('Cancelar'));
  expect(screen.queryByText('Confirmar associacao')).not.toBeInTheDocument();

  // Re-open: error must not persist
  await user.click(screen.getByText('Loja Alpha'));
  expect(screen.queryByText('Pagamento ja associado a outra nota')).not.toBeInTheDocument();
});
```

**m6. `ConfirmDialog` nao captura ESC nem ofereçe `aria-modal` / role**
- **Arquivo**: `src/components/ConfirmDialog.tsx`
- **Descricao**: O componente nao expoe nenhum atributo de acessibilidade (`role="dialog"`, `aria-modal="true"`, `aria-labelledby`, foco inicial automatico) e nao captura ESC para fechar. Isso ja existia antes desta task -- nao foi introduzido aqui -- mas o escopo da Task 6 expandiu o uso do componente. Vale registrar para tratar em uma task de a11y dedicada.
- **Correcao sugerida (opcional, fora do escopo)**:
```tsx
<div className="cd-overlay" role="dialog" aria-modal="true" aria-labelledby="cd-title">
  <div className="cd-sheet">
    <p className="cd-title" id="cd-title">{title}</p>
    ...
  </div>
</div>
```
E um `useEffect` que escuta ESC. Como o ControlAI roda em Capacitor (mobile-first), o ganho real e baixo, mas a11y vale o esforco.

## Pontos Positivos

1. **Decisao de estender o `ConfirmDialog` em vez de criar `SuggestionConfirmDialog` novo**: as 3 props adicionadas (`children`, `loading`, `error`) sao todas opcionais e cobrem 100% dos requisitos da Task 6 sem quebrar nenhum dos 4 call sites existentes. Reuso impecavel. Os 18 testes de `CategoriesPage`, `PaymentMethodsPage` e `PurchaseList` (consumidores do dialog) seguem 100% verde sem qualquer alteracao.

2. **Bloqueio do dismiss no overlay durante loading** (linha 25 do `ConfirmDialog.tsx`): `onClick={loading ? undefined : onCancel}` impede que o usuario feche o modal acidentalmente clicando fora enquanto a API esta em curso. Detalhe sutil, mas critico para UX em chamadas que tomam tempo.

3. **Botoes em `disabled` durante loading + label muda para "Aguarde..."**: previne duplo-clique no "Confirmar" (que dispararia duas chamadas PATCH e poderia causar 409 espurio na segunda) e tambem desabilita o "Cancelar" enquanto a API esta executando -- evitando estado inconsistente onde o usuario fecha o modal mas a API completa em background com sucesso.

4. **Tratamento estruturado de erros**: `try/catch/finally` com discriminacao explicita entre 409 (negocio) e demais erros (genericos). O `finally` garante que `setIsAssociating(false)` sempre roda, mesmo se outro erro nao previsto ocorrer. O `setAssociateError(null)` no inicio limpa o erro anterior (caso o usuario reabra o modal ou tente de novo).

5. **Limpeza completa de estado em `handleCancelConfirm`**: reseta `showConfirm`, `selectedSuggestion` e `associateError`, garantindo que reabrir o modal nao mostre dados antigos ou erros stale.

6. **Correcao do mock de `useParams`** (de `invoiceId` para `id`): a rota em `App.tsx` usa `/purchase/invoice/:id/suggestions`, entao `useParams<{ id: string }>()` e o correto. O mock antigo (`{ invoiceId: '42' }`) era um bug latente -- o teste passava porque o componente da Task 3 nao usava `useParams()` (vinha tudo do `location.state`), mas qualquer mudanca que comecasse a usar `useParams()` quebraria silenciosamente. A Task 6 nao introduziu `useParams` (ja existia desde Task 3 com o nome correto), mas a correcao do mock foi necessaria porque agora o componente exercita o `numId` derivado de `useParams` em mais paths (no `handleConfirmAssociation`). Bem feito.

7. **Resumo lado-a-lado com hierarquia visual clara**: o CSS usa label uppercase pequeno (`.sg-confirm-col-label`), nome do estabelecimento em destaque (`.sg-confirm-col-merchant` -- 14px, peso 600, branco), valor em vermelho monoespacado (16px, peso 700), data secundaria (12px, opaca) e cartao terciario (12px, mais opaca). Hierarquia tipografica consistente com o resto da pagina (`sg-card-*`). Divider central de 1px com `flex-shrink: 0` impede compactacao. `min-width: 0` nas colunas + `text-overflow: ellipsis` no merchant evita overflow horizontal em telas estreitas.

8. **Atualizacao consistente do payload do "Associar manualmente"**: como agora o invoice sera associado via modal direto na SuggestionsPage, o payload para `/purchase/invoice/:id/associate` (que vira `AssociatePage` da Task 7) nao precisa mais carregar os dados de notification (que ficavam no payload antigo para destacar uma sugestao especifica). O codigo removeu corretamente os campos `notificationId`, `notificationAmount`, etc. do payload do `handleManualAssociation`, e o teste foi atualizado para refletir a nova forma.

9. **Substituicao das escape sequences Unicode** (`••` -> `••`, `·` -> `·`, `Δ` -> `Δ`): pequena melhoria de legibilidade do codigo. Sem impacto funcional, mas o codigo fica mais leitivel. Bonus involuntario da edicao.

10. **Cobertura de testes ampla e bem direcionada**: 6 cenarios novos cobrem todos os caminhos materiais (abre, mostra dados, cancela, sucesso, erro 409, erro generico). O teste de "side-by-side summary" valida estrutura DOM (2 colunas) e conteudo (merchant + amount em ambas as colunas), nao so a presenca dos titulos.

11. **`mockPush.not.toHaveBeenCalled()` em multiplos lugares**: garante que o tap NAO navega (regressao explicita do comportamento antigo), e que cancel/erro NAO disparam navegacao indesejada. Esse tipo de "assertion negativa" e o que captura regressoes futuras quando alguem alterar o fluxo.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (TypeScript) | OK |
| React (hooks, state, componentes) | OK |
| CSS (BEM-like, prefixos por componente) | OK (com m3) |
| Acessibilidade | Pre-existente (com m6) |
| Testes (Vitest + Testing Library) | OK (com m4) |
| Reuso e DRY | OK |
| Backward compatibility do `ConfirmDialog` | OK |

## Recomendacoes

1. **[Minor]** Adicionar teste do estado loading/disabled durante a chamada API (m4) -- e o unico comportamento da nova prop `loading` que nao esta coberto.
2. **[Minor]** Considerar adicionar toast de sucesso conforme PRD secao 4 (m1) -- pode ser tratado na Task 9 (PurchaseDetail) lendo flag via `location.state`.
3. **[Opcional]** Substituir `message.includes('409')` por regex ancorado `/\bHTTP 409\b/` ou (idealmente) evoluir o `httpRequest` para lancar um erro tipado com `status: number` -- isso elimina parsing de string em todos os call sites (m2).
4. **[Opcional]** Introduzir CSS custom properties para tokens de cor (`--color-danger: #ff6b6b`) em uma task dedicada de design tokens (m3) -- afetaria varios arquivos, fora do escopo aqui.
5. **[Opcional]** Adicionar atributos de acessibilidade ao `ConfirmDialog` (`role="dialog"`, `aria-modal`, `aria-labelledby`, ESC handler) em uma task de a11y dedicada (m6) -- divida pre-existente, agravada pelo uso expandido do componente.
6. **[Opcional]** Adicionar teste cobrindo o ciclo erro -> cancelar -> reabrir limpa estado (m5).
7. **[Lembrete para Task 7.0]** A `AssociatePage` real (rota `/purchase/invoice/:id/associate`) deve substituir o `AssociatePagePlaceholder`. O `location.state` recebido agora so traz `invoiceId`, `invoiceTotal`, `invoiceDate`, `invoiceMerchantName` (sem mais os campos de `notification*`). Ao selecionar uma notification na busca manual, a `AssociatePage` provavelmente abrira o mesmo `ConfirmDialog` -- considerar extrair o conteudo do modal (resumo lado-a-lado) para um sub-componente `AssociationConfirmContent` reusavel.

## Conclusao

**APROVADO COM OBSERVACOES.**

A Task 6.0 entrega exatamente o que a Task descreve e respeita
integralmente a TechSpec: modal de confirmacao inline com resumo
lado-a-lado, chamada da API com tratamento estruturado de erros
(incluindo o 409 especifico), redirect ao PurchaseDetail no sucesso,
botao de loading que previne duplo-clique, e preservacao da navegacao
manual para a futura `AssociatePage`. O `ConfirmDialog` foi estendido
de forma cirurgica: 3 props opcionais que cobrem 100% dos requisitos
sem quebrar nenhum dos 4 call sites existentes (verificado: 18/18
testes dos consumidores passam sem alteracao). Os 20 testes do
`SuggestionsPage.test.tsx` passam, `tsc --noEmit` retorna 0 e o build
de producao conclui sem erros. As 6 falhas em `Tab2.test.tsx` foram
confirmadas como pre-existentes via `git stash` -- nao relacionadas
a esta task.

As 6 observacoes Minor sao todas de polimento: 1 divergencia menor do
PRD (toast de sucesso, m1), 1 fragilidade de parsing de erro (m2), 1
divida de design tokens (m3), 1 teste faltante de loading state (m4),
1 teste opcional de ciclo de cancelamento (m5) e 1 divida de
acessibilidade pre-existente (m6). Nenhuma bloqueia a entrega ou
impacta a Task 7.0.

A Task 6.0 esta pronta para seguir para a Task 7.0 (AssociatePage --
nova pagina de busca manual de notifications).

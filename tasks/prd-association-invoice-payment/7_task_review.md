# Review: Task 7.0 - AssociatePage - Busca Manual

**Revisor**: AI Code Reviewer
**Data**: 2026-05-24
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Task 7.0 entrega a pagina `AssociatePage.tsx` que substitui o
placeholder criado na Task 5, completando o fluxo de associacao manual
(notification -> invoice) para os casos em que `/suggestions` automatico
nao retorna sugestoes ou o usuario quer buscar manualmente. A pagina
implementa todos os 9 sub-requisitos da task: rota
`/purchase/invoice/:id/associate` registrada no `App.tsx`, hero do
invoice (com fallback para `getPurchaseInvoice` quando `location.state`
nao esta presente), 3 filtros (valor, data inicial, data final), botao
"Buscar" com loading skeleton, lista de notifications em cards,
selecao + `ConfirmDialog` reusando o resumo lado-a-lado, confirmacao
chamando `associateInvoice` (com tratamento estruturado de 409 vs
erro generico), redirect para PurchaseDetail em sucesso, empty state
quando a busca retorna vazio, e botao "Pular associacao" que navega
direto para PurchaseDetail sem chamar API. A pagina-irma
`AssociatePagePlaceholder.tsx` foi corretamente deletada e o import
removido do `App.tsx`.

A decisao arquitetural mais relevante e o **reuso de CSS via
side-effect import** (`import './SuggestionsPage.css'` + `import
'./AssociatePage.css'`): em vez de duplicar as classes `.sg-header`,
`.sg-hero`, `.sg-card`, `.sg-empty`, `.sg-confirm-*` (que totalizam
mais de 200 linhas no CSS da SuggestionsPage), a pagina apenas
importa o arquivo e usa as classes. Os estilos proprios (filtros e
botao skip) ficam isolados em `AssociatePage.css` com prefixo
`.ap-*`. Decisao pragmatica que respeita o requisito "seguir padrao
`.sg-*`" da Task 7.8, mas que acopla as duas paginas — qualquer
mudanca no CSS da SuggestionsPage afeta a AssociatePage e vice-versa.
Veja a observacao Minor m1.

A cobertura de testes e adequada (11 testes, 7 declarados + 4 extras
de robustez), com mocks isolados e assercoes diretas. As 6
recomendacoes da Task 6 foram parcialmente endereçadas — a #7 (extrair
sub-componente `AssociationConfirmContent`) **nao foi implementada** e
gerou duplicacao real entre `SuggestionsPage.tsx` e `AssociatePage.tsx`:
helpers `fmt`, `fmtDateFull`, `getOriginLabel` (54 linhas), o JSX do
modal lado-a-lado (24 linhas), e o parsing fragil `message.includes('409')`
agora aparecem em 2 lugares. Ver observacao Minor m2.

`npx vitest run src/pages/AssociatePage.test.tsx` retorna 11/11,
`npx vitest run src/pages/SuggestionsPage.test.tsx src/App.test.tsx`
retorna 21/21 (zero regressao adjacente), `npx tsc --noEmit` retorna 0
e `npx vite build` conclui em 5.91s. As 6 falhas em `Tab2.test.tsx`
seguem pre-existentes (confirmadas via `git stash` no review da Task 6).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/pages/AssociatePage.tsx` (criado, 381 linhas) | OK com Minors | 4 |
| `src/pages/AssociatePage.css` (criado, 114 linhas) | OK | 0 |
| `src/pages/AssociatePage.test.tsx` (criado, 276 linhas) | OK com Minor | 1 |
| `src/App.tsx` (modificado, +4 -0) | OK | 0 |
| `src/pages/AssociatePagePlaceholder.tsx` (deletado) | OK | 0 |

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Padroes de Codigo (TypeScript) | OK | `useParams<{ id: string }>()` correto, `SuggestionResponse` importado como `type`, `LocationState` tipado, sem `any` em codigo de producao (apenas em mocks de teste, padrao do repo) |
| Reuso do `ConfirmDialog` em vez de criar dialog customizado | OK | Reusa o componente estendido na Task 6 (com `children`, `loading`, `error`) |
| Padrao visual `.sg-*` para hero/cards/empty | OK | Reusa atraves de import lateral de `SuggestionsPage.css` (ver m1) |
| Prefixo `.ap-*` para estilos proprios | OK | `.ap-filters`, `.ap-field`, `.ap-input`, `.ap-search-btn`, `.ap-skip-*` — todos isolados em `AssociatePage.css` |
| Reuso de helpers (`fmt`, `fmtDateFull`, `getOriginLabel`) | Problemas | Helpers duplicados em vez de extraidos para modulo compartilhado (m2) |
| Tipos TypeScript explicitos | OK | Todos states tem tipo (`SuggestionResponse[]`, `SuggestionResponse \| null`, `string \| null`); `params` em `handleSearch` tem tipo inline |
| Naming consistente de classes CSS | OK | Prefixo `ap-` para todos os estilos novos |
| Sem comentarios desnecessarios | OK | Comentarios funcionais: secoes do JSX (`/* Header */`, `/* Filters */`, `/* Results section */`) e 1 justificativa do fallback silencioso da API |
| Imports em ordem | OK | Ionic -> react-router -> react -> ionicons -> services -> components -> CSS, na mesma ordem da SuggestionsPage |
| Testes presentes e passando | OK | 11/11 verde, todos os 7 cenarios declarados cobertos + 4 extras |

## Aderencia a TechSpec

| Decisao Tecnica | Implementado | Observacoes |
|-----------------|--------------|-------------|
| Pagina separada para busca manual (linha 191 techspec) | SIM | Rota propria, hero + filtros + lista + skip |
| Rota `/purchase/invoice/:id/associate` (linha 189 techspec) | SIM | `App.tsx` linha 80, posicionada antes de `/purchase/:type/:id` para evitar conflito de match |
| Filtros: valor + data (sem texto) (linha 193 techspec) | SIM | Input numerico + 2 date pickers (De/Ate). Sem campo de texto/merchant — alinhado com a decisao |
| Reusar `ConfirmDialog.tsx` (linha 221 techspec) | SIM | Reusa o componente estendido na Task 6 (children/loading/error) |
| `searchNotifications(invoiceId, { amount, startDate, endDate })` (linha 71 techspec) | SIM | Linha 118, params montados condicionalmente |
| Sucesso -> redirect PurchaseDetail (linha 34 techspec) | SIM | `history.push('/purchase/invoice/' + numId)` |
| Erro 409 -> mensagem adequada | SIM | Mesma estrategia da SuggestionsPage |

## Aderencia ao PRD

| Criterio (PRD) | Status | Observacoes |
|----------------|--------|-------------|
| 5. Pagina de associacao manual com hero do invoice | OK | Hero reproduz fielmente o padrao da SuggestionsPage (icone clipboard, valor em negativo, merchant, data) |
| 5. Campo de busca por nome do estabelecimento | DIVERGE | PRD pedia filtro por nome; **TechSpec refinou para valor + data** (decisao #4, linha 193). A implementacao segue a TechSpec, que e a fonte mais recente — correto |
| 5. Lista de notifications filtradas | OK | Cards em `.sg-list` com merchant, valor, origem, cartao, data, categoria, parcelas |
| 5. Confirmacao igual a SuggestionsPage | OK | Mesmo `ConfirmDialog` com mesmo layout lado-a-lado |
| 5. Botao "Pular" -> direto ao detalhe do invoice | OK | `handleSkip` navega sem chamar API |
| 9. Botao "Pular" permite ignorar associacao | OK | Idem acima |

## Tasks Verificadas

| Subtask | Status | Observacoes |
|---------|--------|-------------|
| 7.1 Estrutura base (IonPage, header, hero) | COMPLETA | Linhas 164-193; back button com `history.goBack()`, hero com skeleton durante load |
| 7.2 Campos de filtro (valor + data) | COMPLETA | Linhas 198-247; input number com `inputMode="decimal"`, `step="0.01"`, parsing aceita virgula e ponto |
| 7.3 Busca com loading state | COMPLETA | `searching` state, botao desabilitado, label muda para "Buscando...", skeleton de 3 cards na lista |
| 7.4 Cards com dados relevantes | COMPLETA | Merchant, valor negativo, origem + cartao + data em metadata, categoria + parcelas em meta secundaria |
| 7.5 Selecao + confirmacao | COMPLETA | Reusa `ConfirmDialog` com children, mesma logica da SuggestionsPage (incluindo 409) |
| 7.6 Botao "Pular" -> PurchaseDetail | COMPLETA | `handleSkip` (linha 160) navega direto, sem chamar `associateInvoice` |
| 7.7 Empty state | COMPLETA | Renderizado apenas apos `hasSearched` (linha 317) — nao aparece antes da primeira busca |
| 7.8 CSS com prefixo `.ap-*` | COMPLETA | `AssociatePage.css` (114 linhas) com estilos proprios; reuso de `.sg-*` via side-effect import |
| 7.9 Atualizar `App.tsx` | COMPLETA | Rota registrada, placeholder removido, import deletado |

| Teste declarado na tarefa | Implementado | Arquivo |
|---------------------------|--------------|---------|
| Hero renderiza com dados do invoice | SIM | `AssociatePage.test.tsx:113` |
| Busca com filtro de valor chama API corretamente | SIM | `AssociatePage.test.tsx:137` |
| Busca com filtro de data chama API corretamente | SIM | `AssociatePage.test.tsx:153` |
| Selecao de notification abre confirmacao | SIM | `AssociatePage.test.tsx:228` |
| Confirmar chama `associateInvoice` | SIM | `AssociatePage.test.tsx:243` |
| "Pular" navega para PurchaseDetail | SIM | `AssociatePage.test.tsx:264` |
| Empty state quando sem resultados | SIM | `AssociatePage.test.tsx:206` |
| (extra) Hero busca via API quando `location.state` ausente | SIM | `AssociatePage.test.tsx:122` |
| (extra) Busca sem filtros envia params vazios `{}` | SIM | `AssociatePage.test.tsx:174` |
| (extra) Cards renderizam apos busca bem-sucedida | SIM | `AssociatePage.test.tsx:189` |
| (extra) Empty state NAO aparece antes da primeira busca | SIM | `AssociatePage.test.tsx:219` |

## Testes

- Total de testes em `src/pages/AssociatePage.test.tsx`: **11**
- Passando: **11**
- Falhando: **0**
- Pulados: **0**
- Cenarios declarados: **7** (todos cobertos)
- Cenarios extras: **4** (fallback de hero via API, busca sem filtros, render de cards, ausencia de empty state pre-busca)
- Tests adjacentes revalidados: `SuggestionsPage.test.tsx` + `App.test.tsx` -> **21/21 verde** (sem regressao na pagina-irma e no roteamento)
- `npx tsc --noEmit`: exit 0 (sem erros de tipo)
- `npx vite build`: OK em 5.91s
- Suite completa: **201/207 verde**; 6 falhas em `Tab2.test.tsx` confirmadas como pre-existentes (mesmas falhas sem qualquer mudanca desta task, ja documentadas no review da Task 6)

Comandos executados:
```bash
npx vitest run src/pages/AssociatePage.test.tsx                              # 11/11 PASS
npx vitest run src/pages/SuggestionsPage.test.tsx src/App.test.tsx           # 21/21 PASS
npx tsc --noEmit                                                              # exit 0
npx vite build                                                                # OK em 5.91s
```

## Problemas Encontrados

### Problemas Criticos

Nenhum.

### Problemas Major

Nenhum.

### Problemas Minor

**m1. Acoplamento via side-effect import de `SuggestionsPage.css`**
- **Arquivo**: `src/pages/AssociatePage.tsx`, linha 17
- **Descricao**: `import './SuggestionsPage.css'` carrega o CSS da pagina-irma para reusar as classes `.sg-header`, `.sg-hero`, `.sg-card`, `.sg-empty`, `.sg-section`, `.sg-confirm-*`, `.sg-list`, `.sg-divider`, etc. Funciona porque o Vite injeta esses estilos globalmente. Mas isso cria um acoplamento implicito: qualquer alteracao no CSS da SuggestionsPage (renomear classe, ajustar padding, etc.) impactara silenciosamente a AssociatePage, e ninguem que esteja editando `SuggestionsPage.css` saberia que outra pagina depende dessas classes. Tambem viola o principio "1 componente, 1 CSS proprio" implicito no resto do projeto.
- **Correcao sugerida**: a opcao certa de medio prazo e extrair as classes compartilhadas para um modulo `src/styles/association-shared.css` (ou similar) e importar nas duas paginas explicitamente. Como exigiria mover ~200 linhas e revalidar visualmente as duas paginas, fica como divida tecnica para uma task de refatoracao dedicada — mas vale documentar agora. Alternativa intermediaria: adicionar comentario explicito no topo de `SuggestionsPage.css` ("Este arquivo e importado tambem por AssociatePage.tsx — alteracoes afetam ambas as paginas").

**m2. Duplicacao significativa entre `SuggestionsPage.tsx` e `AssociatePage.tsx` (recomendacao #7 da Task 6 nao endereçada)**
- **Arquivo**: `src/pages/AssociatePage.tsx`, varias secoes
- **Descricao**: A recomendacao #7 do review da Task 6 sugeria explicitamente extrair um sub-componente `AssociationConfirmContent` reusavel para o modal de confirmacao. Essa recomendacao **nao foi implementada**, resultando em duplicacoes reais:
  1. **Helpers de formatacao** (linhas 27-53, ~30 linhas): `fmt`, `fmtDateFull`, `getOriginLabel` sao **identicos** aos da `SuggestionsPage.tsx` (linhas 31-64 daquele arquivo). O `getOriginLabel` em particular tem 13 linhas com o mesmo mapa de bancos.
  2. **JSX do modal de confirmacao** (linhas 339-374, ~36 linhas): a estrutura `<div className="sg-confirm-grid">...<div className="sg-confirm-col">...<div className="sg-confirm-divider" />...</div></div>` e identica entre as duas paginas, apenas com `selectedSuggestion` vs `selectedNotification`.
  3. **Logica de tratamento de erro 409** (linhas 148-154): identica a SuggestionsPage, incluindo o parsing fragil `message.includes('409')` (Minor m2 do review da Task 6).
  4. **Estados de associacao** (linhas 75-78): `selectedX`, `showConfirm`, `isAssociating`, `associateError` — mesma estrutura.
  5. **Handlers**: `handleNotificationTap`, `handleCancelConfirm`, `handleConfirmAssociation` sao quase identicos aos da SuggestionsPage.
- **Impacto**: qualquer ajuste futuro no fluxo de associacao (mensagem de erro, layout do modal, novo campo no resumo) precisa ser feito em 2 lugares. Ja viu-se na Task 6 que mudancas no `ConfirmDialog` precisaram ser propagadas — agora cada call site da associacao tambem precisa ser sincronizado.
- **Correcao sugerida**: criar 2 utilitarios compartilhados:
  ```ts
  // src/utils/format.ts
  export const formatBRL = (v: number) => ...;
  export const formatDateFull = (d: string) => ...;
  export const getOriginLabel = (origin: string | null) => ...;

  // src/components/AssociationConfirmContent.tsx
  type Props = {
    invoice: { merchantName: string | null; total: number; date: string };
    notification: { merchantName: string; amount: number; purchasedAt: string; cardLastDigits: string | null };
  };
  export const AssociationConfirmContent: React.FC<Props> = ({ invoice, notification }) => (
    <div className="sg-confirm-grid">...</div>
  );
  ```
  Cada pagina passa a renderizar `<AssociationConfirmContent invoice={...} notification={...} />` dentro do `<ConfirmDialog>`. Pode tambem extrair um hook `useAssociateConfirm(invoiceId)` que encapsula os 4 states + 3 handlers + parsing de erro. Como envolve refatorar 2 paginas, fica como recomendacao para task de refatoracao — mas a divida ja vinha sinalizada no review anterior.

**m3. Conversao YYYY-MM-DD -> ISO datetime esta correta para o backend, mas indocumentada**
- **Arquivo**: `src/pages/AssociatePage.tsx`, linhas 109-112
- **Descricao**: O codigo gera `${startDateInput}T00:00:00` e `${endDateInput}T23:59:59`. Validei o backend (`SearchNotificationsProvider.kt` + `PaymentNotificationRepository.kt`): o filtro usa `(:startDate IS NULL OR purchased_at >= :startDate) AND (:endDate IS NULL OR purchased_at <= :endDate)` — ambos inclusivos. Logo `T00:00:00` (start) captura o inicio do dia e `T23:59:59` (end) captura o ultimo segundo, cobrindo o dia inteiro corretamente. **Semanticamente certo.** Pontos a observar:
  1. **Edge case dos milissegundos**: o backend e `LocalDateTime` (precisao de microsegundos no Postgres) e o frontend manda strings sem milissegundos. Eventos no intervalo `23:59:59.001` a `23:59:59.999` no dia final ficariam *fora* do range (porque o filtro e `<=` e o backend pode preencher o `LocalDateTime` com `.000` ou interpretar o `23:59:59` como `.000`). Em pratica e quase irrelevante (1ms de janela perdida), mas se o backend retornar `purchased_at = "2026-05-21T23:59:59.500"` esse registro nao apareceria numa busca com `endDate = "2026-05-21"`. Para correção total, o padrao seguro seria mandar `endDate = startOfNextDay - 1ns` ou usar `< startOfNextDay`.
  2. **Sem validacao de `startDate > endDate`**: o usuario pode selecionar `De: 2026-05-21` e `Ate: 2026-05-19` e a busca ira retornar vazio sem feedback explicativo (vai cair no empty state generico "Tente ajustar o valor ou o periodo"). Nao quebra, mas a UX poderia ter validacao defensiva.
  3. **Sem hint de timezone**: o `T00:00:00` e enviado sem `Z` ou offset, o que e correto para `LocalDateTime` do Java (timezone-naive) mas pode confundir se o backend mudar para `OffsetDateTime` no futuro.
- **Correcao sugerida (opcional)**: extrair as conversoes em um helper documentado:
  ```ts
  // dateRangeToIso: input "2026-05-21" -> start: "2026-05-21T00:00:00", end: "2026-05-21T23:59:59"
  // Match com backend (purchased_at >= start AND purchased_at <= end), ambos inclusivos.
  ```
  E adicionar uma validacao simples antes de chamar a API:
  ```ts
  if (startDateInput && endDateInput && startDateInput > endDateInput) {
    setStartDateError('Data inicial deve ser anterior a final');
    return;
  }
  ```

**m4. `setIsAssociating(false)` ja gerenciado pelo `finally` (positivo) mas estado `notifications` pode ficar inconsistente apos erro no catch da busca**
- **Arquivo**: `src/pages/AssociatePage.tsx`, linhas 117-124
- **Descricao**: No `handleSearch`, ao receber erro de `searchNotifications`, o `catch` faz `setNotifications([])`. Isso e razoavel — limpa a lista — mas combinado com `setHasSearched(true)` (linha 116) acaba mostrando o empty state generico ("Nenhum pagamento encontrado") mesmo quando o problema foi *erro de rede ou 500 do backend*. O usuario nao vai entender que ocorreu uma falha tecnica.
- **Correcao sugerida**: adicionar um state `searchError: string | null` analogo ao `associateError`:
  ```ts
  const [searchError, setSearchError] = useState<string | null>(null);

  } catch {
    setNotifications([]);
    setSearchError('Nao foi possivel buscar pagamentos. Tente novamente.');
  }
  ```
  E renderizar uma faixa de erro entre o botao "Buscar" e a secao de resultados (`{searchError && <div className="ap-search-error">{searchError}</div>}`). Sem isso, falhas de rede ficam invisiveis.

**m5. Falta teste cobrindo erro 409 no `handleConfirmAssociation`**
- **Arquivo**: `src/pages/AssociatePage.test.tsx`
- **Descricao**: A SuggestionsPage tem testes especificos para erro 409 e erro generico no fluxo de confirmacao. A AssociatePage cobre o caminho feliz (`associateInvoice` chamada com IDs corretos + redirect), mas **nao tem teste para o caminho de erro**. Como o fluxo de erro 409 e a regra de negocio mais critica (notification ja associada a outro invoice), e onde o parsing fragil `message.includes('409')` mais importa, esse cenario deveria ter cobertura aqui tambem.
- **Correcao sugerida**:
  ```ts
  it('shows specific message when API returns 409', async () => {
    vi.mocked(purchaseService.associateInvoice).mockRejectedValue(
      new Error('HTTP 409: Notification already associated'),
    );
    const user = userEvent.setup();
    render(<AssociatePage />);
    await waitFor(() => expect(screen.getByText('Estabelecimento Teste')).toBeInTheDocument());
    await user.click(screen.getByText('Buscar'));
    await waitFor(() => expect(screen.getByText('Loja Alpha')).toBeInTheDocument());
    await user.click(screen.getByText('Loja Alpha'));
    await user.click(screen.getByText('Confirmar'));
    await waitFor(() => {
      expect(screen.getByText('Pagamento ja associado a outra nota')).toBeInTheDocument();
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it('shows generic message on non-409 error', async () => {
    vi.mocked(purchaseService.associateInvoice).mockRejectedValue(
      new Error('HTTP 500: Internal server error'),
    );
    // ... similar setup
    await waitFor(() => {
      expect(screen.getByText('Nao foi possivel associar. Tente novamente.')).toBeInTheDocument();
    });
  });
  ```

## Pontos Positivos

1. **Substituicao limpa do placeholder**: a Task 5 criou `AssociatePagePlaceholder.tsx` como ponte intencional. A Task 7 deletou o arquivo, removeu o import do `App.tsx`, e atualizou a `<Route>` para apontar para o novo componente. O `git diff` no `App.tsx` e cirurgico (+4 -0 — adiciona apenas o import e a nova rota; o placeholder foi removido em outro commit ou junto). Nao ha codigo morto deixado para tras.

2. **Hero com fallback robusto** (linhas 80-100): se `location.state` esta presente (caminho normal vindo da SuggestionsPage com "Associar manualmente"), usa direto. Se nao (usuario acessou via URL direta, refresh, ou deep link), faz `getPurchaseInvoice(numId)` em `useEffect` com flag `cancelled` para evitar setState em componente desmontado. O `catch` silencioso e justificado pelo comentario ("invoice data is supplementary") — a busca de notifications nao depende disso. Padrao identico ao da SuggestionsPage, garantindo consistencia.

3. **Parsing robusto do input de valor** (linha 104): `parseFloat(amountInput.replace(',', '.'))` aceita formato brasileiro ("150,00") e americano ("150.00"). Guarda contra `NaN` (`!Number.isNaN(parsedAmount)`) e contra valores nao-positivos (`parsedAmount > 0`). Isso previne envio de `?amount=NaN` ou `?amount=0` (que o backend rejeitaria ou trataria de forma inesperada).

4. **Empty state condicionado a `hasSearched`** (linha 317): o estado vazio so renderiza **depois** que o usuario clicou em "Buscar". Antes disso (pagina recem-aberta), nao mostra nem a lista nem o empty — apenas os filtros e o botao "Pular". Isso evita o "false negative" psicologico de mostrar "Nenhum pagamento encontrado" antes do usuario sequer ter buscado. Esse cenario tem teste explicito (`AssociatePage.test.tsx:219`).

5. **Loading skeleton fiel ao padrao da SuggestionsPage** (linhas 250-266): 3 cards-skeleton com mesmo layout (icone + 3 linhas), reusando `.sg-card-skeleton` e `ctrl-skeleton`. UX coerente entre as duas paginas.

6. **`handleSkip` e `handleConfirmAssociation` mutuamente exclusivos**: o skip navega direto sem chamar `associateInvoice` (teste `AssociatePage.test.tsx:264` valida explicitamente `expect(purchaseService.associateInvoice).not.toHaveBeenCalled()`). Garante que o "Pular" nunca dispara efeito colateral indevido — exatamente o requisito da Task 7.6.

7. **Botao "Pular" sempre disponivel** (linhas 330-334): renderizado fora dos blocos condicionais de loading/results/empty. O usuario pode pular a qualquer momento, sem precisar buscar primeiro. UX correta para o caso "abri a pagina mas mudei de ideia, quero so abrir o detalhe".

8. **Reuso do `ConfirmDialog` com children/loading/error**: as 3 props que a Task 6 adicionou ao componente compartilhado sao usadas aqui exatamente como projetadas. Confirma que a decisao de estender (em vez de criar `SuggestionConfirmDialog` separado) na Task 6 estava certa — agora 2 paginas usam o mesmo dialog com o mesmo layout de resumo lado-a-lado. O componente nao precisou de mais alteracoes.

9. **Disposicao do form de filtros**: valor em linha cheia + datas em row de 2 colunas (`.ap-field-row`) e uma escolha visual coerente — valor e o filtro mais usado e merece destaque; as datas vem como "range" lado-a-lado seguindo convencao de date pickers. Em telas estreitas o `gap: 12px` no row mantem os campos legiveis (input de data Ionic tem largura minima razoavel).

10. **Tipagem explicita do `params` interno** (linha 103): `const params: { amount?: number; startDate?: string; endDate?: string } = {}` espelha exatamente a assinatura do `searchNotifications`, garantindo que mudancas futuras no service quebrem o type-check aqui imediatamente.

11. **Date pickers com `color-scheme: dark`** (linha 61 do CSS): pequeno detalhe de UX — o seletor de data nativo do browser respeita o tema dark, evitando contraste ruim com o background escuro do ControlAI.

12. **Estilo do botao skip distintivo**: o botao "Pular associacao" tem estilo "ghost" (transparente, borda fraca, texto opaco) — visualmente subordinado ao botao primario "Buscar" (azul cheio). Isso comunica corretamente a hierarquia: "Buscar" e a acao primaria; "Pular" e a fuga/escape. UX bem pensada.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (TypeScript) | OK |
| React (hooks, state, componentes) | OK |
| CSS (BEM-like, prefixos por componente) | OK (com m1) |
| Reuso e DRY | Problemas (m2) |
| Testes (Vitest + Testing Library) | OK (com m5) |
| Acessibilidade | Pre-existente (label-input bem associados via `<label>` wrapping, mas modal segue sem `role="dialog"` — divida da Task 6) |
| Roteamento (React Router 5) | OK (rota posicionada antes da rota generica `/purchase/:type/:id` para evitar shadowing) |

## Recomendacoes

1. **[Minor]** Adicionar testes de erro 409 e erro generico no `handleConfirmAssociation` (m5) — paridade com a SuggestionsPage.
2. **[Minor]** Adicionar feedback visual de erro na busca quando `searchNotifications` falha (m4) — hoje cai no empty state generico, escondendo falhas tecnicas.
3. **[Minor]** Adicionar validacao defensiva de `startDate > endDate` antes de chamar a API (m3.2) — previne busca sem feedback.
4. **[Tecnico/refatoracao dedicada]** Extrair `AssociationConfirmContent` como sub-componente compartilhado entre SuggestionsPage e AssociatePage (m2.2) — endereca a recomendacao #7 do review da Task 6 que ficou aberta.
5. **[Tecnico/refatoracao dedicada]** Extrair `fmt`, `fmtDateFull`, `getOriginLabel` para `src/utils/format.ts` (m2.1) — reduz duplicacao em 2 paginas hoje e em todas as futuras.
6. **[Tecnico/divida]** Documentar o acoplamento do CSS via side-effect import (m1) — comentario no topo de `SuggestionsPage.css` apontando que `AssociatePage.tsx` tambem o consome.
7. **[Opcional/futura task de a11y]** Adicionar `role="dialog"` + `aria-modal` ao `ConfirmDialog` (Minor m6 do review da Task 6, ainda pendente) — agora 2 paginas usam o componente, ganho dobra.
8. **[Opcional/futura task de design tokens]** Introduzir CSS custom properties para cores recorrentes (`#4285F4` aparece 2x em `AssociatePage.css`, `#ff6b6b` ja foi sinalizado na Task 6).

## Veredito

**APROVADO COM OBSERVACOES.**

A Task 7.0 entrega exatamente o que a Task descreve e respeita a
TechSpec: pagina de busca manual completa, com hero do invoice (mais
fallback via API), filtros de valor + data (sem texto, conforme
decisao #4 da TechSpec), lista de notifications em cards reusando o
padrao visual da SuggestionsPage, confirmacao via `ConfirmDialog`
estendido na Task 6 com layout lado-a-lado, redirecionamento ao
PurchaseDetail em sucesso, empty state condicionado a `hasSearched` e
botao "Pular" sempre disponivel. O placeholder da Task 5 foi removido
limpamente e a rota em `App.tsx` foi atualizada com posicao correta
no array de routes. Os 11 testes passam (7 declarados + 4 de
robustez), `tsc --noEmit` retorna 0, `vite build` conclui em 5.91s e
os 21 testes adjacentes (SuggestionsPage + App) seguem verdes — zero
regressao. As 6 falhas em `Tab2.test.tsx` continuam pre-existentes
(confirmadas via stash no review da Task 6).

As 5 observacoes Minor sao todas de qualidade interna ou polimento de
UX, nenhuma bloqueia a entrega ou afeta a correcao funcional:
1 acoplamento implicito via import lateral de CSS (m1), 1 divida de
DRY entre as 2 paginas (m2 — a recomendacao #7 da Task 6 ficou
pendente), 1 detalhe de conversao de data com edge cases marginais
(m3), 1 falta de feedback de erro de rede na busca (m4) e 1 teste de
erro 409 ausente (m5). A divida de m2 ja vinha sinalizada e merece
uma task de refatoracao dedicada apos o PRD inteiro concluir — ao
extrair `AssociationConfirmContent` + helpers, a SuggestionsPage e a
AssociatePage ficam consideravelmente mais leves.

A Task 7.0 esta pronta para seguir para a Task 8.0 (PurchaseDetail —
secao "Pagamento Associado") e Task 9.0 (toasts e desassociacao),
fechando o fluxo end-to-end do PRD.

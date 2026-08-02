# Review: Task 5.0 - Frontend Service + Rota

**Revisor**: AI Code Reviewer
**Data**: 2026-05-23
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Task 5.0 estende corretamente o `purchaseService.ts` com os 3 metodos
necessarios para a feature de associacao (`associateInvoice`,
`disassociateInvoice`, `searchNotifications`), define o tipo
`AssociateResponse`, registra a rota `/purchase/invoice/:id/associate` no
`App.tsx` (na ordem correta, antes da rota generica `/purchase/:type/:id`)
e adiciona um componente placeholder dedicado (`AssociatePagePlaceholder`).
A implementacao reusa o helper `httpRequest` existente sem reinventar nada
do encapsulamento Capacitor/fetch, e o uso de `URLSearchParams` lida
corretamente com a omissao opcional de query params (URL sem `?` quando
nenhum filtro e fornecido). Os 5 novos cenarios de teste cobrem todos os
metodos, incluindo o caminho com todos os filtros, o caminho sem filtros e
um cenario de erro 409. A suite roda 48/48 verde e `tsc --noEmit` retorna 0.

As observacoes sao todas Minor: o placeholder ignora o `location.state`
rico que a `SuggestionsPage` ja envia (sem prejuizo funcional para esta
task, ja que sera substituido na Task 7.0), o cenario de erro so e coberto
para `associateInvoice` (faltam erros explicitos para os outros 2 metodos)
e ha um pequeno detalhe estilistico de assinatura (mais de 3 parametros
"materiais" em `associateInvoice` por nao usar objeto, embora consistente
com `updatePaymentNotificationCategory`).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/services/purchaseService.ts` (modificado, +39 linhas) | OK com Minors | 2 |
| `src/services/purchaseService.test.ts` (modificado, +98 linhas) | OK com Minors | 2 |
| `src/App.tsx` (modificado, +4 linhas) | OK | 0 |
| `src/pages/AssociatePagePlaceholder.tsx` (novo, 19 linhas) | OK com Minor | 1 |

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Padroes de Codigo (TypeScript) | OK | camelCase, PascalCase, kebab-case respeitados; sem `any`; sem magic numbers |
| Reuso do `httpRequest` (Capacitor + fetch fallback) | OK | Nenhuma reinvencao -- as 3 funcoes sao one-liners em cima do helper |
| Ordem de rotas no React Router 5 | OK | `/purchase/invoice/:id/associate` registrada antes de `/purchase/:type/:id`; sem isso, a generica capturaria primeiro |
| `URLSearchParams` para query string | OK | Encoding correto de ISO datetime (`:` -> `%3A`) validado no teste |
| Tipos TypeScript explicitos para request/response | OK | `AssociateResponse`, `Promise<AssociateResponse>`, `Promise<void>`, `Promise<SuggestionResponse[]>` |
| Sem comentarios desnecessarios | OK | Apenas separadores de secao (`// --- Association types ---`) ja existentes no padrao do arquivo |
| Imports em ordem | OK | Nao foi adicionado nenhum import novo no service (helper interno) |
| Testes presentes e passando | OK | 5 novos cenarios + 48/48 testes da camada `services` passando |

## Aderencia a TechSpec

| Decisao Tecnica | Implementado | Observacoes |
|-----------------|--------------|-------------|
| `associateInvoice(invoiceId, paymentNotificationId): Promise<AssociateResponse>` | SIM | Body `{ paymentNotificationId }` via `httpRequest('PATCH', ...)` |
| `disassociateInvoice(invoiceId): Promise<void>` | SIM | `httpRequest('DELETE', ...)` -- o helper ja trata 204 retornando `undefined` |
| `searchNotifications(invoiceId, { amount?, startDate?, endDate? }): Promise<SuggestionResponse[]>` | SIM | Reusa `SuggestionResponse` (decisao da TechSpec linha 214) -- nao cria novo tipo |
| Endpoint `/purchases/invoices/{id}/suggestions/search` | SIM | Path correto |
| Rota nova `/purchase/invoice/:id/associate` | SIM | Registrada com placeholder |
| Reuso do padrao HTTP existente (nao reinventar Capacitor/fetch) | SIM | Todas as 3 funcoes usam `httpRequest` |

## Aderencia ao PRD

| Criterio | Status | Observacoes |
|----------|--------|-------------|
| 6. Novos metodos no service (`associateInvoice`, `disassociateInvoice`, `searchSuggestions`) | OK | Implementados com nome `searchNotifications` (alinhado a TechSpec, divergente do PRD que usa `searchSuggestions`) |
| Service centraliza chamadas | OK | Tudo dentro de `purchaseService.ts`, sem componente fazendo fetch direto |
| Rota acessivel (nao mais tela preta) | OK | `AssociatePagePlaceholder` renderiza conteudo basico para `/purchase/invoice/:id/associate` |
| Tipos TypeScript corretos para request/response | OK | `AssociateResponse` define o contrato de retorno do PATCH |

> **Nota sobre divergencia de nome PRD vs TechSpec**: o PRD (linha 134/176) chama o metodo de `searchSuggestions`, mas a TechSpec (linha 69) padronizou para `searchNotifications`. A implementacao seguiu a TechSpec, o que e correto -- TechSpec e o documento mais recente e refina o PRD.

## Tasks Verificadas

| Subtask | Status | Observacoes |
|---------|--------|-------------|
| 5.1 Adicionar tipo `AssociateResponse` em `purchaseService.ts` | COMPLETA | Linhas 224-228 |
| 5.2 Implementar `associateInvoice()` -- PATCH com body JSON | COMPLETA | Linhas 232-239 |
| 5.3 Implementar `disassociateInvoice()` -- DELETE | COMPLETA | Linhas 241-243 |
| 5.4 Implementar `searchNotifications()` -- GET com query params | COMPLETA | Linhas 245-259, com tratamento de URL sem `?` quando nao ha filtros |
| 5.5 Registrar rota no `App.tsx` com componente placeholder | COMPLETA | `App.tsx:80-82` + `AssociatePagePlaceholder.tsx` |

| Teste declarado na tarefa | Implementado | Arquivo |
|---------------------------|--------------|---------|
| `associateInvoice` chama PATCH com body correto | SIM | `purchaseService.test.ts:102` |
| `disassociateInvoice` chama DELETE | SIM | `purchaseService.test.ts:130` |
| `searchNotifications` chama GET com query params corretos | SIM | `purchaseService.test.ts:165` |
| (extra) `associateInvoice` lanca em HTTP 409 | SIM | `purchaseService.test.ts:118` |
| (extra) `searchNotifications` sem filtros omite `?` | SIM | `purchaseService.test.ts:183` |
| Teste manual: `/purchase/invoice/1/associate` sem tela preta | OK (placeholder renderiza) | nao auditavel via codigo |

## Testes

- Total de testes em `src/services/`: **48**
- Passando: **48**
- Falhando: **0**
- Pulados: **0**
- Arquivos: 5 (`installmentService.test.ts`, `categoryService.test.ts`, `paymentMethodService.test.ts`, `purchaseService.test.ts`, `budgetService.test.ts`)
- Cenarios novos do `purchaseService.test.ts`: **5** (de um total de 8 testes no arquivo)
- `npx tsc --noEmit`: exit 0 (sem erros de tipo)

Comandos executados:
```bash
npx vitest run src/services   # 48/48 PASS
npx tsc --noEmit              # exit 0
```

## Problemas Encontrados

### Problemas Criticos

Nenhum.

### Problemas Major

Nenhum.

### Problemas Minor

**m1. `AssociatePagePlaceholder` ignora `location.state` que a `SuggestionsPage` ja envia**
- **Arquivo**: `src/pages/AssociatePagePlaceholder.tsx`
- **Descricao**: A `SuggestionsPage.tsx` (linhas 121 e 136) ja faz `history.push('/purchase/invoice/' + numId + '/associate', { invoiceId, invoiceTotal, invoiceDate, invoiceMerchantName, notificationId?, notificationAmount?, notificationMerchantName?, notificationPurchasedAt?, notificationCardLastDigits? })`. O placeholder so consome `useParams<{ id }>()` e descarta o `location.state` rico. Para esta Task isso e aceitavel (a `AssociatePage` real da Task 7.0 vai consumir), mas vale registrar que durante o teste manual da subtask 5.5 a tela aparece como "em construcao" sem mostrar nenhum dado do invoice/notification que veio no state -- o que pode confundir quem nao conhece o cronograma.
- **Correcao sugerida**: Opcional. Para fins de smoke test, o placeholder pode exibir o state recebido:
```tsx
const AssociatePagePlaceholder: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const location = useLocation<unknown>();
  return (
    <IonPage>
      <IonContent fullscreen>
        <div style={{ padding: 24 }}>
          <h2>Associar Pagamento</h2>
          <p>Invoice ID: {id}</p>
          <pre>{JSON.stringify(location.state, null, 2)}</pre>
          <p>Pagina de associacao manual em construcao.</p>
        </div>
      </IonContent>
    </IonPage>
  );
};
```
Alternativamente, deixar como esta e remover o arquivo na Task 7.0.

**m2. Falta cenario de erro explicito para `disassociateInvoice` e `searchNotifications`**
- **Arquivo**: `src/services/purchaseService.test.ts`
- **Descricao**: Apenas `associateInvoice` tem um cenario que valida o throw em HTTP nao-OK (`HTTP 409`). `disassociateInvoice` (que pode dar 404 quando o invoice nao existe) e `searchNotifications` (que pode dar 400 quando `startDate` esta mal formatado, conforme integration test do backend) nao tem cobertura de erro. Como o tratamento esta centralizado em `httpRequest`, o risco e baixo, mas seria coerente com a Task 4.0 que cobre todos os codigos 404/409/400 no backend.
- **Correcao sugerida**:
```ts
it('disassociateInvoice throws on HTTP 404', async () => {
  mockFetch.mockResolvedValue({
    ok: false, status: 404, text: () => Promise.resolve('Invoice not found'),
  } as Response);
  await expect(disassociateInvoice(999)).rejects.toThrow('HTTP 404');
});

it('searchNotifications throws on HTTP 400 invalid date', async () => {
  mockFetch.mockResolvedValue({
    ok: false, status: 400, text: () => Promise.resolve('Invalid startDate'),
  } as Response);
  await expect(
    searchNotifications(45, { startDate: 'not-a-date' }),
  ).rejects.toThrow('HTTP 400');
});
```

**m3. `associateInvoice(invoiceId, paymentNotificationId)` usa 2 parametros posicionais de tipo `number`**
- **Arquivo**: `src/services/purchaseService.ts`, linhas 232-235
- **Descricao**: A assinatura tem dois `number` posicionais. No call site, `associateInvoice(45, 123)` nao deixa claro qual eh qual, e uma troca acidental compila silenciosamente (ambos sao `number`). O padrao do arquivo e misto: ha funcoes com 2 params posicionais (`updatePaymentNotificationDescription(id, description)`, `updatePaymentNotificationCategory(id, categoryId)`) e funcoes com objeto (`getInvoices(params: { ... })`). Consistente com o padrao existente, mas vale a pena considerar object pattern para reduzir risco.
- **Correcao sugerida (opcional)**: Manter como esta (consistencia ganha aqui), OU evoluir para:
```ts
export function associateInvoice(
  invoiceId: number,
  params: { paymentNotificationId: number },
): Promise<AssociateResponse> {
  return httpRequest('PATCH', `/purchases/invoices/${invoiceId}/associate`, params);
}
```

**m4. Teste de URL com query string usa `toContain` em vez de comparacao exata**
- **Arquivo**: `src/services/purchaseService.test.ts`, linhas 175-180
- **Descricao**: O teste valida com 3 chamadas `toContain('amount=99.9')`, `toContain('startDate=...')`, `toContain('endDate=...')`. Funciona, mas nao detecta erros de ordem ou de delimitador (ex.: se alguem alterar para `?amount=99.9&startDate=...&endDate=...&amount=99.9` por engano, o teste ainda passaria). E um teste fragil em relacao a ordem dos params (que e definida pela ordem de insercao no `URLSearchParams`).
- **Correcao sugerida (opcional)**:
```ts
expect(calledUrl).toBe(
  expect.stringMatching(
    /\/purchases\/invoices\/45\/suggestions\/search\?amount=99\.9&startDate=2026-05-01T00%3A00%3A00&endDate=2026-05-31T23%3A59%3A59$/,
  ),
);
```
Ou parsear: `expect(new URL(calledUrl).searchParams.get('amount')).toBe('99.9')`.

## Pontos Positivos

1. **Reuso impecavel do `httpRequest`**: as 3 novas funcoes sao one-liners (3-6 linhas cada) que delegam tudo ao helper. Nenhuma duplicacao de logica de Capacitor/fetch, tratamento de status, content-type ou parsing de JSON. Aderencia perfeita ao DRY e ao padrao do arquivo.

2. **`searchNotifications` trata o caso "sem filtros" corretamente**: ao calcular `query.length > 0 ? '?' + query : ''`, evita URLs poluidas tipo `.../search?`. O teste em `purchaseService.test.ts:188-189` valida com regex `/\/search$/`, garantindo que a URL termina sem `?` quando nao ha filtros. Pequeno detalhe que evita ambiguidade no backend.

3. **Ordem de rotas no `App.tsx` esta correta**: `/purchase/invoice/:id/associate` foi colocada ANTES de `/purchase/:type/:id`. Sem isso, o React Router 5 (matching por ordem) capturaria primeiro a generica e renderizaria `PurchaseDetail`. Critico, e bem feito.

4. **Tipo `AssociateResponse` alinhado com o DTO backend** (`AssociateInvoiceResponse.kt` da Task 2): mesmos 3 campos (`invoiceId`, `paymentNotificationId`, `associatedAt: string`). Nomes em camelCase consistentes com o resto do service.

5. **Decisao de criar `AssociatePagePlaceholder.tsx` em arquivo separado em vez de inline component no `App.tsx`**: e a escolha correta. Inline component (ex.: `<Route>{() => <div>Em construcao</div>}</Route>`) criaria um novo componente a cada render do `App`, causando remount da rota a cada re-render. Componente separado e estavel referencialmente. Alem disso, ja deixa o "esqueleto" pronto para receber os hooks (`useParams`, futuramente `useLocation`) que a `AssociatePage` real vai precisar.

6. **Reuso do `SuggestionResponse` em vez de criar novo tipo**: alinhado com a decisao explicita da TechSpec (linha 214: "Reusar `SuggestionResponse` no search"). Evita proliferacao de tipos quase-identicos.

7. **Mock de Capacitor isolado no topo do teste**: `vi.mock('@capacitor/core', ...)` com `isNativePlatform: () => false` forca o path de `fetch` (browser fallback), que e o caminho testado. Limpo e nao depende de runtime de Capacitor.

8. **Cobertura de testes 100% das funcoes novas**: cada um dos 3 metodos tem ao menos 1 cenario positivo, e `searchNotifications` tem ate o edge case "sem filtros" (que e a unica branch logica do metodo). Foco bem direcionado.

9. **`jsonResponse()` helper reutilizado**: o autor manteve o helper existente (linhas 21-28 do test) e usou nos cenarios novos, evitando duplicar a construcao do mock de `Response`.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP (paths, metodos, body) | OK |
| React (rotas, componentes) | OK |
| Testes | OK com Minors (m2, m4) |
| Reuso e DRY | OK |

## Recomendacoes

1. **[Minor]** Adicionar cenarios de erro para `disassociateInvoice` (404) e `searchNotifications` (400) para fechar a simetria com `associateInvoice` (m2).
2. **[Minor]** Considerar exibir o `location.state` no `AssociatePagePlaceholder` durante o desenvolvimento para facilitar o smoke test (m1) -- ou simplesmente deletar o arquivo quando a Task 7.0 entrar.
3. **[Minor/Opcional]** Evoluir o teste de query string para comparacao exata (regex ou parsing via `URL`/`URLSearchParams`) (m4).
4. **[Opcional]** Avaliar migrar a assinatura de `associateInvoice` para `(invoiceId, { paymentNotificationId })` para reduzir risco de troca de parametros no call site (m3) -- ou padronizar todas as funcoes do arquivo, o que e fora do escopo desta task.
5. **[Lembrete para Task 7.0]** O placeholder deve ser removido (ou substituido) quando a `AssociatePage` real for criada. A rota em `App.tsx` precisa apontar para o novo componente, e o import em `App.tsx:29` deve ser atualizado.

## Conclusao

**APROVADO COM OBSERVACOES.**

A Task 5.0 entrega exatamente o que foi pedido: 3 metodos de service novos
alinhados a TechSpec, 1 tipo de response, 1 rota registrada na ordem correta
e 1 placeholder funcional. O codigo respeita integralmente o padrao do
arquivo (uso do helper `httpRequest`, separadores de secao, naming) e nao
introduz nenhuma divida tecnica relevante. A suite de 48 testes da camada
`services` passa 100% sem regressao, com 5 cenarios novos cobrindo todas
as funcoes adicionadas. `tsc --noEmit` retorna 0.

As 4 observacoes Minor sao todas de polimento incremental (cobertura de
erro, placeholder mais informativo, teste de URL mais estrito, assinatura
de funcao). Nenhuma bloqueia a entrega ou impacta as Tasks 6.0/7.0.

A Task 5.0 esta pronta para seguir para a Task 6.0 (Modal de confirmacao
na SuggestionsPage).

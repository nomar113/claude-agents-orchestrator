# Review: Task 3.0 - Frontend - Service `updatePaymentNotificationCard` em `purchaseService.ts`

**Revisor**: AI Code Reviewer
**Data**: 2026-06-14
**Arquivo da task**: 3_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task pedia a adicao da funcao `updatePaymentNotificationCard(id, paymentMethodId, subCardId)` no service frontend, reusando o helper `httpRequest` existente e mantendo o sub-cartao como `null` explicito no body quando ausente. A implementacao em `src/services/purchaseService.ts` esta correta, segue exatamente a assinatura e o contrato da Tech Spec (secao "Interfaces Principais — Frontend Service"), reusa o `httpRequest` local sem duplicar logica de transport e ocupa apenas 11 linhas, em linha com clean-code. Os 4 novos testes cobrem os tres branches exigidos pela task (subCardId null, subCardId numerico, erro HTTP), com um teste extra para erro de rede (alem do exigido). A bateria total subiu de 14 para 18 testes, 18 PASS / 0 FAIL, e `npx tsc --noEmit` nao reporta erros. Foi identificada uma observacao minor de consistencia arquitetural (existencia do `httpClient.ts` exportado, sem PATCH, que ja era um desvio pre-existente do projeto e foge ao escopo desta task).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/services/purchaseService.ts` | OK | 1 (minor, pre-existente) |
| `src/services/purchaseService.test.ts` | OK | 1 (minor) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**M1 - Duplicacao pre-existente do helper `httpRequest` entre `purchaseService.ts` e `httpClient.ts`**
- **Arquivo**: `src/services/purchaseService.ts:4-34` e `src/services/httpClient.ts:4-36`
- **Descricao**: O projeto possui um `httpClient.ts` que exporta um `httpRequest<T>` quase identico ao definido inline em `purchaseService.ts`. A diferenca-chave: o exportado em `httpClient.ts` **nao aceita o metodo `PATCH`** (o uniao de literais e `'GET' | 'POST' | 'PUT' | 'DELETE'`), enquanto a copia local em `purchaseService.ts` aceita. Por isso, a nova funcao `updatePaymentNotificationCard` precisa necessariamente usar a versao local. Esta duplicacao **ja existia antes desta task** e nao foi introduzida por ela — todos os endpoints PATCH do `purchaseService.ts` (description, category, purchased-at, cancel, associate) ja dependem do helper local.
- **Impacto**: Nulo nesta entrega; a task explicitamente pede "reusar o helper `httpRequest` existente" e a interpretacao do desenvolvedor foi consistente com o resto do arquivo. Risco arquitetural de drift caso outro service precise de PATCH e copie o helper de novo.
- **Sugestao**: Fora do escopo desta task. Recomenda-se uma task tecnica futura para consolidar: estender `httpClient.ts` para aceitar `PATCH` e migrar todos os services que mantem copias locais (purchase, futuramente outros). Nao bloqueante para a Task 3.0.

**M2 - Teste de `subCardId numerico` nao captura explicitamente o `headers Content-Type: application/json`**
- **Arquivo**: `src/services/purchaseService.test.ts:355-361`
- **Descricao**: O teste `sends PATCH with numeric subCardId when informado` valida `method` e `body` mas omite a verificacao do header `Content-Type: application/json` (que esta presente apenas no primeiro teste do describe). O helper sempre envia esse header quando ha body, entao a asserção poderia ser mais consistente entre os casos.
- **Impacto**: Nulo. O primeiro teste do mesmo describe ja cobre o header e o helper e o mesmo para os dois casos. E uma questao de simetria de asserção, nao de cobertura efetiva.
- **Sugestao**: Opcional — adicionar `headers: { 'Content-Type': 'application/json' }` ao `expect.objectContaining(...)` do segundo teste para uniformidade. Nao bloqueante.

## Destaques Positivos

1. **Assinatura identica ao contrato da Tech Spec** (secao "Interfaces Principais — Frontend Service"): `updatePaymentNotificationCard(id: number, paymentMethodId: number, subCardId: number | null): Promise<PaymentNotificationDetail>`. Tipos, ordem de argumentos e nome do retorno casam exatamente.
2. **`subCardId: null` enviado explicitamente no body**, nao omitido. Confirmado via `JSON.stringify({ paymentMethodId: 3, subCardId: null })` que produz `{"paymentMethodId":3,"subCardId":null}`. Atende ao criterio explicito da PRD/task ("envia `subCardId: null` no body, nao omite chave").
3. **Reuso do helper `httpRequest`** consistente com `updatePaymentNotificationDescription`, `updatePaymentNotificationCategory` e `updatePaymentNotificationPurchasedAt` no mesmo arquivo. Nenhuma logica de transport duplicada nesta task.
4. **Funcao curta (11 linhas) com responsabilidade unica** — apenas monta o body e delega ao helper. Aderente a clean-code: sem branches, sem efeitos colaterais, sem mutacao.
5. **Path correto** com interpolacao do `id`: `/payments/notifications/${id}/payment-method`. Casa com o endpoint da Tech Spec (`PATCH /payments/notifications/{id}/payment-method`) e com o roteamento do controller backend ja revisado nas Tasks 1.0 e 2.0.
6. **Tipo de retorno `PaymentNotificationDetail`** ja inclui `paymentMethodId: number | null` e `subCardId: number | null` (linhas 65-66 do arquivo), entao a Task 5.0 podera consumir esses campos diretamente para atualizar o `PurchaseDetail` sem mapeamento adicional.
7. **Service desacoplado da UI** — nenhum `useState`/`useEffect`/import de React. Atende a skill `vercel-react-best-practices` (servicos como funcoes puras de transport).
8. **Cobertura dos 3 cenarios "Testes da Tarefa"**:
   - subCardId = null -> verifica path, metodo, body com `null` explicito e header (linhas 331-345).
   - subCardId = numero -> verifica path, metodo e body com o numero (linhas 347-362).
   - erro de rede/4xx/5xx propaga sem swallow -> dois testes (HTTP 409 em 364-372, network error em 374-378).
9. **Mock determinista do `Capacitor.isNativePlatform()` para `false`** (linha 4 do teste) — garante o branch `fetch` web, consistente com o ambiente de teste sem JNI nativo. O helper se comporta identico no caminho nativo (mesma serializacao do body).
10. **Resultados de execucao confirmados**: `npx vitest run src/services/purchaseService.test.ts` retorna **18 PASS / 0 FAIL** (14 testes pre-existentes intactos + 4 novos). `npx tsc --noEmit` reporta **No errors found**. Ambos rodados localmente nesta revisao.
11. **Idempotencia honrada via backend** — o frontend nao precisa tratar deduplicacao porque o provider backend ja garante (revisado na Task 1.0). A funcao apenas faz a requisicao, o que e correto.
12. **Erros propagam como `Error('HTTP <status>: <body>')`** via helper compartilhado, mantendo o mesmo formato dos demais services. A Task 5.0 (PurchaseDetail) podera fazer `try/catch` consistente.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (TypeScript estrito + reuso do helper) | OK |
| Clean Code (responsabilidade unica, sem duplicacao logica de transport) | OK |
| Vercel React Best Practices (servico desacoplado da UI) | OK |
| Aderencia a Tech Spec (assinatura e path identicos) | OK |
| Aderencia a Task (requirements + subtarefas 3.1, 3.2, 3.3) | OK |
| Cobertura de Testes (3 branches obrigatorios + extra de rede) | OK |
| Execucao dos Testes (18/18 PASS) | OK |
| Tipagem (npx tsc --noEmit sem erros) | OK |

## Verificacao de Execucao

- `npx vitest run src/services/purchaseService.test.ts`: **18 PASS / 0 FAIL** (14 pre-existentes + 4 novos no describe `updatePaymentNotificationCard`).
- `npx tsc --noEmit`: **No errors found**.
- `git diff` aplicado em `src/services/purchaseService.ts` (+11 linhas) e `src/services/purchaseService.test.ts` (+71 linhas) — apenas adicoes, nenhuma alteracao em codigo existente. Risco de regressao em testes ja verdes: zero.
- Sanity check de serializacao: `JSON.stringify({ paymentMethodId: 3, subCardId: null })` produz `{"paymentMethodId":3,"subCardId":null}`, confirmando que `null` e enviado e nao omitido.

## Recomendacoes

1. **Manter** a duplicacao do helper como esta nesta task. Abrir uma task tecnica futura para unificar `httpClient.ts` e o helper local de `purchaseService.ts` (adicionar `PATCH` ao tipo de uniao do export, migrar os 6 PATCH atuais). Nao bloqueante.
2. **Opcional**: padronizar a asserção do header `Content-Type` em todos os 4 testes do novo describe para uniformidade. Nao bloqueante.
3. **Documentar para a Task 5.0** (`PurchaseDetail.tsx`) que o erro propagado vem como `Error('HTTP <status>: <body>')` — a UI deve mapear `HTTP 409` para mensagem de "notificacao cancelada", `HTTP 400` para "cartao/sub-cartao invalido" e `HTTP 404` para "notificacao nao encontrada", conforme contrato da Tech Spec.
4. **Documentar para a Task 4.0** (`PaymentMethodSelector`) que o callback `onSelect(paymentMethodId, subCardId | null)` deve sempre passar `null` explicito (e nao `undefined`) quando o usuario optar por "Continuar sem sub-cartao" ou quando o cartao nao tiver sub-cards, para que a chamada a `updatePaymentNotificationCard` mantenha o contrato.

## Veredito

A implementacao esta **correta, alinhada ao PRD e a Tech Spec**, segue os padroes do projeto (clean-code + vercel-react-best-practices), reusa o helper `httpRequest` existente sem duplicar logica de transport e cobre todos os criterios de sucesso listados em `3_task.md` com 4 testes que passam (alem dos 14 testes pre-existentes que continuam verdes). A unica observacao minor relevante (M1, duplicacao do helper) ja era um desvio pre-existente do projeto e foge ao escopo desta task. A task esta **aprovada com observacoes** e pode ser considerada concluida. Proximo passo: seguir para a Task 4.0 (estender `PaymentMethodSelector` com modo `edit` e ajustar o callback `onSelect` para sempre receber `subCardId: number | null`).

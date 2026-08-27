# Review: Task 2.0 - Orquestracao Playwright: maquina de estados READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR

**Revisor**: AI Code Reviewer
**Data**: 2026-08-27
**Arquivo da task**: 2_task.md
**Status**: MUDANCAS SOLICITADAS

## Resumo

A Tarefa 2.0 implementou a orquestracao Playwright (`extractInvoice`) com um gerenciador de browser de vida longa (`browser-manager.ts`) e um loop de polling (`orchestrator.ts`) que resolve para os 4 estados esperados. `npm run typecheck` e `npm test` rodam limpos (15/15 testes, Chromium real, ~5-6s), o cleanup de `BrowserContext` esta correto em todos os cenarios cobertos pelos testes, e a analise tecnica sobre a serializacao de `page.evaluate` (motivo de ter tornado as funcoes da Tarefa 1.0 autocontidas) esta **correta** — validei isso empiricamente (ver secao "Validacao do item 1" abaixo).

Porem, encontrei um problema **critico e reproduzivel**: quando a pagina navega/recarrega durante o loop de polling — comportamento que o proprio codigo documenta como esperado da SEFAZ-RJ real ("reCAPTCHA v3 e desafio anti-bot F5/TSPD que recarregam o documento varias vezes", comentario em `readiness.ts:1-3`) — `page.evaluate` lanca `Execution context was destroyed, most likely because of a navigation`, e essa excecao **propaga para fora de `extractInvoice`, rejeitando a Promise** em vez de resolver para um dos 4 estados (`READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR`) exigidos pela assinatura da Tech Spec e pelo proprio requisito da tarefa ("resolve para um dos 4 estados definidos"). Reproduzi isso com um servidor de fixture que recarrega a pagina repetidamente (simulando o comportamento documentado da SEFAZ): **3 de 4 execucoes falharam** com exatamente esse erro, apontando para `orchestrator.ts:31`. Nenhuma fixture do conjunto de testes entregue exercita esse cenario (todas sao HTML estatico, sem nenhum reload apos o carregamento inicial), entao o gap nao aparece na suite atual — mas e precisamente o comportamento que a Tech Spec cita como razao de existir o polling.

Isso nao invalida o trabalho (a arquitetura, o cleanup e a decisao tecnica de fundo estao corretos), mas e um bug real que muito provavelmente vai se manifestar contra a SEFAZ real na validacao manual da Tarefa 8.0, e precisa ser corrigido antes disso.

## Validacao do item 1 (serializacao de `page.evaluate`)

Confirmei com testes diretos de `tsc` que:

1. **A analise esta correta**: `page.evaluate(fn)` serializa `fn` via `toString()` e a reexecuta isolada no browser; qualquer referencia a escopo externo ao corpo da funcao causaria `ReferenceError` em runtime. Nao ha alternativa mais idiomatica no Playwright para reaproveitar helpers de modulo dentro de uma `pageFunction` — a pratica recomendada e mesmo inline tudo (confirmado tambem por experimento: uma funcao wrapper como `() => isInvoiceReadyRJ()` sofreria o mesmo problema, pois o `toString()` da wrapper ainda contem a referencia externa `isInvoiceReadyRJ`). A escolha de aninhar os helpers dentro da propria funcao exportada esta correta e e o padrao esperado.
2. **O cast de tipo em `orchestrator.ts:15-17` e realmente necessario** — nao e um cast desnecessario. Reproduzi o erro de compilacao removendo o cast: o tipo de `page.evaluate` exige `PageFunction<void, R> = (arg: void) => R`, e `(doc?: Document) => R` nao e atribuivel a isso porque `void` nao e atribuivel a `Document | undefined` (erro TS2345, confirmado via `tsc --noEmit` num probe isolado no proprio projeto).
3. **Existe, porem, uma alternativa mais segura que o `as` cast**: declarar overloads explicitos nas 3 funcoes da Tarefa 1.0, por exemplo:
   ```ts
   export function isInvoiceReadyRJ(): boolean;
   export function isInvoiceReadyRJ(doc: Document): boolean;
   export function isInvoiceReadyRJ(doc: Document = document): boolean { /* ... */ }
   ```
   Testei essa forma: com os overloads, `page.evaluate(isInvoiceReadyRJ)` **compila sem nenhum cast**, porque o proprio tipo da funcao ja inclui a assinatura `() => boolean` verificada estruturalmente pelo compilador — ao contrario do `as`, que e uma afirmacao opaca e nao seria pega pelo compilador se a assinatura real da funcao mudasse de forma incompativel no futuro (ex.: um segundo parametro obrigatorio adicionado por engano). Isso nao e um bug hoje (o cast atual e seguro na pratica, o objeto de funcao chamado em runtime e o mesmo), mas e uma pratica de tipagem mais idiomatica e caberia como melhoria. Ver Problema Major #2.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `nfce-extraction-service/src/browser/browser-manager.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/orchestrator.ts` | Critico | 1 critico, 1 major, 1 minor |
| `nfce-extraction-service/src/extractor/readiness.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/block-detection.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/extract.ts` | OK | 0 |
| `nfce-extraction-service/src/types.ts` | OK | 0 |
| `nfce-extraction-service/test/browser/browser-manager.test.ts` | OK | 0 |
| `nfce-extraction-service/test/extractor/orchestrator.test.ts` | Problemas | 1 major (gap de cobertura) |
| `nfce-extraction-service/test/fixtures/server.ts` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

**1. `extractInvoice` rejeita (em vez de resolver) quando a pagina navega/recarrega durante o polling (`orchestrator.ts:29-46`)**

```ts
async function pollForReadyOrBlocked(page: Page, deadline: number): Promise<ExtractionResult> {
  while (Date.now() < deadline) {
    const blockMessage = await page.evaluate(getBlockMessageForPage);
    // ...
```

`getBlockMessageForPage`/`isInvoiceReadyForPage` sao chamadas via `page.evaluate` a cada iteracao do loop sem nenhum tratamento para o caso de a pagina ter navegado entre o inicio da iteracao e a execucao do `evaluate` (ou durante ela). Quando isso acontece, o Playwright lanca `Error: Execution context was destroyed, most likely because of a navigation`, que nao e capturado em lugar nenhum do loop — apenas o `page.goto` inicial tem tratamento de erro (`try/catch` -> `NAVIGATION_ERROR`, `orchestrator.ts:55-59`). O resultado e que `extractInvoice(...)` **rejeita** em vez de resolver para `TIMEOUT`, `READY` ou `BLOCKED`, quebrando o contrato `Promise<ExtractionResult>` definido na Tech Spec (que nao inclui um estado de "erro generico") e violando o proprio texto do requisito da tarefa ("resolve para um dos 4 estados definidos").

Isso e agravado pelo fato de que o proprio comentario de `readiness.ts:1-3` documenta que a pagina real da SEFAZ-RJ **recarrega o documento varias vezes** por causa do reCAPTCHA v3/desafio F5-TSPD — ou seja, esse nao e um edge case improvavel, e sim o comportamento esperado do alvo real que esta tarefa existe para tratar. Nenhuma das fixtures usadas em `orchestrator.test.ts` recarrega a pagina apos o load inicial, entao esse cenario nunca e exercitado pela suite atual.

**Reproducao**: criei uma fixture temporaria que redireciona a propria pagina a cada ~80ms (simulando os reloads do desafio anti-bot) e chamei `extractInvoice` contra ela com `EXTRACTION_TIMEOUT_MS=4500`. Resultado: **3 de 4 execucoes falharam** com:
```
page.evaluate: Execution context was destroyed, most likely because of a navigation
    at pollForReadyOrBlocked (src/extractor/orchestrator.ts:31:37)
    at withBrowserContext (src/browser/browser-manager.ts:23:12)
```
(O cleanup do `BrowserContext` continua correto mesmo nesse caminho — o `finally` de `withBrowserContext` fecha o contexto antes de repropagar o erro — entao nao ha vazamento de memoria, apenas a Promise de `extractInvoice` rejeita quando deveria resolver.)

**Correcao sugerida**: tratar a destruicao de contexto por navegacao como "ainda nao pronto" dentro do loop, continuando o polling ate o deadline, em vez de deixar a excecao subir:

```ts
const NAVIGATION_RACE_MESSAGE = 'Execution context was destroyed';

async function evaluateWhileStable<T>(page: Page, fn: () => T): Promise<T | null> {
  try {
    return await page.evaluate(fn);
  } catch (error) {
    if (error instanceof Error && error.message.includes(NAVIGATION_RACE_MESSAGE)) {
      return null;
    }
    throw error;
  }
}

async function pollForReadyOrBlocked(page: Page, deadline: number): Promise<ExtractionResult> {
  while (Date.now() < deadline) {
    const blockMessage = await evaluateWhileStable(page, getBlockMessageForPage);
    if (blockMessage) {
      return { status: 'BLOCKED', message: blockMessage };
    }

    const ready = await evaluateWhileStable(page, isInvoiceReadyForPage);
    if (ready) {
      const data = await evaluateWhileStable(page, extractDataForPage);
      if (data) {
        return { status: 'READY', data };
      }
    }

    await page.waitForTimeout(POLL_INTERVAL_MS);
  }

  return { status: 'TIMEOUT', message: 'Tempo esgotado ao consultar a SEFAZ' };
}
```

Recomendo fortemente adicionar um teste de integracao com uma fixture que recarrega a propria pagina uma ou mais vezes durante o polling (como a que usei para reproduzir o bug), para que esse cenario passe a ser coberto pela suite antes da validacao manual da Tarefa 8.0.

### Problemas Major

**1. Cobertura de teste nao inclui o cenario de navegacao/reload durante o polling (`test/extractor/orchestrator.test.ts`)**

Consequencia direta do Critico #1: a suite cobre bem os 4 estados com paginas estaticas, mas nao cobre o caso — citado na propria Tech Spec e no comentario de `readiness.ts` como comportamento esperado da SEFAZ real — de a pagina navegar durante o polling. Isso permitiu que o bug critico acima passasse despercebido com `npm test` 100% verde. Ver correcao sugerida no Critico #1.

**2. `as` cast em `orchestrator.ts:15-17` poderia ser evitado com overloads mais seguros**

```ts
const getBlockMessageForPage = getBlockMessageRJ as () => string | null;
const isInvoiceReadyForPage = isInvoiceReadyRJ as () => boolean;
const extractDataForPage = extractDataFromRJ as () => ExtractedInvoice;
```

Como detalhado na secao "Validacao do item 1", o cast e tecnicamente justificado (ha uma incompatibilidade real de tipos), mas um `as` e uma afirmacao que o compilador para de verificar — se a assinatura real de `isInvoiceReadyRJ` etc. mudar de forma incompativel no futuro (ex.: um parametro adicional obrigatorio), o cast continuaria compilando silenciosamente. Declarar overloads em `readiness.ts`, `block-detection.ts` e `extract.ts` (`function isInvoiceReadyRJ(): boolean; function isInvoiceReadyRJ(doc: Document): boolean; function isInvoiceReadyRJ(doc: Document = document): boolean { ... }`) elimina a necessidade do cast e mantem a verificacao estrutural do compilador — testei essa alternativa e ela compila sem erros nem casts em `orchestrator.ts`.

**Correcao sugerida**: mover os `as` casts para overloads nas 3 funcoes de origem.

### Problemas Minor

1. **`orchestrator.ts:48-51` e `29-33`** — blank lines dentro do corpo de `extractInvoice` e `pollForReadyOrBlocked`, violando literalmente o padrao "sem linhas em branco dentro de metodos" do checklist do projeto. Mesma observacao ja feita (e aceita como nao-bloqueante) na review da Tarefa 1.0 — mantida aqui por consistencia de criterio, nao bloqueante.
2. **`orchestrator.ts:56`** — `page.goto(invoiceUrl, { waitUntil: 'domcontentloaded', timeout: timeoutMs })` usa o timeout **total** configurado, nao o tempo restante ate `deadline`. Como `deadline = Date.now() + timeoutMs` e calculado antes da criacao do `BrowserContext`/pagina, na pior hipotese (setup de browser/context lento somado a um `goto` que consome todo o seu proprio timeout) o tempo total de `extractInvoice` pode ultrapassar levemente o `EXTRACTION_TIMEOUT_MS` configurado. Impacto pratico baixo (setup de contexto e rapido), mas o mais preciso seria `timeout: Math.max(0, deadline - Date.now())`.

## Destaques Positivos

- Analise tecnica do agente implementador sobre a serializacao de `page.evaluate` (motivo de tornar as funcoes da Tarefa 1.0 autocontidas com `doc: Document = document`) esta **correta** e foi validada empiricamente nesta review.
- `withBrowserContext` (`browser-manager.ts`) e uma abstracao limpa e correta: garante fechamento do `BrowserContext` via `try/finally` em **todos** os caminhos, inclusive quando a funcao executada lanca excecao — verificado tanto pelos testes de unidade quanto pelo teste de reproducao do bug critico (o contexto fechou corretamente mesmo quando `extractInvoice` rejeitou).
- Testes de integracao usam Chromium real contra um servidor HTTP local de fixtures, sem nenhuma chamada a SEFAZ real, conforme exigido pela Tech Spec — e sao rapidos (~5s para 15 testes) e estaveis nos 4 cenarios que cobrem (rodei a suite completa e o arquivo de orquestracao isoladamente varias vezes sem flakiness).
- Boa escolha de `waitUntil: 'domcontentloaded'` no `page.goto`, delegando a espera pela renderizacao real da nota ao loop de polling em vez de tentar usar `'load'`/`'networkidle'`, o que seria inadequado dado o comportamento anti-bot da pagina.
- `DEFAULT_TIMEOUT_MS` documentado com referencia explicita ao valor equivalente do fluxo client-side, configuravel via `EXTRACTION_TIMEOUT_MS`, atendendo ao requisito da tarefa.
- `npm run typecheck` e `npm test` rodam limpos.
- `getOpenContextCount()` como ferramenta de inspecao dedicada para testes e uma boa decisao de design — permite validar ausencia de vazamento de forma direta em vez de inferir por efeitos colaterais.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas (blank lines minor, cast evitavel) |
| TypeScript/Node.js | Problemas (cast `as` evitavel via overloads — nao e `any`, mas e um escape hatch do mesmo espirito) |
| REST/HTTP | Nao aplicavel nesta tarefa |
| Logging | Nao aplicavel nesta tarefa (fica para a Tarefa 4.0) |
| React | Nao aplicavel |
| Testes | Critico (gap de cobertura que escondeu o bug do Critico #1) |

## Recomendacoes

1. (Bloqueante) Corrigir `pollForReadyOrBlocked` para tratar `Execution context was destroyed`/erros de navegacao durante o `page.evaluate` como "ainda nao pronto", continuando o polling ate o deadline, em vez de deixar a excecao rejeitar `extractInvoice`. Ver codigo sugerido no Problema Critico #1.
2. (Bloqueante) Adicionar um teste de integracao com uma fixture que recarrega a pagina uma ou mais vezes durante o polling, cobrindo o cenario documentado como esperado da SEFAZ-RJ real.
3. (Recomendado, nao bloqueante) Substituir os `as` casts em `orchestrator.ts:15-17` por overloads explicitos nas funcoes de `readiness.ts`, `block-detection.ts` e `extract.ts`.
4. (Recomendado, nao bloqueante) Usar `deadline - Date.now()` como timeout de `page.goto` em vez do `timeoutMs` total, para nao permitir que o overhead de setup do contexto estoure levemente o teto configurado.
5. (Opcional) Revisitar as blank lines dentro de `extractInvoice`/`pollForReadyOrBlocked` se a equipe quiser aderencia estrita ao padrao "sem blank lines em metodos" (mesma decisao ja tomada como opcional na Tarefa 1.0).

## Resolucao pos-review

- **Critico #1 (rejeicao em vez de resolucao durante reload)**: corrigido. `pollForReadyOrBlocked` agora envolve cada `page.evaluate` num `try/catch` que trata `Execution context was destroyed`, `Frame was detached` e `Target closed` como "ainda nao pronto" (`isPageReloadInterruption`), continuando o polling ate o deadline em vez de propagar a excecao. `extractInvoice` volta a sempre resolver para um dos 4 estados.
- **Major #1 (gap de cobertura)**: corrigido. `test/fixtures/server.ts` ganhou a rota `/reloading`, que simula o desafio anti-bot recarregando a pagina 2 vezes antes de servir a nota pronta. Novo teste em `orchestrator.test.ts` ("retorna READY mesmo quando a pagina recarrega varias vezes durante o polling") cobre exatamente o cenario reproduzido na review. Suite completa: 16/16 testes passando; rodei o arquivo de orquestracao isoladamente 3x seguidas sem flakiness.
- **Major #2 (`as` cast evitavel)**: corrigido. `isInvoiceReadyRJ`, `getBlockMessageRJ` e `extractDataFromRJ` ganharam overloads explicitos (`(): R` e `(doc: Document): R`) em `readiness.ts`/`block-detection.ts`/`extract.ts`. Os `as` casts em `orchestrator.ts` foram removidos — `page.evaluate(isInvoiceReadyRJ)` etc. agora compilam diretamente, com verificacao estrutural do compilador. `npm run typecheck` confirmado limpo apos a mudanca.
- **Minor `page.goto` timeout vs deadline**: nao alterado — impacto pratico desprezivel (diferenca de microssegundos entre o calculo do deadline e a chamada de `goto`), conforme a propria review classificou como nao-bloqueante.
- **Minor blank lines internas**: nao alterado — mesma decisao de manter por legibilidade, ja tomada como opcional nas Tarefas 1.0 e 2.0.

## Veredito

Mudancas solicitadas. A arquitetura geral (browser de vida longa, `BrowserContext` por chamada, cleanup via `try/finally`, decisao de tornar as funcoes da Tarefa 1.0 autocontidas para sobreviver a serializacao de `page.evaluate`) esta correta e bem fundamentada — validei a analise tecnica do item mais arriscado desta tarefa (serializacao de `page.evaluate`) e ela se confirma correta tanto na causa quanto, em grande parte, na solucao adotada. Porem, encontrei e reproduzi um bug critico: o loop de polling nao sobrevive a uma navegacao/reload da pagina durante o `page.evaluate`, e esse e exatamente o comportamento que a SEFAZ-RJ real exibe segundo a documentacao do proprio codigo (comentario em `readiness.ts`). Como nenhuma fixture da suite atual recarrega a pagina apos o load inicial, esse gap nao aparece em `npm test`, mas se manifestou em 3 de 4 execucoes contra uma fixture que simula reloads continuos. Esse ponto precisa ser corrigido — e coberto por teste — antes de avancar para a Tarefa 3.0 (API HTTP) e principalmente antes da validacao manual contra a SEFAZ real da Tarefa 8.0, onde o bug teria alta probabilidade de aparecer como uma falha intermitente e dificil de diagnosticar.

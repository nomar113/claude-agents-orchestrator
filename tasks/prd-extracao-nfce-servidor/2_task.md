# Tarefa 2.0: Orquestracao Playwright: maquina de estados READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar a orquestracao com Playwright (+ `playwright-extra`/stealth) que navega ate a URL da nota, faz polling de prontidao/bloqueio usando as funcoes puras da Tarefa 1.0 (via `page.evaluate`), e resolve para um dos 4 estados definidos na Tech Spec: `READY`, `BLOCKED`, `TIMEOUT`, `NAVIGATION_ERROR`. Mantem um browser Chromium de vida longa e abre um `BrowserContext` isolado por requisicao, evitando o custo de boot a cada extracao.

<skills>
### Conformidade com Skills Padroes

Nao ha skill dedicada a Playwright/automacao de browser no repositorio. Nenhuma skill padrao do orquestrador se aplica diretamente alem das boas praticas gerais de codigo limpo.
</skills>

<requirements>
- Implementar `extractInvoice(invoiceUrl: string): Promise<ExtractionResult>` conforme assinatura definida na Tech Spec (secao "Interfaces Principais").
- Browser Chromium deve ser iniciado uma unica vez (processo de vida longa) e reutilizado entre requisicoes; cada extracao usa um `BrowserContext` novo, fechado ao final (sucesso ou erro).
- Aplicar `playwright-extra` + plugin de stealth para reduzir a chance de deteccao pelo desafio F5/TSPD da SEFAZ-RJ.
- Implementar o polling: navegar para `invoiceUrl`, checar periodicamente `isInvoiceReadyRJ`/`getBlockMessageRJ` via `page.evaluate`, ate: nota pronta (`READY` + dados de `extractDataFromRJ`), bloqueio detectado (`BLOCKED` + mensagem), tempo maximo esgotado (`TIMEOUT`), ou erro de navegacao (`NAVIGATION_ERROR`).
- Garantir que o `BrowserContext` e paginas sejam sempre fechados, mesmo em caso de excecao, para nao vazar memoria no processo de longa duracao.
- Timeout maximo configuravel via variavel de ambiente, com um default alinhado ao timeout ja usado hoje no fluxo client-side (referenciar o valor atual em `rj.js`/`InvoiceProcessingContext.tsx` como base).
</requirements>

## Subtarefas

- [x] 2.1 Adicionar dependencias `playwright`, `playwright-extra` e o plugin de stealth ao `nfce-extraction-service`.
- [x] 2.2 Implementar o gerenciador de browser de vida longa (`src/browser/browser-manager.ts`): inicializacao unica, criacao/fechamento de `BrowserContext` por chamada.
- [x] 2.3 Implementar `src/extractor/orchestrator.ts` com a funcao `extractInvoice`, integrando navegacao + polling + as funcoes da Tarefa 1.0 via `page.evaluate`.
- [x] 2.4 Implementar o loop de polling com timeout configuravel e mapeamento para os 4 estados (`READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR`).
- [x] 2.5 Garantir cleanup de `BrowserContext`/pagina em blocos `finally`, cobrindo o caminho de erro.
- [x] 2.6 Escrever testes unitarios/integracao usando um servidor HTTP local (fixture) que simula as paginas de sucesso e bloqueio da SEFAZ, validando que `extractInvoice` retorna o estado e dados corretos sem acessar a SEFAZ real.
- [x] 2.7 Escrever teste cobrindo o caso de `TIMEOUT` (fixture que nunca fica pronta) e `NAVIGATION_ERROR` (URL invalida/servidor indisponivel).

## Detalhes de Implementacao

Ver Tech Spec, secoes "Interfaces Principais" (assinatura `extractInvoice`), "Visao Geral dos Componentes" (browser de vida longa, `BrowserContext` isolado), "Pontos de Integracao" (SEFAZ-RJ, maquina de estados) e "Abordagem de Testes" > "Testes de Integracao" (Node): usar fixture HTTP local, nunca a SEFAZ real em testes automatizados.

## Criterios de Sucesso

- `extractInvoice` retorna `READY` com os dados extraidos corretamente para a fixture de sucesso.
- `extractInvoice` retorna `BLOCKED` com a mensagem apropriada para a fixture de bloqueio.
- `extractInvoice` retorna `TIMEOUT` quando a nota nunca fica pronta dentro do limite configurado.
- `extractInvoice` retorna `NAVIGATION_ERROR` quando a navegacao falha (servidor indisponivel/URL invalida).
- Nenhum `BrowserContext` fica aberto apos a chamada retornar, em nenhum dos cenarios acima (validar via contagem de contexts abertos no browser-manager).

## Testes da Tarefa

- [x] Testes de unidade do `browser-manager` (criacao/fechamento de contexto, incluindo em caso de erro).
- [x] Testes de integracao de `extractInvoice` contra servidor HTTP local com fixtures (sucesso, bloqueio, timeout, erro de navegacao).
- [x] Testes E2E: nao aplicavel nesta tarefa (fica para a Tarefa 8.0, validacao manual contra SEFAZ real).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `nfce-extraction-service/src/browser/browser-manager.ts` (novo)
- `nfce-extraction-service/src/extractor/orchestrator.ts` (novo)
- `nfce-extraction-service/src/extractor/readiness.ts`, `block-detection.ts`, `extract.ts` (da Tarefa 1.0, consumidos aqui)
- `nfce-extraction-service/test/extractor/orchestrator.test.ts` (novo)
- `nfce-extraction-service/test/fixtures/server.ts` (novo, servidor HTTP local de fixtures)
- `nfce-extraction-service/package.json` (dependencias)

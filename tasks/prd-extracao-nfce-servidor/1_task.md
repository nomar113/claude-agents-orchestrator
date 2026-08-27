# Tarefa 1.0: Nucleo de extracao (Node): logica pura de deteccao/parsing

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Portar para TypeScript, como funcoes puras (sem dependencia de browser real), a logica hoje existente em `extract_data_scripts/rj.js` no `controlai-frontend`: deteccao de nota pronta (`isInvoiceReadyRJ`), deteccao de bloqueio/erro da SEFAZ (`getBlockMessageRJ`) e extracao dos campos da nota (`extractDataFromRJ`). Essas funcoes formam a base de todo o `nfce-extraction-service` e devem ser testaveis isoladamente, via parsing de DOM, sem precisar subir um Chromium.

<skills>
### Conformidade com Skills Padroes

Nao ha skill dedicada a Node/TypeScript/Playwright no repositorio. Nenhuma skill padrao do orquestrador se aplica diretamente a esta tarefa alem das boas praticas gerais de codigo limpo.
</skills>

<requirements>
- Criar o projeto `nfce-extraction-service/` (Node.js + TypeScript) com estrutura minima (`package.json`, `tsconfig.json`, `src/`).
- Portar as 3 funcoes de `rj.js` mantendo o mesmo comportamento observavel (mesmos campos extraidos, mesmos criterios de prontidao/bloqueio).
- As funcoes devem operar sobre um DOM ja carregado (ex: recebendo `document`/`window` ou um objeto equivalente via JSDOM), sem chamadas de rede ou dependencia de Playwright nesta tarefa.
- Tipar o retorno de `extractDataFromRJ` conforme o modelo `ExtractedInvoice` descrito na Tech Spec (secao "Modelos de Dados"): `merchantName, cnpj, merchantAddress, totalItems, subtotal, discount, total, taxes, date, items[], payments[]`.
- Salvar fixtures HTML reais (anonimizadas de dados pessoais quando necessario) representando: nota pronta/sucesso, nota bloqueada pela SEFAZ, e nota ainda carregando (nao pronta).
</requirements>

## Subtarefas

- [x] 1.1 Inicializar o projeto `nfce-extraction-service/` (`package.json`, `tsconfig.json`, dependencias de dev: `typescript`, `jest`, `jsdom`, `@types/jest`).
- [x] 1.2 Portar `isInvoiceReadyRJ` de `rj.js` para `src/extractor/readiness.ts`.
- [x] 1.3 Portar `getBlockMessageRJ` de `rj.js` para `src/extractor/block-detection.ts`.
- [x] 1.4 Portar `extractDataFromRJ` de `rj.js` para `src/extractor/extract.ts`, com o tipo `ExtractedInvoice` definido em `src/types.ts`.
- [x] 1.5 Coletar/gerar fixtures HTML (`test/fixtures/rj-success.html`, `rj-blocked.html`, `rj-loading.html`).
- [x] 1.6 Escrever testes unitarios com Jest + JSDOM cobrindo os 3 cenarios de fixture para cada uma das 3 funcoes.
- [x] 1.7 Rodar `tsc --noEmit` e a suite de testes, garantindo 100% de sucesso.

## Detalhes de Implementacao

Ver Tech Spec, secoes "Visao Geral dos Componentes" (`nfce-extraction-service`) e "Abordagem de Testes" > "Testes Unidade" (Node). Referencia de logica-fonte: `controlai-frontend/extract_data_scripts/rj.js` (arquivo listado em "Arquivos relevantes e dependentes" da Tech Spec).

## Criterios de Sucesso

- As 3 funcoes portadas produzem o mesmo resultado que `rj.js` para as fixtures de sucesso, bloqueio e carregamento.
- Nenhuma das funcoes depende de rede, Playwright ou timers reais — sao puras em relacao ao DOM de entrada.
- `ExtractedInvoice` cobre todos os campos exigidos pela Tech Spec para alimentar o endpoint Kotlin sem transformacao adicional.

## Testes da Tarefa

- [x] Testes de unidade (Jest + JSDOM) para `isInvoiceReadyRJ`, `getBlockMessageRJ` e `extractDataFromRJ`, cobrindo fixtures de sucesso, bloqueio e carregamento.
- [x] Testes de integracao: nao aplicavel nesta tarefa (sem HTTP/browser ainda).
- [x] Testes E2E: nao aplicavel nesta tarefa.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `nfce-extraction-service/src/extractor/readiness.ts` (novo)
- `nfce-extraction-service/src/extractor/block-detection.ts` (novo)
- `nfce-extraction-service/src/extractor/extract.ts` (novo)
- `nfce-extraction-service/src/types.ts` (novo)
- `nfce-extraction-service/test/extractor/*.test.ts` (novo)
- `nfce-extraction-service/test/fixtures/*.html` (novo)
- `controlai-frontend/extract_data_scripts/rj.js` (referencia, nao modificar nesta tarefa)

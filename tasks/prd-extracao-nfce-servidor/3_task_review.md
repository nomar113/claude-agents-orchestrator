# Review: Task 3.0 - API HTTP do microservico (POST /extract, GET /health)

**Revisor**: AI Code Reviewer
**Data**: 2026-08-27
**Arquivo da task**: 3_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

Contexto importante desta review: nesta sessão, as Tarefas 1.0 e 2.0 precisaram ser **inteiramente reconstruídas do zero**, porque o `nfce-extraction-service/` inteiro nunca havia sido commitado no git (confirmado via `git status` — todo o diretório aparece como `??`, não rastreado) e o código original sumiu do disco, apesar de `tasks.md` e das reviews antigas (`1_task_review.md`, `2_task_review.md`) indicarem as tarefas como concluídas. A reconstrução usou essas reviews antigas como especificação, incluindo o fix crítico já documentado nelas (tratar `Execution context was destroyed` durante `page.evaluate` como "ainda não pronto" em vez de rejeitar a Promise). Por isso esta review cobre o diretório inteiro (Tarefas 1.0, 2.0 e 3.0), não apenas os arquivos novos da Tarefa 3.0.

Rodei `npm install`, `npx playwright install chromium` (via `npx --yes playwright@1.47.0 install chromium`, contornando um bug no hook `rtk-rewrite.sh` do ambiente que engolia silenciosamente a saída/execução do comando reescrito — ver observação no final), `npm run typecheck` e `npm test` dentro de `nfce-extraction-service/`. Resultado: `tsc --noEmit` limpo e **28/28 testes passando** (7 suites), incluindo o teste que reproduz especificamente o cenário de reload durante o polling.

A API HTTP (`server.ts`, `middleware/internal-auth.ts`, `routes/extract.ts`, `routes/health.ts`) implementa corretamente os quatro requisitos centrais que eu vim checar com mais atenção:

1. **Fail-closed do middleware de auth**: `internal-auth.ts:11` — `if (!expectedKey || providedKey !== expectedKey)` — uma `X_INTERNAL_KEY` não configurada nunca é tratada como "sem autenticação exigida"; o comentário no código já documenta essa decisão explicitamente. Confirmado por teste.
2. **Validação de payload antes do Playwright**: `routes/extract.ts` chama `isValidBody(req.body)` e retorna `400` **antes** de qualquer chamada a `extractInvoice`; a ordem no código garante isso estruturalmente (não é só coincidência dos testes).
3. **Fidelidade da extração / autocontenção das funções de `page.evaluate`**: `readiness.ts`, `block-detection.ts` e `extract.ts` têm todas as constantes e helpers (`toNumber`, `DATE_FIELD_LENGTH`, `MAX_BLOCK_MESSAGE_LENGTH`, `BLOCK_KEYWORD_INDICATORS`) declarados **dentro** do corpo da função exportada, exatamenste como o bug real desta sessão exigiu corrigir. Nenhuma referência a escopo de módulo dentro das funções passadas a `page.evaluate`.
4. **Sobrevivência do polling a reloads de página**: `orchestrator.ts` envolve cada `page.evaluate` em `evaluateWhileStable`, que trata `Execution context was destroyed`/`Frame was detached`/`Target closed` como "ainda não pronto" e continua o polling até o deadline. Existe um teste dedicado (`orchestrator.test.ts:50-56`) contra uma fixture (`test/fixtures/server.ts`, rota `/reloading`) que redireciona a própria página duas vezes antes de servir o HTML de sucesso — exatamente o cenário que causou o bug crítico documentado em `2_task_review.md`. Rodei a suite isoladamente e ela passou de forma estável.

O único ponto que considero merecer atenção séria antes de seguir para a Tarefa 4.0 não é um bug no código da Tarefa 3.0, e sim um risco de repetir o próprio incidente que motivou esta reconstrução: **não existe `.gitignore` em `nfce-extraction-service/`, e o diretório inteiro (incluindo `node_modules/`, ~354 pacotes) está sem controle de versão.** Ver Problema Major #1.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `nfce-extraction-service/src/server.ts` | OK | 0 |
| `nfce-extraction-service/src/middleware/internal-auth.ts` | Problemas | 1 minor |
| `nfce-extraction-service/src/routes/extract.ts` | Problemas | 1 minor |
| `nfce-extraction-service/src/routes/health.ts` | OK | 0 |
| `nfce-extraction-service/src/types.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/readiness.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/block-detection.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/extract.ts` | Problemas | 1 minor |
| `nfce-extraction-service/src/extractor/orchestrator.ts` | OK | 0 |
| `nfce-extraction-service/src/browser/browser-manager.ts` | OK | 0 |
| `nfce-extraction-service/test/server/extract.test.ts` | OK | 0 |
| `nfce-extraction-service/test/server/health.test.ts` | OK | 0 |
| `nfce-extraction-service/test/extractor/*.test.ts` | OK | 0 |
| `nfce-extraction-service/test/browser/browser-manager.test.ts` | OK | 0 |
| `nfce-extraction-service/test/fixtures/server.ts` | OK | 0 |
| `nfce-extraction-service/README.md` | OK | 0 |
| `nfce-extraction-service/package.json` / `tsconfig.json` / `jest.config.js` | OK | 0 |
| `nfce-extraction-service/.gitignore` (ausente) | Problemas | 1 major |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado. O bug critico documentado em `2_task_review.md` (rejeicao da Promise em vez de resolver `TIMEOUT`/`READY` quando a pagina recarrega durante o `page.evaluate`) foi corretamente reproduzido como fix nesta reconstrucao e esta coberto por teste dedicado.

### Problemas Major

**1. Diretorio inteiro sem `.gitignore` e sem controle de versao, incluindo `node_modules/` (`nfce-extraction-service/`)**

```
$ git status --porcelain nfce-extraction-service/
?? nfce-extraction-service/
$ ls nfce-extraction-service/
node_modules/  (354 pacotes)  package-lock.json  package.json  ...
$ cat nfce-extraction-service/.gitignore
cat: No such file or directory
$ cat .gitignore   (raiz do repo)
.DS_Store
**/.progress/
```

Este e exatamente o tipo de situacao que causou o incidente que motivou esta review: o servico inteiro existe apenas em disco, nunca foi commitado, e nao ha `.gitignore` proprio nem no `nfce-extraction-service/` nem uma regra na raiz que exclua `node_modules/` deste subdiretorio. Se alguem rodar `git add .`/`git add -A` na raiz do repositorio (um padrao comum e ate sugerido genericamente em fluxos de commit), o commit resultante incluiria os ~354 pacotes de `node_modules/`, inflando o repositorio e comitando binarios/artefatos de terceiros (incluindo o binario do Chromium referenciado por metadados de pacotes Playwright). Pior: enquanto isso nao for corrigido, o proprio risco que gerou a reconstrucao completa desta sessao (codigo existindo so em disco, sem git) continua presente a cada nova sessao/maquina.

**Correcao sugerida**: criar `nfce-extraction-service/.gitignore` com pelo menos:
```
node_modules/
dist/
coverage/
*.log
```
e commitar o diretorio (codigo-fonte, testes, fixtures, `package-lock.json`, `README.md`) assim que possivel — idealmente ainda nesta sessao, antes de prosseguir para a Tarefa 4.0, para que o trabalho das Tarefas 1.0-3.0 nao corra o mesmo risco de desaparecer novamente.

### Problemas Minor

1. **`internal-auth.ts:9-11`** — a comparacao `providedKey !== expectedKey` e uma comparacao de string comum, nao de tempo constante. Para um segredo compartilhado interno protegido tambem por isolamento de rede (conforme a propria Tech Spec trata isso como "defesa em profundidade", nao a barreira primaria), o risco pratico de um ataque de timing e baixo, mas caberia usar `crypto.timingSafeEqual` com buffers de tamanho igual (`Buffer.alloc` para igualar tamanhos) se o time quiser fechar esse detalhe:
   ```ts
   import { timingSafeEqual } from 'crypto';

   function isValidKey(expected: string, provided: string): boolean {
     const expectedBuffer = Buffer.from(expected);
     const providedBuffer = Buffer.from(provided);
     return expectedBuffer.length === providedBuffer.length && timingSafeEqual(expectedBuffer, providedBuffer);
   }
   ```

2. **`server.ts`** — nao ha middleware de tratamento de erro para JSON malformado no corpo da requisicao. Hoje, se o `Content-Type` for `application/json` mas o corpo nao for JSON valido, `express.json()` lanca antes de chegar na rota, e o handler padrao do Express responde com uma pagina de erro (nao um JSON `{ error: ... }` como o resto da API). Nao e um requisito explicito da tarefa (nao esta nos criterios de sucesso nem nos cenarios de teste pedidos), mas quebra a consistencia do contrato de erro da API. Sugestao para a Tarefa 4.0 (que ja vai mexer em logging estruturado): adicionar um error-handling middleware que normalize qualquer erro de parsing para `{ error: string }` com `400`.

3. **`extract.ts` (extractor), `extractDataFromRJ`** — a funcao tem ~83 linhas (linhas 9-91), acima do limite de 50 linhas por metodo do checklist do projeto. Isso ja vinha da Tarefa 1.0 (nao foi introduzido nesta tarefa) e a review anterior nao levantou esse ponto: registrando aqui por completude, ja que esta review cobre o arquivo novamente. Nao e bloqueante — a funcao e uma sequencia linear de extracoes de campo sem lógica condicional complexa, e quebra-la em sub-funcoes exigiria voltar a referenciar helpers fora do escopo da funcao serializada por `page.evaluate` (o que a propria tarefa 1.0/2.0 identificou como problematico) ou duplicar os helpers dentro de cada sub-funcao. Nao vale a pena forcar a decomposicao apenas por causa da métrica de linhas.

## Destaques Positivos

- **Fix do bug critico da Tarefa 2.0 replicado corretamente**: `evaluateWhileStable`/`isPageReloadInterruption` em `orchestrator.ts` tratam exatamente as tres mensagens de erro (`Execution context was destroyed`, `Frame was detached`, `Target closed`) que a review anterior identificou como causa raiz, e ha um teste de integracao dedicado (`orchestrator.test.ts:50-56` + rota `/reloading` em `test/fixtures/server.ts`) que reproduz o cenario de reload real da SEFAZ documentado no comentario de `readiness.ts:1-3`.
- **Autocontencao correta das funcoes passadas a `page.evaluate`**: `isInvoiceReadyRJ`, `getBlockMessageRJ` e `extractDataFromRJ` usam sobrecargas (`function f(): R; function f(doc: Document): R; function f(doc: Document = document): R { ... }`) com todos os helpers/constantes declarados dentro do corpo — a recomendacao (nao-bloqueante) da review da Tarefa 2.0 de trocar os `as` casts por overloads foi implementada, e nenhum cast `as` aparece em `orchestrator.ts`.
- **Fail-closed do middleware de autenticacao** implementado e documentado com um comentario claro sobre a decisao (`internal-auth.ts:5-6`), coberto por dois testes (header ausente e header incorreto).
- **Ordem de validacao correta**: payload invalido nunca aciona `extractInvoice`, verificado estruturalmente pelo codigo (nao so pelos testes) — `isValidBody` e checado antes de qualquer chamada ao orquestrador.
- **Suite de testes completa e sem flakiness**: 28/28 testes, cobrindo os 4 estados (`READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR`) tanto no nivel do orquestrador quanto via `supertest` na API HTTP, mais autenticacao ausente/incorreta e payload invalido/nao-string — exatamente os cenarios pedidos na subtarefa 3.5.
- **README.md** documenta claramente todas as variaveis de ambiente (`X_INTERNAL_KEY`, `EXTRACTION_TIMEOUT_MS`, `PORT`, `HOST`), a decisao de bind (`0.0.0.0` + defesa em profundidade via header, com a responsabilidade de isolamento de rede explicitamente atribuida a Tarefa 4.0/infra) e os scripts disponiveis — atende a subtarefa 3.6.
- **Log leve por requisicao** em `routes/extract.ts` (status + duracao, sem logar a URL da nota ou dados pessoais), coerente com o escopo da tarefa (log estruturado completo com `pino` fica para a Tarefa 4.0).
- **`GET /health`** simples e correto, sem autenticacao, como pedido.
- Nenhum uso de `any` em todo o `src/`/`test/` (verificado via grep).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (uma observacao minor de tamanho de funcao, pre-existente da Tarefa 1.0) |
| TypeScript/Node.js | OK (`strict`, `noUnusedLocals`, `noUnusedParameters` habilitados; `tsc --noEmit` limpo; zero `any`) |
| REST/HTTP | OK (autenticacao fail-closed, validacao antes de efeitos colaterais, codigos de status corretos: 200/400/401) |
| Logging | OK para o escopo desta tarefa (log leve por requisicao; log estruturado completo e explicitamente Tarefa 4.0) |
| React | Nao aplicavel |
| Testes | OK (28/28 passando, cobrindo os cenarios pedidos pela tarefa, incluindo o caso de reload que causou o bug critico da Tarefa 2.0) |
| Controle de versao / hygiene de repositorio | **Problemas** — diretorio inteiro nao commitado, sem `.gitignore` (ver Major #1) |

## Recomendacoes

1. **(Urgente, nao bloqueia o codigo da Tarefa 3.0 em si, mas bloqueia seguir com seguranca)** Criar `nfce-extraction-service/.gitignore` (`node_modules/`, `dist/`, `coverage/`, `*.log`) e commitar todo o `nfce-extraction-service/` assim que possivel, para eliminar o risco de repetir o incidente que exigiu reconstruir as Tarefas 1.0/2.0 do zero nesta sessao.
2. (Opcional) Usar `crypto.timingSafeEqual` na comparacao de `X_INTERNAL_KEY` em `internal-auth.ts` para eliminar a diferenca de tempo residual, mesmo sendo defesa em profundidade atras de isolamento de rede.
3. (Opcional, pode entrar na Tarefa 4.0 junto com o logging estruturado) Adicionar um error-handling middleware em `server.ts` para normalizar erros de parsing de JSON malformado para o mesmo formato `{ error: string }` usado pelo resto da API.
4. (Registrado, nao bloqueante) `extractDataFromRJ` em `extract.ts` excede o limite de 50 linhas do checklist; aceitavel dado que decompo-la exigiria referenciar helpers fora do escopo serializado por `page.evaluate`, mas fica registrado para consciencia do time.

## Nota sobre o ambiente de execucao

Durante a verificacao desta review, `npx playwright install chromium` (e variantes como `rtk proxy npx playwright install chromium`) executaram com `exit 0` mas **sem baixar o Chromium** (`~/Library/Caches/ms-playwright/` ficou vazio) — o hook `rtk-rewrite.sh` do ambiente reescreve o comando para `rtk playwright install chromium`, que imprime `[RTK:PASSTHROUGH] playwright parser: All parsing tiers failed` e nao executa o download real. Contornei rodando `npx --yes playwright@1.47.0 install chromium` diretamente (mesma major version do `playwright` do `package.json`, `^1.47.0`), o que baixou o Chromium corretamente e permitiu rodar a suite completa. Isso e um problema do tooling do ambiente (RTK), nao do codigo revisado, mas vale reportar para quem mantém o hook `rtk-rewrite.sh`, ja que ele pode mascarar silenciosamente falhas de setup em outras sessoes/tarefas que dependam de `npx playwright install`.

## Veredito

Aprovado com observacoes. A Tarefa 3.0 entrega exatamente o que foi pedido — servidor HTTP minimo com `POST /extract` (autenticado, fail-closed, validado antes do Playwright) e `GET /health` (publico) — e a reconstrucao das Tarefas 1.0/2.0 nesta sessao replicou fielmente as correcoes ja documentadas nas reviews antigas, incluindo o fix do bug critico de reload durante `page.evaluate`, agora coberto por teste dedicado. `npm run typecheck` e `npm test` rodam limpos (28/28). O unico ponto que trato com peso de "major" nesta review nao e um bug de codigo, e sim um risco de processo direto: o `nfce-extraction-service/` inteiro continua sem `.gitignore` e sem estar versionado no git, a mesma condicao que levou ao desaparecimento do codigo original e a reconstrucao completa desta sessao. Recomendo fortemente resolver isso (criar o `.gitignore` e commitar) antes de avancar para a Tarefa 4.0, para que o trabalho ja feito nao fique exposto ao mesmo risco novamente.

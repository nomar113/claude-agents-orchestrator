# Review: Task 8 - Fila BullMQ, Worker de Disparo e Bootstrap

**Revisor**: AI Code Reviewer
**Data**: 2026-06-25 (segunda rodada)
**Arquivo da task**: 8_task.md
**Status**: APROVADO COM RESSALVAS

## Resumo

Nesta segunda passada, todos os cinco bloqueantes da rodada anterior foram corrigidos com qualidade. O wiring real foi extraido para `apps/api/src/scheduling/scheduling.runtime.ts` (`createSchedulingRuntime`) e e instanciado em `apps/api/src/index.ts`, com `bootstrap.run()` disparado apos `app.listen()` e shutdown limpo via `SIGTERM`/`SIGINT` fechando worker, queue e Prisma. O tratamento de `SessionError` foi separado em `deferForSessionRecovery()`: `onetime` agora reagenda em 60s sem avancar `occurrenceCount`/`nextRunAt` (preservando o disparo); recorrentes mantem o avanco para a proxima janela; a perda de sessao mid-stream agora distingue `successfulSends === 0` (defer) de `>=1` (avanca normal). `triggerConfig` invalido no bootstrap marca o schedule como `expired` e zera `nextRunAt`, com contador `invalidConfig` no summary. O update no-op de `nextRunAt` quando dentro da tolerancia foi removido. O integration test foi reescrito como `describe.skipIf(!process.env.REDIS_URL_TEST)` exercitando BullMQ real ponta-a-ponta (cria schedule, espera evento `completed`, verifica `ExecutionLog.status='sent'` e `Schedule.status='expired'`) com header documentando porque `ioredis-mock` nao serve.

Refatoracoes paralelas tambem melhoraram a base: `schedule.parsing.ts` centraliza `parseTriggerConfig`/`parseContactVars`/`contactRowToDto` (DRY entre worker e bootstrap), `dispatchToRecipients()` virou metodo proprio, o cast `as [string, ...string[]]` foi eliminado em favor de `for ... of mediaPaths` com indice rotulado, `enqueueScheduleJob` ganhou parametro `now` para testes deterministicos, e a variavel ociosa `pastRunAt` desapareceu. Cobertura cresceu com dois testes adicionais (`onetime` + `SessionError` reagendando; bootstrap com `triggerConfig` invalido).

Checks finais (executados nesta revisao): `npm run typecheck` OK, `npm run lint` "No issues found", `npm test` 191 passed + 1 skipped (149/1 api, 23 web, 19 shared-types), `npm run build` OK. As ressalvas remanescentes sao todas minor e nao bloqueiam a entrega.

## Arquivos Revisados (nesta rodada)

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| apps/api/src/index.ts | OK | 0 |
| apps/api/src/scheduling/scheduling.runtime.ts | OK | 0 |
| apps/api/src/scheduling/scheduler.worker.ts | OK | 1 minor |
| apps/api/src/scheduling/scheduler.bootstrap.ts | OK | 1 minor |
| apps/api/src/scheduling/schedule.parsing.ts | OK | 0 |
| apps/api/src/scheduling/enqueue.ts | OK | 0 |
| apps/api/src/queue/bullmq.ts | OK | 0 |
| apps/api/src/config/env.ts | OK | 0 |
| apps/api/test/scheduler.worker.test.ts | OK | 0 |
| apps/api/test/scheduler.bootstrap.test.ts | OK | 0 |
| apps/api/test/scheduler.integration.test.ts | OK | 0 |

## Validacao dos Bloqueantes da Rodada Anterior

### Bloqueante 1 (CRITICO) — Wiring real no boot: RESOLVIDO

`apps/api/src/index.ts:6,20-27,31-36,38-47` instancia `createSchedulingRuntime({ prisma, whatsapp, logger, redisConnection: { url: config.redisUrl }, queueName: config.scheduleQueueName, toleranceMin: config.bootToleranceMin })` antes de `app.listen()` e chama `scheduling.bootstrap.run()` no callback do `listen`, com `.catch(...)` que loga falha sem matar o processo (boa pratica — o boot do scheduler nao deve derrubar a API se Redis estiver temporariamente indisponivel). O `shutdown` registrado em SIGTERM/SIGINT chama `server.close()`, depois `scheduling.shutdown()` (que fecha `bullWorker` e `queue`, ignorando erros), depois `prisma.$disconnect()`. Esse fluxo cumpre o requirement 6 da tarefa e habilita os 4 criterios de sucesso em runtime real.

Pequeno detalhe positivo: a fabrica `createSchedulingRuntime` em `scheduling.runtime.ts` deixa `autorunWorker` e `workerConcurrency` opcionais com defaults (`true`, `1`) e expoe a `SchedulingRuntime` completa, o que facilita testes futuros que queiram instanciar o runtime com `autorunWorker: false` para drenar a queue manualmente.

### Bloqueante 2 (MAJOR) — SessionError descartando onetime: RESOLVIDO

`apps/api/src/scheduling/scheduler.worker.ts:73-76,135-162` extrai `deferForSessionRecovery(schedule, trigger, settings)`. Para `trigger.type === 'onetime'`, calcula `retryAt = now + 60s` e chama `enqueueScheduleJob` sem tocar em `occurrenceCount`/`nextRunAt`/`status` — o teste novo (`scheduler.worker.test.ts:239-262`) prova: `updated?.status === 'active'`, `updated?.occurrenceCount === 0`, `queue.recorded[0].opts.delay > 0`. Para recorrentes (`fixed`/`solar`/`birthday`), chama `advanceSchedule` (comportamento documentado: pula a ocorrencia perdida, deixa proxima janela tentar). Mid-stream tambem trata: `dispatchToRecipients()` retorna `{ sessionLost, successfulSends }`; o `process()` so chama `deferForSessionRecovery` quando `sessionLost && successfulSends === 0` (linha 89-92), respeitando logs ja gravados. O teste existente (`scheduler.worker.test.ts:281-314`) valida o caminho mid-stream com 1 sucesso + sessao caindo: confirma 1 log, 1 job reenfileirado (via advance, nao defer) e nenhum log adicional.

O design escolhido (reagendamento manual via porta `ScheduleQueuePort`, em vez de lancar excecao para o BullMQ retry) preserva o requirement "nao consome tentativas" sem depender da semantica de `attempts` do BullMQ — escolha defensavel e mais previsivel em monoinstancia pessoal.

### Bloqueante 3 (MAJOR) — TriggerConfig invalido virando zumbi: RESOLVIDO

`apps/api/src/scheduling/scheduler.bootstrap.ts:72-80,172-182` agora trata `parseTrigger()` retornando `null` como gatilho para marcar o schedule como `status='expired'` com `nextRunAt=null` e incrementar `summary.invalidConfig`. O `BootstrapSummary` ganhou esse campo para observabilidade operacional. O teste novo (`scheduler.bootstrap.test.ts:152-171`) insere `triggerConfig: 'json-quebrado-aqui'` direto via Prisma e valida `summary.invalidConfig === 1`, `updated.status === 'expired'`, `updated.nextRunAt === null` e `queue.recorded.length === 0`.

### Bloqueante 4 (MAJOR) — Integration test real ausente: RESOLVIDO

`apps/api/test/scheduler.integration.test.ts` foi reescrito com:
- Header explicativo (linhas 1-13) documentando o motivo do `ioredis-mock` nao servir (Lua VM fengari nao expoe `cmsgpack`).
- `describe.skipIf(!REDIS_URL)` (linha 36) — skipa silenciosamente quando `REDIS_URL_TEST` nao esta exportado (e o que acontece em CI/local hoje, confirmando o "1 skipped" no output do `npm test`).
- Quando ativo, exercita o protocolo BullMQ <-> Redis ponta-a-ponta: cria schedule `onetime` daqui a 500ms, instancia `SchedulerWorker` real + `bullWorker` real, chama `enqueueScheduleJob`, escuta o evento `completed` (com timeout de 8s) e valida `ExecutionLog.status='sent'`, `fake.sentMessages.length === 1`, `text === 'Oi Irene'` e `Schedule.status === 'expired'` no final.
- `QUEUE_NAME` unico por execucao (`schedules-test-${Date.now()}`) e `queue.obliterate({ force: true })` antes/depois evitam cross-test pollution em runs sucessivos contra o mesmo Redis.

Trade-off aceitavel: para CI sem Docker, o smoke test apenas skipa em vez de falhar. Recomenda-se documentar em README/CI que para validar a integracao Redis e necessario `docker compose up redis -d && REDIS_URL_TEST=redis://127.0.0.1:6379 npm test --workspace=@app/api`.

### Bloqueante 5 (MINOR/PERF) — Update no-op em bootstrap: RESOLVIDO

`apps/api/src/scheduling/scheduler.bootstrap.ts:86-98` agora, no caminho `isPast && within`, chama apenas `enqueueScheduleJob(...)` + log + `continue`, sem a write Prisma redundante. O `nextRunAt` so e atualizado nos caminhos onde realmente muda (linhas 134-137: futuro recalculado).

## Validacao dos Criterios de Sucesso da Tarefa

| Criterio | Status | Evidencia |
|---------|--------|-----------|
| `onetime` daqui a 2s + driver fake + Redis efemero dispara e grava `ExecutionLog status='sent'` | OK (com Redis) | `scheduler.integration.test.ts:73-127` valida exatamente esse fluxo (com runAt=500ms) quando `REDIS_URL_TEST` setado |
| `fixed` (`*/1 * * * *`) gera multiplas execucoes consecutivas com re-enfileiramento | OK | `scheduler.worker.test.ts:118-147` valida envio + re-enfileiramento; `enqueueScheduleJob` no `advanceSchedule` (linha 292-296 do worker) e o mecanismo; integration test cobre o ponta-a-ponta com BullMQ real |
| Boot com `nextRunAt` 5min no passado dispara imediatamente | OK | `scheduler.bootstrap.test.ts:91-103` valida `enqueuedImmediate=1` e `opts.delay=0` |
| `nextRunAt` 60min no passado + tolerancia 30 nao dispara mas recalcula | OK | `scheduler.bootstrap.test.ts:105-122` valida `skippedOutOfTolerance=1`, `enqueuedFuture=1`, `nextRunAt > now` |

## Problemas Encontrados (nesta rodada)

### Problemas Criticos

Nenhum.

### Problemas Major

Nenhum.

### Problemas Minor

**M1. `SchedulerBootstrap.run()` continua acima do limite de 50 linhas**
**Arquivo**: `apps/api/src/scheduling/scheduler.bootstrap.ts:56-144`
**Descricao**: O metodo tem 88 linhas (limite do projeto = 50, conforme `code-standards.md:17`). A logica esta legivel — cada branch (`invalidConfig`, `isPast && within`, `expired`, `isPast && !within`, futuro) tem propositos distintos — mas o tamanho excede o padrao. Recomendacao da rodada anterior (extrair `processOne(schedule)`) foi parcialmente endereçada apenas no worker (`process()` agora tem 37 linhas, OK).
**Correcao sugerida**: extrair `processOne(schedule, settings, now, summary)` retornando `void` e mover toda a logica do corpo do `for` para esse metodo. O `run()` ficaria com setup + loop simples + log final (sub-25 linhas).

**M2. Linhas em branco dentro de metodos**
**Arquivo**: `apps/api/src/scheduling/scheduler.worker.ts:64,68,76,82,88,92` e `apps/api/src/scheduling/scheduler.bootstrap.ts:70,80,85,98,109,119,132,140`
**Descricao**: O padrao `code-standards.md:19` diz "No blank lines within methods/functions". Os metodos `process()` (worker) e `run()` (bootstrap) usam blanks como separador visual entre etapas. Como ja apontado na rodada anterior, e uma escolha estetica defensavel mas tecnicamente fora do padrao. Nao bloqueia, mas vale alinhar com o time se manter ou relaxar a regra.

## Destaques Positivos

- **`createSchedulingRuntime` como factory dedicada**: a extracao para `scheduling.runtime.ts` torna o `index.ts` declarativo (composicao) e habilita reuso em testes/scripts. Excelente padrao para evitar logica de wiring espalhada no entrypoint.
- **Shutdown ordenado em SIGTERM/SIGINT**: `server.close() → bullWorker.close() → queue.close() → prisma.$disconnect()` na ordem certa, com `.catch(() => undefined)` para nao falhar shutdown por erro acessorio. Essencial para evitar jobs orfaos no Redis em prod monoinstancia.
- **`bootstrap.run().catch(...)`** nao mata o processo se o boot inicial falhar — boa pratica para tolerar Redis indisponivel temporariamente sem derrubar a API HTTP.
- **`deferForSessionRecovery` modela explicitamente a politica de retry por sessao**: o metodo separa claramente o caso `onetime` (preservar) do recorrente (avancar), com nome auto-explicativo. Comportamento documentado em comentario JSDoc nas linhas 129-134 do worker.
- **`schedule.parsing.ts` elimina duplicacao**: o helper unico (`parseTriggerConfig` que joga `TriggerConfigParseError`) e consumido tanto pelo worker (que deixa a excecao subir como erro nao-tratavel) quanto pelo bootstrap (que captura e marca expired). Boa separacao de responsabilidades.
- **`successfulSends` discriminando defer vs advance mid-stream**: o codigo agora distingue "sessao caiu e nada foi enviado" (defer/retry) de "sessao caiu apos enviar alguns" (avanca e nao re-tenta os ja entregues). Evita duplicacao de envio em recipientes ja processados.
- **`buildJobId` deterministico (`schedule:{id}:{ms}`)** combinado com BullMQ idempotency garante que o bootstrap reagendando um missed job nao cria duplicatas se ja existir no Redis.
- **Integration test bem documentado e auto-skipped**: o header explicativo elimina a duvida futura "por que isso esta skipped?" e o `obliterate({ force: true })` garante limpeza para runs concorrentes.
- **Cobertura cresceu nos pontos certos**: o novo teste do worker (`onetime + SessionError sem expirar`) e o novo teste do bootstrap (`triggerConfig invalido vira expired`) bloqueiam regressao exatamente nos bloqueantes corrigidos.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas menores (run() > 50 linhas, blanks internos) |
| TypeScript/Node.js | OK |
| REST/HTTP | N/A |
| Logging | OK (pino estruturado, niveis adequados, summary do bootstrap logado) |
| React | N/A |
| Testes | OK (190+ passing, integration test guarded por env, 0 cast unsafe em testes nesta rodada) |

## Verificacoes Executadas

- `npm run typecheck` — OK
- `npm run lint` — "No issues found"
- `npm test` — 191 passed + 1 skipped (api: 149+1 skipped; web: 23; shared-types: 19)
- `npm run build` — OK (api dist + next build 8 paginas)

## Recomendacoes (nao-bloqueantes)

1. Extrair `processOne(schedule, settings, now, summary)` em `SchedulerBootstrap` para baixar `run()` de 88 para ~20 linhas, alinhando com o limite de 50 linhas/metodo.
2. Decidir com o time: manter blank lines como separador visual e atualizar `code-standards.md`, ou removelas em `process()` e `run()`. Recomendo a primeira opcao — os blanks aumentam legibilidade em metodos com mais de uma etapa logica.
3. Documentar no README do `apps/api` (ou no `package.json` script) como rodar o integration test contra Redis local: `docker compose up redis -d && REDIS_URL_TEST=redis://127.0.0.1:6379 npm test`.
4. (Futuro) Considerar metricas Prometheus para o scheduling: `scheduler_session_defers_total`, `scheduler_invalid_config_total`, `scheduler_missed_in_tolerance_total`. Ja existe `apps/api/src/observability/metrics.ts` (mencionado na techspec) — esses counters fechariam o loop de observabilidade do bootstrap.

## Veredito

**APROVADO COM RESSALVAS**. Os 5 bloqueantes da rodada anterior foram resolvidos com qualidade: o wiring de boot esta completo e seguro (com shutdown ordenado), `SessionError` em `onetime` agora preserva o disparo via defer de 60s, `triggerConfig` invalido vira `expired` (sem zumbi), o update no-op foi removido e o integration test com BullMQ real existe (guarded por `REDIS_URL_TEST`). Refatoracoes adicionais (extracao de `schedule.parsing.ts`, `dispatchToRecipients`, eliminacao de cast unsafe, parametro `now` em `enqueueScheduleJob`) melhoram a base. Todos os 4 criterios de sucesso da tarefa sao agora exercitaveis em runtime real e cobertos por testes. As ressalvas remanescentes (`SchedulerBootstrap.run()` com 88 linhas; blank lines internos em dois metodos) sao desvios estilisticos de baixo impacto que podem ir para follow-up sem bloquear a entrega da Task 8.0.

---

## Historico

### Rodada 1 (mesma data): MUDANCAS SOLICITADAS

Bloqueantes apontados e resolvidos nesta rodada:
1. (CRITICO) `SchedulerBootstrap`/Queue/Worker nao wirados no boot da API → resolvido via `scheduling.runtime.ts` + `index.ts`.
2. (MAJOR) `SessionError` descartando `onetime` silenciosamente → resolvido via `deferForSessionRecovery` com retry de 60s.
3. (MAJOR) `triggerConfig` invalido virando schedule zumbi → resolvido marcando como `expired` + contador `invalidConfig`.
4. (MAJOR) Falta de integration test real com Redis → resolvido com test guarded por `REDIS_URL_TEST` + header explicativo.
5. (MINOR) Update Prisma no-op em `isPast && within` → removido.

Os problemas minor remanescentes daquela rodada foram majoritariamente endereçados (DRY de `parseTrigger`, cast `as [string, ...string[]]` removido, `pastRunAt` ocioso limpo, `enqueueScheduleJob` com parametro `now`). Restam apenas duas ressalvas estilisticas (M1 e M2 acima).

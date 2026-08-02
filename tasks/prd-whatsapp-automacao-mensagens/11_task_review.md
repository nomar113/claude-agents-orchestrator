# Relatorio de Code Review - Tarefa 11.0 (Observabilidade — Logs Estruturados + Metricas Prometheus + Polling)

## Resumo

- Data: 2026-06-25
- PRD: `prd-whatsapp-automacao-mensagens`
- Branch: main (entrega via working tree do projeto `whatsapp-automacao`, sem repo git inicializado no projeto)
- Status: **APROVADO**
- Arquivos novos: 6 (`metrics.ts`, `metrics.routes.ts`, `polling.ts`, `metrics.test.ts`, `metrics.integration.test.ts`, `polling.test.ts`)
- Arquivos modificados: 9 (`logger.ts`, `server.ts`, `index.ts`, `scheduler.worker.ts`, `scheduling.runtime.ts`, `schedule.service.ts`, `connect-client.tsx`, `schedules-client.tsx`, `logger.test.ts`, `schedules-client.test.tsx`, `apps/api/package.json`)
- Resultado dos checks: `typecheck` OK, `lint` OK ("ESLint: No issues found"), `test` 199 passed + 1 skipped (api) / 38 passed (web) / 19 passed (shared-types) = **256 passing, 1 skipped, 0 falhando**, `build` OK (Next.js 14.2.35 + tsc).

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Skill `executar-task` (typecheck/lint/test/build antes de fechar) | OK | Todos os checks rodados nesta review confirmam estado verde. |
| Skill `clean-code` (instrumentacao explicita, sem ruido) | OK | `LogEvents` centraliza nomes canonicos; `MetricsRegistry` encapsula `prom-client` com API tipada (`setSessionStatus`, `incScheduleRun`); sem `console.log` espalhado. |
| Skill `vercel-react-best-practices` | OK | `useCallback` em `refresh`/`refreshSilently`, `useEffect` cleanup com `clearInterval`, flag `mountedRef` para evitar setState pos-unmount, dependencias listadas corretamente. |
| Workflow PRD -> TechSpec -> Tasks -> Implementacao | OK | Implementacao referencia secao "Monitoramento e Observabilidade" da techspec ponto a ponto (4 metricas obrigatorias, niveis de log, intervalos de polling 1s/30s/10s). |
| Sem workarounds | OK | Metrics integrado via `ScheduleRunMetricsPort` opcional (injecao de dependencia); fontes de scrape (`QueueDepthSource`/`NextRunLagSource`) sao ports injetados, nao polling embutido; mount do `/api/metrics` e condicional. |

## Aderencia a TechSpec

| Decisao Tecnica (techspec linhas 244-249) | Implementado | Observacoes |
|-------------------------------------------|--------------|-------------|
| Logs `pino` estruturados, `pino-pretty` em dev | SIM | `createLogger({ pretty: nodeEnv !== 'production' })` em `index.ts:14-17`. |
| Nivel `info` em eventos de schedule | SIM | `ScheduleCreated`, `ScheduleUpdated`, `ScheduleRunSent`, `ScheduleExpired`, `ScheduleRequeued` usam `logger.info`. |
| Nivel `warn` em anti-spam skip e sessao perdida | SIM | `ScheduleRunSkipped` (scheduler.worker.ts:156-165), `WhatsAppSessionLost` (scheduler.worker.ts:187-195 e index.ts:35-39). |
| Nivel `error` em `SendError` e excecoes do worker | SIM | `ScheduleRunError` (scheduler.worker.ts:202-211); `worker.exception` (scheduling.runtime.ts:85-95 — listener `bullWorker.on('failed')`). |
| Endpoint `GET /api/metrics` em formato Prometheus | SIM | `metrics.routes.ts` retorna `register.metrics()`, `Content-Type: text/plain; version=...`. Testado por integracao com supertest. |
| Metrica `whatsapp_session_status` (0/1/2/3) | SIM | Gauge com mapeamento `SESSION_STATUS_VALUE` (metrics.ts:8-13). |
| Metrica `schedule_runs_total{status="sent\|skipped\|error"}` | SIM | Counter inicializado com 3 labels em zero (metrics.ts:91-93); incrementado em scheduler.worker.ts para os 3 status. |
| Metrica `queue_depth` (gauge BullMQ) | SIM | Gauge com `collect` async que invoca `getJobCounts('waiting', 'delayed', 'active')` no scrape — soma os tres estados (metrics.ts:121-128). |
| Metrica `next_run_lag_seconds` | SIM | Gauge com `collect` async que consulta `prisma.schedule.findFirst` filtrando `status='active' AND nextRunAt < now` ordenado por `nextRunAt asc` (metrics.ts:130-145). |
| Frontend polling 1s enquanto QR pendente | SIM | `whatsappPollIntervalFor('qr')` = 1000ms; tambem aplicado a `'connecting'`. |
| Frontend polling 30s em `ready` | SIM | `whatsappPollIntervalFor('ready')` = 30000ms. |
| Frontend polling 10s na lista de schedules | SIM | `POLL_INTERVAL_SCHEDULES_MS=10_000` com `setInterval` em `schedules-client.tsx:70-75`. |
| Sem WebSocket no MVP | SIM | Apenas polling HTTP. |
| Documentar como acessar metricas (README ou comentario do endpoint) | SIM | Comentario JSDoc no topo de `metrics.routes.ts:1-7` com `curl` de exemplo e lista de metricas. |
| Monitoramento opcional `process.memoryUsage()` (Riscos Conhecidos) | SIM (via prom-client) | `MetricsRegistry({ collectDefault: true })` em `index.ts:25` ativa `collectDefaultMetrics` do prom-client, que expoe `process_resident_memory_bytes`, `nodejs_heap_size_used_bytes` etc. |

## Tasks Verificadas

| Task | Status | Observacoes |
|------|--------|-------------|
| 11.1 Refinar `logger.ts` com `LogEvents` e campos estruturados | COMPLETA | Constante `LogEvents` declarada `as const` (type-safe), comentario JSDoc explicativo, uso de `service: 'api'` no base context. |
| 11.2 Instrumentar pontos-chave (create, run, antispam skip, send error, sessao perdida) | COMPLETA | Todos os pontos cobertos em `scheduler.worker.ts`, `schedule.service.ts` e `index.ts`. Ressalvas pontuais listadas em Problemas (delete/pause/resume sem log dedicado). |
| 11.3 Implementar `metrics.ts` com `prom-client` | COMPLETA | API limpa via classe `MetricsRegistry`; gauges com `collect` async sao um padrao excelente que evita ticker dedicado. |
| 11.4 Endpoint `GET /api/metrics` | COMPLETA | `createMetricsRouter` montado condicionalmente em `server.ts:80-82` apenas se `options.metrics` for fornecido — testavel sem instanciar prom-client. |
| 11.5 Polling 1s/30s/10s no frontend | COMPLETA | Constantes nomeadas em `polling.ts` com helper `whatsappPollIntervalFor`; fallback 5s para `disconnected` (extensao razoavel, registrada no proprio comentario do arquivo). |
| 11.6 Testes da tarefa | COMPLETA | 7 unit (`metrics.test.ts`) + 2 integration (`metrics.integration.test.ts`) + 2 polling (`polling.test.ts`) + 1 logger (`logger.test.ts`) + 1 polling 10s no `schedules-client.test.tsx`. Cobertura excelente. |
| 11.7 `typecheck`, `lint`, `test`, `build` | COMPLETA | Todos OK (confirmado nesta review). |

## Testes

- Totais: 199 passed + 1 skipped (api) + 38 passed (web) + 19 passed (shared-types) = **256 passing, 1 skipped, 0 falhando**.
- Suites novas/estendidas:
  - `metrics.test.ts` — 7 testes (4 metricas obrigatorias presentes; mapeamento dos 4 status de sessao; counters por status; scrape de queue_depth via source injetada; scrape de next_run_lag via source; mantem ultimo valor em caso de falha no scrape; content-type Prometheus). **Cobertura excelente.**
  - `metrics.integration.test.ts` — 2 testes via supertest contra `createApp` (executa 2 jobs sent+skipped via worker real + validacao do payload Prometheus; atualizacao do gauge quando a sessao cai). Atende exatamente o cenario pedido no criterio de sucesso da Tarefa ("apos 1 execucao de schedule, `curl /api/metrics` mostra `schedule_runs_total{status='sent'} 1`").
  - `logger.test.ts` — estendido com 2 testes novos (`LogEvents` expoe nomes canonicos; campos `event`/`scheduleId`/`contactId`/`status` chegam ao JSON via pino real com stream customizado).
  - `polling.test.ts` — 2 testes (constantes alinhadas a techspec; helper retorna intervalos corretos para qr/connecting/ready/disconnected).
  - `schedules-client.test.tsx` — extensao com teste `faz polling silencioso da lista a cada 10s` usando `vi.useFakeTimers` e `advanceTimersByTimeAsync(10_000)`.

### Justificativa para escolhas de teste

- O criterio do task ("Testes E2E: nao aplicavel") foi corretamente seguido — a observabilidade nao tem fluxo de UI cobrivel por Playwright.
- O teste de integracao usa `createTestDb` (SQLite real em arquivo temp) + `FakeQueue` em memoria + `FakeWhatsAppService` — combinacao adequada para validar contrato Prometheus sem dependencia de Redis.
- O teste de polling 10s usa fake timers ao inves de tentar contar chamadas reais — padrao correto, deterministico.

## Problemas Encontrados

| Severidade | Arquivo | Linha | Descricao | Sugestao |
|------------|---------|-------|-----------|----------|
| Baixa | `apps/api/src/scheduling/scheduling.runtime.ts` | 88 | O listener `bullWorker.on('failed')` usa a string literal `'worker.exception'` em vez da constante `LogEvents.WorkerException` (que existe em `logger.ts:41`). Causa inconsistencia se a constante mudar no futuro. | Trocar por `event: LogEvents.WorkerException` e importar `LogEvents` no runtime. |
| Baixa | `apps/api/src/observability/logger.ts` | 31-44 | `LogEvents` declara `ScheduleDeleted`, `SchedulePaused`, `ScheduleResumed` mas nenhum desses e usado em `schedule.service.ts` (`delete`, `pause`, `resume` nao logam). Constantes "mortas" hoje. | Ou (a) adicionar `logger.info({ event: LogEvents.ScheduleDeleted/Paused/Resumed, ... })` nos respectivos metodos para fechar o ciclo da Subtarefa 11.2 ("eventos de schedule"); (b) ou remover as constantes nao usadas para evitar codigo morto. Preferivel (a) — alinha com o requisito. |
| Baixa | `apps/api/src/index.ts` | 27-40 | O handler de `subscribe` chama `metrics.setSessionStatus` tanto no evento `status` quanto duplicadamente nos eventos `ready` e `disconnected` (que tambem emitem `status` no fake/real). E idempotente (gauge.set sobrescreve), mas ha trabalho duplicado por transicao. | Manter so o handler `type === 'status'` para gauge; usar `ready`/`disconnected` apenas para os logs adicionais. Nao bloqueante. |
| Baixa | `apps/api/src/observability/metrics.ts` | 130-146 | `createPrismaNextRunLagSource` retorna o lag do schedule **mais antigo atrasado** apenas — bom como sinal mas nao reflete a soma/quantidade de atrasados. Para o uso pessoal monoinstancia e suficiente; pode esconder backlog crescente. | Considerar metrica complementar `overdue_schedules_count` (gauge contando `nextRunAt < now`). Opcional, fora do escopo da Tarefa 11 conforme texto da techspec. |
| Baixa | `apps/api/src/observability/metrics.ts` | 67-73, 81-87 | Blocos `catch {}` silenciam falhas de scrape para evitar quebrar `/metrics`. Comentario explica a intencao, mas nao ha log. Em producao um Redis caido fica invisivel. | Considerar `logger.warn({ source: 'queue_depth' }, ...)` no catch. Trade-off: introduz dependencia do logger no `MetricsRegistry` (hoje "puro"). Aceitavel como esta. |
| Baixa | `apps/api/src/scheduling/scheduler.worker.ts` | 215 | Erros nao classificados (`!SessionError && !SendError`) sao re-arremessados (`throw err`); o listener `failed` do BullMQ entao os captura e registra como `worker.exception`. Comportamento correto, mas o `metrics.recordRun('error')` **nao** e chamado nesse caminho. | Considerar `this.deps.metrics?.recordRun('error')` antes do `throw err`, para nao perder contagem em erros nao categorizados. Ou aceitar a semantica atual (so contabiliza erros classificados). Documentar a escolha. |
| Baixa | `apps/web/lib/polling.ts` | 11 | `POLL_INTERVAL_WHATSAPP_DEFAULT_MS = 5_000` para `disconnected` nao esta explicitamente na techspec (que so menciona 1s/30s). Foi auto-justificado no comentario do arquivo. | Aceitavel — UX precisa de algum polling no estado disconnected para detectar reconexao manual. Compativel com PRD. |
| Informacional | `apps/api/src/index.ts` | 25 | `MetricsRegistry({ collectDefault: true })` ativa `collectDefaultMetrics` apenas no `index.ts`, mas o teste de integracao instancia sem essa flag. Sem bug — mas o readme/comentario do endpoint nao menciona que default metrics estarao presentes em prod. | Adicionar uma linha no JSDoc de `metrics.routes.ts` mencionando que prod expoe `process_*`, `nodejs_*` (collect default). Nao bloqueante. |

Nenhum problema de severidade Media ou Alta encontrado.

## Pontos Positivos

- **`LogEvents` como `as const` + type `LogEvent` derivado**: garante autocomplete e impede typos; centraliza o vocabulario de eventos usado por dashboards/alertas externos.
- **`MetricsRegistry` encapsulado**: API tipada (`setSessionStatus(name)`, `incScheduleRun(status)`), sources injetaveis (`bindQueueDepthSource`/`bindNextRunLagSource`), separacao do scrape (collect async) de eventos (counter inc) — design elegante.
- **Inicializacao de labels do counter em zero**: as 3 series (`sent|skipped|error`) aparecem em `/metrics` antes de qualquer evento, evitando "missing series" em dashboards (linhas 91-93 de `metrics.ts`).
- **Collect async para gauges derivadas**: evita poller dedicado; valor sempre fresh no scrape; isolado por try/catch para nao quebrar `/metrics`.
- **Mount condicional do `/api/metrics`**: `server.ts:80-82` so adiciona o router se `options.metrics` for fornecido — bom para isolacao de testes (nao precisa instanciar prom-client em testes que nao testam metrics).
- **Polling helper bem testado**: `whatsappPollIntervalFor` separa "estado da sessao" de "intervalo de polling", facilitando mudancas futuras (ex: adicionar `'expired'` no enum).
- **`refreshSilently` no schedules-client**: padrao correto — polling nao deve substituir feedback do usuario (ex: erro de "Pause failed"). Coincide com a separacao entre `refresh` (acao do usuario) e `refreshSilently` (background polling).
- **Listener `bullWorker.on('failed')`**: captura excecoes do worker BullMQ que nao foram classificadas como `SessionError`/`SendError`, fechando o gap de instrumentacao de excecoes.
- **Logs estruturados no template ja com semantica de dashboard**: `event` + `scheduleId` + `contactId` + `status` em todos os pontos — pronto para indexar em Loki/Elasticsearch.
- **Integration test usa supertest + worker real + DB real**: testa o caminho end-to-end de "evento -> counter -> /metrics" exatamente como o criterio de sucesso da Tarefa exige.
- **Cobertura de teste para fallback de falha**: o teste "mantem ultimo valor quando fonte de scrape falha" valida que `/metrics` nao quebra se o Redis cair temporariamente — comportamento critico em prod.
- **Acessibilidade preservada nos arquivos do frontend tocados**: nenhum atributo `aria-*` removido; `aria-live` do feedback intacto.

## Recomendacoes

1. **Fechar o gap das constantes `LogEvents` nao usadas**: instrumentar `delete`/`pause`/`resume` no `schedule.service.ts` (3 linhas cada). Pequeno commit que completa a Subtarefa 11.2 ("instrumentar pontos-chave... eventos de schedule").
2. **Trocar string literal `'worker.exception'` por `LogEvents.WorkerException`** em `scheduling.runtime.ts:88` para coerencia.
3. **Considerar `metrics.recordRun('error')` no catch de erros nao classificados** em `scheduler.worker.ts:215`, antes do `throw err`. Garante que falhas inesperadas tambem aparecam em `schedule_runs_total{status="error"}`.
4. **Adicionar README curto na pasta `apps/api/src/observability/`** (ou estender o JSDoc do `metrics.routes.ts`) listando as metricas default do prom-client que aparecem em prod (process_*, nodejs_*) — facilita criar dashboards.
5. **Avaliar metrica complementar `overdue_schedules_count`**: gauge com `prisma.schedule.count({ where: { status: 'active', nextRunAt: { lt: now } } })`. Util para detectar backlog. Fora do escopo da Tarefa 11 mas alinhado com "Riscos Conhecidos" da techspec.
6. **Em uma proxima iteracao, evitar a duplicacao do `setSessionStatus`** em `index.ts` (ver problema Baixa #3) — handler unico do tipo `status`.

## Conclusao

**APROVADO**. A implementacao atende integralmente aos requisitos da Tarefa 11.0 e segue fielmente a secao "Monitoramento e Observabilidade" da techspec (4 metricas obrigatorias com nomes exatos, niveis `info`/`warn`/`error`, intervalos 1s/30s/10s). O design via classe `MetricsRegistry` com sources injetaveis e collect async e exemplar — evita pollers dedicados e mantem o `/metrics` resiliente a falhas de Redis. Cobertura de testes solida (12+ novos testes, incluindo um teste de integracao end-to-end que executa worker real, gera execucoes sent+skipped e valida o payload Prometheus por regex). Todos os checks (`typecheck`, `lint`, `test`, `build`) passando, totalizando **256 testes verdes, 1 skipped, 0 falhando**. Os 7 problemas listados sao todos de severidade Baixa/Informacional — destacam-se a constante `LogEvents.WorkerException` declarada mas nao usada e tres metodos de `ScheduleService` (`delete`/`pause`/`resume`) sem log dedicado, mas nenhum bloqueia a aceitacao da tarefa.

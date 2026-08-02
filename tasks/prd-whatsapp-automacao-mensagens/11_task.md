# Tarefa 11.0: Observabilidade (Logs Estruturados + Metricas)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Completar a stack de observabilidade descrita na techspec: logs `pino` estruturados nos pontos-chave (eventos de schedule, anti-spam skip, falha de envio/sessao) e endpoint `GET /api/metrics` em formato Prometheus usando `prom-client` expondo metricas operacionais. Tambem ajustar o polling do frontend para os intervalos definidos (1s com QR pendente; 30s em ready; 10s para schedules).

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `clean-code` (global) — instrumentacao explicita, sem ruido.
</skills>

<requirements>
- Logs:
  - `info` em criacao/edicao/execucao bem sucedida de schedule;
  - `warn` em skip por antispam e sessao desconectada;
  - `error` em falha de envio (`SendError`) e excecoes do worker.
- Endpoint `GET /api/metrics` retornando formato Prometheus.
- Metricas obrigatorias:
  - `whatsapp_session_status` (gauge: 0=disconnected, 1=qr, 2=connecting, 3=ready);
  - `schedule_runs_total{status="sent|skipped|error"}` (counter);
  - `queue_depth` (gauge derivado do BullMQ);
  - `next_run_lag_seconds` (gauge: diferenca atual entre `nextRunAt` e `now` para schedules atrasados).
- Frontend usa intervalos da techspec ("Eventos para o dashboard").
- Documentar como acessar metricas no README ou em comentario inicial do endpoint.
</requirements>

## Subtarefas

- [x] 11.1 Refinar `apps/api/src/observability/logger.ts` com nomes de eventos consistentes (campos `event`, `scheduleId`, `contactId`, `status`).
- [x] 11.2 Instrumentar pontos-chave (criar `Schedule`, executar job, antispam skip, erro de envio, sessao perdida).
- [x] 11.3 Implementar `apps/api/src/observability/metrics.ts` com `prom-client` registrando metricas listadas.
- [x] 11.4 Implementar endpoint `GET /api/metrics` retornando `register.metrics()`.
- [x] 11.5 Ajustar polling no frontend para 1s/30s (status) e 10s (schedules) usando intervalos configuraveis.
- [x] 11.6 Escrever testes da tarefa (ver secao Testes).
- [x] 11.7 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secao "Monitoramento e Observabilidade" (lista exata de metricas e intervalos de polling) e "Riscos Conhecidos - Memoria do Puppeteer" (monitoramento adicional opcional via `process.memoryUsage()`).

## Criterios de Sucesso

- Apos 1 execucao de schedule, `curl /api/metrics` mostra `schedule_runs_total{status="sent"} 1` ou similar.
- `whatsapp_session_status` reflete corretamente o estado atual.
- Logs sao parseaveis em JSON em prod; legiveis com `pino-pretty` em dev.

## Testes da Tarefa

- [ ] Testes de unidade: helpers de log com `pino` mockado verificando campos esperados; `metrics.ts` expoe contadores corretos.
- [ ] Testes de integracao: subir API, executar 2 jobs (1 sucesso e 1 skip), `GET /api/metrics` retorna texto Prometheus contendo as 4 metricas com valores esperados.
- [ ] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/observability/logger.ts`
- `apps/api/src/observability/metrics.ts`
- `apps/api/src/observability/metrics.routes.ts`
- `apps/api/test/metrics.integration.test.ts`
- `apps/web/lib/api-client.ts` (atualizacao dos intervalos de polling)
- `apps/web/hooks/usePolling.ts` (se criado)

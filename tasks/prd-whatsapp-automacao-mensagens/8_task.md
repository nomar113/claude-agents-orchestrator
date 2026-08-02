# Tarefa 8.0: Fila BullMQ, Worker de Disparo e Bootstrap

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Materializar a infraestrutura de execucao dos agendamentos: fila `schedules` em BullMQ + Redis com jobs `delayed`, `SchedulerWorker` que processa cada job (expande destinatarios, renderiza template, envia via `WhatsAppService`, grava `ExecutionLog`, re-enfileira a proxima execucao) e `SchedulerBootstrap` que ao subir reprocessa `nextRunAt` de schedules ativos e enfileira jobs perdidos dentro da janela de tolerancia (default 30min).

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `clean-code` (global) — worker com responsabilidade unica, deps injetadas.
</skills>

<requirements>
- `JobQueue` (BullMQ) com fila `schedules`; jobs `delayed` apontando para `{ scheduleId }`.
- `SchedulerWorker.process(job)` implementa o pipeline: carregar schedule -> expandir destinatarios (`contact` ou `list`) -> renderizar via `TemplateEngine` -> enviar via `WhatsAppService.sendText/sendMedia` -> gravar `ExecutionLog` por contato -> recomputar `nextRunAt` via `ScheduleEngine` -> re-enfileirar (se nao expirou).
- Schedule entra em `status='expired'` quando `computeNextRun` retorna `null`.
- `attempts: 3, backoff: exponential` no job.
- Erro de sessao (`SessionError`) emite alerta no log e nao consome tentativas; erro de envio (`SendError`) grava `ExecutionLog status='error'` com `errorMsg`.
- `SchedulerBootstrap` ao subir a API:
  - recalcula `nextRunAt` de todos `Schedule` com `status='active'`;
  - enfileira jobs perdidos cujo horario caiu na janela de tolerancia (env `BOOT_TOLERANCE_MIN`, default 30);
  - fora da janela: nao reenvia, mas mantem o proximo agendamento.
- Sem dependencia ainda de antispam (proxima tarefa).
</requirements>

## Subtarefas

- [x] 8.1 Implementar `apps/api/src/queue/bullmq.ts` com factory de fila e worker, configurando Redis pelo env.
- [x] 8.2 Implementar `apps/api/src/scheduling/scheduler.worker.ts` com pipeline completo.
- [x] 8.3 Implementar `apps/api/src/scheduling/scheduler.bootstrap.ts` chamado no boot da API.
- [x] 8.4 Implementar funcao utilitaria `enqueueScheduleJob(scheduleId, runAt)` reutilizavel.
- [x] 8.5 Garantir que `Schedule.nextRunAt` e atualizado em cada execucao.
- [x] 8.6 Escrever testes da tarefa (ver secao Testes).
- [x] 8.7 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Visao Geral dos Componentes - JobQueue, SchedulerWorker, SchedulerBootstrap", "Fluxo de dados (disparo)" e "Riscos Conhecidos - Processo precisa estar rodando" para a janela de tolerancia. Decisao de re-enfileiramento manual (nao usar `repeat`): "Decisoes Principais".

## Criterios de Sucesso

- Criar um schedule `onetime` para daqui a 2 segundos com driver fake e Redis efemero -> job e enfileirado -> `ExecutionLog status='sent'` aparece para o(s) contato(s).
- Schedule `fixed` (cron `*/1 * * * *`) gera multiplas execucoes consecutivas com re-enfileiramento.
- Boot da API com schedule cujo `nextRunAt` esta 5min no passado -> dispara imediatamente.
- Schedule cujo `nextRunAt` esta 60min no passado e tolerancia=30 -> nao dispara mas recalcula proximo.

## Testes da Tarefa

- [x] Testes de unidade: pipeline do worker com mocks (`WhatsAppService` fake, `Prisma` in-memory, `ScheduleEngine` stub) cobrindo: envio com sucesso, falha de envio (gravacao de log), expiracao (nao re-enfileira), recipient = `list` (expansao).
- [x] Testes de integracao: subir API + SQLite in-memory + Redis efemero (Docker ou ioredis-mock); criar schedule e validar gravacao de `ExecutionLog` apos disparo; validar `SchedulerBootstrap` com relogio fake.
- [x] Testes E2E: nao aplicavel nesta tarefa.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/queue/bullmq.ts`
- `apps/api/src/scheduling/scheduler.worker.ts`
- `apps/api/src/scheduling/scheduler.bootstrap.ts`
- `apps/api/src/scheduling/enqueue.ts`
- `apps/api/test/scheduler.worker.test.ts`
- `apps/api/test/scheduler.bootstrap.test.ts`
- `apps/api/test/scheduler.integration.test.ts`

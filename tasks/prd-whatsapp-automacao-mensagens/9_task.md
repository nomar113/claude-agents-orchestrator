# Tarefa 9.0: CRUD de Agendamentos com Pause/Resume

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Expor a API de Agendamentos (FR6-FR12, FR18, FR21, FR22) e construir a tela de Agendamentos no frontend com formularios visuais dedicados por tipo de trigger (sem campo livre de cron). Suporta criar, editar, excluir, pausar e retomar, com indicacao visual do proximo disparo e estado (ativo/pausado/expirado).

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `frontend-design` (global) — formularios visuais com cores/icones por estado (FR22).
- `vercel-react-best-practices` (global).
</skills>

<requirements>
- `ScheduleService` em `apps/api/src/schedules/schedule.service.ts` com CRUD que ao criar/editar:
  - valida `triggerConfig` via Zod conforme `triggerType`;
  - calcula `nextRunAt` via `ScheduleEngine`;
  - enfileira o job inicial via `enqueueScheduleJob`.
- Endpoints: `GET/POST /api/schedules`, `PUT/DELETE /api/schedules/:id`, `POST /api/schedules/:id/pause`, `POST /api/schedules/:id/resume`.
- Pausar remove jobs pendentes da fila e mantem o registro com `status='paused'`.
- Retomar recalcula `nextRunAt` e re-enfileira.
- Tela `apps/web/app/schedules/page.tsx`:
  - lista com proximo disparo (formatado no timezone), estado visual (cor/icone) e botoes pause/resume/editar/excluir;
  - criacao em 3 passos (destinatario -> gatilho -> mensagem) com formularios dedicados por tipo de trigger (FR PRD seccao Experiencia do Usuario).
- Validacao previne `onetime` com data passada.
- Indicacao explicita que o agendamento expirou quando `nextRunAt = null`.
</requirements>

## Subtarefas

- [x] 9.1 Definir schemas Zod de `Schedule` em `packages/shared-types/src/schedule.ts` (criar/editar payloads por trigger).
- [x] 9.2 Implementar `ScheduleService` com CRUD + pause/resume integrando com `ScheduleEngine` e fila.
- [x] 9.3 Implementar `schedule.routes.ts` com todos os endpoints.
- [x] 9.4 Implementar tela `apps/web/app/schedules/page.tsx` com listagem.
- [x] 9.5 Implementar wizard de 3 passos: `RecipientStep`, `TriggerStep` (com sub-form por tipo), `MessageStep` (reusa `MessagePreview`).
- [x] 9.6 Implementar badges/estado visual por `status` (`active/paused/expired`).
- [x] 9.7 Escrever testes da tarefa (ver secao Testes).
- [x] 9.8 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Modelos de Dados - Schedule", "Endpoints de API - /schedules e pause/resume" e PRD secao "Experiencia do Usuario - Fluxos Principais" para o wizard de 3 passos.

## Criterios de Sucesso

- Criar schedule via UI: wizard valida cada passo, mostra preview e salva.
- API recalcula `nextRunAt` ao editar trigger.
- Pause/resume reflete na fila (job pendente removido/recriado).
- Schedule expirado e marcado e nao aceita resume sem antes alterar `endsAt/maxOccurrences`.

## Testes da Tarefa

- [x] Testes de unidade: `ScheduleService` (criar/editar/pause/resume) com fila e engine mockadas; validacao Zod de payload invalido por tipo (ex.: solar sem `event`).
- [x] Testes de integracao: SQLite in-memory + fila fake; criar schedule fixo -> verificar registro + job enfileirado; pause -> job removido; resume -> job recriado; editar trigger -> `nextRunAt` atualizado. Testes via supertest contra `createApp`.
- [ ] Testes E2E (Playwright): a infra Playwright sera adicionada na tarefa 12.0; cobertura desta tarefa por testes de componente (`schedules-client.test.tsx`) validando badges, pausar, retomar.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/schedules/schedule.service.ts`
- `apps/api/src/schedules/schedule.routes.ts`
- `apps/api/test/schedule.service.test.ts`
- `apps/api/test/schedule.integration.test.ts`
- `apps/web/app/schedules/page.tsx`
- `apps/web/app/schedules/new/page.tsx`
- `apps/web/components/schedule/RecipientStep.tsx`
- `apps/web/components/schedule/TriggerStep.tsx`
- `apps/web/components/schedule/MessageStep.tsx`
- `apps/web/components/schedule/StatusBadge.tsx`
- `packages/shared-types/src/schedule.ts`

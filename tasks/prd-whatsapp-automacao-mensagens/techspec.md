# Tech Spec — Automação de Mensagens Agendadas no WhatsApp

## Resumo Executivo

A solução é uma aplicação monoinstância organizada como **monorepo npm workspaces** com duas apps independentes: uma **API Node.js + Express + TypeScript** que mantém um processo long-lived hospedando a sessão WhatsApp (via `whatsapp-web.js` com `LocalAuth`) e o worker BullMQ no mesmo processo, e um **dashboard Next.js (App Router)** consumindo a API por HTTP. A persistência usa **SQLite via Prisma** (suficiente para uso pessoal). Os agendamentos são materializados como jobs delayed na fila Redis (BullMQ) e, no momento do disparo, o cálculo do *próximo* horário (fixo, solar, aniversário ou one-time) é refeito e um novo job é enfileirado, garantindo recorrência e tolerância a reinícios.

Decisões-chave: (1) WhatsApp Web pessoal — assumimos risco de ban e aplicamos defaults conservadores; (2) BullMQ + Redis pela persistência de jobs e retries nativos; (3) cálculo solar com `suncalc` e timezone com `date-fns-tz`; (4) interpolação de variáveis simples (`{nome}`, `{data}`, `{hora}`, customizadas) sem motor de templates externo.

## Arquitetura do Sistema

### Visão Geral dos Componentes

**Novos componentes (todos novos — projeto greenfield):**

- `apps/api` (Express) — orquestra requisições HTTP, dispara jobs, e hospeda o cliente WhatsApp e o worker BullMQ.
- `apps/web` (Next.js App Router) — dashboard SPA-like consumindo a API; sem lógica de negócio.
- `packages/shared-types` — Zod schemas + tipos TS compartilhados entre API e Web.
- `WhatsAppService` — wrapper em torno de `whatsapp-web.js Client`, expõe `connect/qr/status/disconnect/sendText/sendMedia/getContacts` e emite eventos de sessão.
- `ScheduleEngine` — calcula `nextRunAt` dado um `Schedule` e um momento de referência (suporta `fixed`, `solar`, `birthday`, `onetime`).
- `JobQueue` (BullMQ) — fila `schedules` com jobs `delayed` que apontam para um `scheduleId`.
- `SchedulerWorker` — processa o job, expande destinatários, aplica anti-spam, renderiza template, envia via `WhatsAppService` e re-agenda a próxima ocorrência.
- `TemplateEngine` — interpolação string com lookup em `contact.vars`, `contact.name`, `now()`.
- `AntiSpamGuard` — verifica histórico (`ExecutionLog`) e aplica regra "máx 1 msg automática por contato em janela de 6h" (configurável).
- `ContactService` / `ListService` — CRUD + importadores (CSV via `papaparse`; WhatsApp via `client.getContacts()`).
- `MediaService` — upload multipart (via `multer`) salvando em `storage/media/<uuid>.<ext>` com metadados em `Media`.
- `SettingsService` — singleton `Settings` (lat/lng/timezone/thresholds).

**Fluxo de dados (disparo):**

```
Boot → SchedulerBootstrap recalcula nextRunAt de cada Schedule ativo e enfileira jobs delayed
     ↓
BullMQ dispara job no horário → SchedulerWorker
     ↓
Worker resolve destinatários → AntiSpamGuard filtra → TemplateEngine renderiza
     ↓
WhatsAppService.sendText/sendMedia → grava ExecutionLog → ScheduleEngine calcula próxima → re-enfileira
```

## Design de Implementação

### Interfaces Principais

```ts
// apps/api/src/whatsapp/whatsapp.service.ts
export interface WhatsAppService {
  connect(): Promise<void>;                       // inicializa client; emite 'qr'
  getQrCode(): string | null;                     // último QR pendente
  getStatus(): 'disconnected' | 'qr' | 'connecting' | 'ready';
  disconnect(): Promise<void>;
  sendText(jid: string, text: string): Promise<void>;
  sendMedia(jid: string, mediaPath: string, caption?: string): Promise<void>;
  listContacts(): Promise<WaContact[]>;
}

// apps/api/src/scheduling/schedule.engine.ts
export interface ScheduleEngine {
  computeNextRun(schedule: Schedule, from: Date): Date | null;  // null => expirado
}

// apps/api/src/scheduling/scheduler.worker.ts
export interface SchedulerWorker {
  process(job: Job<{ scheduleId: string }>): Promise<void>;
}

// apps/api/src/templates/template.engine.ts
export interface TemplateEngine {
  render(text: string, ctx: { contact: Contact; now: Date; tz: string }): string;
}

// apps/api/src/antispam/antispam.guard.ts
export interface AntiSpamGuard {
  canSend(contactId: string, now: Date): Promise<{ ok: boolean; reason?: string }>;
}
```

### Modelos de Dados

```prisma
// apps/api/prisma/schema.prisma
model Contact {
  id        String   @id @default(uuid())
  name      String
  phone     String   @unique           // E.164, ex: +5511999...
  birthdate DateTime?                  // só dia/mês/ano relevantes
  vars      Json     @default("{}")    // chaves arbitrárias
  lists     ContactListMember[]
  logs      ExecutionLog[]
  createdAt DateTime @default(now())
}

model ContactList {
  id      String  @id @default(uuid())
  name    String  @unique
  members ContactListMember[]
}

model ContactListMember {
  contactId String
  listId    String
  contact   Contact     @relation(fields: [contactId], references: [id])
  list      ContactList @relation(fields: [listId], references: [id])
  @@id([contactId, listId])
}

model Schedule {
  id              String   @id @default(uuid())
  triggerType     String   // 'fixed' | 'solar' | 'birthday' | 'onetime'
  triggerConfig   Json     // ver shape abaixo
  recipientType   String   // 'contact' | 'list'
  recipientId     String
  messageText     String
  messageMedia    Json     @default("[]")   // [{ mediaId, order }]
  status          String   @default("active") // active|paused|expired
  endsAt          DateTime?
  maxOccurrences  Int?
  occurrenceCount Int      @default(0)
  nextRunAt       DateTime?
  createdAt       DateTime @default(now())
}

model ExecutionLog {
  id         String   @id @default(uuid())
  scheduleId String
  contactId  String
  runAt      DateTime @default(now())
  status     String   // 'sent' | 'skipped_antispam' | 'error'
  errorMsg   String?
  @@index([contactId, runAt])
}

model Media {
  id        String   @id @default(uuid())
  path      String   // storage/media/<uuid>.<ext>
  mimeType  String
  sizeBytes Int
  createdAt DateTime @default(now())
}

model Settings {
  id                    Int      @id @default(1)  // singleton
  latitude              Float?
  longitude             Float?
  timezone              String   @default("America/Sao_Paulo")
  bulkThreshold         Int      @default(10)
  antiSpamPerContact    Int      @default(1)
  antiSpamWindowHours   Int      @default(6)
  whatsappConnected     Boolean  @default(false)
}
```

**Shape de `triggerConfig`** (discriminado por `triggerType`):

```ts
type TriggerConfig =
  | { type: 'fixed'; cron: string }                                  // ex: "0 9 * * 1" (seg 9h)
  | { type: 'solar'; event: 'sunrise' | 'sunset'; offsetMin: number }
  | { type: 'birthday'; atHHmm: string }                             // ex: "09:00"
  | { type: 'onetime'; runAt: string };                              // ISO
```

### Endpoints de API

Todos sob `/api`, JSON, autenticação simples por token compartilhado em header `x-api-key` (uso pessoal local).

| Método | Path | Descrição |
|---|---|---|
| GET | `/whatsapp/status` | Estado da sessão (qr, ready, etc.) |
| POST | `/whatsapp/connect` | Inicia sessão; retorna QR |
| POST | `/whatsapp/disconnect` | Encerra sessão |
| GET | `/whatsapp/contacts` | Lista contatos sincronizados (FR3) |
| GET/POST | `/contacts` | Lista/cria contatos |
| PUT/DELETE | `/contacts/:id` | Edita/remove |
| POST | `/contacts/import-csv` | Upload CSV |
| POST | `/contacts/import-whatsapp` | Importa selecionados |
| GET/POST | `/lists` | Lista/cria listas |
| PUT/DELETE | `/lists/:id` | Edita/remove |
| GET/POST | `/schedules` | Lista/cria agendamentos |
| PUT/DELETE | `/schedules/:id` | Edita/remove |
| POST | `/schedules/:id/pause` `/resume` | Estado |
| POST | `/schedules/preview` | Renderiza preview com contato exemplo (FR17) |
| POST | `/media/upload` | Upload multipart |
| GET/PUT | `/settings` | Config global |

Validação de payloads via Zod (schemas em `packages/shared-types`).

## Pontos de Integração

- **WhatsApp Web** via `whatsapp-web.js` com `LocalAuth({ dataPath: 'storage/wwebjs' })`. QR é emitido pelo evento `qr` e persistido em memória; cliente é singleton no processo da API.
- **Redis** (Docker) para BullMQ — fila `schedules` com `delayed` e `repeat` desabilitado (re-enfileiramos manualmente após cada execução para suportar gatilhos não-cron como solar/aniversário).
- **SunCalc** (`suncalc` npm) para calcular `sunrise`/`sunset` dado lat/lng/data.
- **date-fns-tz** para conversão entre `UTC` e `Settings.timezone` (cobre DST).
- **rrule** ou `cron-parser` para cálculo do `nextRunAt` no trigger `fixed`.
- **papaparse** para parsing de CSV em streaming.
- **multer** para upload de mídia.

Tratamento de erros: o `WhatsAppService` envolve erros do cliente e classifica em `SessionError` (dispara alerta no dashboard) e `SendError` (vai pro `ExecutionLog` com `status='error'`, sem matar o worker). Jobs do BullMQ usam `attempts: 3, backoff: exponential`.

## Abordagem de Testes

### Testes Unidade

- `ScheduleEngine.computeNextRun` para cada `triggerType`, incluindo bordas: DST forward/backward, ano bissexto para aniversário, deslocamento solar negativo, expiração por `endsAt`/`maxOccurrences`.
- `TemplateEngine.render` cobrindo variáveis ausentes, escaping e variáveis custom.
- `AntiSpamGuard.canSend` com `ExecutionLog` mockado (in-memory) cobrindo janelas e contatos distintos.
- Mocks **apenas** para `WhatsAppService` (serviço externo) e relógio (`vi.useFakeTimers`).

### Testes de Integração

- Express + Prisma com SQLite **em memória** (`file::memory:?cache=shared`).
- Cobertura: CRUD de Contatos/Listas/Schedules, importação CSV, preview de mensagem, fluxo de pause/resume.
- Fila BullMQ apontando para Redis efêmero (container CI) — verifica que criar Schedule enfileira job e que worker grava `ExecutionLog`.

### Testes de E2E

- **Playwright** contra Next.js + API rodando localmente, com `WhatsAppService` substituído por **fake** (envia para sink em memória) via variável `WHATSAPP_DRIVER=fake`.
- Cenários (correspondem às histórias-âncora do PRD):
  1. Onboarding: configurar localização → importar 3 contatos via CSV → criar schedule solar → verificar próximo disparo calculado.
  2. Pause/Resume de schedule ativo.
  3. Bulk: criar schedule para lista de 12 contatos → confirma exibe modal de confirmação.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Bootstrap monorepo**: `package.json` raiz (com campo `workspaces`), `apps/api`, `apps/web`, `packages/shared-types`, configs base (tsconfig, eslint, vitest, prettier).
2. **Persistência**: `schema.prisma`, primeira migration, seed de `Settings`.
3. **WhatsAppService** com `LocalAuth` + endpoints `/whatsapp/*` e tela de conexão na Web (entrega FR23–FR25 e desbloqueia testes manuais).
4. **Contacts + Lists** (CRUD, importação CSV, importação WhatsApp) — FR1–FR5.
5. **MediaService + upload** + **TemplateEngine** + endpoint `preview` — FR13–FR17.
6. **ScheduleEngine + BullMQ + SchedulerWorker** — FR6–FR12, incluindo `SchedulerBootstrap` (rehidratação no boot).
7. **AntiSpamGuard + bulk confirmation** — FR18–FR22.
8. **Frontend** Next.js: layouts, telas (Conexão, Contatos, Listas, Agendamentos, Settings) consumindo a API.
9. **Testes E2E Playwright** dos 3 fluxos âncora.

### Dependências Técnicas

- Redis acessível (Docker Compose com serviços `redis` e `api`).
- Node 20+ (requisito do `whatsapp-web.js` mais recente).
- Chromium nativo (Puppeteer baixa automaticamente; em prod local usa-se sistema).

## Monitoramento e Observabilidade

Stack simples adequada à monoinstância pessoal:

- **Logs estruturados** com `pino` (`pino-pretty` em dev). Níveis: `info` (eventos de schedule), `warn` (anti-spam skip), `error` (falha de envio/sessão).
- **Métricas internas** expostas em `GET /api/metrics` (formato Prometheus, via `prom-client`): `whatsapp_session_status`, `schedule_runs_total{status="sent|skipped|error"}`, `queue_depth`, `next_run_lag_seconds`.
- **Eventos para o dashboard**: o frontend faz polling de `/api/whatsapp/status` (1s enquanto QR pendente; 30s em ready) e `/api/schedules` (10s). Sem WebSocket no MVP.
- **Sem Grafana** no MVP — o dashboard próprio mostra última execução, próxima execução e estado da sessão por agendamento (FR22).

## Considerações Técnicas

### Decisões Principais

- **Express em vez de Fastify**: pedido pelo usuário; maturidade e familiaridade compensam pequena diferença de performance, irrelevante para uso pessoal.
- **whatsapp-web.js em vez de Baileys**: API mais simples, `LocalAuth` plug-and-play, comunidade maior. Trade-off: roda Chromium via Puppeteer (~250–400MB RAM) — aceitável para uma única instância pessoal.
- **API e Worker no mesmo processo**: garante que o cliente WhatsApp é único e que o worker pode chamá-lo diretamente. Alternativa rejeitada: worker separado exigiria IPC ou múltiplas sessões WhatsApp (caro e arriscado).
- **Re-enfileiramento manual após cada execução** (não usar `repeat` do BullMQ): necessário porque solar/aniversário não são exprimíveis em cron e dependem do `Settings.timezone`/`latitude`. O `ScheduleEngine` é a fonte de verdade.
- **SQLite + Prisma**: monoinstância sem requisito de concorrência alta; um único arquivo de dados é fácil de fazer backup. Migração para Postgres é trivial via mudança de provider.
- **Variáveis sem motor externo**: regex simples `\{(\w+)\}` é suficiente; libs como Handlebars/Mustache adicionariam complexidade sem ganho.

### Riscos Conhecidos

- **Ban pelo WhatsApp**: integração não-oficial. Mitigações: defaults anti-spam (`bulkThreshold=10`, `antiSpamPerContact=1`, `antiSpamWindowHours=6`), **delay aleatório 5–20s** entre envios em bulk, aviso explícito no onboarding (PRD §Restrições).
- **Sessão expirando**: a sessão LocalAuth pode invalidar (mudança de device, restart de celular). Mitigação: detectar evento `disconnected`, atualizar `Settings.whatsappConnected=false`, exibir banner persistente no dashboard e disparar regeneração de QR.
- **Processo precisa estar rodando** no momento do disparo (PRD aceita): mitigado parcialmente por `SchedulerBootstrap`, que ao subir reprocessa `nextRunAt` e enfileira jobs perdidos cujo horário caiu na "janela de tolerância" (configurável, default 30min); fora da janela são marcados `missed` no log.
- **Memória do Puppeteer**: pode crescer ao longo do tempo. Mitigação: monitorar `process.memoryUsage()` em `/metrics`; ciclo de restart manual documentado.
- **Mudanças de horário de verão**: garantido por `date-fns-tz` ao converter entre wall-clock e UTC; cobertura por testes unidade do `ScheduleEngine`.

### Conformidade com Skills Padroes

Skills relevantes deste projeto que se aplicam:

- `executar-task` — implementação será conduzida pela skill, com checks `typecheck/test/build/lint` antes de marcar como concluído.
- `executar-review` e `executar-qa` — review e QA padronizados após implementação.
- `executar-bugfix` — correções de bugs reportados pelo QA.
- `frontend-design` (global) — orienta o design do dashboard Next.js evitando estética genérica.
- `vercel-react-best-practices` (global) — boas práticas para o frontend Next.js (App Router, RSC quando aplicável).

Desvio justificado: não há skill `kotlin-springboot` aplicável (stack diferente); skills do `controlai` **não** se aplicam pois este é um projeto independente.

### Arquivos relevantes e dependentes

Projeto greenfield — todos os arquivos abaixo serão **novos**:

- `package.json` raiz (com campo `workspaces`), `docker-compose.yml` (redis).
- `apps/api/src/index.ts`, `apps/api/src/server.ts`.
- `apps/api/src/whatsapp/{whatsapp.service.ts,whatsapp.controller.ts,whatsapp.routes.ts}`.
- `apps/api/src/scheduling/{schedule.engine.ts,scheduler.worker.ts,scheduler.bootstrap.ts}`.
- `apps/api/src/templates/template.engine.ts`.
- `apps/api/src/antispam/antispam.guard.ts`.
- `apps/api/src/contacts/{contact.service.ts,contact.routes.ts,csv-import.ts}`.
- `apps/api/src/lists/{list.service.ts,list.routes.ts}`.
- `apps/api/src/schedules/{schedule.service.ts,schedule.routes.ts}`.
- `apps/api/src/media/{media.service.ts,media.routes.ts}`.
- `apps/api/src/settings/{settings.service.ts,settings.routes.ts}`.
- `apps/api/src/queue/bullmq.ts`.
- `apps/api/src/observability/{logger.ts,metrics.ts}`.
- `apps/api/prisma/schema.prisma`, `apps/api/prisma/migrations/*`.
- `apps/api/test/**` (unit + integration).
- `apps/web/app/{(dashboard)/layout.tsx,page.tsx,connect/page.tsx,contacts/page.tsx,lists/page.tsx,schedules/page.tsx,settings/page.tsx}`.
- `apps/web/lib/api-client.ts`.
- `apps/web/components/**` (formulários por tipo de trigger, preview de mensagem, modal de bulk confirm).
- `apps/web/playwright/**` (E2E).
- `packages/shared-types/src/{schedule.ts,contact.ts,list.ts,settings.ts,index.ts}`.
- `storage/media/` (gitignored), `storage/wwebjs/` (gitignored).

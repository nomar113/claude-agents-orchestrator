# Tarefa 10.0: AntiSpam Guard e Confirmacao de Envio em Massa

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar os controles de seguranca (FR19, FR20): `AntiSpamGuard` consultando `ExecutionLog` para impedir mais de N mensagens automaticas ao mesmo contato em uma janela configuravel, modal de confirmacao para envios em massa quando lista > `bulkThreshold` (FR19), e delay aleatorio 5-20s entre envios consecutivos em bulk (mitigacao de ban listada em "Riscos Conhecidos").

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `frontend-design` (global) — modal de confirmacao com numero total de destinatarios em destaque.
</skills>

<requirements>
- `AntiSpamGuard.canSend(contactId, now)` consulta `ExecutionLog` por `contactId` no intervalo `[now - antiSpamWindowHours, now]` e bloqueia se `count >= antiSpamPerContact`.
- Integrar no `SchedulerWorker`: contatos bloqueados geram `ExecutionLog status='skipped_antispam'` e nao chamam `WhatsAppService`.
- Implementar delay aleatorio 5-20s entre envios consecutivos quando o schedule tem mais de 1 destinatario.
- Endpoint/checagem usada pelo frontend: `POST /api/schedules/validate-bulk` retorna `{ recipientCount, requiresConfirmation }`.
- No wizard de Agendamentos (Tarefa 9), interceptar salvamento quando `requiresConfirmation = true` e exibir modal `BulkConfirmationModal` com contagem, lista preview e botoes "Confirmar"/"Cancelar".
- `bulkThreshold`, `antiSpamPerContact`, `antiSpamWindowHours` lidos de `Settings` (Tarefa 2).
</requirements>

## Subtarefas

- [x] 10.1 Implementar `AntiSpamGuard` em `apps/api/src/antispam/antispam.guard.ts` consumindo Prisma e Settings.
- [x] 10.2 Integrar guard no `SchedulerWorker` (Tarefa 8) gravando `status='skipped_antispam'`.
- [x] 10.3 Implementar delay aleatorio (`5000-20000ms`) entre envios em loop de destinatarios no worker.
- [x] 10.4 Implementar endpoint `POST /api/schedules/validate-bulk` retornando contagem efetiva e flag.
- [x] 10.5 Implementar componente `BulkConfirmationModal.tsx`.
- [x] 10.6 Integrar modal no wizard de Agendamentos (intercepta `MessageStep` -> save).
- [x] 10.7 Escrever testes da tarefa (ver secao Testes).
- [x] 10.8 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Interfaces Principais - AntiSpamGuard", "Riscos Conhecidos - Ban pelo WhatsApp" (delay 5-20s e thresholds) e PRD "Funcionalidades Principais - secao 4 Controles de Seguranca e Operacao".

## Criterios de Sucesso

- Contato com 1 envio nas ultimas 6h e `antiSpamPerContact=1` -> proximo envio agendado e marcado `skipped_antispam`.
- Lista com 12 contatos e `bulkThreshold=10` -> wizard exibe modal antes de salvar; cancelar nao salva.
- Delay aleatorio observado em logs ao processar lista grande (testavel via metrica de tempo entre envios).

## Testes da Tarefa

- [x] Testes de unidade: `AntiSpamGuard.canSend` em multiplos cenarios (janela vazia, dentro do limite, no limite, fora da janela); helper de delay aleatorio com `vi.useFakeTimers`.
- [x] Testes de integracao: SQLite in-memory; criar `ExecutionLog` proximo; processar job e validar `status='skipped_antispam'`; endpoint `validate-bulk` retorna contagem correta para `contact` e `list`.
- [x] Testes E2E (Playwright): criar schedule para lista de 12 contatos -> modal aparece -> cancelar nao cria; confirmar cria.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/antispam/antispam.guard.ts`
- `apps/api/src/scheduling/scheduler.worker.ts` (atualizacao para integrar guard + delay)
- `apps/api/src/schedules/validate-bulk.routes.ts`
- `apps/api/test/antispam.guard.test.ts`
- `apps/api/test/scheduler.antispam.integration.test.ts`
- `apps/web/components/BulkConfirmationModal.tsx`
- `apps/web/app/schedules/new/page.tsx` (atualizacao para chamar validate-bulk)

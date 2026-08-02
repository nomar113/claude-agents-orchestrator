# Tarefa 7.0: Schedule Engine (calculo de nextRunAt)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o `ScheduleEngine.computeNextRun(schedule, from)` que e a fonte de verdade para o calculo do proximo horario de disparo (FR6-FR12). Suporta os quatro tipos de trigger (`fixed`, `solar`, `birthday`, `onetime`), respeita o timezone configurado em `Settings`, trata DST, e considera `endsAt`/`maxOccurrences`/`occurrenceCount` para expiracao.

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `clean-code` (global) — funcao pura testavel; sem efeitos colaterais.
</skills>

<requirements>
- Funcao pura: nao acessa banco; recebe `schedule` e `from: Date`.
- Suporte completo aos quatro `triggerType`:
  - `fixed`: expressao cron via `cron-parser`.
  - `solar`: `event = 'sunrise' | 'sunset'`, `offsetMin` configuravel, usa `suncalc` com lat/lng/timezone.
  - `birthday`: usa `birthdate` do contato e `atHHmm` para gerar proximo aniversario (cobre 29 de fevereiro).
  - `onetime`: retorna `runAt` se ainda no futuro; `null` se passou.
- Retorna `null` quando o schedule expirou (`endsAt` ultrapassado ou `occurrenceCount >= maxOccurrences`).
- Conversoes UTC <-> wall-clock via `date-fns-tz`.
- Testes cobrem casos de DST forward/backward, ano bissexto, deslocamento solar negativo e timezones distintos.
</requirements>

## Subtarefas

- [x] 7.1 Definir tipos `TriggerConfig` (discriminado) em `packages/shared-types/src/schedule.ts`.
- [x] 7.2 Implementar `ScheduleEngine.computeNextRun` em `apps/api/src/scheduling/schedule.engine.ts`.
- [x] 7.3 Implementar helpers `computeFixedNext`, `computeSolarNext`, `computeBirthdayNext`, `computeOnetimeNext`.
- [x] 7.4 Implementar expiracao por `endsAt` e `maxOccurrences`.
- [x] 7.5 Escrever testes da tarefa (ver secao Testes).
- [x] 7.6 Executar `npm run typecheck`, `npm run lint`, `npm test`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Interfaces Principais - ScheduleEngine", "Modelos de Dados - Schedule" (incluindo `triggerConfig` shape), "Pontos de Integracao" (`suncalc`, `date-fns-tz`, `cron-parser`) e "Abordagem de Testes - Testes Unidade" (casos de borda obrigatorios).

## Criterios de Sucesso

- `computeNextRun` testavel sem banco, com relogio injetado (`vi.useFakeTimers`).
- Cobertura unitaria explicitamente para: DST forward (Sao Paulo nao usa DST, mas teste com `America/Sao_Paulo` historico + outro fuso com DST como `Europe/Lisbon`), DST backward, aniversario em 29/02 caindo em ano nao bissexto, `offsetMin` negativo (antes do nascer do sol), `endsAt` no passado, `maxOccurrences` atingido.

## Testes da Tarefa

- [x] Testes de unidade: pelo menos 1 caso por tipo de trigger + casos de borda listados acima. Total esperado >= 20 casos.
- [x] Testes de integracao: nao aplicavel (logica pura).
- [x] Testes E2E: nao aplicavel nesta tarefa (cobertos por tarefas posteriores).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/scheduling/schedule.engine.ts`
- `apps/api/src/scheduling/triggers/fixed.ts`
- `apps/api/src/scheduling/triggers/solar.ts`
- `apps/api/src/scheduling/triggers/birthday.ts`
- `apps/api/src/scheduling/triggers/onetime.ts`
- `apps/api/test/schedule.engine.test.ts`
- `packages/shared-types/src/schedule.ts`

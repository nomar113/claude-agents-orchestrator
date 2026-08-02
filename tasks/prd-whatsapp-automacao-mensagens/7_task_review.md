# Review: Task 7 - Schedule Engine (calculo de nextRunAt)

**Revisor**: AI Code Reviewer
**Data**: 2026-06-25
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Tarefa 7.0 entrega o `ScheduleEngine.computeNextRun(schedule, from, ctx)` como funcao pura testavel, atendendo FR6-FR12 do PRD. A implementacao decompoe os quatro tipos de gatilho em quatro helpers isolados (`computeFixedNext`, `computeSolarNext`, `computeBirthdayNext`, `computeOnetimeNext`), cada um com erro tipado dedicado para pre-condicoes ausentes (`InvalidCronExpressionError`, `MissingLocationError`, `MissingBirthdatesError`, `InvalidOnetimeRunAtError`). O switch no engine usa o padrao `never` para garantir exaustividade em tempo de compilacao. Expiracao por `endsAt` e `maxOccurrences/occurrenceCount` e aplicada de forma uniforme no topo da composicao.

O `triggerConfigSchema` em `packages/shared-types` foi modelado como `z.discriminatedUnion('type', [...])` com tipos derivados via `z.infer` (incluindo `TriggerType` como alias util). Validacoes Zod sao razoaveis (`offsetMin` clamped a ±12h, `atHHmm` com regex `HH:mm`, `runAt` como ISO com offset). Os helpers consomem apenas os tipos derivados — single source of truth bem aplicado.

A cobertura de testes e a forca desta entrega: **28 testes** em `schedule.engine.test.ts` divididos em 5 describes (fixed, solar, birthday, onetime, expiracao, sanidade de fusos), excedendo o minimo de 20 pedido pela task. Casos de borda obrigatorios estao todos cobertos: DST forward em `Europe/Lisbon` (2026-03-29 — slot 01:30 que nao existe), DST backward (2026-10-25 com hora 01:30 que ocorre duas vezes), 29/02 em ano nao bissexto (cai para 28/02) e em ano bissexto, `offsetMin` negativo, expiracao via `endsAt` e via `maxOccurrences`. Os tres workspaces compilam, lintam e testam verdes: `api 135/135`, `web 23/23`, `shared-types 19/19`.

A decisao de adicionar `ScheduleContext` como terceiro parametro (em vez de embutir em `Schedule`) e correta e e o ponto mais relevante a discutir — comentario detalhado abaixo. Identifiquei pequenas observacoes de robustez/clean-code, nenhuma bloqueadora.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| packages/shared-types/src/schedule.ts | OK | 1 minor |
| apps/api/src/scheduling/schedule.engine.ts | OK | 2 minor |
| apps/api/src/scheduling/triggers/fixed.ts | OK | 1 minor |
| apps/api/src/scheduling/triggers/solar.ts | OK | 2 minor |
| apps/api/src/scheduling/triggers/birthday.ts | OK | 1 minor |
| apps/api/src/scheduling/triggers/onetime.ts | OK | 0 |
| apps/api/test/schedule.engine.test.ts | OK | 1 minor |
| apps/api/package.json (deps adicionadas) | OK | 0 |

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Tipagem rigorosa (sem `any`) | OK | Tipos derivados via `z.infer`, narrow com `Date instanceof` + `Number.isFinite`. |
| Funcao pura sem I/O | OK | Engine nao acessa DB, nao usa `Date.now()` — recebe `from` e `ctx` por injecao. |
| Erros tipados com `name` proprio | OK | 4 classes com `override readonly name`. |
| Idioma do codigo (ingles) e comentarios (pt-BR) | OK | Mensagens de erro e variaveis localizadas conforme padrao do projeto. |
| ESM com extensao `.js` nos imports | OK | Todos os imports internos usam `.js` (compativel com `"module": "node16"`-style do projeto). |
| Padrao de discriminated union via Zod | OK | `z.discriminatedUnion('type', ...)` em vez de `z.union`. |
| Lint/Prettier | OK | `npm run lint` reporta "ESLint: No issues found". |

## Aderencia a TechSpec

| Decisao Tecnica | Implementado | Observacoes |
|-----------------|--------------|-------------|
| `ScheduleEngine.computeNextRun(schedule, from): Date \| null` | SIM (com adaptacao) | Assinatura recebe terceiro parametro `ctx: ScheduleContext`. Veja M2. |
| Trigger `fixed` via cron-parser | SIM | `parseExpression` com `tz` e `currentDate`; passes DST testado. |
| Trigger `solar` via `suncalc` + `date-fns-tz` | SIM | Itera ate 366 dias (cobre Svalbard em polar night/day — validei em sanity check separado). |
| Trigger `birthday` cobrindo 29/02 | SIM | `adjustLeapDay(year, 2, 29) -> {2,28}` em ano nao bissexto, testes para ambos casos. |
| Trigger `onetime` retorna `null` se passou | SIM | Linha 15 de `onetime.ts`. |
| Expiracao por `endsAt` e `maxOccurrences` | SIM | Verificada antes (cap) e depois (endsAt) do calculo. |
| Conversoes UTC↔wall-clock via `date-fns-tz` | SIM | `formatInTimeZone` + `zonedTimeToUtc` consistentes (v2 API correta para a versao instalada `2.0.1`). |
| Discriminated union `TriggerConfig` em shared-types | SIM | Schemas Zod + tipos derivados exportados. |

## Tasks Verificadas

| Subtarefa | Status | Observacoes |
|-----------|--------|-------------|
| 7.1 Tipos `TriggerConfig` em shared-types | COMPLETA | Schemas Zod + 5 tipos derivados. |
| 7.2 `ScheduleEngine.computeNextRun` | COMPLETA | Com adicao bem justificada de `ScheduleContext`. |
| 7.3 Quatro helpers de trigger | COMPLETA | Cada um em arquivo proprio em `scheduling/triggers/`. |
| 7.4 Expiracao por `endsAt`/`maxOccurrences` | COMPLETA | Coberta por 5 testes dedicados. |
| 7.5 Testes da tarefa (>= 20) | COMPLETA | 28 testes, cobrindo todos os cenarios obrigatorios + extras. |
| 7.6 `typecheck`/`lint`/`test` | COMPLETA | Re-executei localmente: tudo verde. |

## Testes
- Total de Testes (workspace api): 135 (28 novos para `schedule.engine`)
- Passando: 135
- Falhando: 0
- Outros workspaces: web 23/23, shared-types 19/19
- Coverage: nao instrumentado nesta execucao (suite roda `vitest run` sem `--coverage`); subjetivamente alta para a logica entregue (cada branch dos 4 triggers + ambos caminhos de expiracao + erros tipados).

## Problemas Encontrados

### Problemas Criticos

Nenhum.

### Problemas Major

Nenhum.

### Problemas Minor

**M1 — `requireLocation` repassa `NaN` em vez de rejeitar.**
Arquivo: `apps/api/src/scheduling/schedule.engine.ts:57-63`.
O metodo chama-se `requireLocation` mas nao valida nada — quando `ctx.latitude/longitude` sao `null`, ele substitui por `Number.NaN` e delega a validacao para `computeSolarNext`. A intencao funciona (o erro acaba sendo lancado), porem o nome induz a erro: ler so o engine sugere que la dentro ja existe garantia de coordenadas. Duas opcoes equivalentes:
1. Renomear para `toSolarLocation` (factory neutra).
2. Mover a checagem `Number.isFinite` para dentro do helper, lancando `MissingLocationError` ali, e simplificar `computeSolarNext` para `SolarLocation` ja garantida.

Recomendo a opcao 2 — concentra a regra em um lugar so e elimina o "NaN viajante":
```ts
// schedule.engine.ts
private requireLocation(ctx: ScheduleContext): SolarLocation {
  if (ctx.latitude === null || ctx.longitude === null
      || !Number.isFinite(ctx.latitude) || !Number.isFinite(ctx.longitude)) {
    throw new MissingLocationError();
  }
  return { latitude: ctx.latitude, longitude: ctx.longitude, timezone: ctx.timezone };
}
// solar.ts: remover a checagem NaN do topo.
```

**M2 — `ScheduleContext` foi adicionado mas a interface da Tech Spec nao foi atualizada.**
Arquivo: `apps/api/src/scheduling/schedule.engine.ts:14-20`.
A Tech Spec declara `computeNextRun(schedule: Schedule, from: Date): Date | null` — assinatura de 2 parametros. A implementacao introduziu `ctx: ScheduleContext` como terceiro parametro. **A decisao em si esta correta** (mantem o engine puro, evita acoplar com `Prisma` ou `Settings`), e a alternativa seria pior (embutir `latitude/longitude/timezone/recipientBirthdates` em `Schedule` polui o modelo). Entretanto:

1. A Tech Spec ainda mostra a assinatura antiga — recomendo abrir um pequeno PR de atualizacao da Tech Spec para a assinatura de 3 parametros, registrando o ADR ("por que ctx separado").
2. O JSDoc do `ScheduleContext` ja documenta o uso, mas seria util um comentario tambem na classe explicando a divisao de responsabilidades engine vs caller (worker resolve Settings + destinatarios e injeta).

Sem isso, a Task 8 (SchedulerWorker) pode ser surpreendida ao ler so a Tech Spec.

**M3 — `MAX_DAY_PROBES = 366` e `MAX_YEAR_LOOKAHEAD = 5` sem cobertura de teste para o caminho "nao encontrado".**
Arquivos: `apps/api/src/scheduling/triggers/solar.ts:5,32` e `apps/api/src/scheduling/triggers/birthday.ts:11,42`.
Ambos retornam `null` quando o loop esgota sem achar candidato. Esse caminho nao tem teste. Para `solar.ts` rodei sanity manualmente em Svalbard (lat 78.22): o ciclo encontra dentro de ~70 dias em ambas extremidades — 366 e folgado, mas e bom documentar o porque (raio orbital + qualquer latitude < 90 sempre tem um sunrise/sunset dentro de ~half-year). Sugestao: adicionar comentario tecnico no `solar.ts` justificando o numero e, se possivel, um teste de fumaca para `Longyearbyen` em polar night/day garantindo `next !== null`.

Para `birthday.ts` o `5` e essencialmente arbitrario (cobre 5 anos consecutivos onde 29/02 nao existe — impossivel ja que ano bissexto reaparece a cada 4 anos). Reduzir para `2` deixa a intencao mais clara.

```ts
// birthday.ts
const MAX_YEAR_LOOKAHEAD = 2; // suficiente: 29/02 reaparece em <=4 anos, mas com o ajuste para 28/02 sempre achamos no proximo ano calendario.
```

**M4 — `triggerOnetimeSchema.runAt` aceita string ISO, mas o helper aceita qualquer string parseavel por `new Date(...)`.**
Arquivo: `apps/api/src/scheduling/triggers/onetime.ts:11-14`.
O schema Zod restringe `runAt` a `z.string().datetime({ offset: true })` (bom). Porem `computeOnetimeNext` reaceita qualquer string e re-valida com `Number.isFinite(t.getTime())`. Funcionalmente correto e defensivo, mas duplica a validacao. Recomendado:
- Manter o `Number.isFinite` como defesa em profundidade (caso o engine seja chamado sem passar pelo Zod).
- Trocar `new Date(config.runAt)` por `Date.parse` + construcao explicita; `new Date('not a date')` retorna `Invalid Date` silencioso em alguns runtimes — o teste cobre, mas a forma `Number.isFinite(Date.parse(s))` deixa a intencao explicita.

**M5 — `formatInTimeZone(from, tz, 'yyyy')` invocado 3x em `solar.midDayUtcForLocalDate`.**
Arquivo: `apps/api/src/scheduling/triggers/solar.ts:46-49`.
Pequena ineficiencia: tres chamadas independentes para formatar yyyy, MM, dd. Para um schedule pode ser ignorado; para um worker que avalia centenas de schedules por boot e marginal mas desnecessario. Substituir por uma unica chamada:
```ts
const ymd = formatInTimeZone(from, tz, 'yyyy-MM-dd');
return zonedTimeToUtc(`${ymd}T12:00:00`, tz);
```
Mais legivel e ~3x mais barato.

**M6 — `parseHHmm` confia em entrada validada externamente e usa `Number(...)` sem validar NaN.**
Arquivo: `apps/api/src/scheduling/triggers/birthday.ts:63-66`.
O schema Zod ja garante o formato `HH:mm`, porem o helper e exportado e pode ser chamado por outro caller que pule a validacao. Como ja vale o principio "defesa em profundidade" do M4, o mais seguro e validar inline:
```ts
function parseHHmm(value: string): [number, number] {
  const m = /^([01]\d|2[0-3]):([0-5]\d)$/.exec(value);
  if (!m) throw new Error(`atHHmm invalido: "${value}"`);
  return [Number(m[1]), Number(m[2])];
}
```
Alternativa: deixar como esta e documentar que helpers de `triggers/*` assumem `TriggerXxxConfig` pre-validada por Zod.

**M7 — Helper `wallClockUtc` no teste tem nome enganoso.**
Arquivo: `apps/api/test/schedule.engine.test.ts:38-40`.
A funcao recebe um ISO "local sem timezone" e retorna o UTC equivalente. O nome `wallClockUtc` lido isoladamente sugere "wall clock interpretado como UTC". Algo como `localIsoToUtc(iso, tz)` ou `fromZoned(iso, tz)` deixa explicita a operacao. Detalhe — nao afeta correcao.

**M8 — Borda nao testada: cron `fixed` cujo unico slot do dia cai dentro do "buraco" de DST forward.**
Arquivo: `apps/api/test/schedule.engine.test.ts:68-78`.
O teste atual usa cron `30 1 * * *` em Lisboa e confirma que o slot inexistente `01:30 WET` e realocado para `02:30 WEST` (comportamento do `cron-parser`). Faltou cobrir o caso similar com cron `* 1 * * *` (toda a hora 1) — no DST forward, **a hora 1 inteira nao existe**. Esse e o "buraco completo" e e onde alguns runtimes/libs entram em loop ou pulam o dia. Recomendo adicionar:
```ts
it('cron cuja hora inteira sumiu no DST forward pula o slot consistente', () => {
  const from = wallClockUtc('2026-03-29T00:00:00', LISBON_TZ);
  const next = engine.computeNextRun(
    scheduleOf({ type: 'fixed', cron: '0 1 * * *' }),
    from,
    ctxOf({ timezone: LISBON_TZ }),
  );
  expect(next).not.toBeNull();
  // Documentar o comportamento observado (provavel: 2026-03-30 01:00 WEST).
});
```
Isso vira documentacao executavel do contrato com `cron-parser`. Se for descoberto comportamento inesperado, melhor descobrir agora do que via bug do worker.

**M9 — `M5/Schedule.triggerConfig` em SQLite e `String` mas o engine recebe `TriggerConfig` (objeto) — risco para Task 8.**
Arquivo (origem): `apps/api/prisma/schema.prisma:45`; arquivo (consumidor): `apps/api/src/scheduling/schedule.engine.ts:23`.
Nao e um bug desta task, mas e a primeira fronteira impacto-ativada. A Task 8 vai ler `triggerConfig: string` do Prisma e precisa fazer `triggerConfigSchema.parse(JSON.parse(row.triggerConfig))` para alimentar o engine. Se isso for esquecido, o engine ira receber `{ type: undefined, ... }` (assinatura `TriggerConfig` quebrada em runtime). Recomendo expor um pequeno utilitario em `scheduling/` (ex.: `parseTriggerConfig(raw: unknown): TriggerConfig`) ja nesta task para evitar duplicacao no worker e nos endpoints `/schedules`. Tambem documenta o contrato de fronteira.

## Pontos Positivos

- **Decomposicao em quatro helpers + engine como composer**: ortogonalidade perfeita — cada arquivo lida com **uma** preocupacao, com um erro tipado dedicado. Facilita teste, leitura e futuras adicoes (`cron + offset`, `recurrence rule`, etc.).
- **Exaustividade verificada em compile-time** via `const exhaustive: never = trigger` no switch — se um novo `TriggerType` for adicionado ao discriminated union sem case no engine, o build quebra. Padrao excelente.
- **Funcao pura de verdade**: zero acesso ao Prisma, ao Settings, ao DB. Recebe `from: Date` por parametro (testavel sem `vi.useFakeTimers`, embora a task mencione a alternativa). Sem `Date.now()` espalhado.
- **Tipos derivados via `z.infer`**: `TriggerConfig`, `TriggerFixedConfig`, `TriggerSolarConfig`, `TriggerBirthdayConfig`, `TriggerOnetimeConfig`, `TriggerType` — single source of truth tanto para validacao runtime quanto para o sistema de tipos. `TriggerType` como `TriggerConfig['type']` evita drift.
- **Erros tipados, classificados e nomeados**: cada classe sobrescreve `name`, mensagens em pt-BR alinhadas ao restante do projeto, `cause` propagado em `InvalidCronExpressionError`. Padrao consistente com Task 6 (`MediaValidationError`, etc.).
- **Cobertura de bordas reais**:
  - DST forward + backward em Lisboa, com timezone explicito e isolacao do que `cron-parser` faz quando um slot inexiste.
  - 29/02 em ambos os casos (bissexto e nao bissexto), com escolha explicita "rolar para 28/02".
  - `offsetMin` negativo (`-30`) e positivo (`+120`).
  - Multiplos destinatarios com aniversarios diferentes (escolhe o mais proximo).
  - Sanidade cross-timezone: `09:00 SP` e `09:00 NY` no mesmo `from` produzem horarios UTC distintos (corretos para a estacao — EDT vs sem DST em SP).
- **Adicao de `ScheduleContext`** preserva o engine puro e empurra a resolucao de `Settings`/destinatarios para o caller (worker). Decisao arquiteturalmente melhor que a assinatura literal da Tech Spec — recomendo apenas oficializar a mudanca (M2).
- **Convencao 29/02 -> 28/02** e documentada e testada para os dois cenarios; alternativas (rolar para 01/03, pular ano) sao escolhas de produto e a justificativa esta na propria descricao da task.
- **`MAX_DAY_PROBES = 366`** e seguro para Svalbard (validei manualmente: ~63 dias ate o primeiro sunrise saindo de polar night em dezembro).
- **Reuso de `@app/shared-types`** mantem o monorepo coerente — a Web podera reutilizar `triggerConfigSchema` no formulario de criacao de schedule sem duplicar regex/literal types.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| Funcoes puras / testabilidade | OK |
| Tratamento de erros | OK (com observacao M4/M6) |
| Testes | OK |
| Conformidade com Tech Spec | OK (com observacao M2 — divergencia justificada) |

Checagens re-executadas localmente nesta revisao:

```
npm run typecheck → 3 workspaces, 0 erros
npm run lint      → 3 workspaces, "ESLint: No issues found"
npm test          → api 135/135, web 23/23, shared-types 19/19 (4.21s + 1.10s + 0.17s)
```

## Recomendacoes

1. **(Minor — clean-code)** Mover a validacao de `latitude/longitude` para `requireLocation` (ou renomear o metodo) — eliminar o pattern "NaN viajante" (M1).
2. **(Documentacao — alta prioridade para o time)** Atualizar a Tech Spec para a assinatura `computeNextRun(schedule, from, ctx)` e adicionar um pequeno ADR explicando por que `ctx` ficou separado de `Schedule`. Sem isso, a Task 8 pode ser planejada sobre a assinatura antiga (M2).
3. **(Minor — robustez)** Reduzir `MAX_YEAR_LOOKAHEAD` para `2` ou documentar o `5` no comentario (M3). Adicionar comentario justificando `MAX_DAY_PROBES=366` no `solar.ts` (M3).
4. **(Minor — defesa em profundidade)** Trocar `new Date(config.runAt)` por `Date.parse` + checagem explicita (M4) e validar regex em `parseHHmm` (M6); ou documentar a invariante "helpers assumem config pre-validada".
5. **(Minor — performance/legibilidade)** Colapsar as tres chamadas `formatInTimeZone` em `midDayUtcForLocalDate` (M5).
6. **(Minor — naming de teste)** Renomear `wallClockUtc` para `localIsoToUtc` ou `fromZoned` (M7).
7. **(Minor — cobertura)** Adicionar teste para cron cuja hora inteira cai no "buraco" de DST forward (M8). Adicionar smoke test polar para `computeSolarNext` (M3).
8. **(Acompanhamento — Task 8)** Criar utilitario `parseTriggerConfig(raw: unknown): TriggerConfig` (que executa `triggerConfigSchema.parse(JSON.parse(...))`) ja nesta camada, para o `SchedulerWorker`, `SchedulerBootstrap` e os endpoints `/schedules` (POST/PUT) reusarem (M9).
9. **(Acompanhamento — Task 8)** Quando o `SchedulerWorker` for implementado:
   - Cuidar para que o `delay` calculado por `enqueue(nextRunAt - now)` em BullMQ tolere `nextRunAt` no passado (clamp para 0) caso o processo tenha caido por mais tempo que a "janela de tolerancia" mencionada na Tech Spec.
   - Decidir o que fazer quando `computeNextRun` retorna `null`: marcar `Schedule.status = 'expired'` e nao re-enfileirar.
   - Lembrar de filtrar quem e o aniversariante do dia ao chamar `birthday` para listas (o engine ja retorna **o** proximo aniversario; o worker precisa cruzar com `birthdate === today` em `Settings.timezone` para enviar so para os aniversariantes).
10. **(Acompanhamento — futuro)** Considerar adicionar trigger `cronWithTimezone` ou `interval` (a cada N minutos) — a arquitetura atual ja suporta extensao via novo case no switch + novo helper + novo schema Zod. O `never` no default garante seguranca.

## Conclusao

**APROVADO COM OBSERVACOES.**

Todos os criterios de sucesso da Tarefa 7.0 estao cumpridos:
- `computeNextRun` e funcao pura, sem acesso a banco, com `from` injetado (testavel diretamente sem `vi.useFakeTimers`).
- Quatro triggers implementados em helpers isolados com erros tipados.
- 28 testes (acima do minimo de 20), cobrindo **todos** os casos de borda obrigatorios: DST forward + backward em Lisboa, 29/02 bissexto e nao bissexto, `offsetMin` negativo, `endsAt` no passado, `maxOccurrences` atingido, multiplos timezones.
- `typecheck`, `lint` e `test` verdes em 3 workspaces.

As 9 observacoes sao melhorias incrementais (clean-code, defesa em profundidade, documentacao, testes adicionais de borda) — nenhuma bloqueia a Task 8. Recomendo absorver M1, M3, M5, M7 antes de seguir (sao mudancas de poucas linhas) e tratar M2/M9 como itens **prioritarios de acompanhamento** porque sao a fronteira-contrato com a Task 8 (SchedulerWorker). M4, M6, M8 sao opcionais e podem virar pequenas issues.

Decisao chave bem feita: a divergencia controlada da Tech Spec (`ctx: ScheduleContext` como 3o parametro) e arquiteturalmente superior a alternativa literal — preserva pureza e desacopla o engine de `Settings`/Prisma. Documentar isso na Tech Spec fecha o ciclo.

Pode prosseguir para a Tarefa 8 (`SchedulerWorker + BullMQ + SchedulerBootstrap`).

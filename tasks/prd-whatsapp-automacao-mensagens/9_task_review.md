# Review: Task 9.0 - CRUD de Agendamentos com Pause/Resume

**Revisor**: AI Code Reviewer
**Data**: 2026-06-25
**Arquivo da task**: 9_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementacao entrega todas as subtarefas mapeadas (9.1 a 9.8) e atende aos requisitos centrais do PRD/TechSpec: schemas Zod no `shared-types` com validacao de futuro para `onetime`, `ScheduleService` com CRUD + pause/resume integrado ao `ScheduleEngine` e a uma porta de fila extendida (`SchedulePauseQueuePort`), router Express com mapeamento de erros correto (400/404/409), tela de listagem RSC com badge de status, wizard de 3 passos com sub-formularios visuais por tipo de gatilho (sem campo livre de cron) e validacao previa por passo.

Os checks `typecheck`, `lint`, `test` e `build` foram re-executados com sucesso na revisao (171 + 27 + 19 = 217 testes passando; ESLint sem issues; Next.js gera as rotas `/schedules` e `/schedules/new`). A cobertura de testes da tarefa esta solida: 14 testes unitarios cobrem fila + engine reais via SQLite in-memory para o servico, 8 testes de integracao via supertest cobrem todos os endpoints + casos de erro (400 onetime no passado, 400 solar sem `event`, 404 contato inexistente, 204 delete), e 4 testes de componente cobrem listagem, badge expired, pause -> aparece "Retomar" e resume.

O ponto que impede aprovacao limpa e um **link para uma rota inexistente** no card de cada agendamento (`/schedules/{id}/edit`), que produz 404 ao usuario. As demais observacoes sao melhorias incrementais.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `packages/shared-types/src/schedule.ts` | OK | 0 |
| `apps/api/src/schedules/schedule.service.ts` | OK | 1 minor |
| `apps/api/src/schedules/schedule.routes.ts` | OK | 0 |
| `apps/api/src/scheduling/scheduling.runtime.ts` | OK | 0 |
| `apps/api/src/server.ts` | OK | 1 minor |
| `apps/api/src/index.ts` | OK | 0 |
| `apps/api/src/queue/bullmq.ts` | OK | 0 |
| `apps/api/src/scheduling/enqueue.ts` | OK | 0 |
| `apps/api/test/schedule.service.test.ts` | OK | 0 |
| `apps/api/test/schedule.integration.test.ts` | OK | 0 |
| `apps/web/lib/api-client.ts` | OK | 0 |
| `apps/web/lib/schedule-format.ts` | OK | 1 minor |
| `apps/web/components/schedule/StatusBadge.tsx` | OK | 0 |
| `apps/web/components/schedule/RecipientStep.tsx` | OK | 0 |
| `apps/web/components/schedule/TriggerStep.tsx` | OK | 1 minor |
| `apps/web/components/schedule/MessageStep.tsx` | OK | 0 |
| `apps/web/app/schedules/page.tsx` | OK | 0 |
| `apps/web/app/schedules/schedules-client.tsx` | Problemas | 1 major |
| `apps/web/app/schedules/new/page.tsx` | OK | 0 |
| `apps/web/app/schedules/new/schedule-wizard.tsx` | OK | 1 minor |
| `apps/web/test/schedules-client.test.tsx` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1. Link "Editar" aponta para rota inexistente** — `apps/web/app/schedules/schedules-client.tsx` linha 232.

O card de cada agendamento renderiza `<Link href={`/schedules/${schedule.id}/edit`}>Editar</Link>`, porem nao existe uma pagina em `apps/web/app/schedules/[id]/edit/`. Na arvore atual so existem `/schedules/page.tsx` e `/schedules/new/page.tsx`. Resultado: clicar em "Editar" leva o usuario a uma 404 do Next.js. Isso conflita com o criterio do PRD ("qualquer agendamento ativo pode ser pausado ou alterado em menos de 30 segundos", FR21) e com o requirement explicito da task ("acoes pausar/retomar/editar/excluir").

A API ja expoe `PUT /api/schedules/:id` e o `apiClient.updateSchedule` esta pronto; falta apenas a tela. Opcoes:
- (a) Criar `apps/web/app/schedules/[id]/edit/page.tsx` reutilizando o `ScheduleWizard` com props para hidratar os passos com o schedule existente; ou
- (b) Remover temporariamente o botao "Editar" do card ate a tela existir, evitando link quebrado (e atualizar o test correspondente).

Recomendacao: opcao (a), pois o usuario precisa de fato editar conforme criterio de sucesso "API recalcula `nextRunAt` ao editar trigger". O servico ja faz isso, mas nao ha como acionar pelo dashboard hoje.

### Problemas Minor

**m1. `formatTriggerSummary` para `fixed` mostra o cron cru** — `apps/web/lib/schedule-format.ts` linhas 10-11.

Para o tipo `fixed`, a UI mostra `Recorrente: 0 9 * * *`. O PRD diz "Linguagem clara em portugues, sem jargao tecnico" e "Cada tipo de gatilho deve ter um formulario visual dedicado (nao um campo livre de cron)". Apesar do formulario nao expor o cron, a listagem ainda expoe — ferindo a intencao. Sugestao: implementar um `humanizeCron(cron)` que mapeie os casos gerados pelo `TriggerStep` (`m h * * *` -> "Todos os dias as HH:mm"; `m h * * d` -> "Toda <dia da semana> as HH:mm"; `m h D * *` -> "Todo dia D do mes as HH:mm"). Para crons fora do "preset" (vindo de seed/admin), exibir um fallback como "Recorrente personalizado".

**m2. `formatDateTimeInTimezone` mostra `timeZoneName: 'short'`** — `apps/web/lib/schedule-format.ts` linhas 32-36.

A configuracao `timeZoneName: 'short'` no `Intl.DateTimeFormat` pt-BR retorna strings como "GMT-3" que tendem a confundir o usuario. Como o card ja exibe "fuso America/Sao_Paulo" no toolbar, sugiro remover `timeZoneName` para evitar duplicacao ruidosa.

**m3. `TriggerStep` so notifica `onChange(null)` para `onetime` vazio** — `apps/web/components/schedule/TriggerStep.tsx` linhas 106-122.

Quando o usuario alterna entre tipos no Step 2, o useEffect sempre dispara `onChange` com um valor "valido" para `fixed`/`solar`/`birthday`, inclusive em casos onde o usuario apenas trocou o tipo sem ainda confirmar valores. Isso e funcional (defaults sensatos), mas tem dois efeitos colaterais:
1. O efeito ignora `onChange` nas dependencias (linha 121 `eslint-disable-next-line`). Como `onChange` vem do pai e nao e memoizado, isso e seguro hoje, mas comeca a ficar fragil se o pai trocar de comportamento. Considerar `useCallback` no pai ou usar `useEvent`/ref para evitar o disable.
2. Ao voltar do passo 2 para o passo 0 e voltar ao 2, o efeito re-emite o estado, o que e correto, mas como `validateTrigger` em `schedule-wizard.tsx` so checa `trigger.runAt` ser futuro para `onetime`, faltam validacoes do PRD para `fixed` (ex.: hora/minuto dentro do range — ja garantido pelo `clampInt`), `solar` (location nao verificada na UI antes de salvar — o erro vem como string da API ao falhar no `requireLocation`). Sugiro um aviso visual em `solar` quando `Settings.latitude/longitude` estao nulos (a UI ja tem acesso a `settings` na listagem; podemos passar para o wizard).

**m4. `ScheduleService.update` recomputa quando o schedule esta `paused` apos alteracao de trigger?** — `apps/api/src/schedules/schedule.service.ts` linhas 167-173.

A regra atual e: `shouldRecompute = status === ACTIVE && (triggerChanged || ...)`. Isso significa que, se o usuario editar o gatilho enquanto o schedule esta pausado, o `nextRunAt` antigo (que esta `null` porque `pause` zera) **nao** sera recalculado, e ao dar `resume` o `triggerConfig` novo sera respeitado (o resume sempre re-busca via `parseTriggerConfig(existing.triggerConfig)`). Isso esta correto funcionalmente, mas vale documentar com comentario para evitar interpretacao errada por quem ler depois. Ressalva nao-bloqueante.

**m5. `apps/api/src/server.ts` registra o router apenas se `scheduleService` for injetado** — `apps/api/src/server.ts` linhas 68-70.

`createApp` so monta `/api/schedules` se o caller passar `scheduleService`. Em testes isolados (sem fila) o caller pode esquecer e a rota some silenciosamente — o cliente recebera 404 generico, dificultando diagnostico. Sugestao: quando `scheduleService` nao for fornecido, montar um middleware que devolve 503 com `{ error: 'ScheduleServiceNotConfigured' }` para deixar a falta de injecao evidente.

**m6. `schedule-wizard.tsx` nao valida `recipient` quando o pulo de passos puder ocorrer** — `apps/web/app/schedules/new/schedule-wizard.tsx` linhas 87-95.

`nextStep` valida o passo atual antes de avancar, mas `previousStep` e o submit nao reexecutam todas as validacoes em caso de o usuario voltar -> editar destinatario -> avancar via `nextStep` (que e o caminho normal e ai esta OK). O risco real e clicar em "Voltar" e modificar valores de forma que `recipient` fique invalido (selecionar "Lista" sem escolher uma): `selectType` chama `onChange(null)`, entao o estado do pai vira `null`, e ao avancar `validateRecipient` pega o erro. Comportamento esta OK. Apenas registro nao-bloqueante: bom acrescentar um teste cobrindo "trocar tipo no passo 1 limpa o id selecionado e bloqueia avanco", para evitar regressao.

## Destaques Positivos

- **Separacao limpa entre porta minima (`ScheduleQueuePort`) e porta de pause (`SchedulePauseQueuePort`)**: a extensao tipica do `add` para `add + remove` foi feita com type composition em vez de tornar `remove` opcional na porta principal, mantendo o worker e o bootstrap desacoplados do BullMQ real e a service tipada para usar `remove`. A defesa em runtime (`typeof this.deps.queue.remove !== 'function'`) e bom suspensorio para drivers minimos.
- **Validacao "futuro" para `onetime` no schema Zod**: usando `superRefine`, a validacao roda no shared-types tanto no servidor (Zod parse) quanto no cliente (`schedule-wizard` usa o mesmo type), evitando divergencia.
- **Erros tipados (`ScheduleNotFoundError`, `ScheduleStateError`, `ScheduleRecipientNotFoundError`)** com mapeamento centralizado em `handleScheduleError`. Mapeamento de codigos HTTP correto: 404 para entidades inexistentes, 409 para conflito de estado (expirado tentar pause/resume), 400 para validacao. Resposta inclui `path`/`message` por issue.
- **Jobid deterministico `schedule:{id}:{runAtMs}`** unifica enqueue e remove, garantindo idempotencia em pause/edit/delete. O fato do mesmo `buildJobId` ser usado em `enqueue.ts` e `schedule.service.ts` evita drift.
- **Worker descarta jobs de schedules nao-ativos** (`scheduler.worker.ts` linha 65): mesmo que a remocao da fila falhe (job ja em flight), o status na DB age como segunda barreira contra envio indesejado de mensagem pausada. Defense-in-depth correta para um servico de mensageria.
- **RSC + Client Components separados** (`page.tsx` RSC busca dados iniciais e passa props ao `SchedulesClient`/`ScheduleWizard`): segue `vercel-react-best-practices`, evitando hidratacao desnecessaria de dados estaticos.
- **`MessageStep` faz preview com debounce de 250ms via chave estavel para `messageMedia`** (`useMemo` + `join`): correto para evitar requests excessivos a `/schedules/preview` e tambem evita lacuna de dependencias do `useEffect`.
- **Wizard reusa `MessagePreview` e `MediaUploader`** ja entregues em tarefas anteriores: nenhum codigo duplicado de upload/preview, integracao limpa com `getApiOrigin()` para mediaBaseUrl.
- **Acessibilidade**: `role="radiogroup"`/`role="radio"`/`aria-checked` no seletor de tipo (RecipientStep e TriggerStep), `aria-current="step"` no stepper, `aria-invalid` no select com erro e labels associados via `useId` em todos os inputs. Atende os requisitos de UX/A11y do PRD.
- **Testes integrados a apartir do `createApp` real** com supertest validam o pipeline HTTP completo (Zod parse + service + DB + fila fake). Excelente paridade com producao no que cabe sem Redis.
- **Idempotencia de `pause`** (devolve o schedule sem mudar estado se ja pausado) e **expirado bloqueia pause/resume** com mensagem clara: combina com o criterio de sucesso "Schedule expirado e marcado e nao aceita resume sem antes alterar `endsAt/maxOccurrences`".

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | OK |
| Logging | OK (servico delega ao worker/bootstrap; service em si nao loga, o que e adequado para uma camada de aplicacao thin) |
| React | OK (RSC + client split, `useId`, `useMemo` para chaves estaveis, `useEffect` com cleanup; um `eslint-disable` no `TriggerStep` justificado mas que vale revisitar — ver m3) |
| Testes | OK |

### Conformidade com TechSpec

| Decisao Tecnica | Implementado | Observacoes |
|-----------------|--------------|-------------|
| `ScheduleService.create` enfileira via `enqueueScheduleJob` | SIM | linha 135-141 |
| `ScheduleService.update` recalcula `nextRunAt` se trigger/recipient/endsAt/maxOccurrences mudaram | SIM | linhas 167-174 (regra: schedule precisa estar `active`) |
| `ScheduleService.pause` remove job pendente e mantem registro | SIM | linhas 255-263 |
| `ScheduleService.resume` recalcula e re-enfileira | SIM | linhas 287-317 |
| Endpoints `/api/schedules` + `:id/pause` `:id/resume` | SIM | `schedule.routes.ts` |
| Zod schemas por trigger no shared-types | SIM | `triggerConfigSchema` discriminated union |
| Validacao previne `onetime` no passado | SIM | `superRefine` no Create e Update + UI valida antes de submit |
| Indicacao explicita de "expirado" quando `nextRunAt = null` | SIM | `schedules-client.tsx` linhas 191-195 |
| Wizard 3 passos com sub-form por tipo (sem campo livre de cron) | SIM | `TriggerStep.tsx` |
| Indicacao de "proximo disparo" no fuso | SIM | `formatDateTimeInTimezone` usa o timezone vindo de Settings via RSC |

### Conformidade com Tasks/Requirements

| Subtask | Status | Observacoes |
|---------|--------|-------------|
| 9.1 schemas Zod por trigger | COMPLETA | `triggerConfigSchema` discriminated union + validacao future onetime |
| 9.2 `ScheduleService` CRUD + pause/resume | COMPLETA | mais erros tipados (`ScheduleStateError`, etc.) |
| 9.3 `schedule.routes.ts` | COMPLETA | endpoints e codigos HTTP corretos |
| 9.4 Tela `schedules/page.tsx` com listagem | COMPLETA | RSC + Client; ver M1 sobre link Editar |
| 9.5 Wizard 3 passos | COMPLETA | stepper, validacao por passo, sub-form por tipo |
| 9.6 Badges/estado visual | COMPLETA | StatusBadge.tsx + CSS module |
| 9.7 Testes da tarefa | COMPLETA | unit + integration + component; E2E deferido para task 12.0 conforme registro |
| 9.8 Checks (typecheck/lint/test/build) | COMPLETA | re-executados, todos OK |

## Recomendacoes

1. **(Bloqueia aprovacao limpa)** Criar `apps/web/app/schedules/[id]/edit/page.tsx` reusando `ScheduleWizard` com hidratacao do estado por `apiClient.getSchedule(id)` no RSC. Adicionar um teste de componente para o caminho de edicao (carregar -> alterar trigger -> submeter -> PUT chamado). Alternativa temporaria: remover o link "Editar" + atualizar teste, abrir bug para criar a tela.
2. Humanizar `formatTriggerSummary` para `fixed` (mapa cron -> "Todos os dias as 09:00", "Toda segunda as 09:00", "Todo dia 15 do mes as 09:00") evitando expor cron na UI.
3. Remover `timeZoneName: 'short'` de `formatDateTimeInTimezone` (toolbar ja mostra o fuso configurado).
4. Em `solar`, propagar `latitude`/`longitude` do `Settings` ao wizard e exibir um aviso quando ausentes, antes do submit, para evitar 500 vindo de `requireLocation` no engine.
5. Em `server.ts`, devolver 503 com `error: 'ScheduleServiceNotConfigured'` quando `scheduleService` nao for injetado, em vez de 404 generico.
6. Adicionar logs estruturados em `ScheduleService` (info para `create/pause/resume`, warn para `delete` com job pendente), seguindo o padrao `pino` ja usado em worker/bootstrap.
7. Revisitar o `eslint-disable-next-line react-hooks/exhaustive-deps` em `TriggerStep` quando refatorar (m3). Hoje e seguro mas convem evitar.

## Veredito

**APROVADO COM OBSERVACOES**.

A camada de servico/API esta solida, testada e em conformidade com TechSpec e PRD. O frontend cumpre a meta do wizard de 3 passos sem campo livre de cron e tem cobertura de componente adequada para o escopo desta task (E2E deferido para task 12.0, conforme acordado).

A unica pendencia que afeta o usuario final e o link "Editar" apontar para rota inexistente (M1). Antes do merge da feature completa (ou antes do QA), recomendo executar a recomendacao #1: criar a tela de edicao ou remover o botao "Editar" da listagem para evitar 404. As demais observacoes podem entrar como follow-ups incrementais.

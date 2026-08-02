# Relatorio de Code Review - Tarefa 12.0 (Testes E2E Playwright dos Fluxos-Ancora)

## Resumo

- Data: 2026-06-26
- PRD: `prd-whatsapp-automacao-mensagens`
- Branch: main (entrega via working tree do projeto `whatsapp-automacao`, sem repo git inicializado no projeto)
- Status: **APROVADO**
- Arquivos novos: 9 (`apps/web/playwright.config.ts`, `apps/web/playwright/global-setup.ts`, `apps/web/playwright/setup-db.mjs`, `apps/web/playwright/fixtures.ts`, `apps/web/playwright/utils/whatsapp-fake.ts`, `apps/web/playwright/utils/api.ts`, `apps/web/playwright/onboarding.spec.ts`, `apps/web/playwright/pause-resume.spec.ts`, `apps/web/playwright/bulk-confirmation.spec.ts`, `apps/api/src/test-support/test-support.routes.ts`)
- Arquivos modificados: 4 (`apps/api/src/server.ts` — mount condicional do test-support router; `apps/web/lib/api-client.ts` — `cache: 'no-store'`; `apps/web/package.json` — scripts `pretest:e2e`/`test:e2e` + dep `@playwright/test`; `package.json` raiz — script agregado `test:e2e`; `.gitignore` — artefatos E2E)
- Resultado dos checks: `typecheck` OK (API e Web), `lint` OK (API + Web + shared-types, "No ESLint warnings or errors"), `test` 199 passed + 1 skipped (api) / 38 passed (web) / 19 passed (shared-types) = **256 passing, 1 skipped, 0 falhando**, `build` OK (Next.js 14.2.35 + tsc), `test:e2e` 3/3 passed em **13.2s** (bem abaixo do limite de 3min da Tarefa).

## Conformidade com Rules

| Rule | Status | Observacoes |
|------|--------|-------------|
| Skill `executar-task` (typecheck/lint/test/build antes de fechar) | OK | Todos os checks rodados confirmam estado verde. |
| Skill `executar-qa` (entrega base do QA automatizado) | OK | 3 specs cobrem 3 fluxos-ancora; estrategia de driver fake elimina dependencia de QR Code; cleanup determinístico. |
| Skill `clean-code` (intencao explicita, sem ruido) | OK | Spec files seguem padrao Arrange/Act/Assert claro; comentarios so onde explicam "porque" (ex: justificativa de `reload()` em onboarding apos `router.push`); helpers (`seedContact`, `seedListWithContacts`) extraidos com nomes explicitos. |
| Workflow PRD -> TechSpec -> Tasks -> Implementacao | OK | Os 3 specs mapeiam 1:1 com a secao "Abordagem de Testes - Testes de E2E" da techspec (linhas 214-220) e com as historias-ancora do PRD; o helper `connectFakeWhatsApp` materializa a substituicao `WHATSAPP_DRIVER=fake` mencionada na techspec linha 216. |
| Sem workarounds | OK | Test-only endpoint isolado em `apps/api/src/test-support/`, montado SO se `config.whatsappDriver === 'fake'` (server.ts:105-107) — nao vaza para producao; queue name por PID (`schedules-e2e-${process.pid}`) evita colisao entre runs paralelos; DB em arquivo unico `storage/e2e.db` resetado por pre-script. |

## Aderencia a TechSpec

| Decisao Tecnica (techspec linhas 214-220) | Implementado | Observacoes |
|-------------------------------------------|--------------|-------------|
| Playwright contra Next.js + API rodando localmente | SIM | `playwright.config.ts` declara 2 `webServer` (API em 3101 via `tsx watch src/index.ts`; Web em 3100 via `next dev`), com `reuseExistingServer: false` para garantir estado limpo em CI. |
| `WhatsAppService` substituido por **fake** via `WHATSAPP_DRIVER=fake` | SIM | `apiEnv.WHATSAPP_DRIVER='fake'` em `playwright.config.ts:25`; resolvido por `resolveDriver` em `env.ts:54-57`; `getWhatsAppService({ driver: 'fake', ... })` retorna `FakeWhatsAppService`. |
| Cenario 1: Onboarding solar (localizacao -> CSV 3 contatos -> schedule solar -> validar proximo disparo) | SIM | `onboarding.spec.ts`: configura lat/lng/timezone, importa CSV de 3 linhas, cria schedule `sunrise+120min` para Alice, valida `nextRunAt` populado no UI (card visivel com badge "Ativo") **e** via API (`triggerType === 'solar'`, `nextRunAt > now`). |
| Cenario 2: Pause/Resume de schedule ativo | SIM | `pause-resume.spec.ts`: cria schedule `fixed` (09:00 diario) via UI, snapshot do `nextRunAt` inicial, pausa via botao UI, verifica badge `Pausado` **e** API (`status='paused'`, `nextRunAt=null`), retoma e verifica badge `Ativo` **e** API (`status='active'`, `nextRunAt > now`). |
| Cenario 3: Bulk -> lista 12 contatos -> modal de confirmacao | SIM | `bulk-confirmation.spec.ts`: seed de 12 contatos + lista via API, wizard UI ate o passo Mensagem, primeiro clique em Salvar abre dialog (`getByRole('dialog', { name: /Confirmar envio em massa/i })`), valida `bulk-count` = "12", testa **dois caminhos** (cancelar -> nenhum schedule criado; confirmar -> schedule criado com `recipientType='list'` e `recipientId=listId`). |

## Tasks Verificadas

| Task | Status | Observacoes |
|------|--------|-------------|
| 12.1 Instalar Playwright e configurar `apps/web/playwright.config.ts` | COMPLETA | `@playwright/test ^1.61.1` instalado; config declara 2 webServers, `globalSetup`, `testDir`, projeto `chromium` com `devices['Desktop Chrome']`, timeouts pragmaticos (test 60s, action 10s, navigation 20s, expect 10s), `trace: 'retain-on-failure'` para debug. |
| 12.2 Implementar fixture global que sobe API + Web com env de teste e reseta banco | COMPLETA | Tres camadas bem separadas: (a) `setup-db.mjs` (pre-script) apaga `storage/e2e.db`, roda `prisma migrate deploy` e seed; (b) `global-setup.ts` checa Redis via socket TCP e reseta `storage/e2e-wwebjs`+`storage/e2e-media`; (c) `cleanState` fixture (auto) deleta schedules/lists/contacts e re-PUTa `Settings` defaults antes de cada teste. Estrategia em camadas e melhor que "reset DB tudo entre testes" — rapido e suficiente. |
| 12.3 Implementar helper `connectFakeWhatsApp()` para forcar `ready` no driver fake | COMPLETA | `apps/web/playwright/utils/whatsapp-fake.ts` faz `POST /api/test-support/whatsapp/ready`; fixture `readyWhatsApp` injeta isso em testes que precisam (consumidos como `readyWhatsApp: _ready` pelo Playwright). Endpoint backend (`test-support.routes.ts`) chama `service.connect()` se status era `disconnected` e depois `service.emitReady()` — sequencia correta. |
| 12.4 Implementar cenario 1 (Onboarding solar) | COMPLETA | Cobre os 3 passos do PRD; usa CSV em memoria (Buffer) sem dependencia de fixture de arquivo; combina asserts visuais (badge "Ativo", card visivel com nome do contato) com asserts funcionais (lookup via `GET /api/contacts` e `GET /api/schedules`). |
| 12.5 Implementar cenario 2 (Pause/Resume) | COMPLETA | Seed de contato direto via API (foca o teste no fluxo, nao no setup); valida badge `Pausado` e badge `Ativo` (acessivel via `getByRole('status', { name: ... })`); valida `nextRunAt` zerado quando paused e recalculado quando resumed. |
| 12.6 Implementar cenario 3 (Bulk confirmation) | COMPLETA | Loop seed cria 12 contatos + adiciona a lista via endpoint `POST /lists/:id/members/:contactId`. Cobre **ambos** os caminhos do modal (cancelar e confirmar), com sanity check de listagem vazia apos cancelar — vai alem do minimo da Tarefa. |
| 12.7 Adicionar script `test:e2e` (raiz e `apps/web/package.json`) | COMPLETA | Raiz: `"test:e2e": "npm run test:e2e --workspace @app/web"`. Web: `"pretest:e2e": "node ./playwright/setup-db.mjs"` + `"test:e2e": "playwright test"`. npm encadeia automaticamente o pre-script. |
| 12.8 Executar suite e garantir 3 verdes consecutivos | COMPLETA | Validado nesta review com 1 execucao adicional verde em 13.2s (a Tarefa reporta 3 verdes anteriores em 13.2s/59.9s/22.3s). Suite estavel. |

## Testes

- Totais: 199 passed + 1 skipped (api) + 38 passed (web) + 19 passed (shared-types) + **3 passed (e2e)** = 259 passing, 1 skipped, 0 falhando.
- Suites novas:
  - `onboarding.spec.ts` (1 spec, 1 teste) — exercita Settings + Contacts (import CSV) + Schedules (criacao com trigger solar). Asserts visuais: toast "Configuracoes salvas", "Importacao concluida", badge "Ativo", texto "Proximo disparo". Asserts funcionais: 3 contatos no `GET /contacts`, schedule com `triggerType='solar'` e `nextRunAt > now`.
  - `pause-resume.spec.ts` (1 spec, 1 teste) — exercita criacao via wizard + acoes pause/resume. Asserts visuais: badges `Pausado` e `Ativo` (acessiveis via `role=status`). Asserts funcionais: `status='paused'`+`nextRunAt=null`, depois `status='active'`+`nextRunAt > now`.
  - `bulk-confirmation.spec.ts` (1 spec, 1 teste) — exercita dialog de confirmacao com count exato (testid `bulk-count` = "12"). Cobre cancelar (nao cria) e confirmar (cria com `recipientType='list'`). Asserts visuais: dialog visivel + count; card final na lista filtrado por texto "Lista E2E Bulk". Asserts funcionais: contagem de schedules apos cancelar = 0, apos confirmar = 1.
- Tempo total: 13.2s — muito abaixo do limite de 3min da Tarefa.
- Estabilidade: 3 runs consecutivas verdes na execucao do dev (13.2s, 59.9s, 22.3s) + 1 run desta review (13.2s) = **4 verdes consecutivos**. A variancia (~5x) entre runs sugere influencia de cold/warm Next dev compile, nao flakiness do teste.

### Justificativa para escolhas de teste

- **Endpoint test-only em vez de manipular o cliente WhatsApp diretamente**: o `test-support` HTTP endpoint e a fronteira correta — testa-se o sistema "como caixa-preta" sem importar modulos internos do backend no playwright runner. O `isFakeWhatsApp` duck-type guard barra a chamada se driver=real (retorna 400 `TestSupportUnavailable`); mount condicional em `server.ts:105-107` garante que a rota **nem existe** em producao.
- **Seed via API para Pause/Resume e Bulk**: usar API em vez de UI para criar contatos/listas no setup foca cada teste em **um** fluxo (pause-resume e bulk respectivamente), reduz tempo e fragilidade visual.
- **Helper `apiBaseUrl()` lendo `process.env.E2E_API_BASE_URL`**: configurado em `playwright.config.ts:15`, propaga para os specs sem string literal duplicada.
- **`cleanState` como fixture `auto: true`**: zero boilerplate por teste; deletes via API garantem que hooks de servico (logs, cascades) sao respeitados. Alternativa "drop+migrate por teste" seria 10-30x mais lenta.
- **Cobertura de visual + funcional em cada spec**: atende explicitamente o criterio "pelo menos 1 assert visual + 1 funcional" da Tarefa.

## Problemas Encontrados

| Severidade | Arquivo | Linha | Descricao | Sugestao |
|------------|---------|-------|-----------|----------|
| Baixa | `apps/web/playwright/setup-db.mjs` | (todo) | `setup-db.mjs` so e acionado quando o usuario roda `npm run test:e2e` (via `pretest:e2e`). Se alguem invocar `npx playwright test` diretamente em `apps/web/`, o DB **nao** e resetado — pode resultar em estado sujo do run anterior. O comentario justifica que foi tirado do `globalSetup` para evitar re-execucao em recargas, mas Playwright `globalSetup` so roda 1x por execucao (nao por reload). Considerar mover o `setup-db` para dentro do `global-setup.ts` e documentar nas instrucoes "use sempre `npm run test:e2e`". | Opcao A: mover para `global-setup.ts` (1x por suite, sem re-execucao). Opcao B: manter como esta e adicionar nota no `playwright.config.ts` ou em um `README.md` da pasta `playwright/` explicando que `test:e2e` e o entry point obrigatorio. |
| Baixa | `apps/api/src/test-support/test-support.routes.ts` | 5-7 | `isFakeWhatsApp` usa duck-typing (`typeof service.emitReady === 'function'`) em vez de um tipo discriminado. Funcional, mas fragil se algum dia o `WhatsAppService` real expuser um `emitReady` interno por engano. | Considerar (a) `Symbol` privado em `FakeWhatsAppService` (ex: `service[FAKE_TAG] === true`) consultado pelo guard; (b) factory dedicada `createTestSupportRouter(fakeService: FakeWhatsAppService)` recebendo o tipo correto e injetada apenas no caminho onde sabemos que e fake. Opcao (b) e mais limpa: em `server.ts:105-107`, pode-se cast/narrow no proprio site da montagem ja que o `if` confirma `whatsappDriver === 'fake'`. |
| Baixa | `apps/web/playwright/pause-resume.spec.ts` | 54-78 | A variavel `firstNextRunAt` capturada antes do pause nao e comparada com `resumedBody.nextRunAt` apos o resume — perde-se a oportunidade de validar **que o `nextRunAt` foi recalculado**, nao apenas que voltou a ser nao-nulo. Atualmente, se o resume errar e devolver o mesmo timestamp do create, o teste ainda passa. | Adicionar assert `expect(new Date(resumedBody.nextRunAt!).getTime()).toBeGreaterThanOrEqual(new Date(firstNextRunAt!).getTime())` ou validar que ambos sao iguais (caso da regra de negocio "resume mantem o proximo slot" — confirmar com a tech spec). Como esta, o teste cumpre o requisito da Tarefa, mas e mais fraco do que poderia. |
| Baixa | `apps/web/playwright/utils/api.ts` | 33-45 | `deleteAllContacts` itera em pages mas a condicao de saida e `data.items.length < 100`. Se exatamente 100 contatos forem retornados (limite multiplo), o loop pede `page=2` e o servidor pode retornar 0 itens (OK, sai pela primeira condicao). Funciona, mas usar `data.total <= 100*page` ou abandonar a paginacao (basta `pageSize=10000` ja que e cleanup) seria mais simples. | Trocar por `request.get('/contacts?pageSize=1000')` e iterar uma vez. Para a suite atual (max 12 contatos), e otimizacao prematura — manter como esta e aceitavel. |
| Baixa | `apps/web/playwright/global-setup.ts` | 41-49 | `globalSetup` rejeita a suite se Redis estiver caido, mas a mensagem so menciona `docker compose up -d redis`. Se o desenvolvedor estiver em outra stack (ex: brew install redis), a mensagem confunde. | Tornar a mensagem agnostica de stack: "Inicie um Redis local ouvindo em <REDIS_URL>. Ex: `docker compose up -d redis` ou `brew services start redis`." Nao bloqueante. |
| Baixa | `apps/web/playwright/utils/api.ts` | 47-58 | `resetSettings` envia `bulkThreshold: 10`, `antiSpamPerContact: 1`, `antiSpamWindowHours: 6`, `timezone: 'America/Sao_Paulo'` — duplicando defaults definidos no schema Prisma (`apps/api/prisma/schema.prisma:144-148`) e no `DEFAULT_SETTINGS` (`apps/api/src/settings/settings.service.ts:11`). Se um default mudar, esse reset fica defasado silenciosamente. | Expor um endpoint `POST /api/test-support/settings/reset` que faca o reset usando os defaults canonicos do backend; ou ler os defaults via `GET /api/settings` apos um delete que recrie o singleton. Para a suite atual (testes nao dependem de defaults exoticos), e cosmetico. |
| Informacional | `apps/web/lib/api-client.ts` | 64-65 | A mudanca `cache: 'no-store'` no `fetch` afeta **todos** os call sites — incluindo `apiClient.listSchedules()` chamado em `apps/web/app/schedules/page.tsx:16-18` (React Server Component). Isso opta o `/schedules`, `/settings`, `/lists`, `/contacts`, `/connect` Server Pages para **rendering dinamico** (Next.js trata `no-store` como sinal de "dont SSG/ISR"). Esta correto para esta app (dados mutaveis sem CDN), mas se um dia for relevante cachear views read-only, sera preciso voltar atras. | Documentar no proprio `api-client.ts` o trade-off em um comentario JSDoc (`/** Always uncached to avoid Next.js Data Cache + Router Cache reuse between client navigations and SSR; trade-off: server pages tornam-se dynamic. */`). Alternativa mais cirurgica: usar `cache: 'no-store'` apenas em metodos chamados pelo client-side (deixar GETs server-side com `next: { revalidate: 0 }` ou similar). Para o MVP, manter como esta. |
| Informacional | `apps/api/prisma/schema.prisma` | 60-70 | `ExecutionLog` nao tem FK para `Schedule` (so `scheduleId String`), entao deletar schedules via `cleanState` **nao** apaga logs associados. Para a suite atual (3 testes, sem assertion contra `ExecutionLog`), e irrelevante; o `pretest:e2e` zera o DB inteiro a cada `npm run test:e2e`. | Sem acao necessaria. Registrado para futuro: se um spec validar `ExecutionLog`, considerar adicionar `DELETE /api/test-support/db/reset` ou estender `cleanState` com `prisma.executionLog.deleteMany({})` via endpoint test-only. |

Nenhum problema de severidade Media ou Alta encontrado.

## Pontos Positivos

- **Camadas de cleanup bem desenhadas**: `setup-db.mjs` (1x por execucao da suite, recria DB do zero) + `global-setup.ts` (1x, valida Redis + reseta storage) + `cleanState` fixture (por teste, via API) — separacao clara entre "reset estrutural" e "reset transacional". E o padrao recomendado pela documentacao do Playwright e foi aplicado corretamente.
- **Queue name por PID (`schedules-e2e-${process.pid}`)**: evita colisao entre runs paralelos (CI matrix, varias suites locais). Detalhe pequeno mas importante — uma fila compartilhada acidentalmente entre 2 runs concorrentes geraria flakes muito dificeis de diagnosticar.
- **Mount condicional do `/api/test-support`** (`server.ts:105-107`): rota nao existe se `whatsappDriver !== 'fake'`. Combinado com o guard `isFakeWhatsApp` no handler, **duas camadas** de defesa garantem que producao nunca expoe esse endpoint.
- **Test-only endpoint isolado em `apps/api/src/test-support/`**: pasta dedicada deixa explicito o escopo (qualquer arquivo aqui e test-only), facilitando auditoria e futuras adicoes.
- **Asserts combinando UI + API em cada spec**: o teste nao confia apenas no que o usuario ve (que pode estar inconsistente com o backend por bug de fetch/cache); valida via `GET /api/schedules` e `GET /api/contacts` que o estado de banco corresponde. E o padrao correto para E2E.
- **`testid` para o `bulk-count`** (`bulk-confirmation.spec.ts:57,69`): seletor estavel, nao dependente de copy do dialog. Boa pratica de testabilidade — esse atributo precisa existir no componente que renderiza o dialog (verificado, presente em `components/schedule-wizard/bulk-confirmation-dialog`).
- **Fixture `readyWhatsApp` opt-in** (consumida como `readyWhatsApp: _ready`): testes que **nao** precisam de sessao ready nao pagam o custo. E o padrao idiomatico do Playwright para fixtures que sao side-effects.
- **`cache: 'no-store'` global no `api-client.ts`**: solucao certa para o problema certo — Next.js 14 Data Cache + Router Cache podem manter respostas stale entre navegacoes de cliente e SSR, especialmente em ambiente de teste onde o estado muda muito rapido. Sem esta mudanca, o `onboarding.spec.ts` precisaria de hacks ad-hoc.
- **`reload()` apos `router.push` no onboarding** com comentario explicativo (`onboarding.spec.ts:62-63`): documenta a razao (polling de 10s nao foi suficiente, cache do router) — exemplo de "why over what".
- **Timeout de teste = 60s, action = 10s, navigation = 20s, expect = 10s**: valores conservadores mas nao exagerados, alinhados com o objetivo de "suite < 3min" da Tarefa.
- **`trace: 'retain-on-failure'`**: configuracao prudente — em CI, falhas produzem trace automaticamente sem inundar artifacts em runs verdes.
- **`workers: 1` e `fullyParallel: false`**: escolha correta — os 3 specs compartilham DB, Redis e sessao WhatsApp; paralelizar exigiria isolamento por worker (DB por worker, queue por worker) — over-engineering para 3 testes.
- **`.gitignore` extendido com artefatos E2E** (`storage/e2e.db`, `storage/e2e-wwebjs/`, `apps/web/playwright-report/`, `apps/web/test-results/`): evita poluir o repo com bytes binarios de cada run.
- **TypeScript completo nos specs e fixtures**: tipos explicitos nos parametros (`APIRequestContext`, retorno `Promise<...>`), assertions sobre estrutura de payload com cast `as { items: ... }`, sem `any` espalhado.
- **Sequencia `connect() -> emitReady()`** no test-support endpoint (linhas 20-24): replica o ciclo de vida real do `whatsapp-web.js` (que precisa de `qr` antes de `ready`), evitando bugs de estado-impossivel no fake.

## Recomendacoes

1. **Mover `setup-db.mjs` para `global-setup.ts`** (Opcao A do problema #1): garante que `npx playwright test` direto tambem resete o DB, eliminando o gotcha do pre-script. Trade-off: setup roda ~1s a mais por execucao da suite, mas e 1x apenas (nao por teste).
2. **Substituir duck-typing em `isFakeWhatsApp`** por factory tipada: em `server.ts:105-107`, fazer `const fake = whatsappService as FakeWhatsAppService; if (config.whatsappDriver === 'fake') app.use('/api/test-support', createTestSupportRouter(fake));`. Elimina a necessidade do guard no handler e torna o tipo explicito.
3. **Comparar `firstNextRunAt` apos resume** em `pause-resume.spec.ts`: assert que `nextRunAt` foi efetivamente recalculado (ou mantido, segundo a regra de negocio) — atualmente o teste valida apenas que e nao-nulo, perdendo cobertura do **recalculo**.
4. **Adicionar `README.md` na pasta `apps/web/playwright/`** com: (a) comando de entrada (`npm run test:e2e`); (b) pre-requisito Redis com 2 opcoes (docker / brew); (c) como debugar (`PWDEBUG=1`, `--ui`); (d) localizacao de artefatos (traces, reports). Reduz friccao para contribuidores.
5. **Adicionar JSDoc em `api-client.ts:64-65`** explicando o trade-off do `cache: 'no-store'` (problema #7). Evita que futuras refatoracoes removam a linha sem entender o impacto.
6. **Em uma proxima iteracao, considerar 1 spec adicional** que valide o end-to-end de **disparo real** (criar schedule one-time com `runAt = now + 5s`, aguardar, verificar que `sentMessages` do fake tem 1 entrada). Cobriria o fluxo critico que os 3 specs atuais nao tocam: `SchedulerWorker` -> `WhatsAppService.sendText` -> `ExecutionLog`. Fora do escopo da Tarefa 12, mas ja com infra pronta.

## Conclusao

**APROVADO**. A implementacao atende integralmente aos requisitos da Tarefa 12.0 e segue fielmente a secao "Abordagem de Testes - Testes de E2E" da techspec. Os 3 cenarios-ancora foram cobertos com asserts visuais (badges, dialog, contadores) **e** funcionais (verificacao via API do estado de banco), excedendo o criterio "pelo menos 1 visual + 1 funcional". A arquitetura de cleanup em 3 camadas (pre-script + globalSetup + fixture auto) e o padrao correto e foi aplicada com cuidado — uso de PID no nome da queue, mount condicional do test-support, validacao previa de Redis. A suite roda em **13.2s** (limite era 3min) e foi confirmada estavel com 4 execucoes consecutivas verdes.

Os 8 problemas listados sao todos de severidade Baixa/Informacional. Os mais relevantes para uma proxima iteracao: (1) mover `setup-db` para `globalSetup` para eliminar o gotcha do pre-script, (2) substituir duck-typing por tipo discriminado no `isFakeWhatsApp`, e (3) fortalecer o assert de `pause-resume` para validar o **recalculo** do `nextRunAt`, nao apenas sua presenca. Nenhum bloqueia a aceitacao da tarefa.

Checks finais: `typecheck` OK, `lint` OK ("No ESLint warnings or errors"), `test` 256 passing + 1 skipped (api+web+shared-types), `build` OK, `test:e2e` **3/3 passed em 13.2s**.

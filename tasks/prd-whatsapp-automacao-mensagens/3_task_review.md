# Review: Task 3.0 - Conexao WhatsApp via QR Code

**Revisor**: AI Code Reviewer (task-reviewer)
**Data**: 2026-06-24
**Arquivo da task**: 3_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A tarefa entrega a infraestrutura completa para a conexao WhatsApp via QR Code: interface `WhatsAppService` clara, driver real baseado em `whatsapp-web.js` + `LocalAuth`, driver fake testavel, factory com escolha por env, controller + rotas Express com mapeamento adequado de erros (`SessionError` -> 503, `SendError` -> 502) e tela `/connect` em Next.js com Server Component para hidratacao inicial + Client Component com polling adaptativo (1s em QR/connecting, 30s em ready, 5s default). O codigo respeita ESM com extensoes `.js`, tipagem estrita sem `any`, schemas Zod compartilhados em `packages/shared-types` e separacao adequada de camadas. Os 51 testes (api 32, web 8, shared-types 11) passam, typecheck/lint/build limpos. As subtarefas 3.1-3.10 estao todas marcadas, mas o item E2E com Playwright listado em "Testes da Tarefa" nao foi executado e nao ha justificativa formal documentada na task; trato isso como divida tecnica a registrar.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `apps/api/src/config/env.ts` | OK | 0 |
| `apps/api/src/whatsapp/whatsapp.service.ts` | OK | 0 |
| `apps/api/src/whatsapp/whatsapp.real.ts` | OK | 2 minor |
| `apps/api/src/whatsapp/whatsapp.fake.ts` | OK | 0 |
| `apps/api/src/whatsapp/whatsapp.factory.ts` | OK | 1 minor |
| `apps/api/src/whatsapp/whatsapp.controller.ts` | OK | 2 minor |
| `apps/api/src/whatsapp/whatsapp.routes.ts` | OK | 0 |
| `apps/api/src/settings/settings.service.ts` | OK | 0 |
| `apps/api/src/server.ts` | OK | 0 |
| `packages/shared-types/src/whatsapp.ts` | OK | 0 |
| `apps/web/app/connect/page.tsx` | OK | 0 |
| `apps/web/app/connect/connect-client.tsx` | OK | 2 minor |
| `apps/web/components/QrCodeDisplay.tsx` | OK | 1 minor |
| `apps/web/components/SessionStatusBadge.tsx` | OK | 0 |
| `apps/web/lib/api-client.ts` | OK | 0 |
| `apps/api/test/whatsapp.service.test.ts` | OK | 0 |
| `apps/api/test/whatsapp.integration.test.ts` | OK | 1 minor |
| `apps/api/test/env.test.ts` | OK | 0 |
| `apps/web/test/connect-client.test.tsx` | OK | 0 |
| `apps/web/test/session-status-badge.test.tsx` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**1. Subtarefa Playwright E2E nao implementada**
- **Arquivo**: `3_task.md` (secao "Testes da Tarefa")
- **Descricao**: O item "Testes E2E (Playwright basico)" foi listado como entrega da tarefa, mas nao ha nenhum spec Playwright no repositorio (`apps/web/playwright/` nao foi criado). A subtarefa 3.9 (que engloba os testes) foi marcada como concluida, criando incoerencia entre o checklist e a entrega real.
- **Impacto**: Cobertura E2E reduzida. Como `connect-client.test.tsx` cobre comportamento de UI e `whatsapp.integration.test.ts` cobre o ciclo completo via supertest + driver fake, o risco funcional e baixo, mas a regressao de fluxo UI -> API nao esta automatizada.
- **Sugestao**: Adicionar checkbox separado na proxima tarefa ou abrir uma divida tecnica explicita ("Playwright E2E adiado para Task X") em vez de marcar 3.9 como completo.

**2. Campo morto `readyDispatched` no controller**
- **Arquivo**: `apps/api/src/whatsapp/whatsapp.controller.ts`, linhas 6 e 14/17
- **Descricao**: O campo `readyDispatched` e escrito (true em `ready`, false em `disconnected`), mas nunca lido em lugar algum. E codigo morto que confunde leitura futura.
- **Impacto**: Apenas legibilidade. Sem efeito funcional.
- **Sugestao**: Remover o campo ou justificar com comentario (ex: "reservado para deduplicar callbacks na proxima task").

**3. `setStatus('disconnected')` antes de `c.destroy()` pode mascarar falha**
- **Arquivo**: `apps/api/src/whatsapp/whatsapp.real.ts`, linhas 138-153
- **Descricao**: `disconnect()` zera `client`, define status como `disconnected` e so depois tenta `c.destroy()`. Se o destroy lancar, o codigo lanca `SessionError`, mas o status ja foi propagado como `disconnected` antes da garantia de que o cliente realmente parou. Em uso pessoal o impacto e desprezivel; em cenarios de retry, o estado interno pode divergir do estado real do Chromium.
- **Impacto**: Baixo. O `LocalAuth` ainda esta persistido e um `connect()` subsequente reinicializa do zero.
- **Sugestao**: Mover `setStatus('disconnected')` para apos `c.destroy()` resolver, ou pelo menos comentar a decisao explicitando que e "otimista" para o usuario ver feedback imediato.

**4. Emissao de evento `disconnected` em `disconnect()` mesmo sem cliente ativo**
- **Arquivo**: `apps/api/src/whatsapp/whatsapp.real.ts`, linhas 144-152 / `whatsapp.fake.ts`, linhas 88-93
- **Descricao**: Chamar `disconnect()` quando ja desconectado dispara o evento `{ type: 'disconnected', reason: 'manual' }`, o que no controller leva a um `settings.setWhatsAppConnected(false)` redundante (DB write).
- **Impacto**: Operacao extra em SQLite, irrelevante para uso pessoal.
- **Sugestao**: Curto-circuitar `disconnect()` se `status === 'disconnected'`, ou nao emitir o evento quando nao houver transicao real.

**5. Factory `getWhatsAppService` mantem singleton de modulo nao isolado por teste**
- **Arquivo**: `apps/api/src/whatsapp/whatsapp.factory.ts`, linhas 11-25
- **Descricao**: O cache `let cached: WhatsAppService | null` e por modulo. Atualmente os testes de integracao contornam injetando o service via `createApp({ whatsappService: fake })`, entao nao ha bug. Porem, qualquer teste futuro que esquecer de injetar vai herdar o singleton entre suites de Vitest (Vitest reaproveita o modulo dentro do worker), causando flakiness.
- **Impacto**: Potencial armadilha futura. `resetWhatsAppServiceCache` existe mas nao ha `afterEach` global que o chame.
- **Sugestao**: Adicionar `resetWhatsAppServiceCache()` em um `beforeEach`/`afterEach` global de teste, ou documentar a obrigatoriedade no `vitest.config.ts`.

**6. `<img>` nativo com lint-disable em vez de `next/image`**
- **Arquivo**: `apps/web/components/QrCodeDisplay.tsx`, linhas 12-19
- **Descricao**: O componente usa `<img>` com `eslint-disable-next-line @next/next/no-img-element` porque o src e um `data:` URL. A skill `vercel-react-best-practices` recomenda `next/image` para otimizacao, mas `next/image` nao otimiza data URLs e adicionaria overhead. A decisao e correta, apenas falta justificativa inline.
- **Impacto**: Nenhum tecnico, apenas falta de comentario explicativo.
- **Sugestao**: Trocar o `eslint-disable` por um comentario tipo `// data: URL nao se beneficia de next/image; usar <img> e intencional`.

**7. Polling continua quando aba esta em background**
- **Arquivo**: `apps/web/app/connect/connect-client.tsx`, linhas 53-59
- **Descricao**: O `setInterval` chama `refresh` mesmo com a aba em background. Para tela de QR isso significa requests a cada 1s sem necessidade. A skill `vercel-react-best-practices` recomenda pausar polling com `document.visibilityState === 'hidden'` para reduzir trafego.
- **Impacto**: Baixo para uso pessoal local. Maior em ambientes mobile/celular onde a aba pode ficar em segundo plano com QR ativo.
- **Sugestao**: Envolver o `refresh` em verificacao de visibilidade ou usar `visibilitychange` listener para pausar/retomar.

**8. `useEffect` de polling captura `snapshot.status` mas pode "atrasar" a primeira chamada**
- **Arquivo**: `apps/web/app/connect/connect-client.tsx`, linhas 53-59
- **Descricao**: O effect roda `setInterval(refresh, delay)`, ou seja, o primeiro refresh so acontece apos `delay` ms. Quando o usuario chega na pagina ja em `qr`, ele espera 1s para a primeira atualizacao do polling. Pequeno detalhe de UX.
- **Impacto**: Baixo. Status inicial vem do Server Component (`page.tsx`).
- **Sugestao**: Disparar um `refresh()` imediato dentro do effect antes do `setInterval`, opcional.

**9. Teste de integracao usa singleton compartilhado entre casos**
- **Arquivo**: `apps/api/test/whatsapp.integration.test.ts`, linhas 21-32
- **Descricao**: `db` e criado em `beforeAll` e reusado em todos os testes; o estado em `Settings` (que e tabela singleton) e mantido entre cases. O teste "POST /api/whatsapp/connect is idempotent" e o "503 com payload SessionError" rodam em sequencia e podem deixar `Settings.whatsappConnected=true` da execucao anterior se a ordem mudar.
- **Impacto**: Baixo hoje (cases nao verificam o valor entre si), mas tornar a suite ordem-dependente e fragil.
- **Sugestao**: Em `beforeEach`, executar `prisma.settings.upsert({ where: { id: 1 }, update: { whatsappConnected: false }, create: { id: 1, whatsappConnected: false } })` para isolar estado.

## Destaques Positivos

1. **Arquitetura de driver bem desenhada**: a interface `WhatsAppService` desacopla negocio do `whatsapp-web.js`; o `FakeWhatsAppService` expoe um superset com helpers (`emitReady`, `failNextSend`, `sentMessages`) que viabilizam testes deterministicos sem rodar Chromium. Essa separacao e exemplar.

2. **Classificacao de erros consistente**: `SessionError` x `SendError` propagados desde o driver, passando pelo controller e mapeados nos routes para 503 e 502 respectivamente. Cobre exatamente a regra da Tech Spec ("Pontos de Integracao") e os testes validam o payload.

3. **Tipagem rigorosa sem `any`**: tipagem `InstanceType<typeof Client>` no real driver, types tipo `WhatsAppListener`, `WhatsAppEvent` discriminado por `type`, schemas Zod centralizados em `shared-types`. Zero uso de `any` no diff.

4. **ESM com extensoes `.js`**: todos os imports respeitam a regra de ESM compilado (`./whatsapp.service.js`, `./whatsapp.factory.js`), garantindo Node 20+ rodar sem flags adicionais.

5. **Server + Client component splitting correto**: `page.tsx` busca status no servidor (RSC) e passa via prop para `ConnectClient`, evitando hydration mismatch e pintando UI ja com estado real. Boa pratica de App Router.

6. **Polling adaptativo conforme Tech Spec**: 1s em `qr`/`connecting`, 30s em `ready`, 5s default. A funcao `intervalFor` deixa a regra explicita e testavel.

7. **Aviso de risco visivel e permanente**: o bloco `.warning` cumpre o requisito do PRD (FR Restricoes Tecnicas) sobre comunicar risco de ban. Mensagem clara em PT-BR.

8. **Acessibilidade cuidada**: `role="status"` + `aria-live="polite"` no badge, `role="alert"` no banner persistente de desconexao, `role="note"` no aviso de risco, `alt` descritivo no QR. Atende criterios WCAG AA do PRD.

9. **mkdirSync recursivo antes de inicializar LocalAuth**: evita o erro classico do `whatsapp-web.js` quando o `dataPath` nao existe, deixando o boot resiliente em ambientes novos.

10. **Cobertura de testes solida nos limites importantes**: factory escolhendo driver, transicao completa de estados no fake, idempotencia do connect, retorno 503 com payload formatado, mudanca de `Settings.whatsappConnected` em ambas as direcoes, desativacao do botao "Conectar" enquanto em QR, banner persistente quando ha `lastError`.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Aderencia ao PRD (FR23-FR25) | OK |
| Aderencia a Tech Spec (interface, polling, LocalAuth, classificacao de erros) | OK |
| Subtarefas 3.1-3.10 marcadas | OK (mas Playwright E2E ausente) |
| Naming e separacao de camadas | OK |
| ESM + extensoes `.js` em imports | OK |
| Tipagem strict, sem `any` | OK |
| Schemas Zod compartilhados | OK |
| `frontend-design` (CSS modules, hierarquia visual, paleta consistente) | OK |
| `vercel-react-best-practices` (RSC + client, polling, hooks) | OK com ressalvas (ver minor 6 e 7) |
| Testes unitarios | OK |
| Testes de integracao | OK |
| Testes E2E (Playwright) | NAO REALIZADO |
| Typecheck / Lint / Test / Build locais | OK (51 testes passam) |

## Recomendacoes

1. **Adicionar Playwright E2E** em uma proxima task ou registrar explicitamente como divida tecnica no `tasks.md` do PRD; nao deixar implicito.
2. **Higienizar o controller**: remover `readyDispatched` ou usa-lo para deduplicar callbacks.
3. **Hardening do `disconnect()` real**: mover `setStatus('disconnected')` para depois de `c.destroy()` resolver, ou explicitar a decisao otimista por comentario.
4. **Isolamento do singleton da factory em testes**: registrar `resetWhatsAppServiceCache` em `afterEach` global, evitando vazamento futuro entre suites.
5. **Polling consciente de visibilidade**: pausar `setInterval` quando `document.visibilityState !== 'visible'` para reduzir trafego desnecessario e economia de bateria em mobile.
6. **Refresh imediato no mount do effect** de polling: evita o atraso inicial de 1s quando a pagina abre ja em estado `qr`.
7. **Reset de `Settings.whatsappConnected`** em `beforeEach` da integration suite para evitar dependencia de ordem.
8. **Justificar inline o `<img>` em `QrCodeDisplay`** em vez de apenas `eslint-disable`, deixando a decisao auditavel.

## Veredito

**APROVADO COM OBSERVACOES.** A entrega cumpre integralmente os requisitos funcionais e de Tech Spec da Task 3.0, com arquitetura limpa, tipagem rigorosa, testes solidos e UI acessivel. Nenhum problema critico ou major encontrado. As observacoes minor sao melhorias de robustez, higiene e ergonomia que nao bloqueiam o avanco. A unica pendencia notavel e a ausencia do Playwright E2E listado na propria task; recomendo registrar como divida tecnica antes de fechar o ciclo do PRD.

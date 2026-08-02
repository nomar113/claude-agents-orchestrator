# Tarefa 1.0: Bootstrap do Monorepo e Infraestrutura Base

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Inicializar o monorepo npm workspaces com as apps `apps/api` (Express + TypeScript) e `apps/web` (Next.js App Router), alem do package compartilhado `packages/shared-types`. Estabelece a base de configuracao (tsconfig, eslint, prettier, vitest), o `docker-compose.yml` com Redis, o logger `pino` minimo e um healthcheck para validar que a stack sobe corretamente.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — sera usada para conduzir esta implementacao com checks `typecheck/test/build/lint` antes de marcar como concluido.
- `vercel-react-best-practices` (global) — diretrizes do scaffolding inicial de Next.js (App Router).
</skills>

<requirements>
- Monorepo npm workspaces configurado via campo `workspaces` no `package.json` raiz.
- `apps/api` em Express + TypeScript com endpoint `GET /api/health` retornando 200.
- `apps/web` em Next.js App Router inicializado com pagina inicial vazia/placeholder.
- `packages/shared-types` consumivel pelas duas apps.
- `docker-compose.yml` com servico `redis` (e opcionalmente `api`).
- Logger `pino` (com `pino-pretty` em dev) configurado na API.
- Scripts `typecheck`, `lint`, `test` e `build` funcionando em cada app.
- `.gitignore` cobrindo `storage/media/`, `storage/wwebjs/`, `node_modules`, `.next`, etc.
- Node 20+ como engine.
</requirements>

## Subtarefas

- [x] 1.1 Criar `package.json` raiz com campo `workspaces` (apps/*, packages/*) e configs base (tsconfig, eslint, prettier, vitest).
- [x] 1.2 Inicializar `apps/api` com Express + TypeScript, server.ts, index.ts e endpoint `GET /api/health`.
- [x] 1.3 Inicializar `apps/web` com Next.js (App Router) e pagina raiz placeholder.
- [x] 1.4 Criar `packages/shared-types` com export inicial e integrar como dependencia das duas apps.
- [x] 1.5 Configurar `docker-compose.yml` com servico Redis exposto na porta padrao.
- [x] 1.6 Configurar logger `pino` em `apps/api/src/observability/logger.ts` e usar no bootstrap.
- [x] 1.7 Criar `.gitignore` com diretorios sensiveis e arquivos de storage.
- [x] 1.8 Escrever testes da tarefa (ver secao Testes).
- [x] 1.9 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build` em cada app e garantir sucesso.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Arquitetura do Sistema" e "Sequenciamento de Desenvolvimento - Ordem de Construcao - item 1" e "Dependencias Tecnicas". A lista de arquivos novos esta em "Arquivos relevantes e dependentes".

## Criterios de Sucesso

- `npm install` na raiz instala todas as dependencias dos workspaces.
- `npm run dev --workspace @app/api` sobe a API com log estruturado e responde 200 em `/api/health`.
- `npm run dev --workspace @app/web` sobe o Next.js sem erros.
- `docker compose up redis` sobe o Redis e a API consegue conectar (teste de conexao).
- Todos os scripts `typecheck/test/lint/build` passam em CI local.

## Testes da Tarefa

- [ ] Testes de unidade: factory do logger retorna instancia com niveis corretos; helper de config carrega env vars com defaults.
- [ ] Testes de integracao: `supertest` valida que `GET /api/health` retorna `{ status: 'ok' }` com 200.
- [ ] Smoke test: build de producao (`npm run build`) gera artefatos em `apps/api/dist` e `apps/web/.next` sem erros.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `package.json` (raiz, com campo `workspaces`)
- `docker-compose.yml`
- `.gitignore`
- `tsconfig.base.json`, `.eslintrc.cjs`, `.prettierrc`, `vitest.config.ts` (raiz)
- `apps/api/package.json`, `apps/api/tsconfig.json`
- `apps/api/src/index.ts`, `apps/api/src/server.ts`
- `apps/api/src/observability/logger.ts`
- `apps/api/test/health.test.ts`
- `apps/web/package.json`, `apps/web/tsconfig.json`
- `apps/web/app/layout.tsx`, `apps/web/app/page.tsx`
- `packages/shared-types/package.json`, `packages/shared-types/src/index.ts`

# Review: Task 1.0 - Bootstrap do Monorepo e Infraestrutura Base

**Revisor**: AI Code Reviewer
**Data**: 2026-06-24
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

Bootstrap do monorepo npm workspaces realizado com qualidade. A estrutura espelha exatamente a Tech Spec (`apps/api`, `apps/web`, `packages/shared-types`), as configuracoes base (TypeScript strict + NodeNext, ESLint com `@typescript-eslint`, Prettier, Vitest) estao coerentes entre raiz e workspaces, o `docker-compose.yml` sobe o Redis 7 com persistencia e o logger `pino` esta funcional com `pino-pretty` em desenvolvimento. Todos os comandos de validacao foram executados localmente com sucesso:

- `npm run typecheck`: ok (3 workspaces)
- `npm run lint`: ok (sem issues)
- `npm run test`: 7/7 tests passando (env: 4, logger: 2, health: 1)
- `npm run build`: artefatos gerados em `apps/api/dist`, `apps/web/.next` e `packages/shared-types/dist`

A integracao `shared-types` -> apps esta validada pelo uso real (`HealthResponse` em `server.ts` e `SHARED_TYPES_VERSION` em `app/page.tsx`). Existem apenas observacoes minor relacionadas a robustez do `loadConfig`, documentacao e detalhes de configuracao do Docker. Nada bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| package.json (raiz) | OK | 0 |
| tsconfig.base.json | OK | 0 |
| .eslintrc.cjs | OK | 0 |
| .prettierrc | OK | 0 |
| vitest.config.ts (raiz) | OK | 0 |
| docker-compose.yml | OK (minor) | 1 |
| .gitignore | OK | 0 |
| apps/api/package.json | OK | 0 |
| apps/api/tsconfig.json | OK | 0 |
| apps/api/vitest.config.ts | OK | 0 |
| apps/api/src/index.ts | OK | 0 |
| apps/api/src/server.ts | OK | 0 |
| apps/api/src/config/env.ts | OK (minor) | 2 |
| apps/api/src/observability/logger.ts | OK | 0 |
| apps/api/test/env.test.ts | OK | 0 |
| apps/api/test/logger.test.ts | OK | 0 |
| apps/api/test/health.test.ts | OK | 0 |
| apps/web/package.json | OK | 0 |
| apps/web/tsconfig.json | OK | 0 |
| apps/web/next.config.mjs | OK | 0 |
| apps/web/.eslintrc.json | OK | 0 |
| apps/web/app/layout.tsx | OK | 0 |
| apps/web/app/page.tsx | OK | 0 |
| packages/shared-types/package.json | OK | 0 |
| packages/shared-types/tsconfig.json | OK | 0 |
| packages/shared-types/src/index.ts | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**M1 - `loadConfig` aceita `PORT` invalido e gera `NaN` silenciosamente**
- Arquivo: `apps/api/src/config/env.ts`, linha 13
- Descricao: `Number(env.PORT ?? 3001)` produz `NaN` se `PORT` for uma string nao-numerica (ex.: `PORT=abc`). O `app.listen(NaN, ...)` falha apenas em runtime sem mensagem clara. Como este modulo sera fonte de verdade para mais variaveis (Redis URL, x-api-key, etc.) nas proximas tasks, ja convem validar com Zod aqui (a Tech Spec aponta Zod em `packages/shared-types`).
- Correcao sugerida:

```ts
import { z } from 'zod';

const envSchema = z.object({
  PORT: z.coerce.number().int().positive().default(3001),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).optional(),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const parsed = envSchema.parse(env);
  return {
    port: parsed.PORT,
    logLevel: parsed.LOG_LEVEL ?? (parsed.NODE_ENV === 'production' ? 'info' : 'debug'),
    nodeEnv: parsed.NODE_ENV,
  };
}
```

**M2 - `LOG_LEVEL` aceita qualquer string e e repassado direto para o pino**
- Arquivo: `apps/api/src/config/env.ts`, linha 14
- Descricao: o pino aceita `level` como string arbitraria (criando "custom level"), entao um valor com erro de digitacao (`infoo`) nao produz erro claro. Validar o conjunto fechado de niveis evita debugging perdido.
- Correcao sugerida: incluido no diff de M1 acima.

**M3 - `docker-compose.yml` sem `healthcheck` para o Redis**
- Arquivo: `docker-compose.yml`
- Descricao: a Tech Spec adiciona um servico `api` opcional em compose mais a frente e o boot do worker BullMQ depende de Redis disponivel. Um `healthcheck` curto evita race condition quando `api` for adicionado com `depends_on: { redis: { condition: service_healthy } }`.
- Correcao sugerida:

```yaml
services:
  redis:
    image: redis:7-alpine
    container_name: whatsapp-automacao-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: unless-stopped
    command: ["redis-server", "--appendonly", "yes"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
```

**M4 - Checkboxes da secao "Testes da Tarefa" no `1_task.md` nao foram marcados**
- Arquivo: `tasks/prd-whatsapp-automacao-mensagens/1_task.md`, linhas 54-56
- Descricao: os tres itens de teste (unit do logger/config, integration do health, smoke do build) foram entregues, mas continuam `- [ ]`. Marcar como `[x]` mantem o rastro de cobertura coerente com as subtarefas.

**M5 - `lint` do workspace web nao roda na raiz porque `next lint` cobre apenas `app/`**
- Arquivo: `apps/web/package.json`, linha 10
- Descricao: o script `next lint --dir app` ignora qualquer arquivo futuro fora de `app/` (ex.: `lib/api-client.ts` listado na Tech Spec, `components/`, `playwright/`). Como uma das proximas tasks ja introduz `apps/web/lib/`, o lint passaria a esquecer esses arquivos silenciosamente.
- Correcao sugerida: trocar para `next lint --dir app --dir lib --dir components` (ou simplesmente `next lint`) na proxima task que introduzir `lib/`.

## Destaques Positivos

- **TypeScript strict reforcado**: `tsconfig.base.json` ativa `noUncheckedIndexedAccess`, `noImplicitOverride`, `noFallthroughCasesInSwitch` e `isolatedModules`. Boa base para uma codebase greenfield.
- **Modulo ESM consistente**: `module: NodeNext` na base + `"type": "module"` nos workspaces + imports com extensao `.js` ja garantem build/runtime alinhados (`apps/api/dist/index.js` confirma a saida correta).
- **Separacao de bootstrap e factory**: `index.ts` cuida do ciclo de vida do processo, `server.ts` expoe `createApp()` sem efeitos colaterais. Isso permitiu o teste de integracao do `/api/health` com `supertest` sem subir porta - exatamente o padrao recomendado.
- **`loadConfig` puro e testavel**: aceita um `env` opcional como parametro, viabilizando os 4 cenarios cobertos por `env.test.ts` sem mexer em `process.env`.
- **Logger isolado em `observability/`**: respeita a estrutura prevista na Tech Spec (`apps/api/src/observability/{logger.ts,metrics.ts}`), deixando espaco natural para `metrics.ts` na Task 11.
- **`shared-types` ja consumido por ambos workspaces**: `HealthResponse` em `server.ts` e `SHARED_TYPES_VERSION` em `page.tsx` provam que a pipeline `build -> dist -> consumo` funciona; o `transpilePackages` no Next garante hot reload em dev.
- **Configuracoes de qualidade alinhadas**: `eslint-config-prettier` evita conflito entre lint e formatter; `next/core-web-vitals` cobre o web; padrao consistente de scripts (`typecheck/lint/test/build`) em todos os workspaces.
- **Cobertura de testes proporcional ao escopo**: 7 testes para uma task de bootstrap, cobrindo defaults, overrides, fallback condicional, coercao de `NODE_ENV` invalido e integracao HTTP.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | OK |
| Logging | OK |
| React | OK |
| Testes | OK |

Notas:
- Nomenclatura inteira em ingles, camelCase para funcoes/variaveis, PascalCase para tipos (`AppConfig`, `HealthResponse`, `CreateLoggerOptions`), kebab-case para arquivos.
- Funcoes pequenas (`loadConfig` ~10 linhas, `createLogger` ~12, `createApp` ~8), sem aninhamento excessivo, sem flags booleanas como toggles e sem `any`.
- Nenhum `console.log` direto; toda saida e via `pino`.

## Recomendacoes

1. Adotar Zod ja em `apps/api/src/config/env.ts` (M1/M2) antes da Task 2.0, pois ali entrarao `DATABASE_URL`, `REDIS_URL` e `API_KEY`. Centralizar essa porta antes de proliferar uso evita refactor depois.
2. Adicionar `healthcheck` ao servico `redis` no `docker-compose.yml` (M3) para preparar a Task 8.0, que conecta BullMQ.
3. Atualizar os tres checkboxes da secao "Testes da Tarefa" do `1_task.md` para `[x]` (M4), refletindo a entrega real.
4. Quando a Task 8.0/2.0 introduzir `apps/web/lib/`, ajustar `lint` para `next lint` (sem `--dir app`) ou listar todos os diretorios (M5).
5. Considerar mover o endpoint `/api/health` para um arquivo `apps/api/src/health/health.routes.ts` quando a Task 2.0/3.0 introduzir outros routers; isso evita que `server.ts` cresca alem de 50 linhas conforme novos middlewares e routers forem montados.
6. Documentar no README (ou em uma proxima task) o comando completo de dev: `docker compose up -d redis && npm run dev:api` + `npm run dev:web`, ja que sao tres processos distintos.

## Debitos para Tasks Seguintes (Lacunas Aceitaveis)

- `/api/health` hoje retorna apenas `{ status: 'ok' }`. A Tech Spec sugere expor dependencias (Redis, sessao WhatsApp) eventualmente; quando isso acontecer, considere `{ status, redis, whatsapp, version }` mantendo o tipo no `shared-types`.
- Nao ha `eslint` nem `lint` script no `packages/shared-types` rodando hoje contra arquivos reais alem de `src/index.ts`. Conforme novos tipos forem adicionados (Task 2.0+) o lint comecara a cobrir naturalmente; nenhuma acao agora.
- Nao existe `.env.example` no monorepo. A Tech Spec usa varias variaveis (timezone, lat/lng, API key) — recomendado introduzir na Task 2.0 junto ao Prisma e Settings.
- `vitest.config.ts` na raiz duplica include com o do `apps/api`. Como nao ha test runner sendo invocado na raiz (apenas via workspaces), nao causa problema, mas se sumir esse arquivo um `npx vitest` no root nao quebra nada. Sugiro avaliar se mante-lo agrega valor ou se basta o de cada workspace.

## Veredito

**APROVADO COM OBSERVACOES.** A Task 1.0 cumpre integralmente os requirements (subtarefas 1.1 a 1.9), o setup esta coerente com a Tech Spec e os 5 criterios de sucesso foram validados localmente (`typecheck`, `lint`, `test`, `build`, `GET /api/health` 200). Os 5 problemas minor identificados (M1-M5) nao bloqueiam a transicao para a Task 2.0; M1/M2 podem ser absorvidos como parte do trabalho de variaveis de ambiente da Task 2.0 (DATABASE_URL etc.), M3 antes da Task 8.0 (BullMQ), M4 imediatamente (marcar checkboxes) e M5 ao introduzir `apps/web/lib/`. Pode-se prosseguir para a Task 2.0.

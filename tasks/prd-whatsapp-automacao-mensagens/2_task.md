# Tarefa 2.0: Modelo de Dados (Prisma + SQLite) e Configuracoes Globais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Definir todo o schema Prisma (Contact, ContactList, ContactListMember, Schedule, ExecutionLog, Media, Settings), criar a primeira migration e o seed singleton de Settings. Em seguida, expor o `SettingsService` com endpoints `GET/PUT /settings` e construir a tela de Configuracoes no frontend para latitude, longitude, fuso horario e thresholds.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — execucao com checks.
- `frontend-design` (global) — design da tela de Settings sem estetica generica.
- `vercel-react-best-practices` (global) — boas praticas no Next.js para a pagina.
</skills>

<requirements>
- `schema.prisma` com todos os modelos descritos na techspec, incluindo defaults e indices.
- Primeira migration aplicada gerando arquivo SQLite local.
- Seed que garante 1 registro em `Settings` (id=1) com defaults da techspec.
- Endpoints `GET /api/settings` e `PUT /api/settings` validados com Zod.
- Tela `apps/web/app/settings/page.tsx` permite editar lat/lng/timezone/bulkThreshold/antiSpamPerContact/antiSpamWindowHours.
- Schemas Zod em `packages/shared-types` reutilizados pela API e Web.
- Mudancas de DST tratadas corretamente (Settings.timezone usado pelo `date-fns-tz` em tarefas futuras).
</requirements>

## Subtarefas

- [ ] 2.1 Criar `apps/api/prisma/schema.prisma` com modelos Contact, ContactList, ContactListMember, Schedule, ExecutionLog, Media e Settings.
- [ ] 2.2 Gerar primeira migration via `prisma migrate dev --name init`.
- [ ] 2.3 Implementar seed em `apps/api/prisma/seed.ts` criando `Settings` singleton.
- [ ] 2.4 Implementar `SettingsService` em `apps/api/src/settings/settings.service.ts`.
- [ ] 2.5 Definir schemas Zod de Settings em `packages/shared-types/src/settings.ts` e exportar tipos.
- [ ] 2.6 Implementar `settings.routes.ts` com `GET` e `PUT /api/settings` validando payload via Zod.
- [ ] 2.7 Implementar `apps/web/lib/api-client.ts` com client HTTP baseado em fetch.
- [ ] 2.8 Implementar tela `apps/web/app/settings/page.tsx` com formulario de configuracoes globais.
- [ ] 2.9 Escrever testes da tarefa (ver secao Testes).
- [ ] 2.10 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secao "Modelos de Dados" (schema Prisma completo, incluindo defaults e indices) e "Endpoints de API" para o contrato `/settings`. Persistencia via SQLite com `file::memory:?cache=shared` em testes (techspec "Testes de Integracao").

## Criterios de Sucesso

- `prisma migrate dev` cria o banco e seed gera Settings com os defaults da techspec (`bulkThreshold=10`, `antiSpamPerContact=1`, `antiSpamWindowHours=6`, `timezone=America/Sao_Paulo`).
- `GET /api/settings` retorna o registro singleton; `PUT /api/settings` persiste e retorna o atualizado.
- Tela de Settings salva com feedback de sucesso/erro e mostra erros de validacao por campo (acessibilidade: labels semanticos).

## Testes da Tarefa

- [ ] Testes de unidade: validacao de schemas Zod (timezone valido, lat/lng dentro de [-90,90]/[-180,180], thresholds positivos); `SettingsService` lendo/escrevendo com Prisma mockado ou SQLite in-memory.
- [ ] Testes de integracao: subir API com SQLite in-memory; `supertest` cobrindo `GET /api/settings`, `PUT /api/settings` (sucesso e 400 em payload invalido) e que seed inicializa o singleton.
- [ ] Testes E2E (basico): com `@testing-library/react` ou Playwright minimo, renderizar a pagina, submeter formulario e verificar chamada ao client.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/prisma/schema.prisma`
- `apps/api/prisma/migrations/*`
- `apps/api/prisma/seed.ts`
- `apps/api/src/settings/settings.service.ts`
- `apps/api/src/settings/settings.routes.ts`
- `apps/api/test/settings.integration.test.ts`
- `apps/api/test/settings.service.test.ts`
- `apps/web/app/settings/page.tsx`
- `apps/web/lib/api-client.ts`
- `packages/shared-types/src/settings.ts`
- `packages/shared-types/src/index.ts`

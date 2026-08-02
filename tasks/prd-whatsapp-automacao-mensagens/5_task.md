# Tarefa 5.0: Listas de Contatos

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar listas nomeadas de contatos (FR4): CRUD de `ContactList`, gestao de membros (`ContactListMember`), e a tela de Listas no frontend permitindo criar/editar/excluir listas e adicionar ou remover contatos delas. Esta tarefa habilita o destinatario tipo `list` usado em agendamentos.

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `frontend-design` (global) — UX clara para gestao de membros.
- `vercel-react-best-practices` (global).
</skills>

<requirements>
- `ListService` com CRUD de `ContactList` (unico nome) e operacoes de adicionar/remover membros.
- Endpoints `GET/POST /api/lists`, `PUT/DELETE /api/lists/:id`, e endpoints para gerenciar membros (`POST/DELETE /api/lists/:id/members/:contactId`).
- Tela `apps/web/app/lists/page.tsx` com lista de listas e detalhe da lista mostrando membros.
- Schemas Zod compartilhados em `packages/shared-types/src/list.ts`.
- Exclusao de lista nao deleta contatos.
- Conflito de nome retorna 409 com mensagem clara.
</requirements>

## Subtarefas

- [x] 5.1 Definir schemas Zod e tipos em `packages/shared-types/src/list.ts`.
- [x] 5.2 Implementar `ListService` em `apps/api/src/lists/list.service.ts` (CRUD + membros).
- [x] 5.3 Implementar `list.routes.ts` com endpoints de lista e de membros.
- [x] 5.4 Implementar tela `apps/web/app/lists/page.tsx` com listagem e modal de criacao/edicao.
- [x] 5.5 Implementar pagina/painel de detalhe de lista com selector de contatos para adicionar.
- [x] 5.6 Escrever testes da tarefa (ver secao Testes).
- [x] 5.7 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Modelos de Dados - ContactList, ContactListMember" e "Endpoints de API - /lists".

## Criterios de Sucesso

- Criar lista "Aniversariantes", adicionar 3 contatos, listar membros via API e UI.
- Tentativa de criar lista com nome duplicado retorna 409.
- Exclusao de lista mantem contatos intactos.

## Testes da Tarefa

- [x] Testes de unidade: `ListService` (criar, adicionar/remover membros, conflitos de nome).
- [x] Testes de integracao: CRUD via `supertest` + SQLite in-memory; cenarios de membros (adicionar/remover, contato inexistente retorna 404).
- [ ] Testes E2E (Playwright): criar lista, adicionar contatos, validar contagem na listagem. (Divida tecnica unificada com Task 3.0/4.0)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/lists/list.service.ts`
- `apps/api/src/lists/list.routes.ts`
- `apps/api/test/list.service.test.ts`
- `apps/api/test/list.integration.test.ts`
- `apps/web/app/lists/page.tsx`
- `apps/web/app/lists/[id]/page.tsx`
- `apps/web/components/ListForm.tsx`
- `apps/web/components/ListMembersPanel.tsx`
- `packages/shared-types/src/list.ts`

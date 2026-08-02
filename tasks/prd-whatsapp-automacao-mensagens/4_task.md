# Tarefa 4.0: Contatos: CRUD + Importacao CSV + Importacao WhatsApp

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar gestao completa de contatos (FR1, FR2, FR3, FR5): CRUD, importacao em massa via arquivo CSV usando `papaparse`, e importacao a partir da agenda WhatsApp conectada via `WhatsAppService.listContacts()`. Inclui a tela de Contatos com lista, criacao, edicao, remocao e dois fluxos de importacao.

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `frontend-design` (global) — tabela de contatos com filtros, sem estetica generica.
- `vercel-react-best-practices` (global) — paginacao e RSC quando aplicavel.
</skills>

<requirements>
- `ContactService` com CRUD em Prisma, normalizando telefone para E.164 (`phone @unique`).
- Endpoints `GET/POST /api/contacts`, `PUT/DELETE /api/contacts/:id`.
- `POST /api/contacts/import-csv` aceita multipart e parseia em streaming.
- `GET /api/whatsapp/contacts` lista contatos sincronizados do driver WhatsApp.
- `POST /api/contacts/import-whatsapp` importa lista selecionada para o banco.
- Tela de Contatos com lista paginada, criacao/edicao via formulario (nome, telefone, data de nascimento opcional, vars custom), botoes de "Importar CSV" e "Importar do WhatsApp".
- Schemas Zod compartilhados em `packages/shared-types/src/contact.ts`.
- Remover contato nao afeta `ExecutionLog` ja gravados (relacao mantem registros) (FR5).
</requirements>

## Subtarefas

- [x] 4.1 Definir schemas Zod e tipos em `packages/shared-types/src/contact.ts`.
- [x] 4.2 Implementar `ContactService` com CRUD (`apps/api/src/contacts/contact.service.ts`) incluindo normalizacao E.164.
- [x] 4.3 Implementar parser CSV em `apps/api/src/contacts/csv-import.ts` usando `papaparse` em modo streaming.
- [x] 4.4 Implementar `contact.routes.ts` com endpoints CRUD + `import-csv` (multer) + `import-whatsapp`.
- [x] 4.5 Implementar endpoint `GET /api/whatsapp/contacts` consumindo `WhatsAppService.listContacts()`.
- [x] 4.6 Implementar tela `apps/web/app/contacts/page.tsx` com lista, criacao/edicao e drawer/modal de importacoes.
- [x] 4.7 Implementar componentes `ContactForm`, `CsvImportModal`, `WhatsAppImportModal` em `apps/web/components/`.
- [x] 4.8 Escrever testes da tarefa (ver secao Testes).
- [x] 4.9 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Modelos de Dados - Contact", "Endpoints de API" (linhas de `/contacts` e `/whatsapp/contacts`) e "Pontos de Integracao" (papaparse, multer).

## Criterios de Sucesso

- CRUD funcional via API e UI; telefone unico aplicado e mensagem de erro descritiva no duplicado.
- Importacao CSV aceita colunas `nome,telefone[,data_nascimento,vars...]` e retorna sumario (criados/atualizados/erros).
- Importacao WhatsApp (driver fake nos testes) lista contatos e cria registros em lote.
- Remocao de contato nao deleta `ExecutionLog` historicos (FR5).

## Testes da Tarefa

- [ ] Testes de unidade: normalizacao E.164 (com casos +55, sem +, espacos), parser CSV (headers ausentes, linhas invalidas, encoding UTF-8/Latin-1), `ContactService.upsert`.
- [ ] Testes de integracao: SQLite in-memory; CRUD completo (criar/listar/editar/excluir); upload de CSV via `supertest` com arquivo multipart (3 contatos validos + 1 invalido); importacao WhatsApp com driver fake retornando contatos pre-definidos.
- [ ] Testes E2E (Playwright): criar contato manualmente; importar CSV; importar do WhatsApp; verificar lista exibe os 3 contatos.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/contacts/contact.service.ts`
- `apps/api/src/contacts/csv-import.ts`
- `apps/api/src/contacts/contact.routes.ts`
- `apps/api/test/contact.service.test.ts`
- `apps/api/test/contact.csv.test.ts`
- `apps/api/test/contact.integration.test.ts`
- `apps/web/app/contacts/page.tsx`
- `apps/web/components/ContactForm.tsx`
- `apps/web/components/CsvImportModal.tsx`
- `apps/web/components/WhatsAppImportModal.tsx`
- `packages/shared-types/src/contact.ts`

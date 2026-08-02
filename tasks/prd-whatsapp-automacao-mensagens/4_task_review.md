# Review: Task 4.0 - Contatos: CRUD + Importacao CSV + Importacao WhatsApp

**Revisor**: AI Code Reviewer
**Data**: 2026-06-24
**Arquivo da task**: 4_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A entrega cumpre integralmente os requisitos funcionais previstos para a Task 4.0
(FR1, FR2, FR3, FR5) e fornece uma camada de contatos solida, com schemas Zod
compartilhados, servico de dominio bem isolado, parser CSV em streaming via
`papaparse`, rotas REST com tratamento adequado de erros e uma tela `/contacts`
completa em Next.js (RSC + client). A migration
`20260625021445_contacts_preserve_logs` modela corretamente a preservacao de
`ExecutionLog` apos remocao de contato (`onDelete: SetNull` + `contactId String?`),
fechando o requisito FR5. Os checks executam limpos: `typecheck`, `lint`, `build`
e `npm test` rodam sem erros e a suite passa 84/84 (62 API + 11 web + 11
shared-types). Nao foram encontrados problemas criticos. Existem pontos minor
relacionados a validacao defensiva, contrato de payloads, organizacao de
estilos compartilhados entre componentes e a divida de E2E Playwright explicitada
no proprio resumo.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| packages/shared-types/src/contact.ts | OK | 0 |
| packages/shared-types/src/index.ts | OK | 0 |
| apps/api/src/contacts/phone.ts | OK | 1 minor |
| apps/api/src/contacts/contact.service.ts | OK | 2 minor |
| apps/api/src/contacts/csv-import.ts | OK | 2 minor |
| apps/api/src/contacts/contact.routes.ts | OK | 2 minor |
| apps/api/src/whatsapp/whatsapp.routes.ts | OK | 0 |
| apps/api/prisma/schema.prisma | OK | 0 |
| apps/api/prisma/migrations/20260625021445_contacts_preserve_logs/migration.sql | OK | 0 |
| apps/api/src/server.ts | OK | 0 |
| apps/api/test/contact.phone.test.ts | OK | 0 |
| apps/api/test/contact.service.test.ts | OK | 0 |
| apps/api/test/contact.csv.test.ts | OK | 0 |
| apps/api/test/contact.integration.test.ts | OK | 0 |
| apps/web/app/contacts/page.tsx | OK | 0 |
| apps/web/app/contacts/contacts-client.tsx | OK | 1 minor |
| apps/web/components/Modal.tsx | OK | 1 minor |
| apps/web/components/ContactForm.tsx | OK | 1 minor |
| apps/web/components/CsvImportModal.tsx | OK | 0 |
| apps/web/components/WhatsAppImportModal.tsx | OK | 0 |
| apps/web/lib/api-client.ts | OK | 0 |
| apps/web/test/contacts-client.test.tsx | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **apps/api/src/contacts/phone.ts:22** — A heuristica
   `hasPlus || digits.length > 11 ? digits : ${defaultCountry}${digits}` ignora a
   possibilidade de um numero local com 11 digitos digitados juntos para um pais
   diferente. Para uso pessoal BR isso e aceitavel, mas vale documentar a regra
   no JSDoc da funcao (ou tornar `defaultCountry` orientado ao `Settings.timezone`
   futuramente) para evitar surpresas quando `defaultCountry` for parametrizado em
   tasks subsequentes.

2. **apps/api/src/contacts/contact.service.ts:144** — Em `update`, quando o conflito
   acontece e `patch.phone` nao foi enviado, a mensagem fica
   `telefone undefined ja cadastrado`. Isso so e teoricamente alcancavel caso o
   schema mude no futuro (hoje `P2002` em update so ocorre quando `phone` esta no
   patch), mas vale guardar a entrada normalizada e usa-la, ou trocar pelo
   `existing.phone` para evitar mensagens vazias.

3. **apps/api/src/contacts/contact.service.ts:135** — `parseBirthdate(patch.birthdate)`
   retorna `null` silenciosamente quando a string e invalida. Como o schema Zod ja
   valida `YYYY-MM-DD`, a probabilidade e baixa, mas a service nao deveria
   converter "data invalida" em "remocao da data". Considere lancar erro
   `PhoneFormatError`-like (ex.: `ContactValidationError`) para defesa em
   profundidade quando a service e usada fora do router.

4. **apps/api/src/contacts/csv-import.ts:25** — A regex
   `/[̀-ͯ]/g` foi escrita como literal de combining marks
   (`[̀-ͯ]`). Funciona em runtime moderno mas e fragil em copy/paste de editores
   diferentes e a leitura visual confunde reviewers. Sugiro substituir por
   `/[̀-ͯ]/g`, mais explicito e seguro.

5. **apps/api/src/contacts/csv-import.ts:101–106** — O parsing usa
   `Papa.NODE_STREAM_INPUT` mas, ao final, todas as linhas sao acumuladas em
   `rowsToProcess` antes de processar uma a uma. Para CSVs grandes (limite atual e
   5MB) ainda e tolerado, mas perde-se a vantagem de streaming. Como
   `service.upsertByPhone` faz `findUnique` + `create/update` por linha, o gargalo
   real e o banco; valeria processar dentro do `parseStream.on('data')` ou usar
   `prisma.$transaction` em lote para reduzir round-trips.

6. **apps/api/src/contacts/contact.routes.ts:96–115** — O loop em
   `import-whatsapp` reporta `errors` com `row: i + 1`, o que pode confundir o
   cliente quando combinado com `summary` reutilizando `csvImportRowErrorSchema`
   (rotulos remetem a CSV). Sugiro criar `whatsappImportRowErrorSchema` ou apenas
   usar `phone`/`name` como identificador no payload de erro para melhorar UX.

7. **apps/api/src/contacts/contact.routes.ts:60-77** — Os handlers de
   `PUT /:id` e `DELETE /:id` aceitam qualquer string como `id`. Validar como UUID
   via Zod evitaria 500 do Prisma em ids absurdos (ex.: SQL injection-like) e
   garantiria mensagens 400 padronizadas.

8. **apps/web/app/contacts/contacts-client.tsx:61-68** — O effect que dispara a
   busca debounced ignora intencionalmente `refresh` da dependencia (eslint
   disabled). Funciona, mas atualizar `refresh` para usar `useEvent`/ref para
   `search`/`page` (em vez de capture no `useCallback`) deixaria o hook honesto.
   Alternativa simples: trocar `[search]` por `[search]` com `void refresh(1, search)`
   chamado via `refreshRef.current(...)`. Ponto pequeno mas evita futuras
   regressoes quando o componente crescer.

9. **apps/web/components/Modal.tsx:38** — `aria-labelledby="modal-title"` usa um
   id fixo. Se mais de um `Modal` for montado simultaneamente (ex.: confirmacao
   sobre confirmacao), o leitor de tela ficara ambiguo. Trocar por `useId()` (como
   ja e feito no `ContactForm`) elimina o risco.

10. **apps/web/components/ContactForm.tsx:7** — Import cruzado de
    `contacts.module.css` dentro de um componente em `apps/web/components/` cria um
    acoplamento reverso (componentes nao deveriam depender de estilos da page).
    Mover botoes `.primary/.secondary/.ghost` para um modulo compartilhado (ex.
    `Button.module.css`) destacaria a fronteira e evita ciclos de import futuros.

## Destaques Positivos

- **Modelagem de dominio limpa**: `ContactService` separa parsing, normalizacao,
  persistencia e dto bem; o uso de `ContactConflictError`/`ContactNotFoundError`
  permite que o router devolva codigos HTTP precisos sem `if (err.code)` espalhado.
- **`upsertByPhone` faz merge de vars** corretamente, preservando chaves antigas
  e atualizando as novas. Testado com `cidade: SP` + `idade: 30` e validado no
  unit test.
- **Migration FR5 cuidadosa**: usar `SetNull` em ExecutionLog mantem o historico
  rastreavel e o teste `preserves ExecutionLog rows when contact is deleted`
  comprova o comportamento end-to-end.
- **Tratamento de SessionError em `/api/whatsapp/contacts`** com retorno 503 e
  mensagem amigavel na UI (`Conecte o WhatsApp antes de importar contatos.`)
  oferece DX/UX consistente com Task 3.0.
- **Acessibilidade da tela /contacts**: labels semanticos, `aria-invalid`,
  `aria-describedby`, `role="alert"`/`role="status"` para feedback, `inputMode="tel"`,
  fechamento via ESC e click fora no modal. Aderente ao PRD §UX.
- **Schemas Zod cobrem todo o ciclo** (request/response/error). O reuso pelo
  cliente web via `@app/shared-types` minimiza drift contratual.
- **Suite de testes solida**: 23 testes especificos da task (10 phone + 8 service
  + 5 csv + 7 integration + 3 web). Cobertura cobre cenarios criticos: CRUD,
  conflito, parsing de datas BR, BOM UTF-8, headers ausentes, FR5, importacao
  WhatsApp via driver fake e propagacao do 503.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | OK (status codes 200/201/204/400/404/409/503 utilizados corretamente) |
| Logging | OK (nao foi necessario logger custom nesta task; servico nao loga, padroes mantidos) |
| React | OK (RSC para fetch inicial, client component para interacao, hooks bem usados) |
| Testes | OK (84/84 passando, cobre unit + integration + render) |

Observacoes adicionais:

- **Tech Spec**: a entrega segue o que o techspec descreve em `Modelos de Dados`,
  `Endpoints de API` e `Pontos de Integracao` (`papaparse`, `multer`). A unica
  diferenca sutil e que `Contact.vars` foi armazenado como `String` JSON em vez
  de `Json` por causa do provider SQLite — decisao tecnicamente correta e
  documentada implicitamente no schema.
- **PRD**: cumpre FR1 (cadastro com nome/telefone/birthdate/vars), FR2 (CSV),
  FR3 (WhatsApp) e FR5 (delete preserva ExecutionLog). FR4 (listas) nao era
  escopo desta task.
- **Tarefa explicitamente nao entregue**: testes E2E Playwright dos fluxos
  ancora. A divida ja esta declarada no resumo e nao bloqueia o aceite, mas deve
  ser registrada em uma tarefa de follow-up junto com o item equivalente da Task
  3.0.

## Recomendacoes

1. Substituir o regex de remocao de combining marks em `csv-import.ts` por
   `/[̀-ͯ]/g` para legibilidade e robustez (minor #4).
2. Validar `id` dos endpoints `PUT/DELETE /api/contacts/:id` com `z.string().uuid()`
   para garantir 400 consistente (minor #7).
3. Extrair os estilos `.primary/.secondary/.ghost` para um modulo compartilhado e
   parar de importar `contacts.module.css` de dentro de `components/` (minor #10).
4. Usar `useId()` para o `aria-labelledby` do Modal (minor #9).
5. Avaliar processar as linhas do CSV dentro do callback `data` do parseStream,
   ou ao menos agrupar em `prisma.$transaction` para reduzir round-trips no
   importador (minor #5).
6. Criar tarefa de follow-up para os testes Playwright E2E (Task 3.0 + Task 4.0)
   conforme citado nas Observacoes.
7. Documentar em `update`/`create` (`contact.service.ts`) que `parseBirthdate`
   retornar `null` exige que o caller ja tenha validado a string — ou jogar erro
   na service para defesa em profundidade (minor #3).
8. Para futuras evolucoes que tratem o worker (`SchedulerWorker`), garantir que
   `ExecutionLog.contactId === null` seja apresentado como "contato removido"
   nos relatorios.

## Veredito

**APROVADO COM OBSERVACOES**. A Task 4.0 esta funcionalmente completa, com
qualidade de codigo alta, testes verdes (84/84) e conformidade integral com PRD
e Tech Spec para os requisitos definidos. As observacoes listadas sao
melhorias incrementais (minor) que podem ser endereçadas em uma tarefa de
polimento ou nas proximas iteracoes, sem impedir o avanço para a Task 5.0
(Mídia + Templates + Preview). A unica divida explicita e os testes E2E
Playwright — recomendo abrir um item de divida tecnica unindo Tasks 3.0 e 4.0
antes de fechar o PRD.

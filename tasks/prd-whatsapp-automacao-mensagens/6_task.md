# Tarefa 6.0: Midia, Template Engine e Pre-visualizacao de Mensagem

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar (a) upload e armazenamento local de midia (FR15, FR16) via `multer`, (b) `TemplateEngine` para interpolacao de variaveis (FR14) e (c) endpoint `POST /schedules/preview` que renderiza texto final + midia anexada (FR17). Tambem entrega o componente de pre-visualizacao no frontend que sera reutilizado na tela de Agendamentos.

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `frontend-design` (global) — preview de mensagem com fidelidade visual.
- `vercel-react-best-practices` (global).
</skills>

<requirements>
- `MediaService` que salva arquivos em `storage/media/<uuid>.<ext>` e cria registro em `Media`.
- Endpoint `POST /api/media/upload` (multipart) suportando imagem, GIF, video, audio, PDF e planilhas.
- Limite de tamanho configuravel e validacao de mimetype.
- `TemplateEngine` com regex `\{(\w+)\}` resolvendo `contact.name`, `contact.vars[*]`, `now()` e `data/hora` formatados no timezone de Settings.
- Endpoint `POST /api/schedules/preview` recebe `{ messageText, messageMedia, contactId? }` e retorna `{ renderedText, mediaUrls }`.
- Componente React `MessagePreview` reutilizavel.
- Variaveis ausentes nao quebram render (substituidas por placeholder ou removidas conforme regra definida e documentada).
</requirements>

## Subtarefas

- [x] 6.1 Implementar `MediaService` em `apps/api/src/media/media.service.ts` e criar `storage/media/` (gitignored).
- [x] 6.2 Implementar `media.routes.ts` com `POST /api/media/upload` via multer (limites configuraveis em env).
- [x] 6.3 Implementar `TemplateEngine` em `apps/api/src/templates/template.engine.ts`.
- [x] 6.4 Implementar endpoint `POST /api/schedules/preview` com validacao Zod.
- [x] 6.5 Implementar `apps/web/components/MessagePreview.tsx` para renderizar texto + thumbnails de midia.
- [x] 6.6 Implementar componente `MediaUploader.tsx` consumindo `/api/media/upload`.
- [x] 6.7 Escrever testes da tarefa (ver secao Testes).
- [x] 6.8 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Interfaces Principais - TemplateEngine", "Pontos de Integracao - multer" e "Endpoints de API - /media/upload e /schedules/preview". Estrategia de regex e ausencia de motor externo em "Decisoes Principais - Variaveis sem motor externo".

## Criterios de Sucesso

- Upload de PNG/PDF retorna `{ id, path, mimeType, sizeBytes }`.
- `TemplateEngine.render("Ola {nome}, hoje e {data}", ctx)` retorna texto correto no timezone configurado.
- `POST /schedules/preview` com `contactId` retorna texto interpolado para aquele contato.
- Componente `MessagePreview` exibe texto final e cartoes de midia (imagem inline, demais como link/icone).

## Testes da Tarefa

- [ ] Testes de unidade: `TemplateEngine` com variaveis presentes/ausentes, escaping de chaves literais, vars custom, format de `data/hora` em multiplos timezones (incluindo DST).
- [ ] Testes de integracao: upload via `supertest` (PNG, PDF), validacao de mimetype invalido, `POST /schedules/preview` com contato salvo gerando texto correto.
- [ ] Testes E2E (basico): render do componente `MessagePreview` em Playwright/Testing Library com props simulando resposta da API.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/media/media.service.ts`
- `apps/api/src/media/media.routes.ts`
- `apps/api/src/templates/template.engine.ts`
- `apps/api/src/schedules/preview.routes.ts`
- `apps/api/test/template.engine.test.ts`
- `apps/api/test/media.integration.test.ts`
- `apps/api/test/preview.integration.test.ts`
- `apps/web/components/MessagePreview.tsx`
- `apps/web/components/MediaUploader.tsx`
- `storage/media/` (gitignored)

# Review: Task 6 - Midia, Template Engine e Pre-visualizacao de Mensagem

**Revisor**: AI Code Reviewer
**Data**: 2026-06-25
**Arquivo da task**: 6_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Tarefa 6.0 entrega tres capacidades centrais do PRD: (a) upload e armazenamento local de midia via `MediaService` + rotas multer; (b) `TemplateEngine` com interpolacao de variaveis built-in (`{nome}`, `{phone}`, `{data}`, `{hora}`, `{now}`, `{aniversario}`) e customizadas (`contact.vars`), com escape e formatacao timezone-aware via `Intl.DateTimeFormat`; (c) endpoint `POST /api/schedules/preview` que orquestra contato salvo + render + midia anexada; alem dos componentes React `MessagePreview` e `MediaUploader` no dashboard.

A implementacao esta coerente com a Tech Spec, bem isolada em modulos, com tipagem forte (sem `any`), validacao Zod nos endpoints, classes de erro tipadas (`MediaValidationError`, `MediaNotFoundError`), e cobertura de testes solida: 30 testes novos (11 unidade do `TemplateEngine`, 6 integracao midia, 4 integracao preview, 5 + 4 componentes React) — todos verdes junto com o restante (107 API, 23 web, 19 shared-types). Lint e typecheck passam em todos os workspaces.

A qualidade geral e alta. Identifiquei apenas observacoes pontuais (sem bloqueadores) ligadas a YAGNI, vazamento de path interno na resposta da API e pequenos pontos de robustez.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| apps/api/src/media/media.service.ts | OK | 2 minor |
| apps/api/src/media/media.routes.ts | OK | 1 minor |
| apps/api/src/templates/template.engine.ts | OK | 1 minor |
| apps/api/src/schedules/preview.routes.ts | OK | 0 |
| apps/api/src/config/env.ts | OK | 0 |
| apps/api/src/server.ts | OK | 0 |
| packages/shared-types/src/media.ts | OK | 0 |
| packages/shared-types/src/schedule.ts | OK | 0 |
| packages/shared-types/src/index.ts | OK | 0 |
| apps/web/components/MessagePreview.tsx | OK | 1 minor |
| apps/web/components/MediaUploader.tsx | OK | 1 minor |
| apps/web/components/MessagePreview.module.css | OK | 0 |
| apps/web/components/MediaUploader.module.css | OK | 0 |
| apps/web/lib/api-client.ts | OK | 0 |
| apps/api/test/template.engine.test.ts | OK | 0 |
| apps/api/test/media.integration.test.ts | OK | 0 |
| apps/api/test/preview.integration.test.ts | OK | 0 |
| apps/web/test/message-preview.test.tsx | OK | 0 |
| apps/web/test/media-uploader.test.tsx | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**M1 — `MediaService.delete` e dead code (YAGNI).**
Arquivo: `apps/api/src/media/media.service.ts:121-130`.
O metodo `delete()` foi criado mas nenhuma rota nem servico atual o consome (`grep` em todo `apps/api/src/` confirma zero uso). O proprio autor sinalizou o ponto. Como o projeto adota Clean Code estrito e a Tech Spec nao demanda `DELETE /media/:id` no MVP, o ideal e remover ate que a Task 9 (limpeza/garbage collection de midia orfa, se aplicavel) chegue. Manter dead code dificulta entender quem e dono do contrato e abre porta para chamar sem teste.
Correcao sugerida: remover por enquanto. Quando uma feature consumir, traga junto com o caller + testes.

```ts
// remover bloco completo:
async delete(id: string): Promise<void> { ... }
```

**M2 — `path` interno do filesystem e exposto na resposta da API.**
Arquivo: `apps/api/src/media/media.service.ts:143-154` (DTO `rowToDto`) e `packages/shared-types/src/media.ts:27-36` (schema).
O DTO expoe `path: "storage/media/<uuid>.<ext>"`. Para uso pessoal local isso e tolerable, mas vaza o layout de storage interno e nada o consome no frontend (`MessagePreview` usa apenas `url`/`mimeType`/`fileName`/`kind`/`sizeBytes`). Mais higienico manter `path` apenas como detalhe de persistencia/servidor.
Correcao sugerida: criar dois tipos — `Media` (publico, sem `path`) e `MediaRecord` (interno). Ou marcar `path` como opcional no schema publico e omiti-lo em `rowToDto`. Atualizar testes que verificam `existsSync(res.body.path)` para consultar via `service.findById(id)` direto.

**M3 — Placeholders `__OPEN__`/`__CLOSE__` do `TemplateEngine` podem colidir com input do usuario.**
Arquivo: `apps/api/src/templates/template.engine.ts:17-18, 36, 48`.
Se o `template` recebido contiver literalmente `__OPEN__` ou `__CLOSE__`, ele vira `{` ou `}` apos o segundo `.split()`. Cenario pouco provavel em pratica, mas e um caso de borda nao coberto pelos testes e a correcao e trivial.
Correcao sugerida: usar tokens com probabilidade desprezivel de colisao (caracteres do PUA Unicode), por exemplo:

```ts
const PLACEHOLDER_OPEN = '';
const PLACEHOLDER_CLOSE = '';
```

E adicionar um teste como:

```ts
it('preserva sequencias __OPEN__/__CLOSE__ no texto', () => {
  const r = engine.render('debug __OPEN__ {nome} __CLOSE__', {
    contact: makeContact(),
    now: REFERENCE,
    tz: 'America/Sao_Paulo',
  });
  expect(r.text).toBe('debug __OPEN__ Irene __CLOSE__');
});
```

**M4 — `MessagePreview` injeta `mediaBaseUrl` via concatenacao simples sem normalizar barras.**
Arquivo: `apps/web/components/MessagePreview.tsx:29, 59`.
`const src = ` `${base}${m.url}` ` ` produz URL invalida se o caller passar `mediaBaseUrl="http://api.local/"` (trailing slash) — vira `http://api.local//api/media/...`. Funcional em maioria dos browsers, mas inconsistente. Normalize com `URL` ou regex.
Correcao sugerida:

```ts
function joinUrl(base: string, path: string): string {
  if (!base) return path;
  return `${base.replace(/\/$/, '')}${path.startsWith('/') ? path : `/${path}`}`;
}
// ...
const src = joinUrl(base, m.url);
```

**M5 — `MediaUploader` aceita o mesmo arquivo duas vezes sem validar duplicidade por hash/nome.**
Arquivo: `apps/web/components/MediaUploader.tsx:39-65`.
O componente nao tem nenhuma protecao contra anexar o mesmo arquivo (mesmo `originalname` + `size`) duas vezes, e cada upload reposta no servidor (gerando duas `Media` rows com o mesmo conteudo). Para um app pessoal isso pode ser proposital (anexar dois PDFs com mesmo nome), mas no minimo vale alertar.
Correcao sugerida: opcional — checar no client se o `fileName` ja existe na lista atual e perguntar/avisar. Alternativa: dedupe servidor por checksum (sha256 do buffer) — fica para outra task.

**M6 — `MediaService.readBuffer` carrega arquivo inteiro em memoria em vez de stream.**
Arquivo: `apps/api/src/media/media.service.ts:114-119`, consumido em `media.routes.ts:62-73`.
Com `MEDIA_MAX_MB=25` o impacto e contido, mas `res.status(200).end(data)` aloca o buffer completo por request. Idealmente usar `fs.createReadStream(media.path).pipe(res)` (ou `res.sendFile`) que e zero-copy.
Correcao sugerida: substituir `readBuffer` por `streamFile` que retorna um `Readable` + metadata; atualizar o handler para pipe.

**M7 — Input file no `MediaUploader` nao tem `aria-label`/`<label>` associado.**
Arquivo: `apps/web/components/MediaUploader.tsx:89-97`.
O input esta visualmente escondido (clip-rect) e nao tem label nem `aria-label`. O botao dropzone tem o `aria-describedby` apontando para o hint, o que cobre o usuario de teclado, mas a11y audits (ex. axe) frequentemente sinalizam o input. Como o input e trigger meramente programatico, adicionar `aria-hidden="true"` + `tabIndex={-1}` deixa explicita a intencao e silencia o aviso.

```tsx
<input
  ref={inputRef}
  id={inputId}
  className={styles.input}
  type="file"
  accept={accept}
  onChange={handleChange}
  disabled={disabled || uploading}
  aria-hidden="true"
  tabIndex={-1}
/>
```

## Destaques Positivos

- **Validacao defensiva em duas camadas**: o `multer.fileFilter` rejeita mimetypes nao permitidos antes mesmo de ler o body, e `MediaService.save` revalida (`isAllowedMime`, tamanho, buffer vazio) garantindo que chamadas internas tambem sejam seguras. Erros classificados em `MediaValidationError` mapeiam para HTTP 400/413 de forma consistente.
- **Testes cobrem cenarios reais**, nao apenas happy path: rejeicao de mimetype, 413 por tamanho, retorno binario via GET, ausencia do campo `file`, ordenacao de midias por `order` no preview, e teste de DST com timezone real (`America/New_York` 2026-03-08 spring-forward) — esse ultimo e justamente o tipo de bug sutil que a Tech Spec sinaliza como risco.
- **Tipagem rigorosa**: zero `any`, uso correto de `override readonly name`, classes de erro nomeadas, `unknown` no `catch` com narrowing. `MediaService` e injetado via construtor, facilitando testes.
- **`TemplateEngine` resolve precedencia certa**: built-ins ganham de `vars` com mesmo nome (teste `ignora nomes reservados quando ha var com mesmo nome`) — decisao explicita e testada.
- **Schemas compartilhados** (`mediaSchema`, `schedulePreviewRequestSchema`, `messageMediaItemSchema`) com tipos derivados via `z.infer` reutilizados no client (`uploadMedia`, `previewSchedule`) — single source of truth e exatamente o objetivo do `packages/shared-types`.
- **`MEDIA_MAX_MB` configuravel via env** com default coerente (25 MB), parseado com fallback seguro contra valores invalidos (`Number.isFinite && > 0`). Bom uso de `loadConfig(env)` injetavel nos testes (vide `media.integration.test.ts:32-37`).
- **CSS-modules isolados** e estilo consistente com os componentes ja existentes (variaveis CSS `--surface`, `--text-muted`, etc.).
- **Limpeza de recursos nos testes** (`mkdtempSync` + `rmSync` no `afterAll`) garante que cada execucao parte de diretorios temporarios novos — bom higiene.
- **Documentacao do trade-off `Intl` vs `date-fns-tz`** na descricao da task: a escolha e correta para apenas formatar (`Intl.DateTimeFormat` ja resolve DST, validado nos testes); `date-fns-tz` so faz sentido quando vier aritmetica de tempo (proxima task).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | OK |
| Logging | Problemas (vide nota) |
| React | OK |
| Testes | OK |

Nota sobre Logging: nenhum dos novos handlers usa `logger.info/warn/error`. O padrao do projeto ate aqui ja era assim (contact.routes, list.routes etc. nao logam tambem), entao **nao e regressao desta task**. Vale levar para uma task transversal de observabilidade junto com `/api/metrics` (Tech Spec §Monitoramento).

Checagens executadas localmente (resultado real desta revisao):

```
npm run typecheck → 3 workspaces, 0 erros
npm run lint      → 3 workspaces, "ESLint: No issues found"
npm test          → api 107 / web 23 / shared-types 19 — todos verdes
```

## Recomendacoes

1. **(Minor — pequena limpeza)** Remover `MediaService.delete()` ate que exista caller real (M1). Mantenha o codigo enxuto.
2. **(Minor — higiene de contrato)** Omitir `path` interno do DTO publico `Media` ou separar em `MediaRecord` vs `MediaPublic` (M2). Atualizar `media.integration.test.ts:62` para nao depender de `res.body.path`.
3. **(Minor — robustez do parser)** Trocar `__OPEN__`/`__CLOSE__` por sentinelas Unicode PUA e cobrir com teste (M3).
4. **(Minor — robustez de URL)** Adicionar helper `joinUrl(base, path)` no `MessagePreview` para tolerar `mediaBaseUrl` com/sem trailing slash (M4).
5. **(Minor — UX/eficiencia)** Avaliar dedupe de anexos no `MediaUploader` (alerta simples por `fileName`) (M5). Postergar checksum-based dedupe.
6. **(Minor — performance/memoria)** Trocar `readBuffer` por stream (`createReadStream` + `pipe`) no handler `GET /api/media/:id/file` (M6).
7. **(Minor — a11y)** Acrescentar `aria-hidden="true"` + `tabIndex={-1}` ao input file escondido no `MediaUploader` (M7).
8. **(Acompanhamento — fora do escopo desta task)** Cobrir as outras rotas com `logger.info` e expor `/api/metrics` numa task transversal de observabilidade. Avaliar tambem rate-limit e middleware `x-api-key` (Tech Spec §Endpoints) antes do MVP ir ao ar.
9. **(Acompanhamento — Task 7)** Quando entrar `ScheduleEngine`, trazer `date-fns-tz` para aritmetica timezone-aware (somar dias, comparar wall-clock, calcular proxima ocorrencia em DST boundary).

## Veredito

**APROVADO COM OBSERVACOES.**

Todos os criterios de sucesso da Tarefa 6.0 estao cumpridos:
- Upload PNG/PDF retorna `{ id, path, mimeType, sizeBytes, kind, url, fileName, createdAt }` (HTTP 201) — validado em `media.integration.test.ts`.
- `TemplateEngine.render("Ola {nome}, hoje e {data}", ctx)` retorna texto correto em `America/Sao_Paulo` e outros timezones, incluindo transicao DST — validado em `template.engine.test.ts`.
- `POST /api/schedules/preview` com `contactId` resolve o contato salvo e renderiza texto interpolado — validado em `preview.integration.test.ts`.
- `MessagePreview` exibe texto, lista variaveis ausentes, renderiza thumbnail para imagem e icone para documento/video/audio — validado em `message-preview.test.tsx`.

Todos os checks (`typecheck`, `lint`, `test`, `build`) sao verdes em 3 workspaces. As 7 observacoes listadas sao melhorias incrementais (YAGNI, robustez de URL, a11y, dead code), nenhuma bloqueia a entrega. Recomendo absorver M1, M3 e M7 antes do merge (sao mudancas triviais), e tratar M2, M4, M5, M6 como follow-ups (issues separadas) — voce escolhe a estrategia.

Pode prosseguir para a Tarefa 7 (`ScheduleEngine + BullMQ + SchedulerWorker`).

# Tarefa 3.0: Conexao WhatsApp via QR Code

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o `WhatsAppService` baseado em `whatsapp-web.js` com `LocalAuth`, expondo conexao via QR Code, status da sessao e desconexao. Tambem disponibilizar um driver `fake` para testes (`WHATSAPP_DRIVER=fake`) e a tela de Conexao no frontend com QR e estado da sessao, alertando o usuario quando a sessao expira (FR23-FR25).

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `frontend-design` (global) — tela de Conexao com estado/erro visiveis.
- `vercel-react-best-practices` (global) — polling no client component.
</skills>

<requirements>
- `WhatsAppService` singleton hospedado no processo da API.
- Interface da techspec implementada: `connect`, `getQrCode`, `getStatus`, `disconnect`, `sendText`, `sendMedia`, `listContacts`.
- Driver `fake` que respeita a mesma interface; selecionavel via `WHATSAPP_DRIVER=fake`.
- Endpoints `GET /api/whatsapp/status`, `POST /api/whatsapp/connect`, `POST /api/whatsapp/disconnect`.
- Classificacao de erros em `SessionError` x `SendError` (techspec "Pontos de Integracao").
- Atualiza `Settings.whatsappConnected` em transicoes de estado.
- Tela `apps/web/app/connect/page.tsx` exibindo QR (renderizando o data URL), status atual e botoes de conectar/desconectar.
- Polling do frontend: 1s enquanto QR pendente; 30s em `ready` (techspec "Eventos para o dashboard").
- LocalAuth aponta para `storage/wwebjs/` (gitignored).
- Aviso explicito de risco de ban no onboarding.
</requirements>

## Subtarefas

- [x] 3.1 Criar diretorio `storage/wwebjs/` (gitignored) e adicionar variavel de ambiente `WHATSAPP_DRIVER` (defaults: `real` em prod, `fake` em testes).
- [x] 3.2 Implementar interface `WhatsAppService` em `apps/api/src/whatsapp/whatsapp.service.ts`.
- [x] 3.3 Implementar `whatsapp.real.ts` usando `whatsapp-web.js` + `LocalAuth`, com eventos `qr`, `ready`, `disconnected`.
- [x] 3.4 Implementar `whatsapp.fake.ts` com sinks em memoria, simulacao de QR e ready.
- [x] 3.5 Implementar factory `createWhatsAppService` que escolhe driver por env.
- [x] 3.6 Implementar `whatsapp.controller.ts` e `whatsapp.routes.ts` (status/connect/disconnect).
- [x] 3.7 Atualizar `Settings.whatsappConnected` em eventos relevantes do service.
- [x] 3.8 Implementar `apps/web/app/connect/page.tsx` com QR + status + reconexao + aviso de risco.
- [x] 3.9 Escrever testes da tarefa (ver secao Testes).
- [x] 3.10 Executar `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Interfaces Principais - WhatsAppService", "Pontos de Integracao" (config do `LocalAuth`), "Riscos Conhecidos - Sessao expirando" e "Eventos para o dashboard" (politica de polling).

## Criterios de Sucesso

- Com `WHATSAPP_DRIVER=fake`, `POST /api/whatsapp/connect` move o status para `qr` e expoe um QR fake; `getStatus()` retorna `qr` no driver fake.
- Driver fake simula transicao para `ready` apos confirmacao programatica (util para testes).
- Tela de Conexao mostra QR, atualiza status conforme polling e exibe banner de alerta quando `disconnected`.
- Reconectar pelo dashboard reinicializa o cliente sem perder configuracoes.

## Testes da Tarefa

- [ ] Testes de unidade: factory do service escolhe driver correto por env; estados emitidos pelo driver fake; classificacao de erros em `SessionError` x `SendError`.
- [ ] Testes de integracao: API + driver fake; `supertest` cobrindo o ciclo conectar -> qr -> ready -> desconectar e mudanca de `Settings.whatsappConnected`.
- [ ] Testes E2E (Playwright basico): com driver fake, abrir `/connect`, clicar em "Conectar", validar exibicao do QR e transicao para "ready" simulada via hook de teste.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/api/src/whatsapp/whatsapp.service.ts`
- `apps/api/src/whatsapp/whatsapp.real.ts`
- `apps/api/src/whatsapp/whatsapp.fake.ts`
- `apps/api/src/whatsapp/whatsapp.factory.ts`
- `apps/api/src/whatsapp/whatsapp.controller.ts`
- `apps/api/src/whatsapp/whatsapp.routes.ts`
- `apps/api/test/whatsapp.service.test.ts`
- `apps/api/test/whatsapp.integration.test.ts`
- `apps/web/app/connect/page.tsx`
- `apps/web/components/QrCodeDisplay.tsx`
- `apps/web/components/SessionStatusBadge.tsx`
- `storage/wwebjs/` (gitignored)

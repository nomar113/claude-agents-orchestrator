# nfce-extraction-service

Microserviço interno (Node.js + TypeScript + Playwright) responsável por consultar a SEFAZ-RJ e extrair os dados de uma NFC-e do lado servidor, resolvendo o bloqueio anti-bot que hoje impede a leitura via WebView no app. Consumido internamente pelo backend Kotlin (`controlai`) através de `POST /extract`.

## Variáveis de ambiente

| Variável | Obrigatória | Default | Descrição |
|---|---|---|---|
| `X_INTERNAL_KEY` | Sim | — | Segredo compartilhado exigido no header `X-Internal-Key` de toda chamada a `POST /extract`. Sem essa variável configurada, `POST /extract` rejeita **todas** as requisições com `401` (fail-closed). |
| `EXTRACTION_TIMEOUT_MS` | Não | `60000` | Tempo máximo (ms) que `extractInvoice` aguarda a nota ficar pronta/bloqueada antes de resolver como `TIMEOUT`. Mesma ordem de grandeza do timeout já usado no fluxo client-side (`PAGE_LOAD_TIMEOUT_MS` em `controlai-frontend`). |
| `PORT` | Não | `3000` | Porta HTTP do servidor. |
| `HOST` | Não | `0.0.0.0` | Interface de bind do servidor. |

## Endpoints

- `POST /extract` — **interno**, protegido por `X-Internal-Key`. Recebe `{ "invoiceUrl": string }` e retorna `ExtractionResult` (`{ status: 'READY'|'BLOCKED'|'TIMEOUT'|'NAVIGATION_ERROR', data?, message? }`).
  - `401` se o header `X-Internal-Key` estiver ausente ou incorreto.
  - `400` se `invoiceUrl` estiver ausente ou não for uma string.
- `GET /health` — público (sem autenticação), para uso do healthcheck do Docker. Retorna `200 { "status": "ok" }`.

## Rede

`POST /extract` não é destinado a exposição pública. O bind default (`0.0.0.0:3000`) permite que o serviço seja alcançado pelo backend Kotlin via rede interna do Docker/VPS, mas **não** deve ter sua porta publicada para a internet — isso é reforçado pelo header `X-Internal-Key` como defesa em profundidade, mas a garantia efetiva de isolamento de rede (sem mapeamento de porta pública, rede Docker interna/firewall) é responsabilidade da Tarefa 4.0/infra, não deste servidor em si.

## Scripts

```bash
npm install
npx playwright install chromium   # baixa o binário do Chromium usado pelo Playwright
npm run typecheck                 # tsc --noEmit
npm test                          # jest (unidade + integração, sempre contra fixtures locais, nunca a SEFAZ real)
npm run build                     # compila para dist/
npm start                         # roda a partir de dist/server.js
npm run dev                       # roda a partir de src/server.ts via ts-node
```

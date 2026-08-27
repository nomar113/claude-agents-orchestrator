# Tech Spec: Extração Server-Side de Dados de NFC-e (RJ)

## Resumo Executivo

A extração passa a rodar num **microserviço Node.js dedicado** (Playwright + stealth), chamado de forma síncrona por um **novo endpoint no backend Kotlin** (`POST /purchases/invoice/extraction`). O backend Kotlin já é JVM/Spring, sem tooling nativo de automação de browser com evasão de anti-bot (isso só existe maduro no ecossistema Node/Python); isolar essa responsabilidade num serviço separado evita acoplar um processo Chromium pesado ao processo principal e dá acesso às libs de stealth necessárias para vencer o desafio F5/TSPD da SEFAZ-RJ. O fluxo de persistência (`POST /purchases/invoice`, assíncrono via SQS) **não muda** — o app continua chamando-o normalmente depois de receber os dados extraídos, conforme já definido no PRD (FR9).

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **`nfce-extraction-service`** (novo, Node.js/TypeScript): microserviço interno com Playwright + `playwright-extra`/stealth. Expõe `POST /extract` e `GET /health`. Mantém um browser Chromium de vida longa (evita o custo de boot a cada request) e abre um `BrowserContext` isolado por requisição. Porta a lógica de `isInvoiceReadyRJ`, `getBlockMessageRJ` e `extractDataFromRJ` (hoje em `extract_data_scripts/rj.js`) para `page.evaluate`.
- **`NfceExtractionGateway`** (novo, Kotlin, porta em `domain/purchases_invoices/gateway/`): interface que o domínio usa para pedir a extração, sem conhecer HTTP/Playwright.
- **`NfceExtractionHttpProvider`** (novo, Kotlin, `application/purchases_invoices/application/`): implementa o gateway via chamada HTTP síncrona ao `nfce-extraction-service`.
- **`ExtractPurchaseInvoiceUseCase`** (novo, `domain/purchases_invoices/usecase/`): valida a URL, extrai a `accessKey`, checa duplicidade (reaproveitando `PurchaseInvoiceRepository.countByAccessKey`, já usado por `SavePurchaseInvoiceProvider`) e delega ao gateway.
- **`PurchaseInvoiceController`** (existente, modificado): ganha o método `POST /invoice/extraction`, síncrono, reaproveitando a mesma autenticação JWT do endpoint atual.
- **`purchase_invoices` / `purchase_items` / `purchase_payments`**, `PurchaseInvoiceQueueListener`, SQS: **inalterados** — o fluxo de persistência continua exatamente como está hoje.

Fluxo: App → `POST /purchases/invoice/extraction {invoiceUrl}` (Kotlin) → checa duplicidade → `POST /extract` (Node, interno) → Playwright navega, faz polling de prontidão/bloqueio, extrai dados → Kotlin devolve os campos extraídos ao app → App chama `POST /purchases/invoice` (existente, inalterado) para persistir.

## Design de Implementação

### Interfaces Principais

```kotlin
fun interface NfceExtractionGateway {
    fun extract(invoiceUrl: InvoiceUrl): Result<ExtractedPurchaseInvoice>
}

@Component
class ExtractPurchaseInvoiceUseCase(
    private val extractionGateway: NfceExtractionGateway,
    private val purchaseInvoiceRepository: PurchaseInvoiceRepository,
) {
    fun execute(invoiceUrl: InvoiceUrl): Result<ExtractedPurchaseInvoice> = runCatching {
        val accessKey = AccessKey.fromInvoiceUrl(invoiceUrl)
        check(purchaseInvoiceRepository.countByAccessKey(accessKey.value) == 0L) { "Nota já registrada" }
        extractionGateway.extract(invoiceUrl).getOrThrow()
    }
}
```

```typescript
type ExtractionStatus = 'READY' | 'BLOCKED' | 'TIMEOUT' | 'NAVIGATION_ERROR';
interface ExtractionResult {
  status: ExtractionStatus;
  data?: ExtractedInvoice;
  message?: string;
}
async function extractInvoice(invoiceUrl: string): Promise<ExtractionResult>;
```

### Modelos de Dados

- **`ExtractPurchaseInvoiceRequest`** (Kotlin, request do novo endpoint): `{ invoiceUrl: String }`.
- **`ExtractedPurchaseInvoiceResponse`** (Kotlin, response do novo endpoint): mesmos campos hoje extraídos client-side — `merchantName, cnpj, merchantAddress, totalItems, subtotal, discount, total, taxes, date, items: [{productName, code, quantity, unit, unitPrice, totalPrice}], payments: [{type, value}]`. Formato pensado para o app conseguir montar o `PurchaseInvoiceRequest` do `/purchases/invoice` existente sem transformação adicional.
- **`ExtractedInvoice`** (Node, JSON de resposta do `/extract`): espelha 1:1 o `ExtractedPurchaseInvoiceResponse`.
- Nenhuma tabela nova — nada disso é persistido pelo novo endpoint; a persistência continua sendo responsabilidade exclusiva do fluxo existente.

### Endpoints de API

- `POST /purchases/invoice/extraction` — Kotlin, autenticado (JWT, mesmo padrão de `/purchases/invoice`). Recebe `{ invoiceUrl }`, retorna os campos extraídos ou erro. Síncrono, timeout de resposta ~60s.
- `POST /extract` — Node, **interno** (não exposto publicamente; acessível só via rede interna do Docker/VPS + header `X-Internal-Key` como defesa em profundidade). Recebe `{ invoiceUrl }`, retorna `ExtractionResult`.
- `GET /health` — Node, para healthcheck do Docker e verificação manual.

Mapeamento de erro no endpoint Kotlin (seguindo o padrão existente de `ResponseStatusException` por tipo de exceção, ver `mapAssociationError`):

| Situação | Status | Mensagem ao app |
|---|---|---|
| `accessKey` já registrada | 409 | "Nota já registrada" |
| SEFAZ bloqueou/recusou (`BLOCKED`) | 422 | mensagem repassada de `getBlockMessageRJ` |
| Tempo esgotado (`TIMEOUT`) | 504 | "Tempo esgotado ao consultar a SEFAZ" |
| Falha de navegação/serviço indisponível (`NAVIGATION_ERROR`, `nfce-extraction-service` fora do ar) | 502 | "Não foi possível consultar a SEFAZ" |

Essa distinção alimenta diretamente o FR11 do PRD (diferenciar bloqueio de timeout genérico na UI).

## Pontos de Integração

- **SEFAZ-RJ** (`consultadfe.fazenda.rj.gov.br`): única integração externa nova. Sem autenticação — acesso público via URL do QR Code. Tratamento de erro via a máquina de estados `READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR` do `nfce-extraction-service`.
- **Kotlin ↔ Node** (interno): HTTP simples, mesma VPS (São Paulo, já validada por `curl` como não bloqueada pelo WAF ao nível de rede). Autenticação via header compartilhado; sem exposição pública da porta do Node.

## Abordagem de Testes

### Testes Unidade

- Kotlin: `ExtractPurchaseInvoiceUseCase` testado com `NfceExtractionGateway` como lambda mockada (padrão de `UseCasesTest.kt`) — cenários: sucesso, duplicidade, bloqueio, timeout, erro de gateway. Controller testado isolado do Spring context (padrão de `PurchaseInvoiceControllerTest.kt`).
- Node: as funções de detecção/extração (portadas de `rj.js`) são funções puras de parsing de DOM — testáveis com fixtures HTML reais salvas de execuções bem-sucedidas/bloqueadas (Jest + JSDOM), sem depender de browser real.

### Testes de Integração

- Kotlin: `MockMvc` + `NfceExtractionGateway` fake (não mock de rede), verificando a costura controller → use case → mapeamento de status HTTP (padrão de `AssociateInvoiceControllerIntegrationTest.kt`).
- Node: `supertest` no `/extract`, mas contra um servidor HTTP local servindo fixtures da página da SEFAZ (sucesso e bloqueio), nunca contra a SEFAZ real em CI — chamadas reais e automatizadas de teste correm o risco de contribuir para o fingerprint anti-bot do IP de CI.

### Testes de E2E

Não recomendado automatizar via Playwright contra a SEFAZ real: é uma dependência externa protegida por anti-bot, e execuções repetidas de teste (CI, re-runs) aumentam o risco de o próprio pipeline ser bloqueado, mascarando falhas reais. Em vez disso, validação end-to-end fica como **checklist de smoke test manual** antes do rollout: escanear 3-5 notas RJ reais e confirmar sucesso, bloqueio tratado corretamente e timeout tratado corretamente.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. `nfce-extraction-service` (núcleo de extração + stealth) — maior incerteza técnica (taxa de sucesso contra o WAF), então vem primeiro e é validado manualmente contra a SEFAZ real antes de integrar o resto.
2. Dockerização e deploy do serviço na VPS de São Paulo; smoke test manual.
3. Gateway/provider/use case/endpoint no backend Kotlin, com checagem de duplicidade.
4. Testes unidade e integração (Kotlin e Node).
5. Integração do app (consumo do novo endpoint) — depende da API do passo 3 estar estável; tratada como trabalho separado no app cliente.

### Dependências Técnicas

- Docker instalado na VPS (a confirmar se já existe).
- RAM disponível na VPS para um processo Chromium de longa duração (~1-2GB) somado ao backend Kotlin já rodando ali.
- Definição do segredo compartilhado entre os dois serviços (variável de ambiente).

## Monitoramento e Observabilidade

- Kotlin: log SLF4J (padrão existente) em cada chamada ao `NfceExtractionGateway` — resultado (sucesso/bloqueio/timeout/erro) e duração, sem logar o HTML ou dados pessoais da nota.
- Node: log estruturado leve (ex: `pino`) por extração — status final e duração; sem persistir HTML da página.
- Sem Prometheus/Grafana hoje no projeto (e dashboard dedicado está explicitamente fora de escopo no PRD) — a métrica principal do PRD (% de sucesso no primeiro scan) é apurável, nesta versão, via análise manual desses logs.

## Considerações Técnicas

### Decisões Principais

- **Microserviço Node/Playwright separado**, em vez de Selenium dentro do próprio processo Kotlin: as libs de evasão de anti-bot (`playwright-extra` + stealth) só existem maduras em Node/Python; rodar num processo separado também isola o custo de memória do Chromium do backend principal.
- **Endpoint de extração separado do endpoint de persistência**: minimiza o raio de mudança — o fluxo assíncrono via SQS que já persiste corretamente hoje não é tocado.
- **Checagem de duplicidade antes de acionar o browser**: evita gastar uma sessão headless (cara e sob risco de contribuir para bloqueio) numa nota já registrada.

### Riscos Conhecidos

- Taxa real de sucesso do bypass (stealth + Chromium real) contra o desafio F5/TSPD da SEFAZ-RJ é desconhecida até validação em produção — mitigar com rollout gradual e smoke test manual antes de liberar amplamente.
- SEFAZ pode alterar o desafio anti-bot a qualquer momento, quebrando o bypass (mesma fragilidade que já existe hoje no fluxo client-side) — a lógica de detecção/extração fica isolada no `nfce-extraction-service` justamente para facilitar ajustes rápidos.
- **Achado não relacionado a esta feature, mas relevante**: `SavePurchaseInvoiceProvider` (fluxo existente de persistência) depende de `RequestContext`/`groupId` de escopo de requisição, mas é acionado a partir de um listener `@Scheduled` fora de qualquer request HTTP — potencial falha de tenancy pré-existente, fora do escopo desta spec, mas recomenda-se validar com o time antes ou depois deste rollout.
- Concorrência baixa (2-3 extrações simultâneas) mitiga tanto o consumo de RAM quanto o risco de padrão de tráfego suspeito vindo do mesmo IP da VPS, mas ainda existe o risco de, com uso continuado, esse IP também ser eventualmente fingerprintado — rotação de IP está explicitamente fora de escopo (PRD).

### Conformidade com Skills Padrões

Não há skills dedicadas nos repositórios `controlai` (backend) e `controlai-frontend`. O padrão de referência é o `CLAUDE.md` do backend (arquitetura hexagonal, `fun interface` para gateways, `*Provider` para implementações, `Result<T>`/`runCatching` para erros de domínio) — seguido integralmente pelos novos componentes Kotlin descritos acima.

### Arquivos relevantes e dependentes

**Backend Kotlin (`controlai`)**
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt` — ganha o novo método.
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/usecase/` — novo `ExtractPurchaseInvoiceUseCase`.
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/gateway/` — novo `NfceExtractionGateway`.
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/application/SavePurchaseInvoiceProvider.kt` — referência de padrão para o novo provider.
- `src/test/kotlin/.../PurchaseInvoiceControllerTest.kt`, `UseCasesTest.kt`, `AssociateInvoiceControllerIntegrationTest.kt`, `PaymentNotificationQueueListenerTest.kt` — padrões de teste a seguir.
- `build.gradle.kts` — nenhuma dependência nova necessária (cliente HTTP já disponível via Spring Web).

**Novo microserviço**
- `nfce-extraction-service/` (novo diretório/repo ou submódulo) — `src/server.ts`, `src/extractor.ts` (porta de `rj.js`), `Dockerfile`, `package.json` (`playwright`, `playwright-extra`, stealth plugin).

**Frontend (`controlai-frontend`, referência apenas — mudanças tratadas em task separada)**
- `src/context/InvoiceProcessingContext.tsx` — remove InAppBrowser/injeção de JS (FR8 do PRD), passa a chamar `POST /purchases/invoice/extraction`.
- `extract_data_scripts/rj.js` — lógica-fonte a portar para o `nfce-extraction-service`.

# Tarefa 4.0: Endpoint de webhook da Kiwify com idempotência

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Implementar o endpoint `POST /webhooks/kiwify` e o `HandleKiwifyWebhookUseCase`, que interpreta os eventos da Kiwify (`compra_aprovada`, `compra_recusada`, `compra_reembolsada`, `chargeback`, `subscription_canceled`, `subscription_late`, `subscription_renewed`) e atualiza a assinatura do grupo correspondente, de forma idempotente. Depende da Tarefa 3.0 (gateways de billing) e dos IDs de produto/token de webhook definidos na Tarefa 1.0.

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — controller REST, `Result<T>`, tratamento de exceção via `ResponseStatusException`, conforme padrão de `AuthController.kt`.
</skills>

<requirements>
- RF-9 e RF-10 do PRD: compra aprovada libera acesso; cancelamento/reembolso/estorno revoga acesso.
- Tech Spec `Pontos de Integração`: autenticação por token compartilhado (`KIWIFY_WEBHOOK_TOKEN`), mapeamento de plano por ID de produto (`kiwify.product.annual-id`, `kiwify.product.lifetime-id`).
- Tech Spec `Endpoints de API`: `POST /webhooks/kiwify?token={secret}`, sempre responde `200` em eventos ignorados, `401` se o token não confere, idempotente por `kiwify_event_id`.
- Tech Spec `Riscos Conhecidos`: parser tolerante a campos desconhecidos no payload (schema não 100% documentado publicamente) — validar com um evento de teste real disparado pela Kiwify (ver Tarefa 1.0) antes de considerar concluída.
</requirements>

## Subtarefas

- [x] 4.1 Criar `KiwifyWebhookController` em `application/billing/entrypoint/rest`, validando o token via query param antes de processar o payload (permitAll + validação manual, mesmo padrão do `ApiKeyAuthFilter`).
- [x] 4.2 Adicionar `.requestMatchers("/webhooks/kiwify").permitAll()` ao `SecurityConfig`.
- [x] 4.3 Criar `HandleKiwifyWebhookUseCase` em `domain/billing/usecase`, orquestrando: checagem de idempotência por `kiwify_event_id`, gravação do payload bruto em `kiwify_webhook_events`, e atualização de `subscriptions` conforme o `order_status` recebido.
- [x] 4.4 Implementar o mapeamento de plano: eventos `compra_aprovada` cujo produto corresponde ao ID configurado como vitalício resultam em `plan = LIFETIME`; caso contrário `plan = ANNUAL`.
- [x] 4.5 Implementar as transições de status: `compra_aprovada`/`subscription_renewed` → `ACTIVE`; `subscription_canceled`/`compra_reembolsada`/`chargeback` → `CANCELLED`; `subscription_late` → manter `ACTIVE` (ou `EXPIRED` conforme regra de carência a definir na implementação, documentando a decisão no código).
- [x] 4.6 Disparar a criação/atualização de conta (delegando para a lógica que será implementada na Tarefa 5.0 — pode ser stubada nesta tarefa e conectada na 5.0, ou implementada em conjunto se mais simples).
- [x] 4.7 Testar manualmente com o "Test Webhook" da Kiwify configurado na Tarefa 1.0, validando o payload real contra o parser implementado.

## Detalhes de Implementação

Ver Tech Spec `Design de Implementação > Endpoints de API` e `Pontos de Integração`. Ver `config/ApiKeyAuthFilter.kt` como referência de padrão para validação manual de credencial em endpoint público.

## Critérios de Sucesso

- Endpoint responde `200` para eventos válidos e processados, `401` para token inválido, e idempotentemente ignora (`200`) eventos já processados (mesmo `kiwify_event_id`).
- Um evento `compra_aprovada` com o produto vitalício resulta em `subscriptions.plan = LIFETIME`; com o produto anual, `plan = ANNUAL`.
- Um evento `subscription_canceled`/`compra_reembolsada`/`chargeback` muda `status` para `CANCELLED` imediatamente.

## Testes da Tarefa

- [x] Testes de unidade do `HandleKiwifyWebhookUseCase` cobrindo cada `order_status` e o mapeamento de plano por produto.
- [x] Teste de unidade de idempotência: mesmo `kiwify_event_id` processado duas vezes não duplica efeito nem lança erro.
- [x] Teste de integração (H2) do `POST /webhooks/kiwify` fim a fim com payloads de exemplo para cada evento relevante, validando o token inválido retornando `401`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/billing/entrypoint/rest/KiwifyWebhookController.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/domain/billing/usecase/HandleKiwifyWebhookUseCase.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/config/SecurityConfig.kt` (modificado)
- `application.yml` (novas propriedades: `kiwify.webhook-token`, `kiwify.product.annual-id`, `kiwify.product.lifetime-id`)
- Depende de: Tarefas 1.0 (IDs/token) e 3.0 (gateways)

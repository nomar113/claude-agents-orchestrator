# Review: Task 4.0 - Endpoint de webhook da Kiwify com idempotência

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 4_task.md
**Status**: APROVADO COM OBSERVAÇÕES (majors e minors do follow-up abaixo corrigidos)

## Resumo

A implementação cobre corretamente o fluxo principal exigido pela Tarefa 4.0: `KiwifyWebhookController` valida o token compartilhado com comparação de tempo constante (`MessageDigest.isEqual`), delega para `HandleKiwifyWebhookUseCase`, que grava o evento bruto para auditoria/idempotência e atualiza `subscriptions` conforme o `order_status`, com mapeamento de plano (ANNUAL/LIFETIME) por `product_id`. A idempotência tem fallback em três níveis bem documentado, o parser é tolerante a campos desconhecidos/casing (isolado num `ObjectMapper` local, sem afetar o mapper global), e a stubagem da subtarefa 4.6 (criação de conta) foi feita de forma explícita e rastreável, sem tentar mascarar como concluída — assim como a subtarefa 4.7 (teste manual no painel da Kiwify), corretamente deixada pendente em `4_task.md`/`tasks.md`.

Reexecutei os testes automatizados desta tarefa (`HandleKiwifyWebhookUseCaseTest`: 12/12 ok; `KiwifyWebhookControllerIntegrationTest`: 10/10 ok, via H2/MockMvc) e o build completo (`./gradlew build`), ambos sem falhas, confirmando o relato da implementação.

O ponto que mais chama atenção é a assinatura do `HandleKiwifyWebhookUseCase.execute()` com 5 parâmetros primitivos, o que diverge do padrão de todos os demais use cases do domínio (que usam objeto quando passam de ~3 parâmetros) e da própria assinatura definida na Tech Spec. Também há uma lacuna na seção de Observabilidade da Tech Spec (métrica Prometheus e logs INFO de ativação/cancelamento) que não foi implementada nem explicitamente sinalizada como adiada. Nenhum dos dois pontos é bloqueante para o funcionamento do endpoint.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/billing/entrypoint/rest/KiwifyWebhookController.kt` | OK | 0 |
| `application/billing/entrypoint/rest/dto/KiwifyWebhookPayload.kt` | OK | 0 |
| `domain/billing/usecase/HandleKiwifyWebhookUseCase.kt` | Problemas | 2 (1 major, 1 minor) |
| `config/SecurityConfig.kt` | OK | 0 |
| `src/main/resources/application.properties` | OK | 0 |
| `src/test/resources/application.properties` | OK | 0 |
| `test/.../HandleKiwifyWebhookUseCaseTest.kt` | OK | 1 (minor, cobertura) |
| `test/.../KiwifyWebhookControllerIntegrationTest.kt` | OK | 1 (minor, cobertura) |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

**1. `HandleKiwifyWebhookUseCase.execute()` com 5 parâmetros primitivos, violando o padrão do projeto de "máximo 3 parâmetros, usar objeto para mais"**

Arquivo: `src/main/kotlin/br/com/nomar/controlai/domain/billing/usecase/HandleKiwifyWebhookUseCase.kt:30-35`

```kotlin
fun execute(
    rawPayload: String,
    eventId: String,
    orderStatus: String,
    customerEmail: String?,
    productId: String?,
): Result<Unit> = runCatching {
```

Todos os demais use cases do domínio que recebem mais de 2-3 dados primitivos usam um objeto de domínio como parâmetro único (ex.: `SavePurchaseInvoiceUseCase.execute(purchaseInvoice: PurchaseInvoice)`, `SaveBudgetUseCase.execute(budget: Budget)`, `UpdatePaymentMethodUseCase.execute(paymentMethod: PaymentMethod)`). A própria Tech Spec definiu a interface como `HandleKiwifyWebhookGateway.execute(rawPayload: String, eventId: String, orderStatus: String): Result<Unit>` — 3 parâmetros — e a implementação real adicionou mais dois (`customerEmail`, `productId`) sem revisitar esse formato.

Sugestão: extrair um data class, por exemplo:

```kotlin
data class ParsedKiwifyWebhookEvent(
    val rawPayload: String,
    val eventId: String,
    val orderStatus: String,
    val customerEmail: String?,
    val productId: String?,
)

fun execute(event: ParsedKiwifyWebhookEvent): Result<Unit> = runCatching { ... }
```

Isso também facilita testes futuros (menos posicionamento por ordem de parâmetro) e evolução do payload sem quebrar a assinatura a cada novo campo necessário.

**2. Observabilidade da Tech Spec não implementada nem sinalizada como adiada**

A seção "Monitoramento e Observabilidade" da Tech Spec pede explicitamente:
- Métrica Prometheus `kiwify_webhook_events_total{order_status, result="success|error|duplicate"}` a cada processamento.
- Log estruturado (INFO) a cada assinatura criada/renovada/cancelada, com e-mail mascarado.
- Log (WARN) para tokens de webhook inválidos.

O item de WARN para token inválido foi implementado corretamente (`KiwifyWebhookController.kt:40`). Porém não há `MeterRegistry` injetado/incrementado em nenhum ponto do fluxo (diferente do padrão já usado em `ApiKeyAuthFilter`, que injeta `MeterRegistry` e incrementa `auth.api_key.invalid`), e o log INFO com e-mail mascarado só ocorre no caminho "sem conta existente" (`HandleKiwifyWebhookUseCase.kt:62-66`) — não há log ao ativar (`activateSubscription`) nem ao cancelar (`transitionActiveSubscription`) uma assinatura.

Isso não está listado como subtarefa explícita em `4_task.md` (que foca em idempotência/transições de status), então não considero bloqueante para esta tarefa especificamente, mas é uma lacuna real frente à Tech Spec que deveria ao menos ser documentada como decisão consciente (como foi feito com as subtarefas 4.6/4.7), para não passar despercebida quando a Tarefa 5.0 ou uma tarefa de observabilidade futura assumir que isso já existe.

### Problemas Minor

**1. Fallback de `productId` desconhecido sem cobertura de teste**

Arquivo: `HandleKiwifyWebhookUseCase.kt:87-96` — quando `productId` não é nulo e não corresponde nem ao ID anual nem ao vitalício, o código loga um WARN e assume `SubscriptionPlan.ANNUAL` por padrão. Esse comportamento de fallback silencioso é importante (evita rejeitar o evento, mas pode mascarar um ID de produto mal configurado) e não tem teste dedicado nem em `HandleKiwifyWebhookUseCaseTest` nem no teste de integração. Sugestão: adicionar um teste com `productId = "produto-desconhecido"` verificando que o plano resultante é `ANNUAL`.

**2. Sem teste para payload com JSON sintaticamente inválido**

A Tech Spec (`Riscos Conhecidos`) chama atenção especificamente para a necessidade de tolerância a payloads reais da Kiwify. Os testes cobrem payloads bem formados com campos ausentes/desconhecidos implicitamente (via `customer`/`product` opcionais), mas nenhum teste envia um corpo que não seja JSON válido (ex.: string vazia, HTML de erro, JSON truncado) para confirmar que `parsePayload` (via `runCatching`) realmente evita uma exceção não tratada e que o endpoint ainda responde `200`. Dado que esse é exatamente o risco citado na Tech Spec e que a validação manual real (subtarefa 4.7) ainda está pendente, um teste automatizado desse caso reduziria o risco residual.

**3. Evento com parsing falho é registrado com `orderStatus = ""`**

Arquivo: `KiwifyWebhookController.kt:50` (`payload?.orderStatus.orEmpty()`) — quando o payload não pode ser parseado, o evento é gravado em `kiwify_webhook_events` com `order_status` vazio, o que deixa o registro de auditoria pouco informativo para reprocessamento manual (Tech Spec: "grava o payload bruto ... para reprocessamento manual"). Um valor sentinela como `"unparsed"` tornaria a investigação mais direta.

**4. `maskEmail` duplicado do padrão de `ResendEmailClient` em vez de reaproveitado**

Arquivo: `HandleKiwifyWebhookUseCase.kt:114` — a Tech Spec menciona explicitamente "mesmo padrão já usado em `ResendEmailClient`, ex.: `toEmail.take(3) + "***"`". A implementação replica a mesma lógica em vez de extrair um utilitário compartilhado (ex.: `EmailMasker`). Não é um problema funcional, mas é uma pequena duplicação que pode divergir com o tempo se um dos dois pontos for ajustado isoladamente.

## Destaques Positivos

- Comparação de token com `MessageDigest.isEqual` (tempo constante) em vez de `==`, prevenindo timing attack — boa prática de segurança não pedida explicitamente na task, mas bem aplicada.
- Estratégia de idempotência com fallback em 3 níveis (`webhook_event_id` → `orderId:orderStatus` → hash SHA-256 do corpo bruto), com a decisão de engenharia documentada em comentário no código diante da lacuna de documentação pública da Kiwify — exatamente como pedido na Tech Spec (Riscos Conhecidos).
- Parser tolerante isolado em um `ObjectMapper` local (`tolerantMapper`), copiado do mapper global via `.copy()`, evitando relaxar `FAIL_ON_UNKNOWN_PROPERTIES` para o resto da aplicação.
- Reaproveitamento correto dos gateways já existentes (`FindUserByEmailGateway`, `FindUserGroupGateway`) em vez de criar gateways redundantes, conforme decisão registrada.
- Boa cobertura de testes: 12 testes unitários cobrindo todos os `order_status` relevantes, mapeamento de plano, idempotência, e-mail desconhecido e e-mail em branco; 10 testes de integração H2/MockMvc cobrindo o fluxo real fim a fim, incluindo token ausente/inválido.
- `UpsertSubscriptionProvider` (Tarefa 3.0) resolve corretamente o upsert por `group_id` antes de salvar, então `activateSubscription` não corre risco de violar a constraint única mesmo construindo uma nova instância de `Subscription` sem `id`.
- Decisão de manter `ACTIVE` em `subscription_late` (período de carência) documentada diretamente no código com a justificativa de negócio, facilitando auditoria futura da decisão.
- Transparência no estado da tarefa: subtarefas 4.6 (stub) e 4.7 (pendente) claramente sinalizadas como não finalizadas em vez de marcadas incorretamente como concluídas.
- Build completo (`./gradlew build`) e os 22 testes desta tarefa reexecutados nesta revisão, todos passando sem falhas.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código | Problemas (parâmetros em excesso no use case) |
| Kotlin/Spring Boot | OK |
| REST/HTTP (`kotlin-springboot`) | OK |
| Segurança (token webhook) | OK |
| Logging/Observabilidade (Tech Spec) | Problemas (métrica e logs de ativação/cancelamento ausentes) |
| Testes | OK (com gaps minor pontuais) |

## Recomendações

1. (Major) Extrair um data class para os parâmetros de `HandleKiwifyWebhookUseCase.execute()`, alinhando com o padrão de use cases do domínio e reduzindo o acoplamento posicional.
2. (Major) Decidir e documentar explicitamente o que fazer com a métrica Prometheus e os logs de ativação/cancelamento da seção "Monitoramento e Observabilidade" da Tech Spec — implementar agora ou registrar como item pendente para uma tarefa futura de observabilidade do bounded context `billing`.
3. (Minor) Adicionar teste para `productId` desconhecido (fallback para `ANNUAL` com WARN).
4. (Minor) Adicionar teste com corpo de requisição JSON inválido, validando resposta `200` e nenhuma exceção não tratada.
5. (Minor) Usar um valor sentinela (ex.: `"unparsed"`) em vez de string vazia para `order_status` quando o parsing falhar completamente.
6. (Minor) Considerar extrair `maskEmail` para um utilitário compartilhado com `ResendEmailClient`, já que a Tech Spec cita explicitamente a reutilização do mesmo padrão.

## Follow-up (pós-review)

Aplicadas as correções recomendadas antes de prosseguir para a Tarefa 5.0:

- **Major 1 (resolvido)**: `HandleKiwifyWebhookUseCase.execute()` agora recebe um único parâmetro `ParsedKiwifyWebhookEvent` (data class com `rawPayload`, `eventId`, `orderStatus`, `customerEmail`, `productId`) em vez de 5 primitivos.
- **Major 2 (resolvido)**: adicionado `MeterRegistry` ao use case, incrementando `kiwify_webhook_events_total{order_status, result="success|error|duplicate"}` a cada execução; adicionados logs INFO com e-mail mascarado em `activateSubscription` e `transitionActiveSubscription` (ativação/renovação/cancelamento), além do log já existente para conta ainda não provisionada.
- **Minor 1 (resolvido)**: adicionado teste `compra_aprovada with unknown product id defaults to ANNUAL`.
- **Minor 2 (resolvido, com ajuste)**: adicionado teste de corpo JSON malformado. Na prática, como `kiwify_webhook_events.raw_payload` é uma coluna `JSON` nativa do MySQL, um corpo que não é JSON válido não pode ser persistido para auditoria (o insert falha na constraint de tipo da coluna) — o endpoint segue respondendo `200` (a falha é engolida pelo `runCatching` do use case), mas o evento não fica registrado nesse caso extremo específico. Isso é uma limitação conhecida herdada do desenho de dados da Tarefa 2.0/3.0, não um bug desta tarefa, e na prática não afeta tráfego real da Kiwify (que sempre envia JSON sintaticamente válido). O teste documenta esse comportamento real em vez do comportamento originalmente assumido.
- **Minor 3 (resolvido)**: `KiwifyWebhookController` agora usa os sentinelas `"unparsed"` (payload não pôde ser deserializado) e `"unknown-status"` (payload parseado mas sem `order_status`) em vez de gravar `order_status = ""`.
- **Minor 4 (não aplicado, decisão consciente)**: optei por não extrair `maskEmail` para um utilitário compartilhado com `ResendEmailClient` nesta tarefa — o próprio `ResendEmailClient` já duplica a mesma lógica internamente em dois pontos sem essa extração, e criar um utilitário novo tocaria o módulo `auth` fora do escopo de arquivos da Tarefa 4.0. Fica registrado como possível limpeza futura, não bloqueante.

Reexecutados após as correções: `HandleKiwifyWebhookUseCaseTest` (13 testes), `KiwifyWebhookControllerIntegrationTest` (12 testes) e `./gradlew build` completo (89 suítes de teste) — todos passando sem falhas.

## Veredito

A implementação atende aos critérios de sucesso funcionais da Tarefa 4.0: o endpoint responde `200`/`401` corretamente, é idempotente por `kiwify_event_id`, e as transições de plano/status (`ANNUAL`/`LIFETIME`, `ACTIVE`/`CANCELLED`) funcionam conforme especificado, com boa cobertura de testes automatizados (todos passando) e decisões de engenharia bem documentadas no código para as lacunas conhecidas (parser tolerante, carência do `subscription_late`, stub da criação de conta).

Não há problemas críticos. Os dois problemas major (parâmetros em excesso no use case e lacuna de observabilidade da Tech Spec) não impedem o funcionamento correto do endpoint e podem ser resolvidos em um ajuste pontual, sem necessidade de refazer a implementação. Recomendo **aprovar com observações**: pode prosseguir para a Tarefa 5.0 (onboarding pós-compra), mas os itens 1 e 2 das recomendações devem entrar no backlog antes de considerar o bounded context `billing` pronto para produção — em especial a observabilidade, que é a única forma de saber se webhooks estão falhando silenciosamente em produção. A subtarefa 4.7 (teste manual com o webhook real da Kiwify) continua corretamente pendente e deve ser executada antes do lançamento comercial.

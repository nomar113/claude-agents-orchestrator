# Tech Spec: Comercialização do ControlAI (Landing Page + Assinatura Kiwify)

## Resumo Executivo

A solução cria um novo bounded context `billing` no backend Kotlin/Spring existente, responsável por receber webhooks da Kiwify, manter uma tabela `subscriptions` vinculada a `group_id` (a mesma unidade de tenancy já usada por cartões, faturas e orçamento) e liberar/revogar acesso via um filtro de segurança adicional, sem embutir o status de assinatura no JWT (garantindo revogação imediata em caso de estorno/cancelamento). Contas de compradores são criadas automaticamente na aprovação da compra, reaproveitando o gateway de criação de usuário+grupo pessoal e o mecanismo de token de "definição de senha" já existentes. A landing page de vendas é um site estático separado, desacoplado do bundle Ionic/Capacitor, e o cadastro público (`/register`) do app é desativado — todo acesso novo passa a nascer de uma compra aprovada ou de uma conta já existente antes do lançamento (grandfathered via migração de dados).

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **`billing` (novo bounded context, backend)** — recebe e processa eventos da Kiwify, mantém o estado de assinatura por grupo, e expõe o gate de acesso.
  - `KiwifyWebhookController` — endpoint público (validado por token compartilhado) que recebe os eventos.
  - `HandleKiwifyWebhookUseCase` — decide o efeito de cada evento (`compra_aprovada`, `compra_reembolsada`, `chargeback`, `subscription_canceled`, `subscription_renewed`, `subscription_late`) sobre a assinatura do grupo, com idempotência por id de evento.
  - `SubscriptionModel` / `SubscriptionRepository` (JPA) e `KiwifyWebhookEventModel` (log de auditoria e idempotência).
  - `SubscriptionGuardFilter` — novo filtro Spring Security, roda após a autenticação JWT/API Key já existente, bloqueia requests de grupos sem assinatura ativa com `402 Payment Required`.
- **`auth` (existente, modificado)** — `RegisterUserUseCase` deixa de ser acionável publicamente; seu gateway `CreateUserWithPersonalGroupGateway` passa a ser reaproveitado internamente pelo `HandleKiwifyWebhookUseCase` para criar a conta do comprador. `ForgotPasswordUseCase`/`CreatePasswordResetTokenGateway` são reaproveitados para o fluxo de "defina sua senha" pós-compra.
- **`controlai-frontend` (existente, modificado)** — remove a rota `/register` e o link de cadastro na tela de login; trata a resposta `402` do backend com uma nova tela de bloqueio (`SubscriptionRequiredPage`), sem qualquer link de pagamento.
- **Landing page (novo, site estático separado)** — HTML/CSS/JS simples, deploy independente do `controlai-frontend`, hospeda a proposta de valor e o link de checkout Kiwify. Não referencia nem é referenciada pelo app mobile.

Fluxo de dados principal: `Kiwify → POST /webhooks/kiwify → HandleKiwifyWebhookUseCase → (cria/encontra User+Group | atualiza Subscription) → Resend (e-mail) `. Fluxo de gate: `Request autenticado → JWT/ApiKey resolve groupId → SubscriptionGuardFilter consulta subscriptions por group_id → permite ou responde 402`.

## Design de Implementação

### Interfaces Principais

```kotlin
fun interface HandleKiwifyWebhookGateway {
    fun execute(rawPayload: String, eventId: String, orderStatus: String): Result<Unit>
}

fun interface FindActiveSubscriptionByGroupIdGateway {
    fun execute(groupId: Long): Result<Subscription?>
}

fun interface UpsertSubscriptionGateway {
    fun execute(subscription: Subscription): Result<Subscription>
}

fun interface FindUserByEmailGateway // já existe, reaproveitado sem alteração
fun interface CreateUserWithPersonalGroupGateway // já existe, reaproveitado sem alteração
```

### Modelos de Dados

```kotlin
enum class SubscriptionPlan { ANNUAL, LIFETIME, GRANDFATHERED }
enum class SubscriptionStatus { ACTIVE, CANCELLED, EXPIRED }

class Subscription(
    val id: Long? = null,
    val groupId: Long,
    val plan: SubscriptionPlan,
    val status: SubscriptionStatus,
    val kiwifyOrderId: String? = null,
    val currentPeriodEnd: java.time.Instant? = null, // null para LIFETIME e GRANDFATHERED
)
```

Migração `V39__create_billing_tables.sql`:
- `subscriptions(id, group_id UNIQUE FK, plan, status, kiwify_order_id, current_period_end, created_at, updated_at)`.
- `kiwify_webhook_events(id, kiwify_event_id UNIQUE, order_status, raw_payload JSON, processed_at)` — auditoria e idempotência.
- Backfill: `INSERT INTO subscriptions (group_id, plan, status) SELECT id, 'GRANDFATHERED', 'ACTIVE' FROM \`groups\`` — grandfathering de todos os grupos existentes antes do lançamento, sem nenhuma condicional de código.

### Endpoints de API

- `POST /webhooks/kiwify?token={secret}` — recebe o payload JSON da Kiwify. Responde `200` mesmo em eventos ignorados (evita reenvio desnecessário pela Kiwify), `401` se o token não confere, `409`/`200` idempotente se `kiwify_event_id` já processado.

Nenhum endpoint novo é exposto ao frontend: o gate de assinatura reaproveita os endpoints já existentes, apenas adicionando uma resposta `402` quando aplicável. `POST /auth/register` é removido (ou passa a responder `410 Gone`).

## Pontos de Integração

- **Kiwify (inbound)** — autenticação via token compartilhado configurado no painel da Kiwify e replicado como variável de ambiente (`KIWIFY_WEBHOOK_TOKEN`), comparado no controller antes de processar o payload (mesmo padrão de "permitAll + validação manual" já usado por `ApiKeyAuthFilter` para `/payments/notification`). Mapeamento de plano: IDs de produto/oferta da Kiwify (assinatura anual vs. order bump vitalício) configurados via propriedade (`kiwify.product.annual-id`, `kiwify.product.lifetime-id`).
- **Resend (outbound, já integrado)** — reaproveita `EmailGateway`/`ResendEmailClient`: e-mail de "defina sua senha" (reaproveitando o template e token do fluxo de reset de senha) no primeiro acesso pós-compra, e um e-mail informativo em caso de cancelamento/estorno.
- **Tratamento de erro**: falha ao processar um evento (ex.: e-mail malformado) é logada e retorna `200` para não gerar retries agressivos da Kiwify, mas grava o payload bruto em `kiwify_webhook_events` para reprocessamento manual.

## Abordagem de Testes

### Testes de Unidade
- `HandleKiwifyWebhookUseCase`: usuário novo vs. e-mail já existente (grandfathered ou compra repetida); idempotência por `kiwify_event_id`; efeito correto de cada `order_status` sobre `plan`/`status`; order bump (`compra_aprovada` com produto vitalício) resultando em `plan = LIFETIME`.
- `SubscriptionGuardFilter`: libera grupos `ACTIVE` (qualquer plano), bloqueia grupos sem linha em `subscriptions`, bloqueia `CANCELLED`/`EXPIRED`, ignora rotas públicas (`/auth/**`, `/webhooks/**`, `/health`).

### Testes de Integração
- `POST /webhooks/kiwify` fim a fim com H2: payloads de exemplo para `compra_aprovada` (anual e anual+bump), `compra_reembolsada`, `chargeback`, `subscription_canceled`, `subscription_renewed`; valida efeito em `subscriptions`, `users` e `kiwify_webhook_events`.
- Endpoint protegido qualquer (ex.: `GET /purchases`) retornando `402` para grupo sem assinatura e `200` para grupo `ACTIVE`.

### Testes de E2E
- Playwright no `controlai-frontend`: usuário sem assinatura ativa vê a tela de bloqueio ao logar; usuário grandfathered acessa normalmente; rota `/register` não existe mais.

## Sequenciamento de Desenvolvimento

### Ordem de Construção
1. Migração `V39` + entidade `Subscription` + gateways/providers de leitura e escrita (fundação de dados, sem risco para o fluxo existente).
2. `HandleKiwifyWebhookUseCase` + `KiwifyWebhookController` + idempotência (testável isoladamente antes de mexer em autorização).
3. `SubscriptionGuardFilter` no `SecurityConfig` (depende de 1; é o passo que efetivamente liga o gate).
4. Remoção do cadastro público (`/auth/register` no backend e `/register` no frontend).
5. `SubscriptionRequiredPage` e tratamento do `402` no `httpClient.ts`/`AuthContext`.
6. E-mails transacionais (reaproveitando Resend + token de reset de senha).
7. Landing page estática (paralelo, sem dependência técnica além de já ter os links/IDs de produto da Kiwify).

### Dependências Técnicas
- Produto de assinatura anual e order bump vitalício já criados na Kiwify, com IDs de produto conhecidos.
- Token de webhook gerado no painel da Kiwify e configurado como variável de ambiente no backend.
- Domínio e hospedagem definidos para o site estático da landing page.

## Monitoramento e Observabilidade

- Métrica Prometheus `kiwify_webhook_events_total{order_status, result="success|error|duplicate"}` incrementada a cada processamento.
- Log estruturado (INFO) a cada assinatura criada/renovada/cancelada, com e-mail mascarado (mesmo padrão já usado em `ResendEmailClient`, ex.: `toEmail.take(3) + "***"`).
- Log (WARN) para tokens de webhook inválidos, útil para detectar token desatualizado ou tentativa de acesso indevido ao endpoint.

## Considerações Técnicas

### Decisões Principais
- Assinatura vinculada a `group_id`, não a `user_id`: consistente com o resto do sistema, que já usa `group_id` como unidade de tenancy compartilhada pelo casal.
- Status de assinatura consultado a cada request (não embutido no JWT): garante que um estorno/cancelamento revogue o acesso imediatamente, sem esperar o próximo refresh de token.
- Grandfathering resolvido inteiramente via dado (linha `GRANDFATHERED`/`ACTIVE` inserida na migração), não via lógica condicional no caminho de autorização — o gate só conhece "tem assinatura ativa ou não".
- Onboarding pós-compra reaproveita `CreateUserWithPersonalGroupGateway` e o token de "esqueci minha senha" já existentes, evitando duplicar fluxo de criação de conta ou de e-mail.
- Landing page como site estático separado do `controlai-frontend`: evita acoplar marketing ao bundle Capacitor/Ionic e mantém a regra de "zero menção a pagamento dentro do app".

### Riscos Conhecidos
- A documentação pública da Kiwify não detalha o payload completo do webhook nem o mecanismo exato de verificação do token (confirmado apenas que os eventos usam o campo `order_status` com valores como `compra_aprovada`, `subscription_canceled`, `subscription_renewed`, e que cada webhook tem um token configurável) — o parser deve ser tolerante a campos desconhecidos, e o payload real deve ser validado com um evento de teste disparado pelo próprio painel da Kiwify antes de finalizar a integração.
- Colisão de e-mail entre autocriação via webhook e uma conta já existente (grandfathered ou criada antes da desativação do registro público) é mitigada buscando por e-mail antes de criar, mas precisa de teste dedicado.
- Guideline 3.1.1 da Apple: como o app não conterá nenhum link/menção ao checkout, o risco de rejeição por "compra externa não declarada" é baixo (padrão equivalente a apps cuja assinatura é vendida só no site, já usado por diversas categorias de apps); ainda assim, vale revisar a ficha de privacidade da loja (tratado no PRD de publicação nas lojas) para não contradizer essa postura.

### Conformidade com Skills Padrão
- `kotlin-springboot` — convenções de Kotlin/Spring Boot aplicam-se ao novo bounded context `billing`.
- `clean-code` — nomes e responsabilidades enxutas nos novos use cases/gateways, seguindo o padrão Gateway/Provider já estabelecido no repositório.
- `frontend-design` — aplica-se à autoria visual da landing page estática quando ela for implementada.

### Arquivos Relevantes e Dependentes
- Backend: novos pacotes `domain/billing/**`, `application/billing/**`; `src/main/resources/db/migration/V39__create_billing_tables.sql`; `config/SecurityConfig.kt`; `application/auth/entrypoint/rest/AuthController.kt`; `domain/auth/usecase/RegisterUserUseCase.kt`; `application/auth/application/ResendEmailClient.kt`; `domain/auth/usecase/ForgotPasswordUseCase.kt` (referência de reaproveitamento).
- Frontend: `src/App.tsx` (remover rota `/register`, tratar `402`); `src/context/AuthContext.tsx`; `src/services/httpClient.ts` (novo evento equivalente a `ctrl:auth-failure`); novo `src/pages/SubscriptionRequiredPage.tsx`; `src/pages/LoginPage.tsx` (remover link de cadastro).
- Novo projeto: site estático da landing page (repositório/deploy a definir, fora do `controlai-frontend`).

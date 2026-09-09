# Review: Task 2.0 - Migração e modelo de dados de assinatura (billing)

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 2_task.md
**Status**: APROVADO

## Resumo

A Tarefa 2.0 cria a fundação de dados do bounded context `billing`: migração Flyway `V39__create_billing_tables.sql` (tabelas `subscriptions` e `kiwify_webhook_events` + backfill de grandfathering), as entidades JPA `SubscriptionModel`/`KiwifyWebhookEventModel` com seus repositórios Spring Data, e a entidade de domínio `Subscription` (com `SubscriptionPlan`/`SubscriptionStatus`) livre de anotações de framework.

A implementação está em conformidade estrita com a Tech Spec (schema, nomes de coluna, regra de `currentPeriodEnd` nulo para `LIFETIME`/`GRANDFATHERED`, backfill 100% via dado sem condicional de código) e replica com precisão os padrões já estabelecidos no repositório `controlai` (nomenclatura de FK/UK, separação enum-de-domínio vs. enum-de-persistência sufixado `Model`, estrutura `application/<contexto>/entrypoint/database/{model,repository}`, timestamps `LocalDateTime` com `@CreationTimestamp`/`@UpdateTimestamp`). O escopo foi respeitado rigorosamente — nenhum gateway, provider, use case ou controller foi criado, corretamente deixados para a Tarefa 3.0+.

Os testes cobrem exatamente os critérios de sucesso da task (existência de tabelas, colunas, constraints UNIQUE/FK, backfill e invariante de domínio) e usam uma estratégia de fixture (grupo legado `id=1` da V29) apropriada para o ambiente real de testes do projeto (MySQL compartilhado via Docker, não H2), evitando asserções frágeis de contagem total. Re-executei os testes do pacote `billing` de forma independente (`./gradlew test --tests "...billing.*"`) e confirmei 14/14 testes passando (6 unitários + 8 integração), 0 falhas, 0 erros — consistente com o relato de 559/559 na suíte completa.

Não há problemas críticos ou major. Duas observações minor (não bloqueantes) estão listadas abaixo.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/main/resources/db/migration/V39__create_billing_tables.sql` | OK | 0 |
| `src/main/kotlin/.../domain/billing/entity/Subscription.kt` | OK | 0 |
| `src/main/kotlin/.../application/billing/entrypoint/database/model/SubscriptionModel.kt` | OK | 0 |
| `src/main/kotlin/.../application/billing/entrypoint/database/model/KiwifyWebhookEventModel.kt` | OK | 0 |
| `src/main/kotlin/.../application/billing/entrypoint/database/repository/SubscriptionRepository.kt` | OK | 0 |
| `src/main/kotlin/.../application/billing/entrypoint/database/repository/KiwifyWebhookEventRepository.kt` | OK | 0 |
| `src/test/kotlin/.../domain/billing/SubscriptionTest.kt` | OK | 0 |
| `src/test/kotlin/.../application/billing/BillingMigrationIntegrationTest.kt` | OK (1 minor) | 1 |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`BillingMigrationIntegrationTest.kt:63-71` — teste de UNIQUE reaproveita o grupo legado sem isolar a falha do teste de FK seguinte.**
   O teste `should enforce unique constraint on subscriptions group_id` depende implicitamente do teste de backfill (`legacyGroupId` já ter uma linha em `subscriptions`) ter rodado/sido verdadeiro para o `INSERT` falhar por violação de UNIQUE. Como o JUnit 5 por padrão não garante ordem determinística entre métodos de uma classe (a menos que haja `@TestMethodOrder`), isso funciona "por sorte" hoje porque a linha grandfathered já existe fisicamente no banco (inserida pela própria migração, não por outro teste) — não é uma dependência de ordem de execução entre testes, e sim do estado do banco após a migração. Não é um bug, mas vale um comentário no código deixando explícito que a asserção depende do estado pós-migração (já garantido pela V39), não de outro `@Test`, para evitar confusão numa manutenção futura.
   Sugestão (comentário, não requer mudança de comportamento):
   ```kotlin
   @Test
   fun `should enforce unique constraint on subscriptions group_id`() {
       // legacyGroupId já possui uma subscription inserida pelo backfill da própria V39
       // (independente da ordem de execução dos testes desta classe).
       val exception = runCatching {
   ```

2. **`SubscriptionModel.kt` / `KiwifyWebhookEventModel.kt` — valores default "vazios" em colunas obrigatórias (`groupId = 0`, `kiwifyEventId = ""`, `orderStatus = ""`, `rawPayload = "{}"`).**
   Isso é exatamente o mesmo padrão já usado em `UserModel` (`name = ""`, `email = ""`) e `RefreshTokenModel` (`tokenHash = ""`), então não é uma inconsistência introduzida por esta task — é convenção herdada, provavelmente necessária pelo construtor sem argumentos exigido pelo Hibernate em `data class`. Registro apenas como observação geral do projeto (fora do escopo desta task corrigir), não como pendência desta implementação.

## Destaques Positivos

- **Aderência exata ao schema da Tech Spec**: colunas, tipos, `ENUM` inline no MySQL e constraint `uk_subscriptions_group_id`/`fk_subscriptions_group` batem 1:1 com o documento, incluindo o `INSERT ... SELECT` de backfill sem nenhuma condicional de código, conforme a decisão técnica explícita ("Grandfathering resolvido inteiramente via dado").
- **Nomenclatura de constraints consistente com V1–V38**: `fk_subscriptions_group` e `uk_subscriptions_group_id`/`uk_kiwify_webhook_events_event_id` seguem exatamente o padrão `fk_<tabela>_<referencia>` / `uk_<tabela>_<coluna>` usado em todas as 38 migrações anteriores (verificado via grep comparativo).
- **Separação enum de domínio vs. enum de persistência**: `SubscriptionPlanModel`/`SubscriptionStatusModel` (JPA) duplicando `SubscriptionPlan`/`SubscriptionStatus` (domínio) replica fielmente o precedente já existente em `GroupInviteModel`/`GroupInviteStatusModel` vs. `GroupInvite`/`InviteStatus` — não é duplicação acidental, é o padrão arquitetural do projeto para não vazar anotações JPA no domínio.
- **Entidade de domínio limpa**: `Subscription` é uma `data class` Kotlin pura, sem qualquer import de `jakarta.persistence`, com uma única invariante de negócio expressa via `init { require(...) }` — mensagem em português, consistente com o padrão já usado em `RegisterUserUseCase`, `InvoiceUrl`, `Cnpj`, etc.
- **Repositórios minimalistas**: `SubscriptionRepository`/`KiwifyWebhookEventRepository` são interfaces `JpaRepository` de uma linha com apenas o método de busca necessário, sem anotação `@Repository` redundante — idêntico a `UserRepository`/`ApiKeyRepository`.
- **Estratégia de teste de integração adaptada corretamente ao ambiente real**: usar o grupo legado `id=1` (estável, criado pela V29) como fixture em vez de contagens totais de linhas é a escolha certa dado que o banco de teste é compartilhado e acumulado entre os 165+ grupos de outras suítes — e o comentário no topo da classe (`BillingMigrationIntegrationTest.kt:10-12`) documenta essa decisão de forma clara para quem for mantê-la depois.
- **Cobertura completa das subtarefas de teste pedidas**: migração cria tabelas/colunas (2 testes), constraints UNIQUE e FK são efetivamente exercitadas tentando violá-las (não apenas inspecionando o `information_schema`), backfill do grupo legado é validado, e todas as combinações de plano vs. `currentPeriodEnd` (incluindo os dois casos de rejeição) têm teste unitário dedicado.
- **Escopo respeitado à risca**: nenhum gateway/provider/use case/controller foi criado nesta task, mesmo havendo interfaces de gateway já desenhadas na Tech Spec — a interpretação de que "fundação de dados" termina nas entidades/repositórios está correta e evita acoplamento prematuro com a Tarefa 3.0.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (nomenclatura, tamanho de classe/método, sem lógica nas entidades JPA) | OK |
| Kotlin/Spring Boot (JPA, Spring Data, convenções do projeto) | OK |
| Migração Flyway (numeração sequencial, nomenclatura de constraints, backtick em `groups`) | OK |
| Domain-Driven Design (separação domínio/persistência, Gateway/Provider) | OK (fundação apenas; gateways ficam para 3.0) |
| Testes (unidade + integração, convenção MySQL local do projeto) | OK |

## Recomendações

1. (Minor, opcional) Adicionar um comentário de uma linha em `BillingMigrationIntegrationTest.kt` explicitando que o teste de UNIQUE depende do backfill da própria migração V39 já ter inserido a linha do grupo legado — não de outro `@Test` ter rodado antes — para evitar dúvidas em manutenções futuras sobre ordem de execução de testes.
2. Ao iniciar a Tarefa 3.0, os gateways `FindActiveSubscriptionByGroupIdGateway`/`UpsertSubscriptionGateway` deverão reaproveitar `SubscriptionRepository.findByGroupId` já criado aqui — nenhuma mudança nos artefatos desta task é necessária para isso.

## Veredito

**APROVADO.** A implementação da Tarefa 2.0 está pronta para produção dentro do escopo definido: schema fiel à Tech Spec, convenções do repositório `controlai` seguidas com precisão (nomenclatura de constraints, separação domínio/persistência, estrutura de pacotes), testes cobrindo todos os critérios de sucesso e a invariante de domínio, e verificação independente confirmando 14/14 testes do pacote `billing` passando sem falhas. Nenhuma mudança é necessária antes de prosseguir para a Tarefa 3.0 (`HandleKiwifyWebhookUseCase` + `KiwifyWebhookController`). As duas observações minor são cosméticas e não bloqueiam o avanço.

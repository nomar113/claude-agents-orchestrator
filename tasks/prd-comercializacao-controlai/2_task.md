# Tarefa 2.0: Migração e modelo de dados de assinatura (billing)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Criar a fundação de dados do novo bounded context `billing` no backend: as tabelas `subscriptions` e `kiwify_webhook_events`, incluindo o backfill de grandfathering para todos os grupos já existentes. Esta tarefa não depende de nenhuma outra e não altera comportamento existente — apenas adiciona estrutura de dados.

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — convenções de migração Flyway e organização de projeto Spring Boot/Kotlin já usadas no repositório `controlai`.
</skills>

<requirements>
- RF-11 do PRD: contas de usuários já existentes antes do lançamento comercial devem manter acesso gratuito e vitalício.
- Tech Spec `Modelos de Dados`: schema exato de `subscriptions` e `kiwify_webhook_events`, incluindo o `INSERT` de backfill `GRANDFATHERED`/`ACTIVE`.
- Seguir a convenção de migrações Flyway já usada em `src/main/resources/db/migration/` (próximo número sequencial após a última migração existente).
</requirements>

## Subtarefas

- [x] 2.1 Criar a migração Flyway com as tabelas `subscriptions` (`group_id` UNIQUE, `plan`, `status`, `kiwify_order_id`, `current_period_end`, timestamps) e `kiwify_webhook_events` (`kiwify_event_id` UNIQUE, `order_status`, `raw_payload` JSON, `processed_at`), conforme Tech Spec.
- [x] 2.2 Incluir na mesma migração (ou em uma migração subsequente) o backfill que insere uma linha `GRANDFATHERED`/`ACTIVE` para cada grupo já existente na tabela `groups`.
- [x] 2.3 Criar as entidades JPA (`SubscriptionModel`, `KiwifyWebhookEventModel`) e os repositórios Spring Data correspondentes, seguindo o padrão de nomenclatura já usado em outros bounded contexts (ex.: `application/auth/entrypoint/database/model`).
- [x] 2.4 Criar a entidade de domínio `Subscription` (com enums `SubscriptionPlan` e `SubscriptionStatus`) em `domain/billing/entity`, sem anotações de framework.

## Detalhes de Implementação

Ver Tech Spec `Modelos de Dados` para o schema completo (SQL e classe Kotlin). Seguir o padrão já usado nas migrações `V27`–`V38` (nomenclatura, uso de backtick em `groups` por ser palavra reservada no MySQL).

## Critérios de Sucesso

- `./gradlew build` roda a migração sem erros contra o banco local (Docker Compose).
- Após rodar a migração em um banco com grupos já existentes, cada grupo possui exatamente uma linha em `subscriptions` com `plan = GRANDFATHERED` e `status = ACTIVE`.
- Entidades JPA e de domínio compilam e seguem o padrão Gateway/Provider do restante do projeto (sem lógica de negócio nas entidades JPA).

## Testes da Tarefa

- [x] Teste de integração (MySQL local, seguindo a convenção já usada no projeto) validando que a migração cria as tabelas com as colunas/constraints esperadas.
- [x] Teste de integração validando o backfill: grupos pré-existentes recebem `subscriptions` com `GRANDFATHERED`/`ACTIVE`.
- [x] Teste de unidade validando as regras de construção da entidade `Subscription` (ex.: `currentPeriodEnd` nulo para planos `LIFETIME`/`GRANDFATHERED`).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/V39__create_billing_tables.sql` (novo)
- `src/main/kotlin/br/com/nomar/controlai/domain/billing/entity/Subscription.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/billing/entrypoint/database/model/SubscriptionModel.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/billing/entrypoint/database/model/KiwifyWebhookEventModel.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/billing/entrypoint/database/repository/` (novo)

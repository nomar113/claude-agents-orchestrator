# Review: Task 3.0 - Domínio billing — entidade, gateways e providers

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 3_task.md
**Status**: APROVADO

## Resumo

A Tarefa 3.0 implementa a camada de domínio e os providers do bounded context `billing`: os quatro gateways exigidos (`FindActiveSubscriptionByGroupIdGateway`, `UpsertSubscriptionGateway`, `FindKiwifyWebhookEventByIdGateway`, `SaveKiwifyWebhookEventGateway`), seus providers correspondentes, o `SubscriptionConverter` e a nova entidade de domínio `KiwifyWebhookEvent`.

A implementação segue o padrão Gateway/Provider do repositório com precisão cirúrgica. Verifiquei linha a linha que `FindActiveSubscriptionByGroupIdProvider`/`UpsertSubscriptionProvider` replicam exatamente a estrutura de `FindUserByEmailProvider` (mesmo `@Component`, mesmo uso de `runCatching`, mesma injeção de `Repository` + `Converter`), e que `FindKiwifyWebhookEventByIdProvider`/`SaveKiwifyWebhookEventProvider` replicam `CreatePasswordResetTokenProvider` (mapeamento manual inline, sem converter dedicado, justificado pela ausência de uma entidade `KiwifyWebhookEvent` na Tech Spec). As duas decisões mais sensíveis desta task — filtrar `status == ACTIVE` dentro do provider em vez de criar um método novo no repositório, e implementar o upsert via `findByGroupId` + cópia de `id` + `save()` — seguem exatamente as recomendações deixadas no review da Tarefa 2.0 e estão corretas dado que `SubscriptionModel.id` usa `@GeneratedValue(strategy = IDENTITY)` (o que faz `SimpleJpaRepository.save()` decidir INSERT vs. UPDATE/merge com base em `id == null`).

Reexecutei de forma independente `./gradlew compileKotlin compileTestKotlin` (sucesso, sem warnings) e `./gradlew test --tests "...billing.*"` (23/23 testes passando, 0 falhas — confirmado via XML de resultado: `UpsertSubscriptionProviderTest`=2, `BillingMigrationIntegrationTest`=8, `SubscriptionTest`=6, `KiwifyWebhookEventProviderTest`=3, `FindActiveSubscriptionByGroupIdProviderTest`=2, `SubscriptionConverterTest`=2), consistente com o relatado na sessão de implementação.

Não há problemas críticos ou major. Duas observações minor (não bloqueantes) estão listadas abaixo.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/billing/entity/KiwifyWebhookEvent.kt` | OK | 0 |
| `domain/billing/gateway/FindActiveSubscriptionByGroupIdGateway.kt` | OK | 0 |
| `domain/billing/gateway/UpsertSubscriptionGateway.kt` | OK | 0 |
| `domain/billing/gateway/FindKiwifyWebhookEventByIdGateway.kt` | OK | 0 |
| `domain/billing/gateway/SaveKiwifyWebhookEventGateway.kt` | OK | 0 |
| `application/billing/converter/SubscriptionConverter.kt` | OK | 0 |
| `application/billing/application/FindActiveSubscriptionByGroupIdProvider.kt` | OK | 0 |
| `application/billing/application/UpsertSubscriptionProvider.kt` | OK (1 minor) | 1 |
| `application/billing/application/FindKiwifyWebhookEventByIdProvider.kt` | OK (1 minor) | 1 |
| `application/billing/application/SaveKiwifyWebhookEventProvider.kt` | OK (1 minor, mesma observação) | - |
| `test/.../SubscriptionConverterTest.kt` | OK | 0 |
| `test/.../FindActiveSubscriptionByGroupIdProviderTest.kt` | OK | 0 |
| `test/.../UpsertSubscriptionProviderTest.kt` | OK | 0 |
| `test/.../KiwifyWebhookEventProviderTest.kt` | OK | 0 |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`UpsertSubscriptionProvider.kt:16-21` — upsert via "ler-depois-escrever" não é atômico sob concorrência.**
   `findByGroupId` e `save()` são duas operações separadas sem lock nem `INSERT ... ON DUPLICATE KEY`. Se dois webhooks para o mesmo `groupId` forem processados verdadeiramente em paralelo (ex.: reenvio simultâneo da Kiwify), ambos podem ler `existingId = null` e tentar `INSERT`, e o segundo falharia com violação da constraint `uk_subscriptions_group_id` (propagado como `Result.failure` via `runCatching`, não como corrupção de dado). Isto é exatamente o comportamento pedido pela task (reaproveitar `findByGroupId` sem alterar o repositório) e o risco é baixo dado o volume esperado e que a idempotência por `kiwify_event_id` (Tarefa 4.0) deve serializar o processamento por evento. Não bloqueia esta task; vale reavaliar quando `HandleKiwifyWebhookUseCase` for implementado (ex.: `@Transactional` com isolamento maior, ou tratar a falha de UNIQUE como sinal para reter/retry).

2. **`FindKiwifyWebhookEventByIdProvider.kt` / `SaveKiwifyWebhookEventProvider.kt` — mapeamento manual duplicado nas duas direções em dois arquivos diferentes.**
   Os dois providers repetem o mesmo bloco de conversão `KiwifyWebhookEventModel <-> KiwifyWebhookEvent` campo a campo. O precedente citado (`CreatePasswordResetTokenProvider`) só mapeia uma direção manualmente em um único provider; aqui a mesma lógica de mapeamento aparece duas vezes. Funciona corretamente hoje (confirmado pelos testes), mas se um terceiro provider de `KiwifyWebhookEvent` for adicionado numa próxima task, considerar extrair um `KiwifyWebhookEventConverter` (mesmo padrão do `SubscriptionConverter` já existente neste PR) para eliminar a duplicação antes que ela cresça. Sugestão, não obrigatório para aprovar esta task.

## Destaques Positivos

- **Aderência exata ao padrão Gateway/Provider do repositório**: comparei diretamente com `FindUserByEmailGateway`/`FindUserByEmailProvider` (referência citada na própria task) e a estrutura — `fun interface` no domínio, `@Component` + construtor injection no provider, `runCatching` envolvendo toda a lógica — é idêntica.
- **Reaproveitamento correto da recomendação da Tarefa 2.0**: `FindActiveSubscriptionByGroupIdProvider` filtra `status == ACTIVE` em memória via `takeIf`, sem adicionar método novo ao `SubscriptionRepository`, exatamente como recomendado no review anterior.
- **Upsert semanticamente correto e independente do estado do objeto de entrada**: `UpsertSubscriptionProvider` sempre busca o `id` real via `findByGroupId` antes de salvar, em vez de confiar em um `id` que o chamador possa ter passado — isso torna o gateway correto mesmo se for chamado repetidamente com o mesmo `Subscription` sem `id`, o que é exatamente o cenário de um webhook de renovação.
- **Testes cobrem precisamente os critérios de sucesso da task**: transição de status ao longo do tempo (ACTIVE → CANCELLED → ACTIVE) exercitando o filtro do `FindActiveSubscriptionByGroupIdProvider`, os dois caminhos do upsert (criação e atualização, com assert de `COUNT(*) = 1` para provar que não duplicou linha), e o conflito de `kiwify_event_id` duplicado retornando `Result.failure` em vez de lançar exceção não tratada.
- **Cuidado correto com a precisão de `TIMESTAMP` do MySQL**: o teste de upsert trunca o `Instant` esperado para `ChronoUnit.SECONDS` com um comentário explicando o motivo (`current_period_end TIMESTAMP` na V39 não tem precisão fracionária) — evita um teste frágil por diferença de nanossegundos.
- **Isolamento de teste consistente com a convenção já estabelecida**: `@AfterEach` limpando `subscriptions`/`kiwify_webhook_events`/`groups` via `JdbcTemplate`, e uso de `System.nanoTime()` para IDs de evento únicos, seguindo a mesma estratégia adotada em `BillingMigrationIntegrationTest` (Tarefa 2.0) para conviver com o banco MySQL compartilhado entre suítes.
- **Entidade `KiwifyWebhookEvent` bem posicionada**: mesmo não estando explícita na Tech Spec, foi corretamente alocada em `domain/billing/entity` ao lado de `Subscription`, mantendo a separação domínio/persistência já estabelecida pela Tarefa 2.0.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (nomenclatura, tamanho de classe/método, sem lógica vazando de camada) | OK |
| Kotlin/Spring Boot (Gateway/Provider, `fun interface`, `Result<T>`, `@Component`) | OK |
| Domain-Driven Design (domínio livre de anotações JPA, conversores explícitos) | OK |
| Testes (unidade + integração, convenção MySQL do projeto, cobertura dos critérios da task) | OK |

## Recomendações

1. (Minor, não bloqueante) Ao implementar `HandleKiwifyWebhookUseCase` na Tarefa 4.0, reavaliar se o padrão "ler-depois-escrever" do `UpsertSubscriptionProvider` precisa de reforço transacional/tratamento de conflito, já que múltiplos webhooks para o mesmo grupo passarão a fluir por ele.
2. (Minor, opcional) Se um terceiro ponto de mapeamento de `KiwifyWebhookEvent` surgir, extrair um `KiwifyWebhookEventConverter` nos moldes do `SubscriptionConverter` para eliminar a duplicação hoje presente em `FindKiwifyWebhookEventByIdProvider`/`SaveKiwifyWebhookEventProvider`.
3. Commitar os arquivos desta task (atualmente `??` no `git status`, não commitados) antes de iniciar a Tarefa 4.0, seguindo o padrão de commit por task já usado nas Tarefas 2.0 e anteriores.

## Veredito

**APROVADO.** A implementação da Tarefa 3.0 está pronta para servir de base para a Tarefa 4.0 (`HandleKiwifyWebhookUseCase` + `KiwifyWebhookController`): os quatro gateways/providers pedidos existem, seguem o padrão Gateway/Provider do repositório com fidelidade comprovada por comparação direta com as referências citadas na própria task, e os critérios de sucesso (compilação, upsert funcionando para criação e atualização, controllers/use cases nunca acessando repositórios JPA diretamente) estão satisfeitos. Reexecutei de forma independente a suíte do pacote `billing` e confirmei 23/23 testes passando, 0 falhas. As duas observações minor (concorrência no upsert e duplicação de mapeamento do webhook event) são registradas para acompanhamento futuro e não bloqueiam o avanço.

# Review: Task 6.0 - Gate de acesso por assinatura (SubscriptionGuardFilter)

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 6_task.md
**Status**: APROVADO (pendência Major resolvida em follow-up)

## Resumo

A implementação cobre corretamente RF-9, RF-10 e RF-11: um novo `SubscriptionGuardFilter` (`OncePerRequestFilter`) resolve o `groupId` a partir da `Authentication` no `SecurityContextHolder` (suportando `ApiKeyAuthentication` e `JwtAuthenticationToken`, com a mesma lógica de leitura do claim `groupId` já usada em `JwtRequestContext`), consulta `FindActiveSubscriptionByGroupIdGateway` e responde `402 Payment Required` quando o grupo não tem assinatura com `status = ACTIVE`. As rotas públicas (`/auth/**`, `/webhooks/**`, `/health`, `/actuator/health`) são corretamente excluídas via `shouldNotFilter`, sem nenhuma consulta ao banco. O filtro é registrado no `SecurityConfig` com `addFilterAfter(..., BearerTokenAuthenticationFilter::class.java)`, posição que efetivamente garante execução após a resolução de autenticação tanto via API Key (que roda antes do `BearerTokenAuthenticationFilter`) quanto via JWT.

O código segue fielmente o padrão já estabelecido por `ApiKeyAuthFilter.kt` (uso de `Result<T>` + `onFailure`/`getOrNull()`, filtro fail-closed em caso de erro no gateway, escrita manual do corpo JSON de erro). A decisão técnica de checar o status a cada request (sem embutir no JWT) foi respeitada — a implementação não faz nenhuma leitura de status de assinatura fora do gateway.

A suíte de testes (unidade + integração, incluindo os dois testes de integração pré-existentes ajustados para inserir uma subscription ACTIVE) foi executada e passou (`BUILD SUCCESSFUL`, confirmado nesta revisão via `./gradlew test` com os testes relevantes, com o container `mysql_local` ativo).

Único ponto que impede o "APROVADO" sem ressalvas é uma lacuna de cobertura de teste no branch de `ApiKeyAuthentication` do próprio filtro (ver Problemas Major).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/main/kotlin/.../config/SubscriptionGuardFilter.kt` | Problemas (minor) | 3 |
| `src/main/kotlin/.../config/SecurityConfig.kt` | OK | 0 |
| `src/test/kotlin/.../config/SubscriptionGuardFilterTest.kt` | Problemas (major) | 1 |
| `src/test/kotlin/.../config/SubscriptionGuardFilterIntegrationTest.kt` | Problemas (major, mesmo gap) | 1 (compartilhado) |
| `src/test/kotlin/.../auth/ForgotResetPasswordIntegrationTest.kt` | OK | 0 |
| `src/test/kotlin/.../groups/GroupInviteIntegrationTest.kt` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema crítico encontrado.

### Problemas Major

1. ~~**Falta cobertura de teste para o branch `ApiKeyAuthentication` de `resolveGroupId`**~~ — **RESOLVIDO.** Foram adicionados dois testes de unidade (`allows request authenticated via API key when group has an active subscription`, `blocks with 402 when group authenticated via API key has no subscription`) autenticando via `ApiKeyAuthentication(groupId)` diretamente, e um teste de integração (`POST payments notification returns 402 for an API-key group without an active subscription`) contra o endpoint real `POST /payments/notification`. Este último exigiu sobrescrever explicitamente o header `Authorization` (com valor vazio) para neutralizar o Bearer token padrão injetado pelo `TestAuthMockMvcConfig` em toda requisição do MockMvc — sem isso, o `BearerTokenAuthenticationFilter` sobrescrevia a `ApiKeyAuthentication` com um `JwtAuthenticationToken` para o grupo 1 (grandfathered/ativo), mascarando o cenário testado. Suíte completa (`./gradlew test`) reexecutada e passando (`BUILD SUCCESSFUL`) após a correção.

### Problemas Minor

1. **Duplicação da lógica de resolução de `groupId`** (`SubscriptionGuardFilter.kt:50-54` vs. `JwtRequestContext.kt:17-23`). O `when` que distingue `ApiKeyAuthentication` de `JwtAuthenticationToken` e extrai o claim `"groupId"` está copiado quase identicamente nos dois arquivos. Se o nome do claim ou o tipo de autenticação mudar no futuro, é fácil atualizar um lugar e esquecer o outro. Vale extrair para uma função utilitária compartilhada (ex.: `AuthenticationGroupIdResolver`) usada por ambos.

2. ~~**Passagem silenciosa quando um `JwtAuthenticationToken` autenticado não tem claim `groupId`**~~ — **RESOLVIDO.** O comentário em `SubscriptionGuardFilter.kt` foi expandido para deixar explícito que o branch `groupId == null` cobre tanto "sem autenticação" quanto "JWT autenticado sem claim `groupId`".

3. **Constante local para o código HTTP 402** (`SubscriptionGuardFilter.kt:14`). `HTTP_STATUS_PAYMENT_REQUIRED = 402` evita magic number (correto), mas o restante do código de produção usa `org.springframework.http.HttpStatus` (ex.: `AuthController.kt`, `ProfileController.kt`) enquanto os filtros (`ApiKeyAuthFilter`) usam constantes cruas do Servlet (`HttpServletResponse.SC_UNAUTHORIZED`). Como não existe `SC_PAYMENT_REQUIRED` no Servlet API, a escolha atual é razoável e consistente com o padrão de filtro referenciado pela task; citando apenas como observação de estilo, não como bloqueio.

4. **Fail-closed indistinguível de "sem assinatura" em caso de falha no gateway** (`SubscriptionGuardFilter.kt:38-40`). Se `findActiveSubscriptionByGroupIdGateway.execute` falhar (ex.: timeout de banco), o filtro loga o erro mas responde `402 subscription_inactive` para o cliente — indistinguível, do ponto de vista do usuário, de uma assinatura realmente inativa. Esse é o mesmo padrão fail-closed já usado em `ApiKeyAuthFilter` (que trata falha do gateway igual a "chave inválida"), então é consistente com a convenção do projeto e aceitável do ponto de vista de segurança. Vale considerar, como melhoria futura (fora do escopo desta task), emitir uma métrica (como o `meterRegistry.counter("auth.api_key.invalid")` do `ApiKeyAuthFilter`) para diferenciar operacionalmente "erro no gateway" de "assinatura genuinamente inativa" durante um incidente de infraestrutura.

## Destaques Positivos

- Aderência exata ao padrão de filtro já estabelecido por `ApiKeyAuthFilter` (`OncePerRequestFilter`, `shouldNotFilter`, tratamento de `Result<T>` com `onFailure`/`getOrNull()`).
- Reaproveitamento correto e consistente da lógica de leitura do claim `groupId` já validada em `JwtRequestContext`.
- Posicionamento do filtro no `SecurityConfig` corretamente analisado e documentado via comentário — cobre tanto o fluxo de autenticação por API Key quanto por JWT, e a ordem foi verificada nesta revisão em relação à posição do `BearerTokenAuthenticationFilter`, `AnonymousAuthenticationFilter` e `AuthorizationFilter` na cadeia padrão do Spring Security.
- Boa cobertura de teste de unidade cobrindo os quatro cenários pedidos pela task (ativo, sem assinatura, cancelado, bypass de rotas públicas) e teste de integração end-to-end real contra `GET /purchases` com estados de assinatura reais no MySQL.
- Efeito colateral nos dois testes de integração pré-existentes (`ForgotResetPasswordIntegrationTest`, `GroupInviteIntegrationTest`) tratado corretamente: subscription ACTIVE inserida junto com o grupo de teste e removida no cleanup, respeitando a FK `subscriptions.group_id -> groups.id`.
- Nenhum código, comentário ou nome fora do inglês; nomes claros, sem abreviações, sem magic numbers.
- Toda a suíte de testes relevante foi re-executada nesta revisão e passou (`BUILD SUCCESSFUL`).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP | OK |
| Segurança (fail-open/fail-closed) | OK (com observação minor 4) |
| Testes | Problemas (gap major no branch ApiKeyAuthentication) |
| Aderência PRD/Tech Spec (RF-9/10/11, decisões técnicas) | OK |

## Recomendacoes

1. (Prioridade alta) Adicionar teste de unidade cobrindo o branch `ApiKeyAuthentication` de `resolveGroupId` no `SubscriptionGuardFilterTest`, e idealmente um teste de integração para `POST /payments/notification` com API Key.
2. (Opcional) Extrair a lógica de resolução de `groupId` a partir da `Authentication`, hoje duplicada entre `SubscriptionGuardFilter` e `JwtRequestContext`, para uma função compartilhada.
3. (Opcional) Explicitar no comentário do `doFilterInternal` que o caminho de "groupId nulo" cobre tanto "sem autenticação" quanto "JWT autenticado sem claim `groupId`".
4. (Fora do escopo desta task, backlog) Considerar métrica/alerta para diferenciar falha do gateway de subscription realmente inativa.

## Veredito

Implementação sólida, aderente ao PRD/Tech Spec e ao padrão de código já estabelecido no projeto (`ApiKeyAuthFilter`, `JwtRequestContext`). Não há problemas críticos nem bugs de comportamento identificados — os critérios de sucesso da task (grupo ativo/grandfathered acessa, grupo sem assinatura ou cancelado recebe 402, rotas públicas seguem acessíveis sem consulta a `subscriptions`) estão todos cobertos e verificados por teste. A única pendência relevante é a falta de teste para o branch de autenticação via API Key, que recomendo adicionar antes de considerar a tarefa definitivamente encerrada, mas que não bloqueia o merge nem indica um defeito funcional conhecido. Status: **APROVADO COM OBSERVACOES**.

# Review: Task 3.0 - Backend — API key para automacao do iPhone + groupId no SQS

**Revisor**: AI Code Reviewer
**Data**: 2026-08-01
**Arquivo da task**: 3_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task implementa autenticacao por API key para o endpoint `POST /payments/notification`, propagacao do `groupId` na mensagem SQS, gerenciamento de chaves via `/me/api-key` e metrica Micrometer. A arquitetura segue o padrao clean architecture do projeto (entidade de dominio, gateways, usecases, providers) e todos os criterios funcionais foram atendidos. A qualidade geral e boa: nomes expressivos, testes solidos e nenhum bug critico. Foram identificadas quatro issues minor e uma observacao de segurança que merecem atencao, mas nenhuma bloqueia a promocao desta task.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/main/resources/db/migration/V31__create_api_keys_table.sql` | OK | 0 |
| `domain/auth/entity/ApiKey.kt` | Problemas | 1 |
| `domain/auth/gateway/CreateApiKeyGateway.kt` | OK | 0 |
| `domain/auth/gateway/FindApiKeyByGroupIdGateway.kt` | OK | 0 |
| `domain/auth/gateway/FindApiKeyByHashGateway.kt` | OK | 0 |
| `domain/auth/gateway/RevokeApiKeyGateway.kt` | OK | 0 |
| `domain/auth/usecase/CreateApiKeyUseCase.kt` | Problemas | 2 |
| `domain/auth/usecase/GetApiKeyUseCase.kt` | OK | 0 |
| `domain/auth/usecase/RevokeApiKeyUseCase.kt` | OK | 0 |
| `domain/auth/TokenHasher.kt` | OK | 0 |
| `application/auth/entrypoint/database/model/ApiKeyModel.kt` | OK | 0 |
| `application/auth/entrypoint/database/repository/ApiKeyRepository.kt` | OK | 0 |
| `application/auth/application/ApiKeyProvider.kt` | OK | 0 |
| `config/ApiKeyAuthentication.kt` | OK | 0 |
| `config/ApiKeyAuthFilter.kt` | Problemas | 1 |
| `config/SecurityConfig.kt` | OK | 0 |
| `config/JwtRequestContext.kt` | OK | 0 |
| `application/auth/entrypoint/rest/ProfileController.kt` | OK | 0 |
| `application/auth/entrypoint/rest/response/AuthResponses.kt` | OK | 0 |
| `application/payments_notification/entrypoint/queue/model/PaymentNotificationQueueMessage.kt` | OK | 0 |
| `application/payments_notification/entrypoint/queue/PaymentNotificationQueueListener.kt` | OK | 0 |
| `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` | OK | 0 |
| `test/domain/auth/ApiKeyUseCasesTest.kt` | OK | 0 |
| `test/application/payments_notification/ApiKeyAuthIntegrationTest.kt` | Problemas | 1 |
| `test/application/payments_notification/entrypoint/queue/PaymentNotificationQueueListenerTest.kt` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**[MINOR-1] Erro de infraestrutura silenciado como falha de autenticacao**

Arquivo: `src/main/kotlin/br/com/nomar/controlai/config/ApiKeyAuthFilter.kt`, linha 28

O uso de `.getOrNull()` faz com que qualquer excecao lancada pelo gateway (timeout de banco, erro de conexao, etc.) seja tratada como chave nao encontrada. O efeito pratico e duplo: o request recebe 401 como se a chave fosse invalida, e o contador `auth.api_key.invalid` e incrementado, gerando falso positivo em monitoramento.

```kotlin
// Atual — erros de infraestrutura viram 401 silenciosamente
val apiKey = findApiKeyByHashGateway.execute(keyHash).getOrNull()
if (apiKey == null || apiKey.isRevoked()) {
    meterRegistry.counter("auth.api_key.invalid").increment()
    rejectUnauthorized(response)
    return
}

// Sugestao — distinguir chave ausente de erro de infraestrutura
val result = findApiKeyByHashGateway.execute(keyHash)
if (result.isFailure) {
    logger.error("Failed to look up API key", result.exceptionOrNull())
    response.status = HttpServletResponse.SC_INTERNAL_SERVER_ERROR
    return
}
val apiKey = result.getOrNull()
if (apiKey == null || apiKey.isRevoked()) {
    meterRegistry.counter("auth.api_key.invalid").increment()
    rejectUnauthorized(response)
    return
}
```

---

**[MINOR-2] String magica `"cap_"` sem constante nomeada**

Arquivo: `src/main/kotlin/br/com/nomar/controlai/domain/auth/usecase/CreateApiKeyUseCase.kt`, linha 24

O prefixo `"cap_"` e uma string literal hardcoded dentro do metodo `execute`. Violacao do padrao "no magic numbers/strings".

```kotlin
// Atual
val rawKey = "cap_" + UUID.randomUUID().toString().replace("-", "")

// Sugestao — extrair como constante na companion object
companion object {
    private const val RAW_KEY_PREFIX = "cap_"
}

val rawKey = RAW_KEY_PREFIX + UUID.randomUUID().toString().replace("-", "")
```

---

**[MINOR-3] Valor default `"iPhone Shortcut"` repetido em tres lugares sem constante compartilhada**

Arquivos:
- `domain/auth/entity/ApiKey.kt`, linha 10
- `application/auth/entrypoint/database/model/ApiKeyModel.kt`, linha 27
- `domain/auth/usecase/CreateApiKeyUseCase.kt`, linha 17

O label padrao `"iPhone Shortcut"` e definido como literal em tres arquivos distintos. Se o valor precisar mudar, todos os tres pontos precisam ser atualizados.

```kotlin
// Sugestao — definir na entidade de dominio e referenciar nos demais
// Em ApiKey.kt
companion object {
    const val DEFAULT_LABEL = "iPhone Shortcut"
}

data class ApiKey(
    val label: String = DEFAULT_LABEL,
    ...
)

// Em ApiKeyModel.kt
val label: String = ApiKey.DEFAULT_LABEL

// Em CreateApiKeyUseCase.kt
fun execute(groupId: Long, label: String = ApiKey.DEFAULT_LABEL): ...
```

---

**[MINOR-4] Inconsistencia de tipos de data/hora na entidade `ApiKey`**

Arquivo: `src/main/kotlin/br/com/nomar/controlai/domain/auth/entity/ApiKey.kt`, linhas 11-12

`createdAt` usa `LocalDateTime` enquanto `revokedAt` usa `Instant`. Sem fuso horario em `LocalDateTime`, o valor fica ambiguo em contextos onde o servidor muda de timezone. A convencao do Spring Boot com Hibernate e usar `Instant` para timestamps de auditoria, que e timezone-aware.

```kotlin
// Atual — tipos mistos
val createdAt: LocalDateTime? = null,
val revokedAt: Instant? = null,

// Sugestao — uniformizar para Instant
val createdAt: Instant? = null,
val revokedAt: Instant? = null,
```

Obs: o `ApiKeyModel.kt` ja usa `LocalDateTime` com `@CreationTimestamp`, entao a mudanca exigiria alinhamento no modelo JPA tambem. Se a preferencia do projeto for manter `LocalDateTime` no JPA, o ideal e manter consistencia e usar `LocalDateTime` em ambos os campos da entidade de dominio.

---

**[MINOR-5] Linhas em branco dentro do corpo do metodo `execute` em `CreateApiKeyUseCase`**

Arquivo: `src/main/kotlin/br/com/nomar/controlai/domain/auth/usecase/CreateApiKeyUseCase.kt`, linhas 23 e 30

Dentro do bloco `runCatching`, ha duas linhas em branco separando logica dentro do mesmo metodo. O padrao do projeto e nao ter linhas em branco dentro de metodos.

```kotlin
// Atual — linhas em branco dentro do metodo
return runCatching {
    val existing = findApiKeyByGroupIdGateway.execute(groupId).getOrThrow()
    if (existing != null && !existing.isRevoked()) {
        throw IllegalStateException("An active API key already exists. Revoke it before creating a new one.")
    }
                                          // <-- linha em branco aqui
    val rawKey = "cap_" + UUID.randomUUID().toString().replace("-", "")
    val keyHash = TokenHasher.sha256(rawKey)
    val saved = createApiKeyGateway.execute(
        ApiKey(groupId = groupId, keyHash = keyHash, label = label)
    ).getOrThrow()
                                          // <-- linha em branco aqui
    Pair(saved, rawKey)
}

// Sugestao — remover as linhas em branco
return runCatching {
    val existing = findApiKeyByGroupIdGateway.execute(groupId).getOrThrow()
    if (existing != null && !existing.isRevoked()) {
        throw IllegalStateException("An active API key already exists. Revoke it before creating a new one.")
    }
    val rawKey = RAW_KEY_PREFIX + UUID.randomUUID().toString().replace("-", "")
    val keyHash = TokenHasher.sha256(rawKey)
    val saved = createApiKeyGateway.execute(
        ApiKey(groupId = groupId, keyHash = keyHash, label = label)
    ).getOrThrow()
    Pair(saved, rawKey)
}
```

## Destaques Positivos

- **Arquitetura limpa e consistente**: a adicao de `ApiKey` seguiu fielmente o padrao existente do projeto (entidade de dominio, gateways SAM, usecases `@Component`, providers como adapters). O resultado e um codigo novo que parece ter sempre existido no codebase.

- **`ApiKeyAuthFilter` nao e um `@Bean`**: a instanciacao manual dentro do `.addFilterBefore()` evita que o Spring Boot registre o filtro automaticamente para todas as requisicoes HTTP fora da security filter chain. E uma decisao correta e nao-obvvia.

- **`FindApiKeyProvider` implementa dois gateways em uma unica classe de forma legitima**: o comentario explica que os dois SAMs nao colidem por terem tipos de parametro diferentes (`Long` vs `String`). Isso evita duas classes triviais sem sacrificar a separacao de interfaces.

- **Fallback `LEGACY_GROUP_ID` bem documentado**: a constante nomeada e o comentario no `PaymentNotificationQueueMessage` e no listener deixam clara a intencao e a janela de transicao. Futuro desenvolvedor entende imediatamente quando esse codigo pode ser removido.

- **Testes de qualidade**: os 8 testes de unidade cobrem todos os casos de borda dos usecases (chave ativa existente, chave revogada existente, unicidade de raw key). Os 4 testes de integracao exercitam os 4 cenarios do filtro com banco real. Os testes do listener cobrem os dois caminhos de fallback. Cobertura adequada para o escopo da task.

- **Protecao correta da rota `POST /payments/notification` no SecurityConfig**: o filtro API key roda antes do `BearerTokenAuthenticationFilter` e rejeita a requisicao sem JWT como alternativa aceitavel, o que e o comportamento desejado para automacao.

- **Metrica `auth.api_key.invalid` implementada**: requisito da task atendido com a API idiomatica do Micrometer.

- **Valor da chave nunca retornado apos a criacao**: o `ApiKeyResponse` (GET) nao expoe o `keyHash` nem o valor em claro. Apenas o `ApiKeyCreatedResponse` (POST) exibe o raw value, e so no momento da criacao.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas |
| Kotlin/Spring Boot | OK |
| REST/HTTP | OK |
| Logging | Problemas |
| Testes | OK |

**Padroes de Codigo**: cinco issues minor detectadas (string magica `"cap_"`, string repetida `"iPhone Shortcut"`, linhas em branco dentro de metodo, inconsistencia de tipos de data, e erro de infraestrutura silenciado).

**Logging**: `ApiKeyAuthFilter` nao possui `Logger` e nao loga erros de gateway — falhas de infraestrutura passam silenciosas sem nenhum rastro alem do 401 retornado.

## Recomendacoes

1. **(Alta prioridade)** Corrigir o `ApiKeyAuthFilter` para diferenciar `Result.failure` (erro de infraestrutura) de `null` (chave nao encontrada), retornando 500 e logando o erro no primeiro caso.

2. **(Media prioridade)** Extrair `"cap_"` como constante `RAW_KEY_PREFIX` na companion object de `CreateApiKeyUseCase`.

3. **(Media prioridade)** Definir `DEFAULT_LABEL = "iPhone Shortcut"` como constante em `ApiKey.kt` e referenciar nos demais locais.

4. **(Baixa prioridade)** Uniformizar os tipos de data/hora na entidade `ApiKey` — usar `Instant` em ambos os campos (`createdAt` e `revokedAt`) ou `LocalDateTime` em ambos.

5. **(Baixa prioridade)** Remover as duas linhas em branco dentro do metodo `execute` de `CreateApiKeyUseCase` para conformidade com o padrao do projeto.

## Veredito

A implementacao esta correta, segura e bem testada. Todos os criterios de sucesso da task foram atendidos: o endpoint `POST /payments/notification` autentica via `X-Api-Key` com rejeicao adequada (401) para chaves ausentes, invalidas e revogadas; o `groupId` e propagado na mensagem SQS com fallback para o grupo legado; a metrica Micrometer esta implementada; os endpoints de gerenciamento de chave estao funcionais.

Os cinco problemas minor nao comprometem a funcionalidade e podem ser corrigidos nesta task ou acumulados para uma sessao de limpeza tecnica. A recomendacao 1 (silenciamento de erros de infraestrutura) e a unica que tem impacto em observabilidade em producao e merece resolucao antes do cutover completo (Task 9.0).

**Proximos passos**: task pode seguir para a Task 4.0 (frontend — sessao). Recomendacoes 1-3 sao candidatas a correcao rapida antes de seguir.

# Review: Task 7.0 - E-mail: Recuperacao e troca de senha (Resend)

**Revisor**: AI Code Reviewer
**Data**: 2026-08-02
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

---

## Resumo

A Task 7.0 implementa os tres fluxos de autoatendimento de senha: recuperacao via e-mail (Resend), redefinicao com token de validade de 1 hora e uso unico, e troca de senha para usuario autenticado. A implementacao respeita rigorosamente a arquitetura clean (domain/gateway/provider/controller), segue os padroes do projeto e cobre os requisitos de segurança criticos: token single-use, SHA-256 no banco, raw token enviado por e-mail, e resposta sempre 204 no forgot-password para nao revelar a existencia do e-mail. Cobertura de testes solida: 15 testes de integracao e 13 testes unitarios no backend, 17 testes Vitest no frontend, todos passando. Nenhum problema critico foi encontrado; os pontos levantados sao oportunidades de hardening e melhoria de consistencia.

---

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/auth/entity/PasswordResetToken.kt` | OK | 0 |
| `domain/auth/gateway/EmailGateway.kt` | OK | 0 |
| `domain/auth/gateway/CreatePasswordResetTokenGateway.kt` | OK | 0 |
| `domain/auth/gateway/FindPasswordResetTokenByHashGateway.kt` | OK | 0 |
| `domain/auth/gateway/MarkPasswordResetTokenUsedGateway.kt` | OK | 0 |
| `domain/auth/usecase/ForgotPasswordUseCase.kt` | OK | 1 minor |
| `domain/auth/usecase/ResetPasswordUseCase.kt` | OK | 1 minor |
| `domain/auth/usecase/ChangePasswordUseCase.kt` | OK | 1 minor |
| `domain/auth/exception/AuthExceptions.kt` | OK | 0 |
| `domain/auth/TokenHasher.kt` | OK | 0 |
| `application/auth/application/ResendEmailClient.kt` | Problemas | 2 major |
| `application/auth/application/CreatePasswordResetTokenProvider.kt` | OK | 0 |
| `application/auth/application/FindPasswordResetTokenByHashProvider.kt` | OK | 0 |
| `application/auth/application/MarkPasswordResetTokenUsedProvider.kt` | Problemas | 1 major |
| `application/auth/application/UpdateUserPasswordProvider.kt` | OK | 0 |
| `application/auth/entrypoint/rest/AuthController.kt` | OK | 0 |
| `application/auth/entrypoint/rest/ProfileController.kt` | OK | 0 |
| `application/auth/entrypoint/rest/request/AuthRequests.kt` | OK | 0 |
| `application/auth/entrypoint/database/model/PasswordResetTokenModel.kt` | OK | 0 |
| `application/auth/entrypoint/database/repository/PasswordResetTokenRepository.kt` | OK | 0 |
| `db/migration/V32__create_password_reset_tokens_table.sql` | Problemas | 1 major |
| `domain/auth/test/PasswordUseCasesTest.kt` | OK | 1 minor |
| `application/auth/ForgotResetPasswordIntegrationTest.kt` | OK | 0 |
| `pages/ForgotPasswordPage.tsx` | OK | 0 |
| `pages/ResetPasswordPage.tsx` | OK | 1 minor |
| `pages/ForgotPasswordPage.test.tsx` | OK | 0 |
| `pages/ResetPasswordPage.test.tsx` | OK | 0 |
| `services/authService.ts` | OK | 0 |

---

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

---

### Problemas Major

**MAJOR-1 — `MarkPasswordResetTokenUsedProvider`: race condition no single-use enforcement**

Arquivo: `application/auth/application/MarkPasswordResetTokenUsedProvider.kt`, linhas 15–19

O metodo faz `findById` seguido de `save` em duas operacoes separadas. Em ambiente com multiplas instancias ou requisicoes concorrentes com o mesmo token, dois threads podem passar pela verificacao `if (model.usedAt == null)` antes que qualquer um persista o `usedAt`, resultando em duplo uso do token. A correto seria usar uma query UPDATE atomica diretamente no repositorio.

Correcao sugerida:

```kotlin
// PasswordResetTokenRepository
@Modifying
@Query("UPDATE PasswordResetTokenModel m SET m.usedAt = :usedAt WHERE m.id = :id AND m.usedAt IS NULL")
fun markUsedById(@Param("id") id: Long, @Param("usedAt") usedAt: Instant): Int

// MarkPasswordResetTokenUsedProvider
override fun execute(tokenId: Long): Result<Unit> {
    return runCatching {
        passwordResetTokenRepository.markUsedById(tokenId, Instant.now())
    }
}
```

Note: o valor de retorno `Int` (linhas afetadas) pode ser ignorado pois a validacao de estado ja foi feita pelo `isValid()` antes de chegar aqui. Se for desejavel um erro explicito em caso de race, pode-se verificar `== 0` e lancar excecao.

---

**MAJOR-2 — `ResendEmailClient`: `RestClient` criado a cada instancia em vez de singleton**

Arquivo: `application/auth/application/ResendEmailClient.kt`, linha 17

```kotlin
private val restClient = RestClient.create()
```

`RestClient.create()` internamente cria um `SimpleClientHttpRequestFactory` (um `HttpURLConnection` pool). Em producao, o padrao Spring Boot e injetar um `RestClient.Builder` configurado com timeouts, interceptors e connection pooling. Criar o cliente direto no construtor do bean e um anti-padrao que pode gerar problemas de performance e dificulta testes.

Correcao sugerida:

```kotlin
@Component
class ResendEmailClient(
    restClientBuilder: RestClient.Builder,
    @Value("\${resend.api-key}") private val apiKey: String,
    @Value("\${resend.from-email}") private val fromEmail: String,
) : EmailGateway {

    private val restClient = restClientBuilder.build()
    // ...
}
```

---

**MAJOR-3 — Migration V32: FK sem `ON DELETE` e ausencia de indice por `user_id`**

Arquivo: `db/migration/V32__create_password_reset_tokens_table.sql`, linhas 12–13

A FK `fk_prt_user` nao define comportamento em caso de exclusao do usuario (`ON DELETE`). Se um usuario for removido, os tokens orfaos ficam na tabela. O padrao mais seguro para este caso e `ON DELETE CASCADE`.

Alem disso, a coluna `user_id` e acessada frequentemente para limpeza de tokens por usuario (ex: durante testes e em eventual janela de cleanup), mas nao tem indice proprio. O `UNIQUE` em `token_hash` gera um indice, mas nao cobre queries por `user_id`.

Correcao sugerida (nova migration ou ajuste se a tabela nao esta em producao):

```sql
CONSTRAINT fk_prt_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
-- E adicionar:
INDEX idx_prt_user_id (user_id)
```

---

### Problemas Minor

**MINOR-1 — `ForgotPasswordUseCase`: comentario inline viola padrao "codigo autoexplicativo"**

Arquivo: `domain/auth/usecase/ForgotPasswordUseCase.kt`, linha 24

```kotlin
// Always returns success to avoid revealing whether the email exists (RF-2.3)
fun execute(email: String): Result<Unit> {
```

O padrao do projeto proibe comentarios para codigo autoexplicativo. A referencia ao requisito RF-2.3 e util, mas o nome do usecase e o contrato da funcao ja sao suficientemente claros. Remover o comentario ou mover a referencia ao RF para o KDoc do arquivo/classe se for obrigatoria a rastreabilidade.

---

**MINOR-2 — `ResetPasswordUseCase`: mensagem de validacao em portugues no dominio**

Arquivo: `domain/auth/usecase/ResetPasswordUseCase.kt`, linha 23

```kotlin
require(newPassword.length >= MIN_PASSWORD_LENGTH) {
    "A senha deve ter no minimo $MIN_PASSWORD_LENGTH caracteres"
}
```

O padrao do projeto e que comentarios e mensagens de codigo estejam em ingles. A mensagem de validacao que aparece na excecao `IllegalArgumentException` sera repassada ao controller e eventualmente ao cliente. Isso e inconsistente com `AuthRequests.kt` onde a mesma validacao usa `@Size(min = 8, message = "A senha deve ter no minimo 8 caracteres")` em portugues. Padronizar ambos em ingles no dominio e deixar a traducao para a camada de apresentacao (o controller/frontend ja faz isso).

O mesmo vale para `ChangePasswordUseCase.kt` linha 18 e a mensagem de usuario nao encontrado em `UpdateUserPasswordProvider.kt` linha 15.

---

**MINOR-3 — `MarkPasswordResetTokenUsedProvider`: `ifPresent` oculta ausencia do token**

Arquivo: `application/auth/application/MarkPasswordResetTokenUsedProvider.kt`, linhas 15–19

```kotlin
passwordResetTokenRepository.findById(tokenId).ifPresent { model ->
    if (model.usedAt == null) { ... }
}
```

Se `findById` retornar vazio (token nao encontrado por algum motivo), o metodo retorna silenciosamente `Unit` sem errar. Na pratica isso nao e um problema pois o token e validado antes pelo `ResetPasswordUseCase`, mas torna o provider mais fragil do que o necessario. Preferir `orElseThrow` com excecao explicita.

---

**MINOR-4 — `ResetPasswordPage.tsx`: detecao de erro HTTP por string matching**

Arquivo: `pages/ResetPasswordPage.tsx`, linha 53

```typescript
if (err instanceof Error && err.message.includes('400')) {
```

O `authService.authFetch` lanca `new Error(\`HTTP ${res.status}: ...\`)`. Checar `'400'` dentro da string e fragil: um erro generico contendo "400" em outra parte da mensagem (ex: texto de resposta do servidor) poderia ser classificado incorretamente. O ideal e o `authFetch` lancar uma subclasse tipada de `Error` com o `status` como propriedade.

Correcao sugerida no `authFetch`:

```typescript
export class HttpError extends Error {
  constructor(public readonly status: number, message: string) {
    super(message);
    this.name = 'HttpError';
  }
}

// No catch do ResetPasswordPage:
if (err instanceof HttpError && err.status === 400) { ... }
```

---

**MINOR-5 — `PasswordUseCasesTest`: teste com logica de setup duplicada e redundante**

Arquivo: `test/kotlin/br/com/nomar/controlai/domain/auth/PasswordUseCasesTest.kt`, linhas 209–224

O teste `` `ChangePasswordUseCase should fail when new password is shorter than 8 chars` `` cria uma instancia de `ChangePasswordUseCase` com `changeUseCase(userWithPassword())` que e descartada imediatamente (variavel `result` do `.also` e ignorada) e entao cria outra instancia identica no `.let`. A intencao e clara (verificar que `updateCalled` permanece false), mas o codigo e confuso e contem uma variavel `updateCalled` declarada com `var` e nunca lida via `changeUseCase`. Simplificar usando a factory `changeUseCase` diretamente.

---

## Destaques Positivos

- **Seguranca exemplar no forgot-password**: o `ForgotPasswordUseCase` garante 204 sempre, nao vaza existencia do e-mail, e a falha de envio de e-mail e absorvida com log sem quebrar o fluxo. Isso implementa corretamente o RF-2.3 e e um padrao de segurança dificil de acertar.

- **Token design correto**: raw UUID enviado por e-mail, SHA-256 hex armazenado no banco, lookup por hash. Isso previne exposicao de token mesmo em caso de vazamento do banco de dados.

- **Single-use enforcement no dominio**: a entidade `PasswordResetToken` encapsula as regras `isExpired()`, `isUsed()` e `isValid()` com metodos expressivos, mantendo a logica no lugar certo.

- **Revogacao de sessoes apos reset**: `ResetPasswordUseCase` invoca `revokeAllRefreshTokensByUserIdGateway` apos alterar a senha, garantindo que sessoes anteriores sejam invalidadas — padrao de segurança que muitas implementacoes esquecem.

- **`fun interface` nos gateways**: uso consistente de functional interfaces torna os mocks de teste extremamente concisos e expressivos.

- **Testes de integracao de alta qualidade**: `ForgotResetPasswordIntegrationTest` cobre 15 cenarios com MockMvc, incluindo: DB assertions (token gravado, password_hash alterado), single-use enforcement no nivel HTTP, e o helper `triggerForgotAndGetToken()` com a solucao elegante para o problema do `ArgumentCaptor` do Kotlin com parametros nao-nulos.

- **Frontend com UX de segurança**: a tela `ForgotPasswordPage` exibe mensagem generica apos submit ("Se este e-mail estiver cadastrado..."), nao revelando ao usuario se o e-mail existe — alinhado com o backend.

- **Validacao dupla**: frontend valida comprimento minimo e confirmacao de senha antes de fazer a chamada, e o backend valida novamente via `@Size` e `require`. Defesa em profundidade correta.

- **`authService.ts` clean**: os metodos `forgotPassword`, `resetPassword` e `changePassword` sao adicionados de forma consistente com o restante do servico, sem duplicacao.

---

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Codigo em ingles (variaveis, funcoes, classes) | OK |
| Nomenclatura (camelCase/PascalCase/kebab-case) | OK |
| Sem abreviacoes ou nomes acima de 30 chars | OK |
| Sem magic numbers (constantes nomeadas) | OK |
| Funcoes com verbo, acao unica | OK |
| Maximo 3 parametros por funcao | OK |
| Funcoes: mutation OU query, nao ambos | OK |
| Maximo 2 niveis de aninhamento | OK |
| Sem flags booleanas em parametros | OK |
| Maximo 50 linhas por metodo | OK |
| Maximo 300 linhas por classe | OK |
| Sem linhas em branco dentro de metodos | OK |
| Comentarios (violacoes pontuais) | Problemas (MINOR-1, MINOR-2) |
| Clean Architecture (domain/gateway/provider) | OK |
| Kotlin/Spring Boot | OK — exceto MAJOR-2 |
| Ionic React | OK |
| Testes (unit + integracao + frontend) | OK |
| TypeScript (sem erros de compilacao) | OK |

---

## Recomendacoes

1. **(MAJOR-1 — Alta prioridade)** Substituir o padrao `findById + save` no `MarkPasswordResetTokenUsedProvider` por um UPDATE atomico com `@Modifying @Query` para eliminar a race condition no single-use enforcement.

2. **(MAJOR-2 — Alta prioridade)** Injetar `RestClient.Builder` no `ResendEmailClient` em vez de chamar `RestClient.create()` diretamente, adotando o padrao Spring Boot de configuracao centralizada de HTTP clients.

3. **(MAJOR-3 — Media prioridade)** Adicionar `ON DELETE CASCADE` na FK de `password_reset_tokens.user_id` e um indice em `user_id` para suportar queries de cleanup futuras sem degradacao de performance.

4. **(MINOR-4 — Baixa prioridade)** Criar uma classe `HttpError` com propriedade `status: number` no `authService` para substituir a deteccao de erro por string matching no `ResetPasswordPage`.

5. **(MINOR-2 — Baixa prioridade)** Padronizar mensagens de `require()` e `orElseThrow` nos usecases para ingles, deixando a localizacao para a camada de apresentacao.

6. **(MINOR-5 — Limpeza)** Simplificar o teste `` `ChangePasswordUseCase should fail when new password is shorter than 8 chars` `` removendo a instancia descartada e o `var updateCalled` nao utilizado.

---

## Veredito

A implementacao e solida, segura e bem testada. Os tres requisitos criticos de segurança (token single-use, nao-revelacao de e-mail, revogacao de sessoes) foram implementados corretamente. A race condition no `MarkPasswordResetTokenUsedProvider` (MAJOR-1) e o unico ponto que precisa ser corrigido antes de ir para producao em ambiente com multiplas instancias. Os demais pontos major (MAJOR-2 e MAJOR-3) sao melhorias de robustez recomendadas.

**Status: APROVADO COM OBSERVACOES** — corrigir MAJOR-1 antes do deploy em producao com multiplas replicas.

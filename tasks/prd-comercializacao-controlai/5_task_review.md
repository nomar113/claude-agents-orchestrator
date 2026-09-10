# Review: Task 5.0 - Onboarding automático de conta pós-compra

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVAÇÕES (crítico e majors do follow-up abaixo corrigidos e revalidados)

## Resumo

A implementação cobre corretamente o caminho feliz exigido pela Tarefa 5.0: para um `compra_aprovada` de e-mail novo, `HandleKiwifyWebhookUseCase.onboardNewCustomer` cria o usuário+grupo pessoal via `CreateUserWithPersonalGroupGateway`, ativa a assinatura, gera um token via `CreatePasswordResetTokenGateway` (TTL de 72h, constante nomeada `WELCOME_TOKEN_TTL_HOURS`) e envia o e-mail via `EmailGateway.sendWelcomeSetPassword`, reaproveitando exatamente os componentes que a Tech Spec pede (nada de fluxo de criação de conta ou de e-mail duplicado). Para e-mail já existente, o fluxo cai corretamente no caminho normal de atualização de assinatura, sem reenviar o e-mail de "defina sua senha" nem recriar token. Confirmei via agente de exploração que `passwordHash` fica `null` para o usuário recém-criado e que `LoginUseCase` bloqueia login por senha nesse caso — não há brecha de segurança aí.

Reexecutei a suíte completa de billing/auth/groups (`./gradlew test` com MySQL de teste via `docker-compose`, que já estava de pé): 117 testes, 0 falhas, 0 erros — confirmando o relato da implementação.

Encontrei, porém, um problema crítico de concorrência que o próprio Tech Spec já havia sinalizado como risco ("Colisão de e-mail... precisa de teste dedicado", seção `Riscos Conhecidos`): `onboardNewCustomer` não trata a exceção que `CreateUserWithPersonalGroupGateway` lança quando dois webhooks concorrentes tentam criar conta para o mesmo e-mail novo simultaneamente. O teste adicionado para esse cenário (`repeated compra_aprovada for the same new email never violates uk_users_email`) só exercita chamadas **sequenciais** (a primeira request termina completamente antes da segunda começar), então não cobre de fato a race condition — dá falsa confiança justamente no ponto que a Tech Spec pediu para testar com cuidado.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/billing/usecase/HandleKiwifyWebhookUseCase.kt` | Crítico | 1 crítico, 1 major, 1 minor |
| `domain/auth/gateway/EmailGateway.kt` | OK | 0 |
| `application/auth/application/ResendEmailClient.kt` | OK | 1 minor (cosmético) |
| `application/billing/entrypoint/rest/KiwifyWebhookController.kt` | OK | 0 (sem mudanças de escopo desta tarefa além de repassar `customerName`) |
| `test/.../domain/billing/HandleKiwifyWebhookUseCaseTest.kt` | Problemas | 1 minor (gap de cobertura da race condition) |
| `test/.../application/billing/KiwifyWebhookControllerIntegrationTest.kt` | Problemas | 1 minor (mesmo gap, no nível de integração) |
| `test/.../domain/auth/PasswordUseCasesTest.kt` | OK | 0 |
| `test/.../domain/groups/GroupInviteUseCasesTest.kt` | OK | 0 |
| `config/SecurityConfig.kt`, `application.properties`, `test/application.properties` | OK | 0 (herdados da Tarefa 4.0, sem mudança nesta tarefa) |

## Problemas Encontrados

### Problemas Críticos

**1. Race condition entre webhooks concorrentes para o mesmo e-mail novo não é tratada — pode perder silenciosamente a ativação de uma assinatura**

Arquivo: `src/main/kotlin/br/com/nomar/controlai/domain/billing/usecase/HandleKiwifyWebhookUseCase.kt:149-157`

```kotlin
private fun onboardNewCustomer(email: String, customerName: String?, productId: String?) {
    val name = customerName?.trim()?.takeIf { it.isNotBlank() } ?: email.substringBefore("@")
    val user = createUserWithPersonalGroupGateway.execute(User(name = name, email = email)).getOrThrow()
    ...
}
```

Confirmei (via leitura de `CreateUserWithPersonalGroupProvider.kt`) que essa gateway captura `DataIntegrityViolationException` da constraint `uk_users_email` e relança como `EmailAlreadyUsedException` — exatamente o padrão que `RegisterUserUseCase` usa e trata. **`onboardNewCustomer` não captura essa exceção.** Ela simplesmente propaga através do `getOrThrow()`, sobe até o `runCatching` externo de `execute()` (linha 54) e vira `Result.failure`.

O problema é a ordem das operações em `execute()`: o evento já foi persistido como processado em `saveKiwifyWebhookEventGateway.execute(...)` (linhas 61-68), **antes** de `onboardNewCustomer` ser chamado. Ou seja, se dois eventos `compra_aprovada` para o mesmo e-mail novo chegam em paralelo (dois pedidos quase simultâneos — por exemplo o pedido principal e o order bump vitalício citados no PRD, ou uma simples redundância de entrega do provedor de webhook), o cenário é:

1. Ambas as threads passam pelo `findUserByEmailGateway.execute(email)` e recebem `null` (o usuário ainda não existe para nenhuma das duas).
2. Ambas chamam `onboardNewCustomer`. Uma delas cria o usuário com sucesso.
3. A outra recebe `EmailAlreadyUsedException` do `CreateUserWithPersonalGroupGateway`, que não é capturada — a chamada falha, é registrada como erro na métrica (`recordMetric(event.orderStatus, "error")`) e logada, mas **o evento dessa segunda compra já está marcado como processado** (passo anterior à falha). A Kiwify não vai reenviar (recebeu `200`), e o código não tem nenhum caminho de fallback para "já existe, buscar de novo e aplicar a assinatura".

Resultado prático: a segunda compra (ex.: o upgrade vitalício do order bump) nunca ativa a assinatura correta, e não há qualquer mecanismo de reprocessamento automático — o cliente pagou e não recebeu o que comprou, silenciosamente. Isso é exatamente o risco que a própria Tech Spec identificou (`Riscos Conhecidos`: "Colisão de e-mail entre autocriação via webhook e uma conta já existente ... precisa de teste dedicado") e que o critério de sucesso da task pede para nunca acontecer ("sem criar conta duplicada nem violar a constraint de e-mail único" — a constraint em si não é violada graças ao `CreateUserWithPersonalGroupProvider`, mas o efeito de negócio equivalente, perda da compra, acontece).

**Correção sugerida**: capturar `EmailAlreadyUsedException` ao redor da chamada de criação em `onboardNewCustomer` e, nesse caso, cair no mesmo caminho do usuário já existente (buscar por e-mail de novo — agora deve retornar o usuário criado pela thread concorrente — buscar o grupo e aplicar `applyOrderStatus`), em vez de deixar a exceção propagar:

```kotlin
private fun onboardNewCustomer(email: String, customerName: String?, productId: String?) {
    val name = customerName?.trim()?.takeIf { it.isNotBlank() } ?: email.substringBefore("@")
    val createdUser = createUserWithPersonalGroupGateway.execute(User(name = name, email = email))
        .getOrElse { error ->
            if (error !is EmailAlreadyUsedException) throw error
            return applyExistingCustomerPurchase(email, productId)
        }
    val groupId = findUserGroupGateway.execute(createdUser.id!!).getOrThrow()?.id
        ?: error("Personal group not found right after creation for user ${createdUser.id}")
    activateSubscription(groupId, email, productId)
    sendWelcomeSetPasswordEmail(createdUser)
}

private fun applyExistingCustomerPurchase(email: String, productId: String?) {
    val user = findUserByEmailGateway.execute(email).getOrThrow() ?: error("User not found after EmailAlreadyUsedException for $email")
    val groupId = findUserGroupGateway.execute(user.id!!).getOrThrow()?.id ?: return
    activateSubscription(groupId, email, productId)
}
```

E o teste correspondente precisa simular de fato a concorrência (ver Minor 1 em Testes abaixo), não apenas duas chamadas sequenciais.

### Problemas Major

**1. Falha parcial no meio do onboarding pode deixar o cliente permanentemente sem senha, sem retry automático**

Arquivo: `HandleKiwifyWebhookUseCase.kt:149-171`

`onboardNewCustomer` faz três operações que não compartilham uma transação (não há `@Transactional`/`TransactionTemplate` envolvendo o método inteiro — só `CreateUserWithPersonalGroupGateway` é atômico internamente): criar usuário+grupo, ativar assinatura (`activateSubscription`) e criar o token de senha + enviar e-mail (`sendWelcomeSetPasswordEmail`). Se `activateSubscription` ou `createPasswordResetTokenGateway.execute(token).getOrThrow()` falhar **depois** que o usuário já foi criado com sucesso (ex.: falha transitória de banco), o evento é marcado como processado, a conta existe com `password_hash = null`, mas nem token nem e-mail de definição de senha nunca são gerados.

Isso é agravado por um detalhe do fluxo: o caminho "usuário já existe" (linhas 96-101) **nunca** chama `sendWelcomeSetPasswordEmail` nem cria um novo token — essa lógica só existe em `onboardNewCustomer`. Então, se esse cliente comprar de novo ou a Kiwify reenviar um evento com `order_status` diferente, o sistema vai apenas atualizar a assinatura (corretamente) mas o usuário segue sem nenhuma forma de definir senha e acessar a conta, exigindo intervenção manual de suporte. Não é bloqueante para o caminho feliz, mas é uma lacuna de confiabilidade real para um fluxo que envolve dinheiro e acesso do cliente. Sugestão: ao menos documentar essa limitação conhecida (como foi feito no review da Tarefa 4.0 para outras lacunas) ou adicionar uma forma de detectar "usuário sem `password_hash` e sem token válido" e reenviar o e-mail de definição de senha nesse caso.

### Problemas Minor

**1. Testes de "compra repetida" cobrem apenas o caso sequencial, não a race condition real**

Arquivos: `HandleKiwifyWebhookUseCaseTest.kt:186-199` (unidade) e `KiwifyWebhookControllerIntegrationTest.kt:376-406` (integração, `repeated compra_aprovada for the same new email never violates uk_users_email`).

Ambos os testes fazem a primeira chamada terminar completamente (usuário já criado, commitado) antes de disparar a segunda. Isso valida um caso real (nova tentativa depois que a primeira já foi processada), mas não o caso que a Tech Spec pede explicitamente para testar: duas requisições **concorrentes**, ambas passando pelo `findUserByEmailGateway` antes de qualquer uma delas terminar de criar o usuário. Sugestão:
- No teste de unidade, simular a race fazendo o fake de `createUserWithPersonalGroupGateway` retornar `Result.failure(EmailAlreadyUsedException())` na segunda chamada (mesmo com `usersByEmail` ainda vazio no momento da chamada), e verificar que o use case se recupera corretamente (após a correção do problema crítico acima).
- No teste de integração, considerar dois threads/`CompletableFuture` disparando o `mockMvc.perform` ao mesmo tempo para o mesmo e-mail novo, ou, no mínimo, renomear o teste atual para deixar explícito que cobre apenas retries sequenciais, e abrir um teste dedicado (ou nota em `5_task.md`) para o caso concorrente como item pendente.

**2. Linha em branco dentro de método (`HandleKiwifyWebhookUseCase.kt:165`)**

```kotlin
createPasswordResetTokenGateway.execute(token).getOrThrow()

val setPasswordLink = "$appWebUrl/reset-password?token=$rawToken"
```

Padrão do projeto (checklist de code-review) pede "sem linhas em branco dentro de métodos". Cosmético, não bloqueante.

**3. Saudação do e-mail pode ficar estranha quando o nome cai no fallback do prefixo do e-mail**

Arquivo: `ResendEmailClient.kt` (`buildWelcomeSetPasswordHtml`, `name.split(" ").first()`). Quando `customerName` vem nulo/vazio da Kiwify, `onboardNewCustomer` usa `email.substringBefore("@")` como nome (ex.: `"sem-nome"`), e o e-mail cumprimenta com `"Olá, sem-nome!"`. Não é um bug, mas é um detalhe de UX que vale mencionar — talvez usar uma saudação genérica ("Olá!") quando o nome vier do fallback em vez do nome real.

**4. Divergência entre Tech Spec (H2) e execução real (MySQL) dos testes de integração**

A Tech Spec descreve "`POST /webhooks/kiwify` fim a fim com H2" na seção de Testes de Integração, mas a suíte real (herdada das Tarefas 2.0-4.0) roda contra o MySQL de teste via `docker-compose`. Isso não é uma regressão desta tarefa — é uma convenção já estabelecida antes dela — mas vale atualizar a Tech Spec para refletir a realidade, para não confundir quem ler o documento depois.

## Destaques Positivos

- Reaproveitamento correto e limpo de `CreateUserWithPersonalGroupGateway`, `CreatePasswordResetTokenGateway`, `TokenHasher.sha256` e `EmailGateway` — nenhuma lógica de criação de conta ou de hashing de token foi duplicada, exatamente como pedido nas "Decisões Principais" da Tech Spec.
- TTL de 72h corretamente isolado numa constante nomeada (`WELCOME_TOKEN_TTL_HOURS`) e propositalmente diferente do TTL de 1h do `ForgotPasswordUseCase` — decisão correta, já que são fluxos com propósitos distintos (onboarding vs. reset de senha ativo).
- Falha ao enviar e-mail é isolada corretamente com `.onFailure { log.error(...) }` sem relançar — uma instabilidade no Resend nunca derruba o processamento do webhook, atendendo exatamente ao requisito citado no briefing desta review.
- `passwordHash` fica `null` para o usuário recém-criado e o `LoginUseCase` bloqueia explicitamente login por senha nesse caso (confirmado lendo o código) — não há brecha de autenticação para contas onboardadas sem senha.
- Fallback de nome ausente (`customerName` nulo/vazio → prefixo do e-mail) é uma proteção defensiva a mais do que o mínimo pedido pela task, evitando um `name` vazio na conta criada.
- Continuidade boa com o review da Tarefa 4.0: o `major` anterior sobre parâmetros posicionais em excesso já está resolvido (`ParsedKiwifyWebhookEvent` como parâmetro único).
- Boa cobertura para os caminhos felizes: teste de unidade e de integração cobrindo e-mail novo, e-mail existente, nome ausente, e o teste de integração validando corretamente `password_hash IS NULL`, criação do grupo pessoal e uma única chamada a `sendWelcomeSetPassword` — mais robusto que testar só a camada de unidade.
- `EmailGateway` mockado via `@MockitoBean` no teste de integração evita qualquer chamada real ao Resend durante a suíte.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código | Problemas (linha em branco em método, ver Minor 2) |
| Kotlin/Spring Boot | Problemas (ausência de tratamento de `EmailAlreadyUsedException`, ver Crítico 1) |
| Reaproveitamento (Tech Spec: Decisões Principais) | OK |
| Segurança (senha nula bloqueando login) | OK |
| Tratamento de erro (e-mail não deve derrubar webhook) | OK |
| Testes | Problemas (gap de cobertura da race condition, ver Minor 1) |

## Recomendações

1. (Crítico) Capturar `EmailAlreadyUsedException` em `onboardNewCustomer` e cair no fluxo de "usuário já existente" em vez de deixar a exceção propagar e marcar o evento como processado sem aplicar o efeito de negócio.
2. (Major) Documentar (ou tratar) o cenário de falha parcial entre criação do usuário e envio do e-mail de definição de senha — hoje não há caminho de recuperação automática se o token/e-mail falhar após a conta já ter sido criada.
3. (Minor) Adicionar um teste que simule de fato a concorrência entre dois webhooks para o mesmo e-mail novo (não apenas chamadas sequenciais), validando a correção do item 1.
4. (Minor) Remover a linha em branco dentro de `sendWelcomeSetPasswordEmail`.
5. (Minor) Ajustar a saudação do e-mail para não usar o prefixo do e-mail como "nome" quando `customerName` vier ausente.
6. (Minor) Atualizar a Tech Spec para refletir que os testes de integração rodam contra MySQL, não H2.

## Veredito (avaliação original)

O caminho feliz da Tarefa 5.0 está bem implementado e reaproveita corretamente a infraestrutura de `auth` existente, sem duplicar fluxo de criação de conta ou de e-mail, e sem abrir brecha de login por senha nula. Testes automatizados passam integralmente (117/117 na suíte focada, reexecutada nesta revisão).

Porém, o problema crítico de concorrência (item 1) é exatamente o risco que a própria Tech Spec pediu para testar com atenção antes de considerar essa colisão de e-mail resolvida, e o teste adicionado para o cenário de "compra repetida" não cobre esse caso — apenas o caso sequencial, que já era o mais simples de acertar. Como o bounded context `billing` lida diretamente com dinheiro e liberação de acesso pago, uma falha silenciosa nesse ponto (cliente paga o order bump vitalício e não recebe o upgrade, sem qualquer log de erro visível além de uma métrica) não deve seguir para produção sem correção.

Recomendo **mudanças solicitadas**: aplicar a correção do item crítico (captura de `EmailAlreadyUsedException` com fallback para o fluxo de usuário existente) e, idealmente, um teste que exercite a concorrência real antes de aprovar. Os itens major/minor restantes podem entrar no backlog do bounded context `billing`, mas o crítico deve ser resolvido antes de prosseguir para a integração real com o painel da Kiwify (subtarefa de teste manual, ainda pendente segundo o histórico da Tarefa 4.0).

## Follow-up (pós-review) — releitura do código atual

Reli o `HandleKiwifyWebhookUseCase.kt` atual, os dois arquivos de teste e a Tech Spec após as correções relatadas, e revalidei tudo rodando a suíte eu mesmo (não apenas confiando no relato). Avaliação item a item:

**Crítico 1 (resolvido)**: `onboardNewCustomer` agora usa `createUserWithPersonalGroupGateway.execute(...).getOrElse { ... }` e, quando o erro é `EmailAlreadyUsedException`, cai em `applyToRaceWinnerAccount(email, productId)` (linhas 157-174), que busca o usuário pela outra requisição vencedora da corrida via `findUserByEmailGateway` e aplica a compra normalmente (`applyOrderStatus`) em vez de deixar a exceção propagar e o evento ficar marcado como processado sem efeito. A implementação está correta: o `return` dentro do lambda de `getOrElse` é um non-local return válido (função inline do Kotlin), confirmado pelo build verde. Validei a correção de duas formas independentes:
- Reexecutei `./gradlew test` com os módulos `billing`/`auth`/`groups`: **120 testes, 0 falhas, 0 erros** (subiu de 117 para 120 com os 3 novos testes).
- Reexecutei especificamente `KiwifyWebhookControllerIntegrationTest` (que contém o novo teste `two concurrent compra_aprovada webhooks for the same brand-new email never violate uk_users_email`, usando `CyclicBarrier` + `ExecutorService` disparando duas requisições HTTP de fato simultâneas contra o MySQL de teste real) **três vezes seguidas**: 14/14 testes verdes nas três execuções, sem flakiness. O teste corretamente evita afirmar qual das duas compras "vence" a corrida (não determinístico por natureza), focando no que realmente importa: exatamente 1 usuário, 1 vínculo de grupo e 1 linha de assinatura — ou seja, `uk_users_email` nunca é violada e nenhum dos dois pedidos é perdido silenciosamente.

**Major 1 (resolvido, com uma nuance que vale documentar)**: `applyOrderStatus` agora reenvia o e-mail de "defina sua senha" sempre que um `compra_aprovada` é aplicado a um usuário com `passwordHash == null` (linhas 111-116), cobrindo tanto o fallback da race condition quanto uma falha parcial anterior (token/e-mail que falhou depois da conta já criada) — sem exigir transação distribuída, a próxima compra ou reprocessamento do mesmo e-mail reenvia o e-mail até o cliente definir a senha. Isso é uma boa solução de engenharia para o problema real que eu levantei (conta órfã sem forma de definir senha). Vale registrar uma nuance: a subtarefa 5.4 pede literalmente "pular... o envio do e-mail de 'defina sua senha'" para usuários já existentes — a implementação atual reinterpreta isso como "usuários já existentes **que já têm senha definida**" (o caso real de grandfathered/compra repetida), e passa a reenviar o e-mail para o caso mais específico de "existe mas nunca definiu senha" (race loser ou falha parcial). Concordo que essa é a interpretação correta da intenção da task — a alternativa (nunca reenviar) é exatamente o bug que motivou o Major 1 — mas registro aqui para que fique explícito que o comportamento observável mudou em relação ao texto literal da subtarefa. Confirmado com o novo teste unitário (`compra_aprovada for an existing user who never set a password resends the set-password email`) e com o teste de integração sequencial (`sequential repeated compra_aprovada...`, agora corretamente renomeado e com `verify(..., times(2))` documentando a decisão).

**Minor 1 — cobertura de teste da race condition (resolvido)**: os dois testes novos (unidade e integração) cobrem exatamente o que faltava. O de unidade simula a corrida via um fake que retorna `Result.failure(EmailAlreadyUsedException())` na criação e já "cria" o usuário concorrente no mapa antes de retornar a falha, validando que a assinatura correta (`LIFETIME`, no teste) é aplicada e o e-mail é enviado ao usuário vencedor. O de integração usa concorrência real (threads de verdade + `CyclicBarrier`), que é bem mais forte que um mock de exceção — valida o comportamento sob o MySQL real, incluindo a constraint `uk_users_email` de fato sendo exercitada sob concorrência.

**Minor 2 — linha em branco (resolvido)**: confirmado removida em `sendWelcomeSetPasswordEmail` (linhas 177-188 do arquivo atual).

**Minor 3 — saudação com fallback estranho (resolvido)**: `DEFAULT_CUSTOMER_NAME = "Cliente ControlAI"` substitui `email.substringBefore("@")`; a saudação do e-mail passa a ser "Olá, Cliente!" em vez de algo como "Olá, sem-nome!". Testado em `compra_aprovada for new email without a name falls back to a generic customer name`.

**Minor 4 — divergência Tech Spec/realidade (resolvido)**: confirmei em `techspec.md:83` que o texto agora diz "fim a fim contra o MySQL de teste (via `docker-compose`)", refletindo a suíte real.

## Veredito Final

Todos os pontos críticos e major do review original foram corrigidos e revalidados de forma independente (não apenas reexecutando o relato da implementação, mas rodando a suíte eu mesmo, inclusive repetindo o teste de concorrência três vezes para checar estabilidade). A correção do item crítico é sólida: usa o mesmo mecanismo de segurança (`EmailAlreadyUsedException` sobre a constraint `uk_users_email`) que `RegisterUserUseCase` já usa, e o teste de integração com concorrência real é uma validação genuinamente mais forte do que o exigido — dá confiança de que o cenário citado nos "Riscos Conhecidos" da Tech Spec está, de fato, coberto.

A única observação que registro (não bloqueante) é a nuance do Major 1: o comportamento de reenvio do e-mail de definição de senha para usuários sem senha passou a divergir ligeiramente do texto literal da subtarefa 5.4, mas na direção correta e com testes que documentam a decisão explicitamente — recomendo apenas atualizar a redação de `5_task.md`/subtarefa 5.4 numa próxima revisão de documentação para refletir "usuários já existentes **com senha definida**", evitando confusão para quem ler a task no futuro sem o contexto deste review.

**Aprovado com observações.** Pode prosseguir para a subtarefa de teste manual com o webhook real da Kiwify (ainda pendente) e para as próximas tarefas do bounded context `billing`.

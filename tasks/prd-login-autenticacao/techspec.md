# Tech Spec — Login e Autenticação (ControlAI)

## Resumo Executivo

A autenticação será implementada com **Spring Security** no backend (`controlai`), usando **JWT de acesso de curta duração (15 min, HS256 auto-assinado)** validado como resource server, e **refresh token opaco persistido no MySQL com rotação** (expiração absoluta de 90 dias). O login social usa **Google ID Token** verificado no backend. O isolamento de dados segue o modelo **grupo como dono**: toda tabela raiz de dados ganha `group_id`; cada usuário nasce em um grupo pessoal e o compartilhamento (casal) é a entrada do convidado no grupo do convidante.

No frontend (`controlai-frontend`), um `AuthContext` + interceptação no `httpClient` anexam o `Authorization: Bearer` e fazem refresh silencioso single-flight. No iOS, o refresh token fica no Keychain protegido por biometria (`@capgo/capacitor-native-biometric`) — o desbloqueio por Face ID é a própria recuperação da credencial. Google Sign-In via `@capgo/capacitor-social-login` (v8, compatível com Capacitor 8). E-mails transacionais (reset de senha e convites) via **Resend**. A automação do iPhone que chama `POST /payments/notification` passa a autenticar com **API key por conta** (header `X-Api-Key`).

## Arquitetura do Sistema

### Visão Geral dos Componentes

**Backend (novos):**

- `domain/auth` — entidades `User`, `RefreshToken`, `PasswordResetToken`, `ApiKey`; usecases `RegisterUserUseCase`, `LoginUseCase`, `GoogleLoginUseCase`, `RefreshSessionUseCase`, `LogoutUseCase`, `ForgotPasswordUseCase`, `ResetPasswordUseCase`, `ChangePasswordUseCase`; gateways correspondentes (padrão clean architecture existente).
- `domain/groups` — entidades `Group`, `GroupMember`, `GroupInvite`; usecases `InviteToGroupUseCase`, `AcceptInviteUseCase`, `DeclineInviteUseCase`, `LeaveGroupUseCase`, `ListPendingInvitesUseCase`.
- `application/auth/entrypoint/rest` — `AuthController`, `ProfileController`; `application/groups/entrypoint/rest` — `GroupInviteController`.
- `config/SecurityConfig` — filter chain do Spring Security: rotas `/auth/**` e `/actuator/health` públicas; `POST /payments/notification` autenticado por `ApiKeyAuthFilter`; todo o resto exige JWT.
- `config/JwtConfig` — `JwtEncoder`/`JwtDecoder` (Nimbus, HS256 com secret de 256 bits via env `JWT_SECRET`).
- `RequestContext` (request-scoped) — expõe `userId` e `groupId` extraídos do JWT para usecases e gateways.
- `EmailGateway` + `ResendEmailClient` — envio via API HTTP do Resend (`RestClient`).

**Backend (modificados):**

- Todos os gateways/repositories de dados (categories, payment_methods, holders, budgets, purchase_invoices, payment_notifications, installments) passam a filtrar por `group_id`.
- `PaymentNotificationQueueMessage` e listeners SQS carregam `groupId` (resolvido na entrada pela API key).
- `CorsConfig` mantido; OpenAPI ganha security scheme bearer.

**Frontend (novos):** `AuthContext`, `authService`, `tokenStorage` (Keychain nativo / localStorage web), `biometricService`, páginas `LoginPage`, `RegisterPage`, `ForgotPasswordPage`, `ResetPasswordPage`, `ProfilePage` (convites, alterar senha, API key, logout), componente `PrivateRoute`.

**Frontend (modificados):** `httpClient.ts` (header Authorization, refresh single-flight em 401, redirect a `/login`), `App.tsx` (rotas públicas + guarda), tabs ganham acesso ao perfil.

**Fluxo principal:** app abre → refresh token no Keychain → prompt Face ID → `POST /auth/refresh` → access token em memória → chamadas normais. Sem token/refresh inválido → `/login`.

## Design de Implementação

### Interfaces Principais

```kotlin
// domain/auth/usecase — follows existing UseCase/Result pattern
class LoginUseCase(gateway: FindUserByEmailGateway, tokens: IssueTokensGateway) {
    fun execute(email: String, password: String): Result<AuthSession>
}

class GoogleLoginUseCase(verifier: GoogleTokenVerifierGateway, /* ... */) {
    fun execute(idToken: String): Result<AuthSession> // find-or-create by verified email
}

data class AuthSession(
    val accessToken: String,   // JWT, 15 min, claims: sub=userId, groupId, email
    val refreshToken: String,  // opaque, stored hashed (SHA-256) in MySQL
    val user: User,
)

// request-scoped, populated by JwtAuthConverter / ApiKeyAuthFilter
interface RequestContext { val userId: Long; val groupId: Long }
```

```typescript
// frontend services/authService.ts
interface AuthService {
  login(email: string, password: string): Promise<User>;
  loginWithGoogle(): Promise<User>;            // SocialLogin plugin -> POST /auth/google
  refresh(): Promise<boolean>;                  // single-flight
  logout(): Promise<void>;
  unlockWithBiometrics(): Promise<boolean>;     // Keychain + Face ID gate
}
```

### Modelos de Dados

Novas tabelas (Flyway `V27+`):

- `users` — id, name, email (unique), password_hash (nullable — conta só-Google), google_sub (nullable, unique), created_at, updated_at.
- `groups` — id, name, created_at.
- `group_members` — id, group_id FK, user_id FK (unique — usuário pertence a exatamente 1 grupo ativo), joined_at.
- `group_invites` — id, group_id FK, inviter_user_id FK, invitee_email, status (PENDING/ACCEPTED/DECLINED/CANCELLED), token (unique), expires_at, created_at.
- `refresh_tokens` — id, user_id FK, token_hash (unique), expires_at, absolute_expires_at, revoked_at, replaced_by_id, created_at.
- `password_reset_tokens` — id, user_id FK, token_hash, expires_at (1 h), used_at, created_at.
- `api_keys` — id, group_id FK, key_hash (unique), label, created_at, revoked_at.

Tenancy (migração em 3 passos na mesma release):

1. `ALTER TABLE ... ADD COLUMN group_id BIGINT NULL` nas tabelas raiz: `holders`, `payment_methods`, `categories`, `budgets`, `payment_notifications`, `purchase_invoices`, `installments`. Tabelas filhas (`sub_cards`, `purchase_items`, `purchase_payments`, `budget_items`, `budget_incomes`, `budget_payment_periods`) herdam via FK do pai — sem coluna própria.
2. Migração de dados: cria `groups` ("Família"), `users` (Ramon, email `ramonmesquita113@gmail.com`, sem senha — define via "esqueci minha senha" ou entra com Google) e faz `UPDATE ... SET group_id = 1`.
3. `ALTER ... MODIFY group_id BIGINT NOT NULL` + FK + índices compostos (ex.: `idx_purchase_invoices_group_created (group_id, created_at)`). Uniques globais viram compostos: `uk_categories_name` → `(group_id, name)`; `uk_budgets_reference_month` → `(group_id, reference_month)`.

Novos grupos recebem seed das 15 categorias padrão na criação (cópia por grupo).

### Endpoints de API

Públicos:

- `POST /auth/register` — nome, email, senha (≥8). 409 se email em uso.
- `POST /auth/login` — email/senha → `AuthSession`. 401 genérico ("Credenciais inválidas") sem revelar existência do email.
- `POST /auth/google` — `{ idToken }` → verifica assinatura/audience/iss → find-or-create por email → `AuthSession`.
- `POST /auth/refresh` — `{ refreshToken }` → rotaciona (invalida o antigo, emite par novo). Reuso de token rotacionado → revoga a família inteira (detecção de roubo).
- `POST /auth/password/forgot` — sempre 204 (não revela email); envia link via Resend.
- `POST /auth/password/reset` — `{ token, newPassword }`.

Autenticados (Bearer):

- `POST /auth/logout` — revoga refresh token do dispositivo.
- `GET /me` — dados do usuário + grupo.
- `PUT /me/password` — senha atual + nova.
- `POST /me/api-key` / `GET /me/api-key` / `DELETE /me/api-key` — gestão da chave da automação (valor exibido apenas na criação).
- `POST /invites` — `{ email }`; `GET /invites/pending`; `POST /invites/{id}/accept`; `POST /invites/{id}/decline`; `POST /groups/leave` — sai do grupo e recebe novo grupo pessoal vazio (dados permanecem no grupo original).
- Aceitar convite: o grupo pessoal do convidado é abandonado (bloqueio se já tiver dados — exige confirmação com flag `force=true`, dados do grupo pessoal são descartados conforme decisão de produto de compartilhamento total).

Especial: `POST /payments/notification` — autenticado por `X-Api-Key`; resolve `groupId` da chave e propaga na mensagem SQS.

Todos os demais endpoints existentes: exigem JWT e passam a filtrar por `RequestContext.groupId`.

## Pontos de Integração

- **Google Identity**: verificação de ID token com `com.google.api-client:google-api-client` (`GoogleIdTokenVerifier`), audiences = [web client ID, iOS client ID] (env `GOOGLE_CLIENT_IDS`). Requer criar OAuth Client IDs (Web + iOS) no Google Cloud Console e configurar `@capgo/capacitor-social-login` no app (URL scheme no `Info.plist`).
- **Resend**: `POST https://api.resend.com/emails` com `RESEND_API_KEY`; templates PT-BR inline (reset de senha, convite). Falha de envio: log de erro + retorno 204 mesmo assim (não bloquear fluxo); sem retry automático no MVP.
- **SQS**: mensagens ganham campo `groupId`; mensagens antigas em fila durante o deploy são tratadas com fallback para o grupo legado (id 1).
- **Erros**: 401 (sem/expirado token) e 403 (recurso de outro grupo → responder 404 para não vazar existência).

## Abordagem de Testes

### Testes Unidade

- UseCases de auth: login ok/senha errada/email inexistente (mesma mensagem), registro duplicado, política de senha, rotação e detecção de reuso de refresh token, find-or-create do Google (link por email — RF-1.5), fluxo de convite (aceitar/recusar/sair).
- Mocks apenas para gateways externos (Resend, GoogleTokenVerifier).
- Frontend (Vitest): `authService` (refresh single-flight, 401→redirect), `tokenStorage`, `PrivateRoute`, páginas de login/registro (validação inline, mensagens PT-BR).

### Testes de Integração

- `@SpringBootTest` + MockMvc: matriz de segurança — **todo endpoint de dados retorna 401 sem token** (teste parametrizado varrendo o mapping do MVC, garante a métrica "0 endpoints abertos" do PRD).
- Isolamento: dois usuários/grupos seedados; usuário A não lê/escreve dados do grupo B (404).
- Migração: Flyway roda sobre dump com dados legados; verifica backfill de `group_id` sem perda.
- `X-Api-Key` válida/revogada no endpoint de notificação.

### Testes de E2E

- Playwright (web): registro → login → dados vazios; login Ramon → dados legados visíveis; convite entre duas contas → mesmo dado visível nas duas; logout → redirect `/login`; deep-link em rota protegida sem sessão → `/login`.
- Biometria não é automatizável — validação manual no device (roteiro no QA).

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Backend — fundação auth**: dependências Spring Security/jose, tabelas `users`/`groups`/`refresh_tokens`, register/login/refresh/logout, `SecurityConfig` + `RequestContext`. (Base de tudo.)
2. **Backend — tenancy**: migrações `group_id` + backfill, filtro por grupo em todos os gateways, testes de isolamento. (Depende de 1; é o maior risco — fazer cedo.)
3. **Backend — API key** no endpoint de notificação + `groupId` no SQS. (Desbloqueia a automação do iPhone antes do lockdown.)
4. **Frontend — sessão**: `AuthContext`, `tokenStorage`, `httpClient` com Bearer/refresh, telas login/registro, `PrivateRoute`. (Depende de 1.)
5. **Google Sign-In** (backend `POST /auth/google` + plugin no app + config GCP).
6. **Biometria iOS** (Keychain + Face ID gate na abertura).
7. **E-mail**: forgot/reset/change password via Resend.
8. **Compartilhamento**: convites backend + UI de perfil.
9. **Migração/cutover**: deploy com backfill, Ramon define senha, convite à esposa, ativar lockdown completo.

### Dependências Técnicas

- Conta Resend + domínio verificado para envio (`RESEND_API_KEY`).
- Google Cloud Console: OAuth Client IDs Web e iOS.
- Envs novos em produção: `JWT_SECRET`, `GOOGLE_CLIENT_IDS`, `RESEND_API_KEY`, `APP_WEB_URL` (links de e-mail).
- Backup do MySQL de produção antes da migração de backfill.

## Monitoramento e Observabilidade

- Actuator já expõe `/actuator/health` (mantido público). Expor `metrics` internamente.
- Logs (nível INFO): login sucesso/falha (sem email em falhas — apenas hash truncado), refresh reuse detectado (WARN — possível roubo), envio de e-mail (sucesso/falha), convites. Nunca logar tokens/senhas.
- Contadores via Micrometer: `auth.login.success/failure`, `auth.refresh.reuse`, `auth.api_key.invalid`.

## Considerações Técnicas

### Decisões Principais

- **Grupo como dono** em vez de `user_id` + tabela de shares: compartilhamento é do conjunto completo (PRD), então filtrar por um único `group_id` mantém toda query simples e à prova de vazamento; sair do grupo preserva os dados no grupo original.
- **Filtro explícito de `group_id` nos gateways** em vez de Hibernate `@Filter` global: mais verboso, porém visível, testável por query e sem risco de filtro não habilitado em um entrypoint (SQS listeners não passam pelo interceptor web).
- **JWT HS256 auto-assinado + refresh opaco com rotação** em vez de sessão opaca única: zero lookup por request nos endpoints de dados, revogação garantida pelo refresh persistido, alinhado às práticas 2026 (access 15 min / refresh 90 dias absoluto).
- **Verificação do Google no backend (ID token)** em vez de fluxo OAuth server-side: o plugin nativo entrega o ID token diretamente; backend só valida assinatura + audience — sem redirect URIs no servidor.
- **`@capgo/capacitor-social-login` e `@capgo/capacitor-native-biometric`**: mantidos ativamente, versionamento pareado com Capacitor 8, cobrem web+iOS; evita os plugins abandonados (codetrix google-auth).
- **Resend** para e-mail: free tier permanente (3k/mês) e API mínima; volume do app é desprezível.

### Riscos Conhecidos

- **Backfill de tenancy** é a mudança mais invasiva (toca todos os gateways). Mitigação: fazer na etapa 2 com teste de isolamento parametrizado; backup antes do deploy; migrações Flyway idempotentes.
- **CapacitorHttp vs fetch**: o `httpClient` tem dois caminhos; o header Authorization e o tratamento de 401 precisam cobrir ambos (testar no device, não só no browser).
- **Face ID + Keychain**: comportamento de `getCredentials` após reinstalação do app ou mudança de biometria pode invalidar credenciais — fallback para login por senha (RF-3.4) cobre, mas exige teste manual.
- **Automação do iPhone**: trocar o Atalho para enviar `X-Api-Key` antes de ativar o lockdown do endpoint (sequenciamento etapa 3 → 9); janela sem chave derrubaria a captura de notificações.
- **App Store**: login social Google sem "Sign in with Apple" pode bloquear publicação futura na App Store (registrado como fora de escopo no PRD; risco aceito).

### Conformidade com Skills Padrões

- `kotlin-springboot` — seguir práticas de Spring Boot + Kotlin (constructor injection, `Result`-based usecases já usados no projeto).
- `ionic-design` — telas de login/registro/perfil com componentes Ionic e padrões iOS.
- `vercel-react-best-practices` — hooks/contexto de auth sem re-renders desnecessários.
- `clean-code` — nomes explícitos nos usecases/gateways, seguindo o padrão de domínio existente.
- Convenção dos repositórios controlai: **comentários de código em inglês**.

### Arquivos relevantes e dependentes

Backend (`/Volumes/SSD480GB/projects/controlai`):

- `build.gradle.kts` — novas dependências (security, oauth2-resource-server, google-api-client).
- `src/main/kotlin/.../config/` — `SecurityConfig.kt` (novo), `JwtConfig.kt` (novo), `CorsConfig.kt`, `OpenApiConfig.kt`.
- `src/main/resources/db/migration/` — `V27+` (auth, tenancy, backfill).
- `src/main/kotlin/.../domain/{auth,groups}/` (novos) e todos os gateways em `application/*/entrypoint/database/`.
- `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` e `queue/PaymentNotificationQueueListener.kt`.

Frontend (`/Volumes/SSD480GB/projects/controlai-frontend`):

- `src/services/httpClient.ts`, `src/config/api.ts`, `src/App.tsx`.
- `src/services/authService.ts`, `src/services/tokenStorage.ts`, `src/context/AuthContext.tsx` (novos).
- `src/pages/{LoginPage,RegisterPage,ForgotPasswordPage,ResetPasswordPage,ProfilePage}.tsx` (novos).
- `capacitor.config.ts`, `ios/App/App/Info.plist` (URL scheme Google), `package.json` (plugins novos).

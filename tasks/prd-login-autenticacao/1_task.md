# Tarefa 1.0: Backend — Fundacao de autenticacao (users, JWT, register/login/refresh/logout)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar toda a base de autenticacao no backend `controlai`: dependencias do Spring Security, tabelas de usuarios/grupos/refresh tokens, usecases de registro/login/refresh/logout no padrao clean architecture existente, e a filter chain que protege a API com JWT. Ao final desta tarefa, e possivel registrar um usuario, fazer login, renovar a sessao e fazer logout via API — as demais rotas de dados ainda nao filtram por grupo (Tarefa 2.0), mas ja exigem token valido.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — constructor injection, usecases baseados em `Result` seguindo o padrao do projeto.
- `clean-code` — nomes explicitos nos usecases/gateways, seguindo o padrao de dominio existente.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-1.1: cadastro com nome, e-mail e senha.
- RF-1.3: rejeitar cadastro com e-mail ja utilizado (409), informando o usuario.
- RF-1.4: senha com no minimo 8 caracteres.
- RF-2.1 (parcial): login com e-mail/senha.
- RF-2.2: endpoints de dados exigem autenticacao; sem credencial valida → 401.
- RF-2.3: mensagens de erro de login nao revelam se o e-mail existe (401 generico "Credenciais invalidas").
- RF-3.1: sessao renovada automaticamente via refresh token com rotacao.
- RF-3.5: sessoes revogadas/expiradas → 401.
- RF-5.3: logout revoga o refresh token do dispositivo.
</requirements>

## Subtarefas

- [ ] 1.1 Adicionar dependencias no `build.gradle.kts`: `spring-boot-starter-security`, `spring-boot-starter-oauth2-resource-server` (Nimbus JWT).
- [ ] 1.2 Migracao Flyway (`V27+`): tabelas `users`, `groups`, `group_members`, `refresh_tokens` conforme "Modelos de Dados" da techspec.md.
- [ ] 1.3 `domain/auth`: entidades `User`, `RefreshToken`, `AuthSession`; usecases `RegisterUserUseCase`, `LoginUseCase`, `RefreshSessionUseCase`, `LogoutUseCase`; gateways correspondentes.
- [ ] 1.4 `domain/groups` (base): entidades `Group`, `GroupMember`; criacao do grupo pessoal no registro do usuario.
- [ ] 1.5 `config/JwtConfig`: `JwtEncoder`/`JwtDecoder` HS256 com secret de 256 bits via env `JWT_SECRET`; access token de 15 min com claims `sub=userId`, `groupId`, `email`.
- [ ] 1.6 `config/SecurityConfig`: rotas `/auth/**` e `/actuator/health` publicas; todo o resto exige JWT (401 sem token).
- [ ] 1.7 `RequestContext` request-scoped expondo `userId` e `groupId` extraidos do JWT.
- [ ] 1.8 `AuthController`: `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`; `ProfileController`: `GET /me`.
- [ ] 1.9 Rotacao de refresh token: refresh invalida o antigo e emite par novo; reuso de token rotacionado revoga a familia inteira (detecao de roubo, log WARN).
- [ ] 1.10 Hash de senha com BCrypt; refresh token opaco armazenado como SHA-256.
- [ ] 1.11 Metricas Micrometer: `auth.login.success/failure`, `auth.refresh.reuse`; logs conforme "Monitoramento" da techspec.md (nunca logar tokens/senhas).
- [ ] 1.12 Testes de unidade dos usecases (ver "Testes da Tarefa").
- [ ] 1.13 Testes de integracao com `@SpringBootTest` + MockMvc (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Arquitetura do Sistema", "Interfaces Principais", "Modelos de Dados" e "Endpoints de API". Decisoes-chave: JWT HS256 auto-assinado (15 min) + refresh opaco com rotacao (90 dias absoluto), persistido com hash no MySQL.

## Criterios de Sucesso

- Registro, login, refresh, logout e `GET /me` funcionando via API.
- Endpoint de dados qualquer (ex.: `GET /categories`) retorna 401 sem token e 200 com token valido.
- Refresh reutilizado apos rotacao revoga a familia de tokens.
- `typecheck`/`build`/`lint`/`test` passando no backend.

## Testes da Tarefa

- [ ] Unidade: login ok / senha errada / e-mail inexistente (mesma mensagem generica); registro com e-mail duplicado; politica de senha (≥8); rotacao e detecao de reuso de refresh token; criacao do grupo pessoal no registro.
- [ ] Integracao: fluxo completo register → login → refresh → logout via MockMvc; 401 em endpoint de dados sem token; 401 apos logout com refresh revogado.
- [ ] Testes E2E: nao aplicavel nesta tarefa (cobertos na Tarefa 9.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai/build.gradle.kts`
- `/Volumes/SSD480GB/projects/controlai/src/main/resources/db/migration/` (novas `V27+`)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../domain/auth/` (novo)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../domain/groups/` (novo)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../config/SecurityConfig.kt` (novo), `JwtConfig.kt` (novo)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../application/auth/entrypoint/rest/` (novo)

Nota de verificacao: testes do backend exigem Docker MySQL rodando.

# Tarefa 5.0: Google Sign-In (backend + app iOS/web)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar login/cadastro com conta Google em um unico fluxo: o app obtem o ID token via `@capgo/capacitor-social-login` (web e iOS) e o backend verifica assinatura/audience e faz find-or-create por e-mail verificado. Um mesmo e-mail corresponde a uma unica conta, independentemente do metodo de login.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — `GoogleTokenVerifierGateway` como gateway externo mockavel.
- `ionic-design` — botao "Entrar com Google" seguindo padroes iOS.
- `clean-code` — separacao clara entre verificacao de token e find-or-create.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-1.2: cadastro/login com Google em fluxo unico (conta inexistente e criada).
- RF-1.5: mesmo e-mail = uma unica conta, independente do metodo (link por e-mail verificado).
- RF-2.1: login com Google funcionando em iOS (Capacitor) e web.
- Caso extremo do PRD: usuario cadastrado com Google tenta e-mail/senha (e vice-versa) com o mesmo e-mail.
</requirements>

## Subtarefas

- [ ] 5.1 Config GCP: OAuth Client IDs Web e iOS; env `GOOGLE_CLIENT_IDS` no backend (documentar passos — execucao manual do usuario se necessario).
- [ ] 5.2 Backend: dependencia `com.google.api-client:google-api-client`; `GoogleTokenVerifierGateway` com `GoogleIdTokenVerifier` (audiences = web + iOS client IDs).
- [ ] 5.3 `GoogleLoginUseCase`: verifica ID token → find-or-create por e-mail → vincula `google_sub` a conta existente de mesmo e-mail (RF-1.5) → `AuthSession`.
- [ ] 5.4 Endpoint publico `POST /auth/google` (`{ idToken }`).
- [ ] 5.5 Frontend: instalar/configurar `@capgo/capacitor-social-login` v8 (Capacitor 8); URL scheme no `Info.plist`.
- [ ] 5.6 Botao "Entrar com Google" na `LoginPage` → plugin → `POST /auth/google` → sessao via `AuthContext`.
- [ ] 5.7 Conta so-Google: `password_hash` nulo; login por senha nesse caso retorna 401 generico (senha definivel via fluxo de reset — Tarefa 7.0).
- [ ] 5.8 Testes de unidade e integracao (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Endpoints de API" (`POST /auth/google`), "Pontos de Integracao" (Google Identity) e "Consideracoes Tecnicas" (verificacao de ID token no backend; plugins @capgo).

## Criterios de Sucesso

- Login com Google funcionando na web e no iOS (validacao manual no device para iOS).
- Conta nova criada no primeiro login Google; e-mail ja cadastrado com senha e vinculado a mesma conta.
- Token invalido/audience errada → 401.
- Checks de backend e frontend passando.

## Testes da Tarefa

- [ ] Unidade: `GoogleLoginUseCase` — find-or-create, link por e-mail (RF-1.5), token invalido; mock do `GoogleTokenVerifierGateway`.
- [ ] Integracao: `POST /auth/google` com verifier mockado → cria conta e retorna `AuthSession`; audience invalida → 401.
- [ ] Unidade (Vitest): fluxo do botao Google no frontend com plugin mockado.
- [ ] Testes E2E: login Google real validado manualmente (web e device iOS).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai/build.gradle.kts` (google-api-client)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../domain/auth/` (`GoogleLoginUseCase`, gateway)
- `/Volumes/SSD480GB/projects/controlai-frontend/package.json` (`@capgo/capacitor-social-login`)
- `/Volumes/SSD480GB/projects/controlai-frontend/capacitor.config.ts`, `ios/App/App/Info.plist`
- `/Volumes/SSD480GB/projects/controlai-frontend/src/pages/LoginPage.tsx`, `src/services/authService.ts`

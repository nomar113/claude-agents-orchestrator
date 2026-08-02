# Tarefa 7.0: E-mail — Recuperacao e troca de senha (Resend)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Fluxos de autoatendimento de senha: "esqueci minha senha" com link enviado por e-mail (Resend), redefinicao com token de validade limitada, e troca de senha para usuario logado. Tambem cobre RF-5.4: contas criadas so com Google definem senha via reset. Inclui as paginas de frontend correspondentes.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — `EmailGateway` como porta; `ResendEmailClient` via `RestClient`.
- `ionic-design` — paginas de forgot/reset com validacao inline.
- `clean-code` — templates de e-mail isolados do dominio.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-5.1: "esqueci minha senha" com link/codigo por e-mail, validade limitada (1 h).
- RF-5.2: usuario logado altera senha informando a senha atual.
- RF-5.4: conta so-Google define senha via fluxo de redefinicao.
- RF-2.3 (coerencia): `POST /auth/password/forgot` sempre responde 204 (nao revela existencia do e-mail).
- Falha de envio de e-mail: log de erro + 204 mesmo assim; sem retry no MVP.
</requirements>

## Subtarefas

- [ ] 7.1 Migracao Flyway: tabela `password_reset_tokens` (token_hash, expires_at 1 h, used_at).
- [ ] 7.2 `EmailGateway` + `ResendEmailClient` (`POST https://api.resend.com/emails`, env `RESEND_API_KEY`); template PT-BR de reset com link usando `APP_WEB_URL`.
- [ ] 7.3 Usecases `ForgotPasswordUseCase` (sempre 204; token single-use) e `ResetPasswordUseCase` (valida token, politica ≥8, marca `used_at`, revoga refresh tokens ativos do usuario).
- [ ] 7.4 `ChangePasswordUseCase` + `PUT /me/password` (senha atual + nova).
- [ ] 7.5 Endpoints publicos `POST /auth/password/forgot` e `POST /auth/password/reset`.
- [ ] 7.6 Frontend: `ForgotPasswordPage` e `ResetPasswordPage` (rota publica com token na URL); ligar link "Esqueci minha senha" da `LoginPage`.
- [ ] 7.7 Conta Resend + dominio verificado (documentar passos manuais se necessario).
- [ ] 7.8 Testes (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Endpoints de API", "Pontos de Integracao" (Resend) e "Modelos de Dados" (`password_reset_tokens`).

## Criterios de Sucesso

- Fluxo completo: forgot → e-mail com link → reset → login com senha nova.
- Token expirado/reutilizado rejeitado; forgot de e-mail inexistente responde 204 sem enviar nada.
- Conta so-Google consegue definir senha via reset e passa a logar por senha.
- Checks de backend e frontend passando.

## Testes da Tarefa

- [ ] Unidade: forgot (e-mail existente/inexistente — mesmo 204), expiracao e single-use do token, politica de senha, change password com senha atual errada, reset em conta so-Google; mock do `EmailGateway`.
- [ ] Integracao: fluxo forgot → reset → login via MockMvc com Resend mockado; falha de envio nao quebra o fluxo (204 + log).
- [ ] Unidade (Vitest): paginas forgot/reset (validacao, mensagens PT-BR).
- [ ] Testes E2E: cobertos na Tarefa 9.0.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai/src/main/resources/db/migration/` (migracao `password_reset_tokens`)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../domain/auth/` (usecases de senha), `.../config/` (client Resend)
- `/Volumes/SSD480GB/projects/controlai-frontend/src/pages/ForgotPasswordPage.tsx`, `src/pages/ResetPasswordPage.tsx` (novos)

Nota de verificacao: testes do backend exigem Docker MySQL rodando.

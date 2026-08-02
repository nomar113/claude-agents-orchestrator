# Tarefa 8.0: Compartilhamento — Convites de grupo + tela de perfil

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o compartilhamento entre duas contas (casal): convite por e-mail para entrar no grupo do convidante, aceite/recusa, saida do grupo, e a `ProfilePage` que centraliza convites, alterar senha, API key e logout. Ao aceitar, o convidado abandona seu grupo pessoal e passa a ver/gerenciar o mesmo conjunto de dados.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — usecases de convite no padrao `Result` existente.
- `ionic-design` — `ProfilePage` com componentes Ionic e padroes iOS.
- `vercel-react-best-practices` — estado de convites sem re-renders desnecessarios.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-4.2: convidar outro usuario por e-mail para compartilhar dados.
- RF-4.3: convidado aceita ou recusa; ao aceitar, ambos veem/gerenciam o mesmo conjunto de dados.
- RF-4.4: compartilhamento desfeito por qualquer participante (sair do grupo → novo grupo pessoal vazio; dados permanecem no grupo original).
- Aceite com grupo pessoal ja contendo dados: bloqueio com exigencia de confirmacao `force=true` (dados do grupo pessoal descartados).
- UX: convite acessivel na tela de perfil/conta, junto de alterar senha e logout; feedback de convite pendente em PT-BR.
</requirements>

## Subtarefas

- [ ] 8.1 Migracao Flyway: tabela `group_invites` (status PENDING/ACCEPTED/DECLINED/CANCELLED, token unique, expires_at).
- [ ] 8.2 `domain/groups`: usecases `InviteToGroupUseCase`, `AcceptInviteUseCase` (com regra `force=true`), `DeclineInviteUseCase`, `LeaveGroupUseCase` (novo grupo pessoal vazio + seed de categorias), `ListPendingInvitesUseCase`.
- [ ] 8.3 E-mail de convite PT-BR via `EmailGateway` (Resend, Tarefa 7.0).
- [ ] 8.4 `GroupInviteController`: `POST /invites`, `GET /invites/pending`, `POST /invites/{id}/accept`, `POST /invites/{id}/decline`, `POST /groups/leave`.
- [ ] 8.5 Frontend `ProfilePage`: dados do usuario/grupo, enviar convite, convites pendentes (aceitar/recusar com confirmacao de `force`), sair do grupo, alterar senha, gestao da API key (Tarefa 3.0), logout.
- [ ] 8.6 Acesso a `ProfilePage` a partir das tabs; remover logout provisorio da Tarefa 4.0.
- [ ] 8.7 Testes (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Endpoints de API" (convites), "Modelos de Dados" (`group_invites`) e "Consideracoes Tecnicas" (grupo como dono; sair preserva dados no grupo original).

## Criterios de Sucesso

- Fluxo casal completo: A convida B por e-mail → B aceita → ambos veem os mesmos dados; B sai → volta a grupo vazio com categorias padrao, dados ficam com A.
- Aceite com dados no grupo pessoal bloqueado sem `force=true`.
- `ProfilePage` concentra convites, senha, API key e logout.
- Checks de backend e frontend passando.

## Testes da Tarefa

- [ ] Unidade: convite (criar/aceitar/recusar/expirar), regra `force=true`, sair do grupo com novo grupo pessoal + seed, convite para e-mail ja no grupo.
- [ ] Integracao: fluxo completo entre dois usuarios via MockMvc — apos aceite ambos leem o mesmo dado; apos sair, isolamento restaurado (404).
- [ ] Unidade (Vitest): `ProfilePage` (convites, confirmacao de force, logout).
- [ ] Testes E2E: cobertos na Tarefa 9.0.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai/src/main/resources/db/migration/` (migracao `group_invites`)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../domain/groups/`, `.../application/groups/entrypoint/rest/GroupInviteController.kt` (novos)
- `/Volumes/SSD480GB/projects/controlai-frontend/src/pages/ProfilePage.tsx` (novo), `src/App.tsx`

Nota de verificacao: testes do backend exigem Docker MySQL rodando.

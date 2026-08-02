# Tarefa 4.0: Frontend — Sessao, telas de login/registro e rotas protegidas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar a camada de sessao no `controlai-frontend`: `AuthContext`, `authService`, `tokenStorage`, interceptacao do `httpClient` (Bearer + refresh silencioso single-flight + redirect em 401), telas de login e registro em Ionic, e `PrivateRoute` protegendo todas as rotas de dados. Ao final, o app web funciona completo com autenticacao por e-mail/senha.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — telas de login/registro com componentes Ionic e padroes iOS.
- `vercel-react-best-practices` — contexto de auth sem re-renders desnecessarios.
- `clean-code` — servicos com responsabilidade unica.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-1.1/RF-1.3/RF-1.4: tela de cadastro (nome, e-mail, senha ≥8) com validacao inline e erro claro de e-mail em uso.
- RF-2.1 (parcial): login com e-mail/senha.
- RF-2.4: acesso nao autenticado redireciona para a tela de login.
- RF-3.1: sessao renovada automaticamente (refresh single-flight em 401).
- RF-3.3: na web (sem biometria), acesso direto com sessao valida.
- RF-3.5: sessao revogada/expirada leva a tela de login.
- RF-5.3: logout encerra a sessao no dispositivo.
- UX: feedback de erros em portugues; acessibilidade (labels, leitor de tela, contraste, area de toque minima).
</requirements>

## Subtarefas

- [ ] 4.1 `tokenStorage`: abstracao com implementacao web (localStorage) e interface pronta para Keychain nativo (Tarefa 6.0); access token apenas em memoria.
- [ ] 4.2 `authService`: `login`, `logout`, `refresh` (single-flight), `register`; conforme interface da techspec.md.
- [ ] 4.3 `AuthContext` + hook `useAuth`: estado do usuario, bootstrap da sessao na abertura (refresh → `GET /me`).
- [ ] 4.4 `httpClient.ts`: anexar `Authorization: Bearer`; em 401, refresh silencioso e retry unico; falha de refresh → limpar sessao e redirect `/login`. Cobrir os dois caminhos (CapacitorHttp e fetch).
- [ ] 4.5 `LoginPage`: e-mail/senha, link para cadastro e recuperacao de senha (placeholder ate Tarefa 7.0), erros em PT-BR.
- [ ] 4.6 `RegisterPage`: nome, e-mail, senha com validacao inline.
- [ ] 4.7 `PrivateRoute` + rotas publicas (`/login`, `/register`) no `App.tsx`; deep-link em rota protegida sem sessao → `/login`.
- [ ] 4.8 Logout acessivel no app (posicionamento provisorio ate a `ProfilePage` da Tarefa 8.0).
- [ ] 4.9 Testes Vitest (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Visao Geral dos Componentes" (frontend), "Interfaces Principais" (`AuthService`) e "Riscos Conhecidos" (CapacitorHttp vs fetch).

## Criterios de Sucesso

- Fluxo completo no navegador: registro → login → dados carregam → refresh automatico apos expirar access token → logout → redirect `/login`.
- Nenhuma rota de dados acessivel sem sessao.
- `tsc`, `lint`, `build` e testes Vitest passando.

## Testes da Tarefa

- [ ] Unidade (Vitest): `authService` (refresh single-flight, 401 → redirect); `tokenStorage`; `PrivateRoute`; paginas de login/registro (validacao inline, mensagens PT-BR).
- [ ] Integracao: `httpClient` com mock de API — anexa Bearer, faz refresh e retry em 401, redireciona ao falhar.
- [ ] Testes E2E: cobertos na Tarefa 9.0.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai-frontend/src/services/httpClient.ts`, `src/config/api.ts`, `src/App.tsx`
- `/Volumes/SSD480GB/projects/controlai-frontend/src/services/authService.ts`, `src/services/tokenStorage.ts`, `src/context/AuthContext.tsx` (novos)
- `/Volumes/SSD480GB/projects/controlai-frontend/src/pages/LoginPage.tsx`, `src/pages/RegisterPage.tsx` (novos)

Nota de verificacao: o dev do frontend aponta para a API de producao — usar backend local ao testar auth.

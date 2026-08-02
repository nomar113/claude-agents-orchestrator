# Tarefa 3.0: Backend — API key para automacao do iPhone + groupId no SQS

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

A automacao do iPhone (Atalho) chama `POST /payments/notification` sem usuario logado. Esta tarefa cria autenticacao por API key por conta (header `X-Api-Key`), resolve o `groupId` da chave e o propaga na mensagem SQS. Desbloqueia a automacao antes do lockdown completo da API (Tarefa 9.0) — sem isso, ativar a seguranca derrubaria a captura de notificacoes.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — filter customizado integrado a filter chain do Spring Security.
- `clean-code` — usecases e gateways nomeados explicitamente.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- `POST /payments/notification` autenticado por `X-Api-Key` (chave por conta/grupo).
- Mensagens SQS carregam `groupId`; mensagens antigas em fila durante o deploy usam fallback para o grupo legado (id 1).
- Gestao da chave: criar/consultar/revogar via `/me/api-key` (valor exibido apenas na criacao).
- Metrica Micrometer `auth.api_key.invalid`.
</requirements>

## Subtarefas

- [ ] 3.1 Migracao Flyway: tabela `api_keys` (id, group_id FK, key_hash unique, label, created_at, revoked_at).
- [ ] 3.2 `domain/auth`: entidade `ApiKey` + usecases de criar/consultar/revogar chave (valor em claro retornado apenas na criacao; armazenar hash).
- [ ] 3.3 `ApiKeyAuthFilter` na filter chain: valida `X-Api-Key` em `POST /payments/notification`, popula `RequestContext` com o `groupId` da chave; chave invalida/revogada → 401 + contador `auth.api_key.invalid`.
- [ ] 3.4 Endpoints autenticados: `POST /me/api-key`, `GET /me/api-key`, `DELETE /me/api-key`.
- [ ] 3.5 `PaymentNotificationQueueMessage` e listeners SQS carregam `groupId`; fallback para grupo legado (id 1) em mensagens sem o campo.
- [ ] 3.6 Testes de unidade e integracao (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Endpoints de API" (especial: `POST /payments/notification`), "Modelos de Dados" (`api_keys`) e "Pontos de Integracao" (SQS).

## Criterios de Sucesso

- `POST /payments/notification` aceita chave valida e rejeita chave ausente/invalida/revogada com 401.
- Notificacao processada via SQS termina associada ao grupo correto.
- Mensagem antiga sem `groupId` processada com fallback para o grupo 1.
- `typecheck`/`build`/`lint`/`test` passando no backend.

## Testes da Tarefa

- [ ] Unidade: geracao/hash/revogacao de chave; resolucao de `groupId`; fallback do listener SQS.
- [ ] Integracao: `X-Api-Key` valida → 2xx e mensagem SQS com `groupId`; chave revogada/ausente → 401; fluxo completo ate persistencia no grupo correto.
- [ ] Testes E2E: nao aplicavel nesta tarefa (validacao real do Atalho na Tarefa 9.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai/src/main/resources/db/migration/` (migracao `api_keys`)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../config/SecurityConfig.kt` (`ApiKeyAuthFilter`)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../application/payments_notification/entrypoint/queue/PaymentNotificationQueueListener.kt`

Nota de verificacao: testes do backend exigem Docker MySQL rodando.

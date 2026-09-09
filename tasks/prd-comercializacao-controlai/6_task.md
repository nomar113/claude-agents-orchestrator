# Tarefa 6.0: Gate de acesso por assinatura (SubscriptionGuardFilter)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Implementar o filtro que efetivamente bloqueia o acesso de grupos sem assinatura ativa aos endpoints protegidos, respondendo `402 Payment Required`. Este é o componente que liga toda a lógica de billing (Tarefas 2.0–5.0) ao restante do sistema. Depende da Tarefa 3.0 (`FindActiveSubscriptionByGroupIdGateway`).

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — filtro Spring Security posicionado na cadeia de filtros, seguindo o padrão já usado por `ApiKeyAuthFilter`.
</skills>

<requirements>
- RF-9, RF-10 e RF-11 do PRD: acesso liberado para assinatura ativa, revogado para cancelada/reembolsada, sempre liberado para grandfathered.
- Tech Spec `Decisões Principais`: status de assinatura checado a cada request, NÃO embutido no JWT, para permitir revogação imediata.
- Tech Spec `Arquitetura do Sistema`: `SubscriptionGuardFilter` roda após a autenticação JWT/API Key já existente; rotas públicas (`/auth/**`, `/webhooks/**`, `/health`) são explicitamente ignoradas pelo filtro.
</requirements>

## Subtarefas

- [ ] 6.1 Criar `SubscriptionGuardFilter` em `config/`, lendo o `groupId` do `RequestContext` (já disponível via `JwtRequestContext`/`ApiKeyAuthentication`) e consultando `FindActiveSubscriptionByGroupIdGateway`.
- [ ] 6.2 Responder `402 Payment Required` (corpo JSON simples, ex.: `{"error": "subscription_inactive"}`) quando o grupo não possui assinatura com `status = ACTIVE`.
- [ ] 6.3 Excluir explicitamente do filtro as rotas `/auth/**`, `/webhooks/**`, `/health`, `/actuator/health` (mesma lista de `permitAll` do `SecurityConfig`).
- [ ] 6.4 Registrar o filtro no `SecurityConfig`, posicionado depois da autenticação (JWT/API Key) já resolvida.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` e `Design de Implementação`. Referenciar `config/ApiKeyAuthFilter.kt` e `config/JwtRequestContext.kt` como padrões de filtro e de acesso ao contexto de request já estabelecidos.

## Critérios de Sucesso

- Uma requisição autenticada de um grupo `GRANDFATHERED`/`ACTIVE` acessa normalmente qualquer endpoint protegido.
- Uma requisição autenticada de um grupo sem linha em `subscriptions`, ou com `status = CANCELLED`/`EXPIRED`, recebe `402` em qualquer endpoint protegido (ex.: `GET /purchases`).
- Rotas públicas continuam acessíveis sem nenhuma consulta a `subscriptions`.

## Testes da Tarefa

- [ ] Teste de unidade do filtro cobrindo: grupo ativo, grupo sem assinatura, grupo cancelado, e rota pública (bypass).
- [ ] Teste de integração (H2) chamando um endpoint protegido real (ex.: `GET /purchases`) com grupos em cada um dos estados acima, validando o código de status HTTP retornado.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/config/SubscriptionGuardFilter.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/config/SecurityConfig.kt` (modificado)
- Depende de: Tarefa 3.0

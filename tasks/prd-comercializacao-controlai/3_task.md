# Tarefa 3.0: Domínio billing — entidade, gateways e providers

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Implementar a camada de domínio e os providers do bounded context `billing` que permitem consultar e atualizar o estado de assinatura de um grupo, seguindo o padrão Gateway/Provider já usado nos demais bounded contexts do projeto (`fun interface` em `domain/*/gateway`, implementação `*Provider` em `application/*/application`). Depende da Tarefa 2.0 (tabelas e modelos JPA já existentes).

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — padrão Gateway/Provider, `Result<T>` para propagação de erro, `fun interface` para gateways de leitura única, conforme já usado em `domain/auth/gateway` e `domain/groups/gateway`.
</skills>

<requirements>
- Tech Spec `Interfaces Principais`: `FindActiveSubscriptionByGroupIdGateway`, `UpsertSubscriptionGateway`.
- Tech Spec `Decisões Principais`: nenhuma lógica de grandfathering condicional no código — o domínio só enxerga "existe uma assinatura ativa para este grupo ou não".
- Reaproveitar o padrão de conversores (`*Converter`) para mapear entre `Subscription` (domínio) e `SubscriptionModel` (JPA), como já feito em outros contextos (ex.: `application/auth/converter`).
</requirements>

## Subtarefas

- [x] 3.1 Criar os gateways em `domain/billing/gateway`: `FindActiveSubscriptionByGroupIdGateway`, `UpsertSubscriptionGateway`, `FindKiwifyWebhookEventByIdGateway`, `SaveKiwifyWebhookEventGateway`.
- [x] 3.2 Implementar os providers correspondentes em `application/billing/application`, usando os repositórios JPA criados na Tarefa 2.0.
- [x] 3.3 Criar o `SubscriptionConverter` (`toModel()`/`toEntity()`) seguindo o padrão já usado em outros bounded contexts.
- [x] 3.4 Garantir que `UpsertSubscriptionGateway` funcione tanto para criar quanto para atualizar a assinatura de um grupo (upsert por `group_id` único).

## Detalhes de Implementação

Ver Tech Spec `Interfaces Principais` para as assinaturas exatas dos gateways. Seguir o mesmo estilo de `domain/auth/gateway/FindUserByEmailGateway.kt` e seu provider correspondente como referência de padrão no repositório.

## Critérios de Sucesso

- Gateways e providers compilam e seguem exatamente o padrão Gateway/Provider já estabelecido (controllers e use cases nunca acessam repositórios JPA diretamente).
- `UpsertSubscriptionGateway` cria uma nova linha quando o grupo não tem assinatura e atualiza a existente quando já tem.

## Testes da Tarefa

- [x] Testes de unidade dos providers com gateways mockados via lambda (`fun interface`), conforme convenção do projeto.
- [x] Teste de integração (H2) do `UpsertSubscriptionGateway` cobrindo os dois caminhos: criação e atualização de uma assinatura existente.
- [x] Teste de integração do `FindActiveSubscriptionByGroupIdGateway` retornando `null` para grupo sem assinatura e a assinatura correta para grupo com uma ou mais atualizações de status ao longo do tempo.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/domain/billing/gateway/` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/billing/application/` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/billing/converter/SubscriptionConverter.kt` (novo)
- Depende de: arquivos criados na Tarefa 2.0

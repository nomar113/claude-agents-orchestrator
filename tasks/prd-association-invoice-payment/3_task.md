# Tarefa 3.0: Search Notifications — Gateway, Provider, UseCase

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a logica de busca manual de payment notifications para associacao. Permite buscar por valor exato e/ou periodo de data, excluindo notifications deletadas, canceladas ou ja associadas a outro invoice.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- Busca por `amount` (exato) quando fornecido
- Busca por periodo `startDate`/`endDate` em `purchased_at` quando fornecido
- Sem filtros: retorna ultimos 7 dias
- Excluir notifications com `deleted_at` nao nulo, `cancelled_at` nao nulo, ou `purchase_invoice_id` apontando para outro invoice
- Limite de 20 resultados
- Ordenacao por `purchased_at DESC`
- Reusar `SuggestionResponse` como formato de retorno
</requirements>

## Subtarefas

- [x] 3.1 Criar `SearchNotificationsGateway` (fun interface) no dominio
- [x] 3.2 Adicionar query nativa no `PaymentNotificationRepository` para busca com filtros dinamicos
- [x] 3.3 Criar `SearchNotificationsProvider` — implementa a busca com filtros condicionais
- [x] 3.4 Criar `SearchNotificationsUseCase` que orquestra o gateway com `Result<T>`

## Detalhes de Implementacao

Consultar a secao **Regras do GET search** da `techspec.md`. Usar `FindInvoiceSuggestionsProvider` como referencia de estrutura. A query nativa deve usar filtros condicionais (WHERE clauses opcionais) para lidar com parametros nulos.

## Criterios de Sucesso

- Busca com `amount` retorna apenas notifications com valor exato
- Busca com `startDate`/`endDate` retorna apenas notifications no periodo
- Busca sem filtros retorna ultimos 7 dias
- Notifications deletadas, canceladas e ja associadas sao excluidas
- Maximo 20 resultados retornados
- Todos os testes passam

## Testes da Tarefa

- [x] Teste unitario: busca com filtro de valor
- [x] Teste unitario: busca com filtro de data
- [x] Teste unitario: busca com ambos os filtros
- [x] Teste unitario: busca sem filtros (padrao 7 dias)
- [x] Teste unitario: exclusao de deletadas/canceladas/ja associadas
- [x] Teste unitario: limite de 20 resultados
- [x] Teste unitario: resultados vazios

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/gateway/SearchNotificationsGateway.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/usecase/SearchNotificationsUseCase.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/application/SearchNotificationsProvider.kt` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` (modificar)
- `src/main/kotlin/br/com/nomar/controlai/application/suggestion/entrypoint/rest/response/SuggestionResponse.kt` (referencia)

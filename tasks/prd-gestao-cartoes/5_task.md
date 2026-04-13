# Tarefa 5.0: Backend — Endpoint de resumo mensal por cartao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o endpoint `GET /payment-methods/summary?month=YYYY-MM` que retorna o total gasto por cartao/meio de pagamento no mes especificado, incluindo breakdown por sub-cartao. Este endpoint alimentara o dashboard do frontend com dados reais.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Endpoint GET /payment-methods/summary com parametro obrigatorio `month` (formato YYYY-MM)
- Consultar payment_notifications fazendo JOIN com payment_methods e sub_cards via as FKs
- Retornar lista de cartoes com: id, nome, nome do titular, total gasto no mes
- Incluir breakdown por sub-cartao: id, ultimos 4 digitos, total
- Cartoes sem despesas no mes devem aparecer com total 0
- Considerar apenas cartoes ativos (soft delete)
- Despesas sem payment_method_id (historicas) nao entram no calculo por cartao
- Criar gateway, use case, provider e response DTO dedicados
</requirements>

## Subtarefas

- [ ] 5.1 Criar gateway `GetPaymentMethodsSummaryGateway`
- [ ] 5.2 Criar use case `GetPaymentMethodsSummaryUseCase`
- [ ] 5.3 Criar query nativa ou JPQL no repository para calcular totais com JOIN
- [ ] 5.4 Criar provider implementando o gateway
- [ ] 5.5 Criar response DTO `PaymentMethodSummaryResponse` com `SubCardTotalResponse`
- [ ] 5.6 Adicionar endpoint no `PaymentMethodController`
- [ ] 5.7 Testes de integracao

## Detalhes de Implementacao

Consultar secao **Endpoints de API** da `techspec.md` para o formato de resposta do endpoint summary.

A query deve fazer SUM(amount) agrupando por payment_method_id e sub_card_id, filtrando por mes (purchased_at entre inicio e fim do mes).

## Criterios de Sucesso

- Endpoint retorna totais corretos por cartao e por sub-cartao
- Cartoes ativos sem despesas aparecem com total 0
- Despesas sem payment_method_id nao causam erro
- Parametro month invalido retorna 400
- Performance aceitavel com indice nas FKs

## Testes da Tarefa

- [ ] Teste de integracao: criar cartoes, registrar despesas, validar totais corretos
- [ ] Teste de integracao: cartao sem despesas retorna total 0
- [ ] Teste de integracao: despesas em meses diferentes nao se misturam
- [ ] Teste de integracao: sub-cartao totals somam para o total do cartao pai
- [ ] Teste MockMvc: parametro month ausente retorna 400
- [ ] Teste MockMvc: formato de resposta JSON conforme techspec

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/gateway/GetPaymentMethodsSummaryGateway.kt` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/usecase/GetPaymentMethodsSummaryUseCase.kt` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/application/GetPaymentMethodsSummaryProvider.kt` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/rest/response/PaymentMethodSummaryResponse.kt` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/rest/PaymentMethodController.kt` (modificado)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/model/PaymentNotification.kt` (referencia)

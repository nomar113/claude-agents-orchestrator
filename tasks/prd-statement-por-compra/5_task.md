# Tarefa 5.0: Corrigir o resumo por meio de pagamento (GetPaymentMethodsSummaryProvider)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

`GetPaymentMethodsSummaryProvider` hoje soma `SUM(pn.amount)` filtrando so por `purchased_at` dentro do periodo — um bug real ja em producao, que mostra o valor total bruto de compras parceladas em vez da parcela do mes. Esta tarefa reescreve o provider para usar o mesmo `INNER JOIN installments` + `PERIOD_MATCH_PREDICATE`/`AMOUNT_EXPRESSION` de `BudgetPeriodSqlSupport` (ja simplificado na Tarefa 4.0), tornando o resumo por meio de pagamento consistente com a listagem e com o resumo por categoria.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot`: reaproveita `BudgetPeriodSqlSupport` ja existente, sem novo componente.
</skills>

<requirements>
- PRD 3.1 (resumo por meio de pagamento passa a ler exclusivamente os statements do mes).
- Contexto do bug: PRD, paragrafo de abertura ("essa mesma regra ja foi corrigida em outras telas do mesmo app" — este e o caso ainda pendente).
- Ver Tech Spec, secao "GetPaymentMethodsSummaryProvider" em Visao Geral dos Componentes.
</requirements>

## Subtarefas

- [ ] 5.1 Reescrever a query de `GetPaymentMethodsSummaryProvider.execute` para usar `BudgetPeriodSqlSupport.INSTALLMENTS_JOIN`, `PERIOD_MATCH_PREDICATE` e `AMOUNT_EXPRESSION` em vez de `SUM(pn.amount)` com filtro direto por `purchased_at`.
- [ ] 5.2 Preservar o agrupamento existente por `payment_method_id`/`sub_card_id` (totais por cartao e por sub-cartao).
- [ ] 5.3 Escrever um teste de integracao que reproduz o bug atual (compra parcelada cruzando meses) e confirma que o total por meio de pagamento agora bate com a soma da listagem do mes.

## Detalhes de Implementacao

Ver Tech Spec, secao "Testes de Integracao": `GetPaymentMethodsSummaryProviderIT` — "total por meio de pagamento bate com a soma da listagem para compra parcelada cruzando meses (reproduz e corrige o bug atual)".

## Criterios de Sucesso

- O total por meio de pagamento de um mes com compras parceladas reflete apenas as parcelas que vencem naquele mes, nao o valor total da compra.
- A soma dos totais por meio de pagamento bate com o total agregado ja exibido em `GetBudgetSummaryProvider` para o mesmo mes.
- Nenhuma regressao no agrupamento por sub-cartao existente.

## Testes da Tarefa

- [ ] Testes de unidade: mapeamento de linhas da query para `PaymentMethodSummary`/`SubCardTotal` continua correto apos a mudanca de SQL.
- [ ] Testes de integracao: `GetPaymentMethodsSummaryProviderIT` — cenario com compra parcelada cruzando meses confirma o bug corrigido; cenario com compra a vista/Pix/dinheiro confirma consistencia.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/payment_methods/application/GetPaymentMethodsSummaryProvider.kt`
- `application/budget/application/BudgetPeriodSqlSupport.kt` (consumido, sem mudanca nesta tarefa)
- `src/test/kotlin/.../payment_methods/application/GetPaymentMethodsSummaryProviderIT.kt` (novo ou existente)

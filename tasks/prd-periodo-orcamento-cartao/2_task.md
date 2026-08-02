# Tarefa 2.0: Auto-calculo de periodos na criacao do orcamento

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Ao criar um novo orcamento, gerar automaticamente os periods para cada meio de pagamento do tipo CREDIT_CARD e PIX. As datas sao calculadas com base no `closingDay` do cartao. Inclui tambem lazy creation para orcamentos existentes que nao possuem periods.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Ao criar budget, gerar periods para todos CREDIT_CARD e PIX ativos
- CREDIT_CARD: startDate = dia (closingDay + 1) do mes anterior, endDate = dia closingDay do mes corrente
- PIX: startDate = dia 1 do mes, endDate = ultimo dia do mes
- Tratar closingDay > dias do mes (clamping com Math.min)
- CASH nao deve ter period
- Lazy creation: ao carregar budget sem periods, gerar automaticamente e persistir
</requirements>

## Subtarefas

- [x] 2.1 Criar servico/utility para calcular datas a partir de closingDay e yearMonth
- [x] 2.2 Modificar `SaveBudgetProvider` para gerar periods ao criar budget
- [x] 2.3 Implementar lazy creation no `GetBudgetSummaryProvider` para budgets existentes sem periods
- [x] 2.4 Escrever testes

## Detalhes de Implementacao

Consultar a secao "Auto-calculo de datas" da techspec.md para a logica de calculo.

Buscar todos os PaymentMethods ativos (nao deletados) do tipo CREDIT_CARD e PIX usando o repositorio existente.

## Criterios de Sucesso

- Criar budget gera periods para todos CREDIT_CARD e PIX
- Datas calculadas corretamente para closingDay no meio do mes, dia 1, dia 28/29/30/31
- PIX gera periodo do dia 1 ao ultimo dia do mes
- CASH nao gera period
- Orcamentos existentes sem periods recebem periods via lazy creation

## Testes da Tarefa

- [x] Teste unitario: calculo de datas para closingDay = 3, 15, 28, 31
- [x] Teste unitario: calculo para fevereiro (28 e 29 dias)
- [x] Teste unitario: calculo para PIX (sem closingDay)
- [x] Teste de integracao: lazy creation testado via GetBudgetSummaryProvider
- [x] Teste de integracao: SaveBudgetProvider gera periods automaticamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/CreateBudgetProvider.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/GetBudgetSummaryProvider.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/entity/PaymentMethod.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/database/repository/PaymentMethodRepository.kt`

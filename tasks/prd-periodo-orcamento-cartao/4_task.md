# Tarefa 4.0: Endpoint PUT para editar periodos

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o endpoint PUT /budgets/{id}/periods para permitir que o usuario atualize os ranges de data dos meios de pagamento de um orcamento.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Endpoint: PUT /budgets/{budgetId}/periods
- Body: lista de PeriodEntry com paymentMethodId, startDate, endDate
- Validacao: endDate >= startDate para cada entry
- Retornar 400 se validacao falhar
- Retornar 404 se budget nao existir
- Atualizar periods existentes (upsert por budget_id + payment_method_id)
</requirements>

## Subtarefas

- [ ] 4.1 Criar DTOs de request: `UpdateBudgetPeriodsRequest` e `PeriodEntry`
- [ ] 4.2 Criar use case `UpdateBudgetPeriodsUseCase`
- [ ] 4.3 Implementar provider com logica de upsert e validacao
- [ ] 4.4 Adicionar endpoint no `BudgetController`
- [ ] 4.5 Escrever testes

## Detalhes de Implementacao

Consultar a secao "Endpoints de API" da techspec.md para formato de request/response.

Seguir o padrao existente de use cases e providers do projeto (ex: CreateBudgetUseCase).

## Criterios de Sucesso

- PUT com datas validas atualiza os periods e retorna 200
- PUT com endDate < startDate retorna 400 com mensagem clara
- PUT com budgetId inexistente retorna 404
- Apos PUT, GET /budgets reflete os novos periods e valores "Real" recalculados

## Testes da Tarefa

- [ ] Teste unitario: validacao endDate >= startDate
- [ ] Teste de integracao: PUT atualiza periods corretamente
- [ ] Teste de integracao: PUT com datas invalidas retorna 400
- [ ] Teste de integracao: PUT com budget inexistente retorna 404
- [ ] Teste de integracao: apos PUT, GET retorna valores Real recalculados

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/budget/entrypoint/rest/BudgetController.kt`
- `src/main/kotlin/br/com/nomar/controlai/domain/budget/usecase/` — Use cases existentes
- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/` — Providers existentes

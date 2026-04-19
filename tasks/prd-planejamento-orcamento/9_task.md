# Tarefa 9.0: Frontend — Integracao do planejamento na Tab1

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Substituir os valores hardcoded do card resumo na Tab1 (Receitas R$ 5.200, Saldo R$ 2.847,52, Orcamento 45%) por dados reais vindos do endpoint GET /budgets/summary. Criar o componente BudgetSummaryCard reutilizavel.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Componente BudgetSummaryCard que recebe dados do BudgetCompactSummary
- Chamar getBudgetSummary(currentMonth) no Tab1 ao carregar
- Exibir: total de receitas, saldo (receitas - gastos), percentual gasto/planejado
- Se nao existir planejamento para o mes, exibir estado vazio com botao "Criar Orcamento"
- Manter loading state e error state
- O card deve ser clicavel para navegar para /budget
</requirements>

## Subtarefas

- [ ] 9.1 Criar componente `BudgetSummaryCard.tsx`
- [ ] 9.2 Integrar no Tab1.tsx substituindo valores hardcoded
- [ ] 9.3 Adicionar chamada ao budgetService no Tab1
- [ ] 9.4 Implementar empty state "Criar Orcamento"
- [ ] 9.5 Testes do componente e integracao

## Detalhes de Implementacao

O card resumo atual na Tab1 tem a estrutura `ctrl-summary-card` com Receitas, Saldo e Orcamento. O BudgetSummaryCard deve manter o mesmo visual mas com dados reais. Quando nao ha budget, mostrar um CTA sutil.

## Criterios de Sucesso

- Tab1 exibe dados reais do planejamento do mes atual
- Valores formatados em BRL
- Click no card navega para /budget
- Empty state funcional com botao para criar orcamento
- Nenhum valor hardcoded permanece

## Testes da Tarefa

- [ ] Teste: BudgetSummaryCard renderiza com dados mockados
- [ ] Teste: empty state exibido quando nao ha budget
- [ ] Teste: click no card navega para /budget
- [ ] Teste: Tab1 chama getBudgetSummary ao montar

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/BudgetSummaryCard.tsx` (novo)
- `src/components/BudgetSummaryCard.test.tsx` (novo)
- `src/pages/Tab1.tsx` (modificar)
- `src/services/budgetService.ts` (criado na task 7)
- `src/types/budget.ts` (criado na task 7)

# Tarefa 6.0: Frontend — Tipos, service e componentes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar os tipos TypeScript para periods, a chamada API para atualizar periods, e os componentes visuais `BudgetPeriodSection` e `BudgetPeriodCard` com inputs de data mascarados (dd/mm/yyyy).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Criar tipo `BudgetPaymentPeriod` em budget.ts
- Adicionar campo `periods` ao tipo `BudgetSummary`
- Criar funcao `updateBudgetPeriods` em budgetService.ts
- Criar componente `BudgetPeriodSection` — secao colapsavel com header "PERIODO POR MEIO DE PAGAMENTO"
- Criar componente `BudgetPeriodCard` — card com badge, nome, closingDay, inputs De/Ate
- Inputs de data com mascara dd/mm/yyyy (nao usar IonDatetime)
- Visual consistente com o design no Paper (dark theme, badges coloridos, bordas sutis)
</requirements>

## Subtarefas

- [ ] 6.1 Adicionar tipos: `BudgetPaymentPeriod` e campo `periods` em `BudgetSummary`
- [ ] 6.2 Adicionar funcao `updateBudgetPeriods(budgetId, periods)` em budgetService.ts
- [ ] 6.3 Criar componente `BudgetPeriodCard` com inputs mascarados dd/mm/yyyy
- [ ] 6.4 Criar componente `BudgetPeriodSection` colapsavel
- [ ] 6.5 Adicionar estilos CSS seguindo padrao do BudgetPage.css
- [ ] 6.6 Escrever testes

## Detalhes de Implementacao

Consultar o design criado no Paper (artboard "Orcamento — Range de Datas por Cartao") para referencia visual.

Para a mascara de data, implementar com formatacao on-change que insere barras automaticamente (ex: ao digitar "04" vira "04/", ao digitar "0403" vira "04/03/").

Seguir o padrao de classes CSS do projeto: `.budget-*` para elementos gerais, criar `.period-*` para os novos.

## Criterios de Sucesso

- Componentes renderizam corretamente com dados mockados
- Mascara de data formata corretamente ao digitar
- Visual identico ao design do Paper
- Secao colapsavel funciona (chevron rotaciona)
- Campos de data desabilitados fora do modo edicao

## Testes da Tarefa

- [ ] Teste unitario: mascara de data formata corretamente (dd/mm/yyyy)
- [ ] Teste unitario: BudgetPeriodCard renderiza com props corretas
- [ ] Teste unitario: BudgetPeriodSection renderiza lista de cards
- [ ] Teste unitario: secao colapsa/expande ao clicar no header

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/types/budget.ts` — Tipos existentes
- `src/services/budgetService.ts` — Service existente
- `src/components/BudgetSummarySection.tsx` — Referencia de componente
- `src/components/BudgetCategoryCard.tsx` — Referencia de componente com progress bar
- `src/pages/BudgetPage.css` — Estilos existentes

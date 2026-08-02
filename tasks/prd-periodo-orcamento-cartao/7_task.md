# Tarefa 7.0: Frontend — Integracao na BudgetPage + modo edicao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar os componentes criados na Task 6 na BudgetPage. Conectar o modo edicao para permitir alteracao das datas, persistir via API e garantir que os valores "Real" sejam atualizados apos salvar.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Renderizar `BudgetPeriodSection` apos `BudgetSummarySection` na BudgetPage
- Secao sempre visivel, editavel apenas no modo edicao
- Ao salvar orcamento, chamar `updateBudgetPeriods` com as datas editadas
- Apos salvar, recarregar o budget para refletir os novos valores "Real"
- Validacao no frontend: endDate >= startDate (exibir feedback visual)
- Texto auxiliar explicando que as datas sao baseadas no fechamento
</requirements>

## Subtarefas

- [ ] 7.1 Adicionar `BudgetPeriodSection` na BudgetPage apos BudgetSummarySection
- [ ] 7.2 Gerenciar estado local dos periods editados
- [ ] 7.3 Conectar modo edicao: habilitar/desabilitar inputs conforme `isEditing`
- [ ] 7.4 Ao salvar: chamar API de update periods + recarregar budget
- [ ] 7.5 Validacao frontend: endDate >= startDate com feedback visual
- [ ] 7.6 Adicionar secao "periods" ao estado de openSections (colapsavel)
- [ ] 7.7 Escrever testes E2E

## Detalhes de Implementacao

Seguir o padrao existente de como BudgetPage gerencia edicao (state `isEditing`, botoes Editar/Salvar/Cancelar).

Ao cancelar edicao, reverter as datas para os valores originais do summary.

## Criterios de Sucesso

- Secao visivel na pagina apos "Planejado vs Real"
- Campos desabilitados fora do modo edicao
- Ao editar datas e salvar, valores "Real" atualizam na tela
- Validacao impede salvar com endDate < startDate
- Cancelar edicao reverte datas para valores originais
- Secao colapsavel funciona independentemente das outras secoes

## Testes da Tarefa

- [ ] Teste E2E: navegar para orcamento e verificar secao "Periodo por Meio de Pagamento" visivel
- [ ] Teste E2E: entrar em modo edicao, alterar data, salvar, verificar que totais mudaram
- [ ] Teste E2E: tentar salvar com endDate < startDate e verificar que validacao impede
- [ ] Teste E2E: colapsar/expandir secao
- [ ] Teste E2E: cancelar edicao reverte datas

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/BudgetPage.tsx` — Pagina principal (CRITICO)
- `src/pages/BudgetPage.css` — Estilos
- `src/components/BudgetPeriodSection.tsx` — Criado na Task 6
- `src/components/BudgetPeriodCard.tsx` — Criado na Task 6
- `src/services/budgetService.ts` — Funcao updateBudgetPeriods da Task 6

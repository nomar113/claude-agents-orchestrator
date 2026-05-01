# Tarefa 6.0: Testes E2E dos Fluxos de Refresh

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar testes E2E com Playwright que validam os fluxos completos de atualizacao automatica de listas. Estes testes garantem que apos operacoes de insert, update e delete, as telas de listagem refletem as mudancas ao serem revisitadas.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir workflow padrao de implementacao com review automatico.
- `executar-qa` — QA com Playwright, acessibilidade e visual.
</skills>

<requirements>
- Testes E2E com Playwright cobrindo os fluxos principais de refresh.
- Cada teste deve validar que a lista atualiza sem refresh manual.
- Testes devem cobrir insert, update e delete.
- Testes devem verificar que dados anteriores nao reaparecem apos exclusao.
- Depende da conclusao das Tasks 1-5.
</requirements>

## Subtarefas

- [x] 6.1 Teste E2E: Inserir gasto manual na ManualEntryPage, voltar para Tab1, verificar que o novo gasto aparece na lista.
- [x] 6.2 Teste E2E: Excluir nota fiscal na Tab2, navegar para outra tab e voltar, verificar que item excluido nao reaparece.
- [x] 6.3 Teste E2E: Editar categoria de um gasto no PurchaseDetail, voltar para Tab1, verificar que a categoria atualizada aparece.
- [x] 6.4 Teste E2E: Criar orcamento na BudgetPage, navegar para outra tela e voltar, verificar que orcamento aparece.
- [x] 6.5 Teste E2E: Criar categoria na CategoriesPage, navegar para outra tela e voltar, verificar que categoria aparece.

## Detalhes de Implementacao

Seguir a abordagem de testes E2E descrita na `techspec.md`, secao "Testes E2E". Usar Playwright conforme padroes do projeto. Cada teste deve simular a navegacao completa do usuario entre telas.

## Criterios de Sucesso

- Todos os 5 testes E2E passam consistentemente.
- Testes cobrem os 3 tipos de operacao: insert, update e delete.
- Testes validam que nao ha skeleton/loading visivel durante o refresh (silent).
- Testes validam propagacao entre telas (ex: insert na ManualEntry reflete na Tab1 E na Tab2).

## Testes da Tarefa

- [ ] Teste E2E: fluxo de insert (ManualEntry → Tab1)
- [ ] Teste E2E: fluxo de delete (Tab2 → Tab2)
- [ ] Teste E2E: fluxo de update (PurchaseDetail → Tab1)
- [ ] Teste E2E: fluxo de create budget (BudgetPage → BudgetPage)
- [ ] Teste E2E: fluxo de create category (CategoriesPage → CategoriesPage)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx` — Tela de destino dos fluxos de insert e update.
- `controlai-frontend/src/pages/Tab2.tsx` — Tela de destino do fluxo de delete.
- `controlai-frontend/src/pages/ManualEntryPage.tsx` — Tela de origem do fluxo de insert.
- `controlai-frontend/src/pages/PurchaseDetail.tsx` — Tela de origem do fluxo de update.
- `controlai-frontend/src/pages/BudgetPage.tsx` — Tela de fluxo de budget.
- `controlai-frontend/src/pages/CategoriesPage.tsx` — Tela de fluxo de categorias.

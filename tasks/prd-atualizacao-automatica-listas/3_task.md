# Tarefa 3.0: Silent Refresh na BudgetPage

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar `useIonViewWillEnter` na BudgetPage para recarregar o budget summary toda vez que a tela fica visivel. Implementar o padrao de silent refresh.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir workflow padrao de implementacao com review automatico.
- `executar-review` — Code review apos implementacao.
</skills>

<requirements>
- Adicionar `useIonViewWillEnter` do `@ionic/react` na BudgetPage.
- Modificar a funcao `load` para aceitar parametro `silent: boolean`.
- Quando `silent = true`: nao setar `loading` para `true`, nao setar `error` em caso de falha, nao limpar `summary` existente.
- Adicionar `hasLoadedRef` para evitar double-fetch na montagem inicial.
- Manter a posicao de scroll.
- Manter funcionalidade existente de edicao inline, modais de add item e duplicate month.
</requirements>

## Subtarefas

- [ ] 3.1 Importar `useIonViewWillEnter` do `@ionic/react` na BudgetPage.
- [ ] 3.2 Adicionar `hasLoadedRef` (useRef) para controlar carga inicial.
- [ ] 3.3 Modificar `load` para aceitar parametro `silent` e condicionar `setLoading`, `setError` e `setSummary(null)`.
- [ ] 3.4 Adicionar `useIonViewWillEnter` que chama `load(true)` condicionado ao `hasLoadedRef`.
- [ ] 3.5 Setar `hasLoadedRef.current = true` apos a carga inicial no `useEffect`.
- [ ] 3.6 Escrever testes unitarios.

## Detalhes de Implementacao

Seguir o padrao de silent refresh descrito na `techspec.md`. Atencao especial: a BudgetPage depende de `currentMonth` (estado derivado de `year`/`month`). O `useIonViewWillEnter` deve usar o mes corrente do state.

## Criterios de Sucesso

- Ao criar/editar um orcamento e voltar para BudgetPage, os dados atualizados aparecem sem refresh manual.
- Ao inserir um gasto em outra tela e voltar para BudgetPage, o progresso do orcamento reflete o novo gasto.
- Silent refresh nao exibe skeleton nem reseta scroll.
- Erro em silent mode mantem dados anteriores visiveis.

## Testes da Tarefa

- [ ] Testes de unidade: verificar que `useIonViewWillEnter` e registrado e chama `load`.
- [ ] Testes de unidade: verificar que `load(true)` nao seta `loading` para `true`.
- [ ] Testes de unidade: verificar que erro em silent mode nao substitui `summary` por `null`.
- [ ] Testes de unidade: verificar que `hasLoadedRef` previne double-fetch na montagem.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/BudgetPage.tsx` — Arquivo principal a modificar.
- `controlai-frontend/src/services/budgetService.ts` — Service de budget.
- `controlai-frontend/src/pages/Tab1.tsx` — Referencia do padrao ja implementado na Task 1.

# Tarefa 1.0: Silent Refresh na Tab1 (Inicio)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar `useIonViewWillEnter` na Tab1 para recarregar todos os dados (notificacoes, cartoes, projecao) toda vez que a tela fica visivel. Implementar o padrao de silent refresh que mantem os dados existentes visiveis durante o recarregamento, sem exibir skeleton/loading.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir workflow padrao de implementacao com review automatico.
- `executar-review` — Code review apos implementacao.
</skills>

<requirements>
- Adicionar `useIonViewWillEnter` do `@ionic/react` na Tab1.
- Modificar as funcoes `loadNotifications`, `loadCards` e `loadProjection` para aceitar parametro `silent: boolean`.
- Quando `silent = true`: nao setar `isLoading/cardsLoading/projectionLoading` para `true`, nao setar erro em caso de falha.
- Adicionar `hasLoadedRef` para evitar double-fetch na montagem inicial.
- O `useEffect` existente continua fazendo a carga inicial com skeleton.
- O `useIonViewWillEnter` faz refresh silencioso a partir da segunda visita.
- Manter a posicao de scroll (nao alterar o DOM de forma que cause reset).
- Manter compatibilidade com o `setReloadFn` do `InvoiceProcessingContext`.
</requirements>

## Subtarefas

- [ ] 1.1 Importar `useIonViewWillEnter` do `@ionic/react` na Tab1.
- [ ] 1.2 Adicionar `hasLoadedRef` (useRef) para controlar se ja houve carga inicial.
- [ ] 1.3 Modificar `loadNotifications` para aceitar parametro `silent` e condicionar `setIsLoading` e `setErrorMessage`.
- [ ] 1.4 Modificar `loadCards` para aceitar parametro `silent` e condicionar `setCardsLoading` e `setCardsError`.
- [ ] 1.5 Modificar `loadProjection` para aceitar parametro `silent` e condicionar `setProjectionLoading`.
- [ ] 1.6 Adicionar `useIonViewWillEnter` que chama as 3 funcoes de load com `silent = true`, condicionado ao `hasLoadedRef`.
- [ ] 1.7 Setar `hasLoadedRef.current = true` apos a carga inicial no `useEffect`.
- [ ] 1.8 Escrever testes unitarios.

## Detalhes de Implementacao

Seguir o padrao de silent refresh descrito na `techspec.md`, secao "Interfaces Principais". A Tab1 tem 3 funcoes de load independentes que devem ser adaptadas individualmente. Referencia: `ScannerPage.tsx` ja usa `useIonViewWillEnter` no projeto.

## Criterios de Sucesso

- Ao navegar para ManualEntryPage, inserir um gasto e voltar para Tab1, a lista de compras mostra o novo registro sem refresh manual.
- Durante o silent refresh, nenhum skeleton/loading e exibido — dados anteriores permanecem visiveis.
- Se o silent refresh falhar (ex: sem conexao), os dados anteriores continuam visiveis sem exibir tela de erro.
- A posicao de scroll e mantida apos o refresh.
- Na primeira renderizacao, nao ocorre double-fetch.

## Testes da Tarefa

- [ ] Testes de unidade: verificar que `useIonViewWillEnter` e registrado e chama as funcoes de reload.
- [ ] Testes de unidade: verificar que `loadNotifications(true)` nao seta `isLoading` para `true`.
- [ ] Testes de unidade: verificar que `loadCards(true)` nao seta `cardsLoading` para `true`.
- [ ] Testes de unidade: verificar que erro em silent mode nao substitui dados existentes.
- [ ] Testes de unidade: verificar que `hasLoadedRef` previne double-fetch na montagem.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx` — Arquivo principal a modificar.
- `controlai-frontend/src/pages/ScannerPage.tsx` — Referencia de uso de `useIonViewWillEnter`.
- `controlai-frontend/src/context/InvoiceProcessingContext.tsx` — Context com `setReloadFn` que deve ser mantido.
- `controlai-frontend/src/components/BudgetSummaryCard.tsx` — Componente filho que consome dados da Tab1.

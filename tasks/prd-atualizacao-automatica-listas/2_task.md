# Tarefa 2.0: Silent Refresh na Tab2 (Notas Fiscais)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar `useIonViewWillEnter` na Tab2 para recarregar a lista de purchase invoices toda vez que a tela fica visivel. Implementar o padrao de silent refresh identico ao da Tab1.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir workflow padrao de implementacao com review automatico.
- `executar-review` — Code review apos implementacao.
</skills>

<requirements>
- Adicionar `useIonViewWillEnter` do `@ionic/react` na Tab2.
- Modificar `loadInvoices` para aceitar parametro `silent: boolean`.
- Quando `silent = true`: nao setar `isLoading` para `true`, nao setar erro em caso de falha.
- Adicionar `hasLoadedRef` para evitar double-fetch na montagem inicial.
- Manter a posicao de scroll.
- Manter compatibilidade com o `setReloadFn` do `InvoiceProcessingContext`.
- Manter funcionalidade existente de delete com state local (swipe + confirm).
</requirements>

## Subtarefas

- [ ] 2.1 Importar `useIonViewWillEnter` do `@ionic/react` na Tab2.
- [ ] 2.2 Adicionar `hasLoadedRef` (useRef) para controlar carga inicial.
- [ ] 2.3 Modificar `loadInvoices` para aceitar parametro `silent` e condicionar `setIsLoading` e `setErrorMessage`.
- [ ] 2.4 Adicionar `useIonViewWillEnter` que chama `loadInvoices(true)` condicionado ao `hasLoadedRef`.
- [ ] 2.5 Setar `hasLoadedRef.current = true` apos a carga inicial no `useEffect`.
- [ ] 2.6 Escrever testes unitarios.

## Detalhes de Implementacao

Seguir o padrao de silent refresh descrito na `techspec.md`, secao "Interfaces Principais". Mesmo padrao da Task 1.0 mas com apenas 1 funcao de load.

## Criterios de Sucesso

- Ao excluir uma nota na Tab2, navegar para outra tab e voltar, o item excluido nao reaparece.
- Ao inserir um gasto via ManualEntryPage, navegar para Tab2, a nova nota aparece na lista.
- Silent refresh nao exibe skeleton nem reseta scroll.
- Erro em silent mode mantem dados anteriores visiveis.

## Testes da Tarefa

- [ ] Testes de unidade: verificar que `useIonViewWillEnter` e registrado e chama `loadInvoices`.
- [ ] Testes de unidade: verificar que `loadInvoices(true)` nao seta `isLoading` para `true`.
- [ ] Testes de unidade: verificar que erro em silent mode nao substitui dados existentes.
- [ ] Testes de unidade: verificar que `hasLoadedRef` previne double-fetch na montagem.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab2.tsx` — Arquivo principal a modificar.
- `controlai-frontend/src/pages/Tab1.tsx` — Referencia do padrao ja implementado na Task 1.

# Tarefa 4.0: Silent Refresh em CategoriesPage e PaymentMethodsPage

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar `useIonViewWillEnter` nas telas de configuracao (CategoriesPage e PaymentMethodsPage) para recarregar os dados ao retornar. Ambas seguem o mesmo padrao de silent refresh.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir workflow padrao de implementacao com review automatico.
- `executar-review` — Code review apos implementacao.
</skills>

<requirements>
- Adicionar `useIonViewWillEnter` do `@ionic/react` em ambas as paginas.
- **CategoriesPage:** Modificar `loadData` para aceitar parametro `silent`. Quando silent, nao setar `isLoading`.
- **PaymentMethodsPage:** Modificar `loadData` para aceitar parametro `silent`. Quando silent, nao setar `isLoading`.
- Adicionar `hasLoadedRef` em ambas as paginas para evitar double-fetch.
- Manter posicao de scroll em ambas.
- Manter funcionalidades existentes: formularios de create/edit, confirm dialogs, toasts.
</requirements>

## Subtarefas

- [ ] 4.1 **CategoriesPage:** Importar `useIonViewWillEnter`, adicionar `hasLoadedRef`, modificar `loadData` com parametro `silent`, adicionar hook.
- [ ] 4.2 **PaymentMethodsPage:** Importar `useIonViewWillEnter`, adicionar `hasLoadedRef`, modificar `loadData` com parametro `silent`, adicionar hook.
- [ ] 4.3 Escrever testes unitarios para CategoriesPage.
- [ ] 4.4 Escrever testes unitarios para PaymentMethodsPage.

## Detalhes de Implementacao

Seguir o padrao de silent refresh descrito na `techspec.md`. Ambas as paginas tem estrutura identica (`loadData` com `useEffect`), tornando a aplicacao do padrao direta. Nota: estas paginas nao sao tabs (sao rotas filhas), mas `useIonViewWillEnter` funciona em qualquer componente mapeado por rota no `IonRouterOutlet`.

## Criterios de Sucesso

- Ao criar/editar/excluir uma categoria e voltar para CategoriesPage, a lista reflete a mudanca.
- Ao criar/editar/excluir um metodo de pagamento e voltar para PaymentMethodsPage, a lista reflete a mudanca.
- Silent refresh nao exibe skeleton nem reseta scroll em nenhuma das paginas.
- Erro em silent mode mantem dados anteriores visiveis.

## Testes da Tarefa

- [ ] Testes de unidade (CategoriesPage): verificar que `useIonViewWillEnter` e registrado e chama `loadData`.
- [ ] Testes de unidade (CategoriesPage): verificar que `loadData(true)` nao seta `isLoading` para `true`.
- [ ] Testes de unidade (PaymentMethodsPage): verificar que `useIonViewWillEnter` e registrado e chama `loadData`.
- [ ] Testes de unidade (PaymentMethodsPage): verificar que `loadData(true)` nao seta `isLoading` para `true`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/CategoriesPage.tsx` — Arquivo a modificar.
- `controlai-frontend/src/pages/PaymentMethodsPage.tsx` — Arquivo a modificar.
- `controlai-frontend/src/services/categoryService.ts` — Service de categorias.
- `controlai-frontend/src/services/paymentMethodService.ts` — Service de metodos de pagamento.

# Tarefa 5.0: Silent Refresh no PurchaseDetail

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar `useIonViewWillEnter` no PurchaseDetail para recarregar os dados do detalhe ao retornar a tela. Implementar o padrao de silent refresh.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir workflow padrao de implementacao com review automatico.
- `executar-review` — Code review apos implementacao.
</skills>

<requirements>
- Adicionar `useIonViewWillEnter` do `@ionic/react` no PurchaseDetail.
- Modificar a funcao `load` para aceitar parametro `silent: boolean`.
- Quando `silent = true`: nao setar loading para `true`, nao setar erro em caso de falha.
- Adicionar `hasLoadedRef` para evitar double-fetch na montagem inicial.
- Manter a posicao de scroll.
- Manter funcionalidades existentes: edicao de categoria, exclusao, etc.
- Considerar que PurchaseDetail recebe `type` e `id` via `useParams` — o `useIonViewWillEnter` deve usar os params correntes.
</requirements>

## Subtarefas

- [x] 5.1 Importar `useIonViewWillEnter` do `@ionic/react` no PurchaseDetail.
- [x] 5.2 Adicionar `hasLoadedRef` (useRef) para controlar carga inicial.
- [x] 5.3 Modificar `load` para aceitar parametro `silent` e condicionar loading e erro.
- [x] 5.4 Adicionar `useIonViewWillEnter` que chama `load(true)` condicionado ao `hasLoadedRef`.
- [x] 5.5 Garantir que `useParams` retorna valores correntes dentro do callback (usar ref se necessario para evitar stale state).
- [x] 5.6 Escrever testes unitarios.

## Detalhes de Implementacao

Seguir o padrao de silent refresh descrito na `techspec.md`. Atencao especial: o PurchaseDetail depende de `useParams` (`type` e `id`). Ha issues reportados no Ionic (#23388) sobre stale state dentro de `useIonViewWillEnter`. Se necessario, armazenar os params em refs para garantir valores atuais.

## Criterios de Sucesso

- Ao editar a categoria de um gasto no PurchaseDetail (via CategoryBottomSheet), sair e voltar, os dados refletem a edicao.
- Silent refresh nao exibe skeleton nem reseta scroll.
- Erro em silent mode mantem dados anteriores visiveis.
- Os params de rota (`type`/`id`) sao lidos corretamente dentro do `useIonViewWillEnter`.

## Testes da Tarefa

- [ ] Testes de unidade: verificar que `useIonViewWillEnter` e registrado e chama `load`.
- [ ] Testes de unidade: verificar que `load(true)` nao seta loading para `true`.
- [ ] Testes de unidade: verificar que erro em silent mode nao substitui dados existentes.
- [ ] Testes de unidade: verificar que params de rota sao usados corretamente no refresh.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/PurchaseDetail.tsx` — Arquivo principal a modificar.
- `controlai-frontend/src/services/purchaseService.ts` — Service de purchase.
- `controlai-frontend/src/services/paymentMethodService.ts` — Service de payment (usado para notifications).

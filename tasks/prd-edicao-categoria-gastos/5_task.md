# Tarefa 5.0: Frontend — Edicao de categoria na listagem (Tab1/PurchaseList)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar exibicao de categoria e edicao inline na listagem principal de gastos (Tab1). Cada item da lista exibe um badge com a categoria atual (ou indicador "sem categoria"). Ao tocar no badge, abre o `CategoryBottomSheet`, salva a selecao via API e atualiza o item na lista sem reload completo.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- Cada item na listagem (PurchaseList) deve exibir a categoria atual como badge/chip
- Se sem categoria, exibir indicador visual distinto (ex: badge cinza "Sem categoria" ou icone de tag vazia)
- Ao tocar no badge de categoria, abrir o `CategoryBottomSheet`
- Ao selecionar categoria, chamar `updatePaymentNotificationCategory(id, categoryId)`
- Atualizar apenas o item modificado na lista (sem recarregar todos os dados)
- Feedback visual breve confirmando a alteracao (ex: flash/highlight no item)
- O toque no badge de categoria NAO deve navegar para o detalhe (event.stopPropagation)
</requirements>

## Subtarefas

- [ ] 5.1 Adicionar badge/chip de categoria em cada item do `PurchaseList`
- [ ] 5.2 Adicionar estado para controlar qual notification esta com bottom sheet aberto
- [ ] 5.3 Integrar `CategoryBottomSheet` no Tab1/PurchaseList
- [ ] 5.4 Implementar handler que salva categoria via API e atualiza o item na lista
- [ ] 5.5 Implementar `stopPropagation` no toque do badge para evitar navegacao
- [ ] 5.6 Adicionar feedback visual de confirmacao (highlight temporario)
- [ ] 5.7 Escrever testes unitarios

## Detalhes de Implementacao

Consultar a secao **"Sequenciamento de Desenvolvimento"** (etapa 5) da `techspec.md`.

**Padrao de referencia:** O componente `PurchaseList.tsx` renderiza cada item com nome e subtitulo. O badge de categoria deve ser adicionado na area de subtitulo ou como elemento separado abaixo.

**Atualizacao inline na lista:** Ao receber a resposta da API, atualizar o array de notifications em Tab1 usando `setNotifications(prev => prev.map(n => n.id === id ? { ...n, categoryId, category } : n))`.

## Criterios de Sucesso

- Badge de categoria visivel em cada item da listagem
- Itens sem categoria exibem indicador visual distinto
- Toque no badge abre bottom sheet (sem navegar para detalhe)
- Selecao salva e atualiza o item inline
- Lista nao recarrega completamente apos alteracao
- Testes passam

## Testes da Tarefa

- [ ] Testes de unidade: badge de categoria renderiza com nome correto
- [ ] Testes de unidade: itens sem categoria exibem indicador "sem categoria"
- [ ] Testes de unidade: toque no badge abre bottom sheet
- [ ] Testes de unidade: stopPropagation impede navegacao
- [ ] Testes de unidade: selecao atualiza item na lista

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Modificar:**
- `src/pages/Tab1.tsx` (no projeto controlai-frontend)
- `src/components/PurchaseList.tsx` (no projeto controlai-frontend)

**Dependencia:**
- `src/components/CategoryBottomSheet.tsx` (task 3.0)
- `src/services/purchaseService.ts` — funcao `updatePaymentNotificationCategory` (task 2.0)

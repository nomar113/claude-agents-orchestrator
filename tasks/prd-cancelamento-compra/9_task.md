# Tarefa 9.0: PurchaseList — IonItemSliding + Swipe

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Migrar a lista de compras do swipe customizado (touch events) para o componente `IonItemSliding` do Ionic, com acoes de "Cancelar" (amber, lado start) e "Excluir" (vermelho, lado end).

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de componentes Ionic do projeto.
</skills>

<requirements>
- Remover logica de swipe customizado (touch events, estado `swiped`, CSS de transform)
- Substituir por `IonItemSliding` com `IonItemOptions` e `IonItemOption`
- Lado start (swipe direita→esquerda): botao "Excluir" vermelho (manter funcionalidade existente)
- Lado end (swipe esquerda→direita): botao "Cancelar" amber
- Ao clicar "Cancelar": exibir dialog de confirmacao (RF-04, RF-05)
- Ao confirmar: chamar `cancelNotification(id)` ou `cancelInvoice(id)`
- Apos confirmacao: fechar slide e atualizar item na lista com estado cancelado
- Nao exibir opcao "Cancelar" para itens ja cancelados
</requirements>

## Subtarefas

- [ ] 9.1 Remover logica de touch events customizada (onTouchStart, onTouchEnd, estado swiped)
- [ ] 9.2 Remover CSS de swipe customizado (.ctrl-swipe-row, .swiped, .ctrl-delete-action)
- [ ] 9.3 Implementar `IonItemSliding` envolvendo cada item da lista
- [ ] 9.4 Adicionar `IonItemOptions side="end"` com opcao "Excluir" (vermelho)
- [ ] 9.5 Adicionar `IonItemOptions side="start"` com opcao "Cancelar" (amber)
- [ ] 9.6 Implementar dialog de confirmacao antes de cancelar (usar IonAlert ou ConfirmDialog existente)
- [ ] 9.7 Chamar API de cancelamento e atualizar estado local apos sucesso
- [ ] 9.8 Ocultar opcao "Cancelar" para itens com `cancelledAt` preenchido

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Visao Geral dos Componentes > PurchaseList.tsx"

O `IonItemSliding` suporta multiplos `IonItemOptions` em lados diferentes. Cada `IonItemOption` recebe `color` e `onClick`.

Dialog de confirmacao (RF-04): "Cancelar esta compra? A compra sera marcada como cancelada e o valor nao sera contabilizado nos seus gastos." Opcoes: "Voltar" e "Cancelar".

## Criterios de Sucesso

- Swipe para esquerda revela botao "Excluir" vermelho
- Swipe para direita revela botao "Cancelar" amber
- Dialog de confirmacao aparece antes de cancelar
- Apos cancelar, item reflete novo estado (sera estilizado na Task 12)
- Itens ja cancelados nao mostram opcao "Cancelar" no swipe
- Funcionalidade de exclusao continua funcionando normalmente

## Testes da Tarefa

- [ ] Teste manual: verificar que swipe funciona em ambas as direcoes
- [ ] Teste manual: confirmar cancelamento atualiza o item
- [ ] Teste manual: verificar que itens cancelados nao tem opcao "Cancelar"
- [ ] Verificar que nao ha regressao na funcionalidade de exclusao

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PurchaseList.tsx`
- `src/components/PurchaseList.css` (ou `src/pages/Tab1.css` para estilos de swipe)
- `src/components/ConfirmDialog.tsx` (dialog existente de confirmacao)
- `src/services/purchaseService.ts`

### Referencia Visual

Artboard "Cancelamento — Acao + Confirmacao" no Paper (arquivo "ControlAI")

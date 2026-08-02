# Tarefa 6.0: SuggestionsPage — Modal de Confirmacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Modificar a `SuggestionsPage` para que ao tocar numa sugestao, em vez de navegar para outra pagina, abra um modal de confirmacao inline (`ConfirmDialog`) com resumo lado-a-lado do invoice e da notification. Ao confirmar, chama o PATCH de associacao e redireciona para o PurchaseDetail.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- Ao tocar numa sugestao, abrir `ConfirmDialog` (componente existente) na propria pagina
- Modal exibe resumo do invoice (merchant, valor, data) e da notification (merchant, valor, data, cartao)
- Botao "Cancelar" fecha o modal
- Botao "Confirmar" chama `associateInvoice()` do service
- Durante chamada API: botao em loading/disabled
- Sucesso: redirecionar para PurchaseDetail do invoice (`/purchase/invoice/{id}`)
- Erro: exibir mensagem de erro no modal (409 = "Pagamento ja associado a outra nota")
- Manter navegacao para `/purchase/invoice/:id/associate` apenas no botao "Associar manualmente"
</requirements>

## Subtarefas

- [x] 6.1 Adicionar state para controlar modal: `selectedSuggestion`, `showConfirm`, `isAssociating`, `associateError`
- [x] 6.2 Modificar `handleSuggestionTap` para abrir modal em vez de navegar
- [x] 6.3 Renderizar `ConfirmDialog` com resumo lado-a-lado (invoice vs notification)
- [x] 6.4 Implementar `handleConfirmAssociation` — chama API, trata sucesso/erro
- [x] 6.5 Manter `handleManualAssociation` navegando para `/purchase/invoice/:id/associate`

## Detalhes de Implementacao

Consultar a secao **Fluxo de dados** da `techspec.md`. Reusar o componente `ConfirmDialog.tsx` existente, que ja tem props `title`, `subtitle`, `confirmLabel`, `onCancel`, `onConfirm`. Pode ser necessario estender o ConfirmDialog com `children` ou criar um dialog customizado para exibir o resumo lado-a-lado.

## Criterios de Sucesso

- Tap em sugestao abre modal de confirmacao (nao navega)
- Modal exibe dados corretos do invoice e notification
- Confirmar chama API e redireciona ao PurchaseDetail
- Cancelar fecha modal sem efeitos colaterais
- Erro 409 exibe mensagem adequada
- "Associar manualmente" continua navegando para pagina de busca
- Testes passam

## Testes da Tarefa

- [x] Teste unitario: tap em sugestao abre modal
- [x] Teste unitario: confirmar chama `associateInvoice` com IDs corretos
- [x] Teste unitario: cancelar fecha modal
- [x] Teste unitario: erro 409 exibe mensagem
- [x] Teste unitario: "Associar manualmente" navega para /associate

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/SuggestionsPage.tsx` (modificar)
- `src/pages/SuggestionsPage.css` (modificar se necessario)
- `src/components/ConfirmDialog.tsx` (referencia, possivelmente estender)
- `src/services/purchaseService.ts` (importar `associateInvoice`)

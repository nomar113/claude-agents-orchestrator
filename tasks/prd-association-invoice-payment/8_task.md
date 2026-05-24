# Tarefa 8.0: PurchaseDetail — Secao Pagamento Associado

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Modificar o `PurchaseDetail.tsx` para exibir informacoes do pagamento associado quando o invoice tem uma notification vinculada, e permitir desassociacao. Quando nao ha associacao, manter o botao "Associar Pagamento" existente.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- Quando invoice tem `paymentNotificationId`: exibir secao "Pagamento Associado" com:
  - Icone de cartao
  - Nome do estabelecimento da notification
  - Valor da notification
  - Data da notification
  - Ultimos digitos do cartao
  - Botao "Remover associacao" com confirmacao (ConfirmDialog)
- Ao remover: chamar `disassociateInvoice()`, atualizar estado local, exibir botao "Associar Pagamento" novamente
- Quando nao tem associacao: manter botao "Associar Pagamento" existente (ja implementado)
- Backend deve retornar dados da notification associada no endpoint GET `/purchases/invoices/{id}`
  - Verificar se o endpoint ja retorna esses dados ou se precisa ser ajustado
</requirements>

## Subtarefas

- [x] 8.1 Verificar/ajustar endpoint GET invoice para retornar dados da notification associada
- [x] 8.2 Atualizar tipo de response no frontend para incluir dados da notification associada
- [x] 8.3 Criar secao "Pagamento Associado" no PurchaseDetail (card com dados da notification)
- [x] 8.4 Implementar botao "Remover associacao" com ConfirmDialog de confirmacao
- [x] 8.5 Implementar chamada `disassociateInvoice()` e atualizar estado local
- [x] 8.6 Condicional: exibir secao associada OU botao "Associar Pagamento"
- [x] 8.7 Adicionar estilos CSS para a secao de pagamento associado

## Detalhes de Implementacao

Consultar a secao **Visao Geral dos Componentes > PurchaseDetail.tsx** da `techspec.md`. A secao de pagamento associado deve ser inserida antes do botao "Associar Pagamento" existente (linha ~615 do PurchaseDetail.tsx). Usar `.pd-` como prefixo CSS. Reusar `ConfirmDialog` para confirmacao de remocao.

**Nota:** Pode ser necessario ajustar o backend para incluir dados da notification no response do GET invoice. Se o endpoint atual nao retorna esses dados, adicionar um join ou campo extra no `PurchaseInvoiceDetailResponse`.

## Criterios de Sucesso

- Invoice com associacao exibe secao com dados da notification
- Invoice sem associacao exibe botao "Associar Pagamento"
- Botao "Remover associacao" abre confirmacao
- Confirmar remocao chama API e atualiza UI (esconde secao, mostra botao)
- Dados da notification exibidos corretamente (merchant, valor, data, cartao)
- Testes passam

## Testes da Tarefa

- [x] Teste unitario: invoice com associacao renderiza secao de pagamento
- [x] Teste unitario: invoice sem associacao renderiza botao "Associar Pagamento"
- [x] Teste unitario: botao "Remover" abre confirmacao
- [x] Teste unitario: confirmar remocao chama `disassociateInvoice`
- [x] Teste unitario: apos remocao, botao "Associar Pagamento" aparece
- [x] Teste integracao: fluxo completo de exibicao e remocao

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/PurchaseDetail.tsx` (modificar)
- `src/pages/PurchaseDetail.css` (modificar)
- `src/services/purchaseService.ts` (importar `disassociateInvoice`)
- `src/components/ConfirmDialog.tsx` (reusar)
- Backend: `PurchaseInvoiceController.kt` e `PurchaseInvoiceDetailResponse.kt` (possivelmente modificar)

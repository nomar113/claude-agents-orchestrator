# Tarefa 8.0: Frontend — Integração em PurchaseDetail e testes E2E

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar `InvoiceSuggestionsSection` e `InvoiceAssociatedSection` no `PurchaseDetail.tsx`, conectar ao service real, implementar a transição in-place ao associar e gerenciar o estado local de sugestões descartadas. Esta é a tarefa final que une todos os componentes e valida a feature end-to-end. Depende das Tarefas 4.0, 5.0, 6.0 e 7.0.

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — gerenciamento de estado com `useState`; chamadas assíncronas com feedback imediato; atualização otimista de UI apenas após confirmação da API.
- `ionic-design` — manter consistência visual com o restante do `PurchaseDetail`.
</skills>

<requirements>
- Em `PurchaseDetail.tsx`, após a seção PARCELAS, renderizar (apenas para notificações, não para compras comuns):
  - Se `notification.associatedInvoice` está populado → `<InvoiceAssociatedSection invoice={...} />` (RF-08, RF-09, RF-10).
  - Senão → buscar sugestões via `getNotificationInvoiceSuggestions` e renderizar `<InvoiceSuggestionsSection suggestions={...} onAssociate={...} onDismiss={...} />` (RF-01, RF-02).
- `onAssociate(invoiceId)`:
  - Chamar `associateNotificationToInvoice(notificationId, invoiceId)`.
  - Após sucesso da API, atualizar o estado local: substituir a seção de sugestão pela seção de NF associada (transição in-place, RF-05, RF-10).
  - Sem navegação — a atualização ocorre na mesma tela.
- `onDismiss(invoiceId)`:
  - Adicionar o `invoiceId` ao estado local `dismissedInvoiceIds: Set<number>` (RF-06).
  - Sem chamada à API.
- Quando não há sugestões e não há `associatedInvoice`, nenhuma seção é exibida (RF-07).
- Estado de loading enquanto `getNotificationInvoiceSuggestions` está em andamento.
</requirements>

## Subtarefas

- [ ] 8.1 Adicionar chamada a `getNotificationInvoiceSuggestions` em `PurchaseDetail` (somente para notificações)
- [ ] 8.2 Renderizar `InvoiceAssociatedSection` quando `associatedInvoice` está populado
- [ ] 8.3 Renderizar `InvoiceSuggestionsSection` quando há sugestões
- [ ] 8.4 Implementar `onAssociate`: chamar API e atualizar estado in-place
- [ ] 8.5 Implementar `onDismiss`: adicionar ao `dismissedInvoiceIds` local
- [ ] 8.6 Garantir que nenhuma seção é exibida quando não há sugestões nem associação
- [ ] 8.7 Escrever testes E2E com Playwright (3 fluxos principais)
- [ ] 8.8 Verificar que typecheck, lint e build passam sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seção "Sequenciamento de Desenvolvimento" (passo 6) e "Decisões Principais" (atualização in-place, `dismissedInvoiceIds` em estado React).

Ver `prd.md` — seção "Experiência do Usuário" (fluxo principal, fluxo de ignorar, fluxo pós-associação).

## Criterios de Sucesso

- Abrir notificação sem NF associada e com candidatas: seção de sugestão aparece abaixo de PARCELAS.
- Clicar "Associar": API é chamada; seção de sugestão é substituída por "NF Associada" sem navegação (RF-05, RF-10).
- Clicar "Ignorar": item desaparece na sessão; reabrir a tela → item volta (RF-06).
- Reabrir notificação já associada: exibe diretamente a seção verde (RF-08).
- Sem candidatas e sem associação: nenhuma seção é renderizada (RF-07).
- Testes E2E dos 3 fluxos passam.

## Testes da Tarefa

- [ ] Testes de integração: `PurchaseDetail.test.tsx`
  - Renderiza `InvoiceSuggestionsSection` quando há sugestões e sem associação
  - Renderiza `InvoiceAssociatedSection` quando `associatedInvoice` está populado
  - Não renderiza seção quando sem sugestões e sem associação
  - Após `onAssociate` bem-sucedido: transição de sugestão → associada
- [ ] Testes E2E (Playwright): `notification-invoice-suggestion.spec.ts`
  - **Fluxo 1 — Associar**: abrir notificação sem NF → sugestão visível → clicar Associar → seção vira "NF Associada" in-place → sem navegação
  - **Fluxo 2 — Ignorar**: abrir notificação → clicar Ignorar → sugestão some → reabrir tela → sugestão volta
  - **Fluxo 3 — Revisitar**: abrir notificação já associada → exibe diretamente seção verde com campos corretos

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/PurchaseDetail.tsx` — modificado
- `src/pages/PurchaseDetail.css` — modificado (se necessário)
- `src/pages/InvoiceSuggestionsSection.tsx` — leitura (tarefa 6.0)
- `src/pages/InvoiceAssociatedSection.tsx` — leitura (tarefa 7.0)
- `src/services/purchaseService.ts` — leitura (funções da tarefa 5.0)
- `src/test/pages/PurchaseDetail.test.tsx` — modificado
- `e2e/notification-invoice-suggestion.spec.ts` — novo
- `tasks/prd-notificacao-sugestao-nf/prd.md` — referência (RF-01 a RF-10, fluxos de UX)
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência

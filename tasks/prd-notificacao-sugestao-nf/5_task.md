# Tarefa 5.0: Frontend — Tipos e funções de service

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar em `purchaseService.ts` os novos tipos TypeScript (`InvoiceSuggestionItem`, `AssociatedInvoiceSummary`) e as funções de chamada à API (`getNotificationInvoiceSuggestions`, `associateNotificationToInvoice`). Também estender `PaymentNotificationDetail` com os novos campos do backend. Sem UI nesta tarefa. Depende da Tarefa 4.0 (backend).

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — tipagem estrita, funções de service puras, sem side effects de UI.
- `kotlin-springboot` — alinhamento com os contratos de API definidos no backend.
</skills>

<requirements>
- Adicionar interfaces em `purchaseService.ts`:
  - `InvoiceSuggestionItem`: `id`, `merchantName`, `cnpj`, `totalItems`, `total`, `date`
  - `AssociatedInvoiceSummary`: mesmos campos de `InvoiceSuggestionItem`
- Estender `PaymentNotificationDetail` com `purchaseInvoiceId: number | null` e `associatedInvoice: AssociatedInvoiceSummary | null`.
- Adicionar função `getNotificationInvoiceSuggestions(notificationId: number): Promise<InvoiceSuggestionItem[]>` — chama `GET /payments/notifications/{id}/invoice-suggestions`.
- Adicionar função `associateNotificationToInvoice(notificationId: number, purchaseInvoiceId: number): Promise<PaymentNotificationDetail>` — chama `PATCH /payments/notifications/{id}/associate`.
- Usar o `httpClient` existente no projeto (padrão `CapacitorHttp` em nativo / `fetch` no browser).
</requirements>

## Subtarefas

- [ ] 5.1 Adicionar interfaces `InvoiceSuggestionItem` e `AssociatedInvoiceSummary` em `purchaseService.ts`
- [ ] 5.2 Estender `PaymentNotificationDetail` com os novos campos
- [ ] 5.3 Implementar `getNotificationInvoiceSuggestions`
- [ ] 5.4 Implementar `associateNotificationToInvoice`
- [ ] 5.5 Escrever testes unitários das funções de service com mocks do httpClient
- [ ] 5.6 Verificar que typecheck passa sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seção "Modelos de Dados" (tipos frontend) e "Endpoints de API" (caminhos e métodos HTTP).

## Criterios de Sucesso

- TypeScript compila sem erros após as alterações.
- `getNotificationInvoiceSuggestions` chama o endpoint correto e retorna a lista tipada.
- `associateNotificationToInvoice` chama o endpoint correto com o body `{ purchaseInvoiceId }` e retorna `PaymentNotificationDetail` atualizado.
- Testes unitários cobrem: resposta com lista, lista vazia, erro de rede.

## Testes da Tarefa

- [ ] Testes de unidade: `purchaseService.test.ts`
  - `getNotificationInvoiceSuggestions` — lista de sugestões retornada corretamente
  - `getNotificationInvoiceSuggestions` — lista vazia (sem erros)
  - `associateNotificationToInvoice` — retorna `PaymentNotificationDetail` com `associatedInvoice` populado
  - Erro de rede → promise rejeitada
- [ ] Testes de integração: não aplicável nesta tarefa
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/services/purchaseService.ts` — modificado
- `src/test/services/purchaseService.test.ts` — novo/modificado
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência

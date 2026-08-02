# Tarefa 5.0: Frontend Service + Rota

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar metodos de API ao `purchaseService.ts` para associar, desassociar e buscar notifications. Registrar a nova rota `/purchase/invoice/:id/associate` no `App.tsx` com placeholder temporario.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- `associateInvoice(invoiceId, paymentNotificationId)` → PATCH endpoint
- `disassociateInvoice(invoiceId)` → DELETE endpoint
- `searchNotifications(invoiceId, { amount?, startDate?, endDate? })` → GET endpoint
- Usar o mesmo padrao HTTP do service existente (Capacitor native ou fetch fallback)
- Rota `/purchase/invoice/:id/associate` registrada no App.tsx ANTES da rota generica `/purchase/:type/:id`
- Tipo `AssociateResponse` definido
</requirements>

## Subtarefas

- [x] 5.1 Adicionar tipo `AssociateResponse` em `purchaseService.ts`
- [x] 5.2 Implementar `associateInvoice()` — PATCH com body JSON
- [x] 5.3 Implementar `disassociateInvoice()` — DELETE
- [x] 5.4 Implementar `searchNotifications()` — GET com query params
- [x] 5.5 Registrar rota no `App.tsx` com componente placeholder (ou importar AssociatePage se ja existir)

## Detalhes de Implementacao

Consultar a secao **Interfaces Principais > Frontend service methods** da `techspec.md`. Seguir o padrao de `getInvoiceSuggestions` e `cancelInvoice` como referencia de chamadas HTTP.

## Criterios de Sucesso

- Metodos chamam os endpoints corretos com parametros corretos
- Rota registrada e acessivel (nao mais tela preta)
- Tipos TypeScript corretos para request/response
- Testes passam

## Testes da Tarefa

- [x] Teste unitario: `associateInvoice` chama PATCH com body correto
- [x] Teste unitario: `disassociateInvoice` chama DELETE
- [x] Teste unitario: `searchNotifications` chama GET com query params corretos
- [x] Teste manual: acessar `/purchase/invoice/1/associate` nao resulta em tela preta (rota registrada com placeholder `AssociatePagePlaceholder`)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/services/purchaseService.ts` (modificar)
- `src/App.tsx` (modificar)

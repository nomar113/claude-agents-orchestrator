# Tarefa 6.0: Frontend - Servicos com suporte a filtros e paginacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar os servicos frontend (`purchaseService.ts`) para passar query params de filtro (`month`, `startDate`, `endDate`) e paginacao (`page`, `size`) aos endpoints do backend. Criar tipo `PageResponse<T>` generico para tipar respostas paginadas.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Tipo `PageResponse<T>` com campos: `content`, `totalElements`, `totalPages`, `number`, `size`, `last`.
- `getNotifications(month, page?, size?)` → `GET /payments/notifications?month=X&page=Y&size=Z`.
- `getInvoices(params)` → `GET /purchases/invoices?month=X` ou `?startDate=X&endDate=Y` + `page/size`.
- Manter funcao existente de `loadNotifications` em Tab1 funcionando (adaptar chamada).
- Usar o `httpClient.ts` existente (httpRequest).
- Manter compatibilidade com Capacitor (CapacitorHttp).
</requirements>

## Subtarefas

- [ ] 6.1 Criar tipo `PageResponse<T>` em `src/types/` (novo arquivo ou adicionar em existente).
- [ ] 6.2 Criar/atualizar funcao `getNotifications(month: string, page?: number, size?: number)` em `purchaseService.ts`.
- [ ] 6.3 Criar/atualizar funcao `getInvoices(params: { month?: string; startDate?: string; endDate?: string; page?: number; size?: number })` em `purchaseService.ts`.
- [ ] 6.4 Garantir que query params sao construidos corretamente na URL (sem params undefined na query string).
- [ ] 6.5 Escrever testes unitarios.

## Detalhes de Implementacao

Consultar `techspec.md` secao "Modelos de Dados" para o tipo `PageResponse<T>`.

**Padrao existente de query params:** Ver `paymentMethodService.ts` → `getPaymentMethodsSummary(month)` que usa template string para montar a URL.

**Nota:** Tab1 atualmente faz fetch direto no componente (nao usa service). Ao criar a funcao `getNotifications`, a Tab1 passara a usa-la na task 7.

## Criterios de Sucesso

- `getNotifications('2026-05')` chama `GET /payments/notifications?month=2026-05&page=0&size=50`.
- `getNotifications('2026-05', 1, 20)` chama `GET /payments/notifications?month=2026-05&page=1&size=20`.
- `getInvoices({ month: '2026-05' })` chama `GET /purchases/invoices?month=2026-05&page=0&size=50`.
- `getInvoices({ startDate: '2026-01-15', endDate: '2026-02-15' })` chama URL com startDate/endDate.
- Retorno tipado como `PageResponse<PaymentNotification>` e `PageResponse<PurchaseInvoice>`.
- Funciona tanto em browser (fetch) quanto em Capacitor (CapacitorHttp).

## Testes da Tarefa

- [ ] Teste unitario: `getNotifications` monta URL correta com month.
- [ ] Teste unitario: `getNotifications` com page/size monta URL correta.
- [ ] Teste unitario: `getInvoices` com month monta URL correta.
- [ ] Teste unitario: `getInvoices` com startDate/endDate monta URL correta.
- [ ] Teste unitario: params opcionais nao incluem `undefined` na URL.
- [ ] Teste unitario: tipo de retorno e `PageResponse<T>`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/services/purchaseService.ts`
- `/controlai-frontend/src/services/httpClient.ts`
- `/controlai-frontend/src/services/paymentMethodService.ts` (referencia de padrao com month)
- `/controlai-frontend/src/types/` (para PageResponse)

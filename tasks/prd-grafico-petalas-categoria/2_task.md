# Tarefa 2.0: Frontend — estender `purchaseService.getNotifications` com `paymentMethodId` e `sort`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Estender a funcao `getNotifications` em `src/services/purchaseService.ts` (`controlai-frontend`) com os parametros opcionais `paymentMethodId?: number | null` e `sort?: 'recent' | 'amount'`, adicionados ao final da assinatura para manter retrocompatibilidade com todos os chamadores existentes. Depende da Tarefa 1.0 (backend).

<skills>
### Conformidade com Skills Padroes

- `clean-code` — assinatura clara com params opcionais no fim; montagem de query string sem duplicacao.
- `vercel-react-best-practices` — service puro, sem acoplamento a componentes.
</skills>

<requirements>
- Assinatura conforme techspec (secao "Interfaces Principais"): params novos opcionais no fim, defaults preservam comportamento atual.
- `paymentMethodId` e `sort` so entram na query string quando informados.
- Nenhum chamador existente de `getNotifications` quebra.
</requirements>

## Subtarefas

- [x] 2.1 Estender a assinatura de `getNotifications` com `paymentMethodId?: number | null` e `sort?: 'recent' | 'amount'` e incluir os params na query string quando presentes.
- [x] 2.2 Testes de unidade do service (Vitest): novos params enviados na URL quando informados; omitidos quando `undefined`/`null`; chamadas existentes inalteradas.

## Detalhes de Implementacao

Ver techspec.md, secao "Interfaces Principais" (assinatura TypeScript completa) e "Endpoints de API".

## Criterios de Sucesso

- Service monta `GET /payments/notifications?month=&categoryId=&paymentMethodId=&sort=&page=&size=` corretamente.
- Retrocompatibilidade verificada por teste (chamada sem os novos params gera a mesma URL de antes).
- `typecheck` e `test` do frontend verdes.

## Testes da Tarefa

- [x] Testes de unidade (service, mock de HTTP)
- [ ] Testes de integracao (nao aplicavel — coberto nas tarefas 6.0 e 8.0)
- [ ] Testes E2E (nao aplicavel nesta tarefa)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/services/purchaseService.ts` (+ teste)
- `controlai-frontend/src/types/*` (tipos de `PageResponse<PaymentNotification>`, consultados)

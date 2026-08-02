# Tarefa 1.0: Backend - Filtro por mes e paginacao no endpoint de Notifications

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar query params `month`, `page` e `size` ao endpoint `GET /payments/notifications` para que retorne notificacoes filtradas por mes e paginadas. Quando nenhum `month` for enviado, retorna o mes corrente.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-1.3: Alterar o mes deve atualizar a lista de ultimas compras.
- RF-1.5: O mes padrao deve ser o mes corrente.
- Endpoint deve aceitar `month` (YYYY-MM), `page` (default 0), `size` (default 50).
- Se `month` nao fornecido, usar mes corrente.
- Retornar `Page<PaymentNotificationResponse>` em vez de `List<PaymentNotificationResponse>`.
- Manter compatibilidade com soft delete (`deleted_at IS NULL`).
- Ordenacao por `purchased_at DESC`.
</requirements>

## Subtarefas

- [ ] 1.1 Criar nova query no `PaymentNotificationRepository` que filtre por range de datas e suporte `Pageable`.
- [ ] 1.2 Atualizar `PaymentNotificationController.listNotifications()` para aceitar `@RequestParam month`, `page`, `size`.
- [ ] 1.3 Implementar logica de conversao de `month` (YYYY-MM) para range de datas (startOfMonth, startOfNextMonth), usando o padrao de `GetPaymentMethodsSummaryProvider`.
- [ ] 1.4 Quando `month` for null, calcular mes corrente automaticamente.
- [ ] 1.5 Escrever testes unitarios e de integracao.

## Detalhes de Implementacao

Consultar `techspec.md` secoes:
- "Interfaces Principais" — assinatura do controller com `@RequestParam`.
- "Queries SQL" — query de notifications por mes.
- "Endpoints de API" — contrato do endpoint.

**Referencia de padrao existente:** `GetPaymentMethodsSummaryProvider.kt` ja implementa conversao de `YearMonth` para range de datas.

## Criterios de Sucesso

- `GET /payments/notifications?month=2026-05` retorna apenas notificacoes de maio/2026.
- `GET /payments/notifications` (sem params) retorna notificacoes do mes corrente.
- `GET /payments/notifications?month=2026-05&page=0&size=10` retorna pagina com ate 10 resultados.
- Resposta inclui campos de paginacao: `totalElements`, `totalPages`, `number`, `size`, `last`.
- Mes sem dados retorna pagina vazia (`content: []`, `totalElements: 0`).
- Registros com `deleted_at` preenchido nao aparecem.

## Testes da Tarefa

- [ ] Teste unitario: controller com `month` valido retorna dados filtrados.
- [ ] Teste unitario: controller sem `month` usa mes corrente.
- [ ] Teste unitario: `month` com formato invalido retorna erro 400.
- [ ] Teste unitario: paginacao com `page` e `size` retorna subset correto.
- [ ] Teste de integracao: query no banco filtra corretamente por range de datas.
- [ ] Teste de integracao: soft delete respeitado (registros deletados nao aparecem).
- [ ] Teste de integracao: ordenacao por `purchased_at DESC`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai/src/.../payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `/controlai/src/.../payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt`
- `/controlai/src/.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `/controlai/src/.../payment_methods/application/GetPaymentMethodsSummaryProvider.kt` (referencia para padrao de mes)

# Tarefa 1.0: Backend — estender `GET /payments/notifications` com `paymentMethodId` e `sort`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar dois parametros opcionais ao endpoint existente `GET /payments/notifications` no backend (`controlai`, Kotlin/Spring Boot): `paymentMethodId` (filtro por cartao, agregando compras de sub-cartoes ao cartao pai) e `sort` (`recent` default | `amount`). Mudanca retrocompativel: params omitidos preservam o comportamento atual. Destrava o filtro por cartao e as ordenacoes do `CategoryDetailSheet` (Tarefa 6.0).

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — extensao do controller/repository seguindo o padrao nativo existente (`@Query` nativa com params opcionais).
- `clean-code` — parametros nomeados, sem duplicacao de query; validacao clara do valor de `sort`.
</skills>

<requirements>
- PRD 4.5: ordenacoes "Recentes" (padrao, data decrescente) e "Maiores" (valor decrescente).
- PRD 4.6: filtro por cartao especifico do casal.
- Techspec: `paymentMethodId` agrega sub-cartoes naturalmente porque `payment_notifications.payment_method_id` referencia o cartao pai.
- Retrocompatibilidade: `paymentMethodId` e `sort` omitidos preservam o comportamento atual do endpoint.
</requirements>

## Subtarefas

- [x] 1.1 Adicionar `@RequestParam paymentMethodId: Long? = null` e `@RequestParam(defaultValue = "recent") sort: String` em `PaymentNotificationController.listNotifications` (assinatura completa na techspec, secao "Interfaces Principais").
- [x] 1.2 Estender `PaymentNotificationRepository.findByBudgetPeriods` e `countByBudgetPeriods` com clausula `AND (:paymentMethodId IS NULL OR pn.payment_method_id = :paymentMethodId)` e `ORDER BY` condicional (`purchased_at DESC` | `amount DESC`).
- [x] 1.3 Testes JUnit de repositorio: filtro por `paymentMethodId` inclui compras de sub-cartoes do metodo; `sort=amount` ordena por valor desc; `sort=recent` (default) por data desc; params omitidos preservam resultado atual.
- [x] 1.4 Testes JUnit de controller: novos params aceitos e repassados; defaults corretos.

## Detalhes de Implementacao

Ver techspec.md, secoes "Interfaces Principais" (assinatura Kotlin do controller), "Modificados (backend)" e "Endpoints de API". Sem entidade nova, sem migracao de banco.

## Criterios de Sucesso

- Endpoint filtra corretamente por cartao incluindo compras de sub-cartoes do cartao pai.
- Ordenacao por data (default) e por valor funcionam com paginacao correta.
- Chamadas existentes (sem os novos params) retornam exatamente o mesmo resultado de antes.
- Suite de testes do backend verde.

## Testes da Tarefa

- [x] Testes de unidade (controller)
- [x] Testes de integracao (repositorio com dados de sub-cartoes)
- [x] Testes E2E (nao aplicavel nesta tarefa)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`
- `controlai/application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt`
- Testes correspondentes em `src/test` (padrao existente do projeto)

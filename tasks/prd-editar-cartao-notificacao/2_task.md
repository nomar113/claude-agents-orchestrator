# Tarefa 2.0: Backend — Endpoint PATCH `/payments/notifications/{id}/payment-method`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Expor a operacao construida na Tarefa 1.0 atraves de um endpoint REST atomico em `PaymentNotificationController`, mapeando erros para HTTP status corretos, retornando `PaymentNotificationResponse` em sucesso e cobrindo o caminho com testes de controller.

<skills>
### Conformidade com Skills Padroes

- **kotlin-springboot** — controllers magros que delegam ao provider, mapeamento consistente de erros, uso de Bean Validation no body.
- **clean-code** — sem logica de dominio no controller; respeitar padrao ja existente dos endpoints `/description`, `/category`, `/purchased-at`.
</skills>

<requirements>
- Adicionar metodo `PATCH /payments/notifications/{id}/payment-method` em `PaymentNotificationController.kt`.
- Receber `@Valid @RequestBody UpdatePaymentMethodRequest` (criado na Tarefa 1.0).
- Delegar ao `UpdateNotificationPaymentMethodProvider.execute(...)`.
- Em sucesso, retornar `200 OK` com `PaymentNotificationResponse` completa.
- Mapear erros do provider:
  - notificacao inexistente -> `404 NOT_FOUND`
  - notificacao cancelada -> `409 CONFLICT`
  - paymentMethodId inexistente OU subCardId nao pertence -> `400 BAD_REQUEST`
  - falha inesperada -> `500 INTERNAL_SERVER_ERROR`
- Operacao deve ser idempotente: o mesmo payload pode ser enviado N vezes sem efeito colateral alem do primeiro save.
- Log estruturado deve aparecer no nivel do provider (ver Tarefa 1.0); controller nao adiciona logging extra alem do padrao do projeto.
</requirements>

## Subtarefas

- [x] 2.1 Adicionar o handler `PATCH /payments/notifications/{id}/payment-method` em `PaymentNotificationController.kt` no mesmo estilo dos endpoints irmaos.
- [x] 2.2 Garantir o mapeamento dos erros do provider para os HTTP status acima (reutilizando `@ControllerAdvice` existente ou ajustes locais).
- [x] 2.3 Escrever `PaymentNotificationControllerTest` cobrindo todos os cenarios da Tech Spec.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Endpoints de API" (path, body, response, codigos de erro) e "Visao Geral dos Componentes" (lista de arquivos modificados). NAO duplique a especificacao aqui — referencie-a.

## Criterios de Sucesso

- Endpoint respondendo com os status corretos para todos os cenarios.
- Cobertura dos testes 100% nos cenarios definidos abaixo.
- Estilo de codigo e estrutura coerentes com endpoints existentes (`/description`, `/category`, `/purchased-at`).

## Testes da Tarefa

- [x] Testes de unidade/controller — `PaymentNotificationControllerTest`:
  - 200 quando `paymentMethodId` valido sem `subCardId`
  - 200 quando `paymentMethodId` + `subCardId` validos
  - 200 quando o mesmo cartao e re-confirmado (idempotencia)
  - 400 quando `paymentMethodId` inexistente
  - 400 quando `subCardId` nao pertence ao `paymentMethod`
  - 404 quando `notificationId` inexistente
  - 409 quando notificacao esta cancelada
- [x] Testes de integracao — cenario feliz de ponta-a-ponta via `MockMvc` ou client de teste do projeto (reuso do padrao existente em outros endpoints da feature).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` (modificar)
- `application/payments_notification/entrypoint/rest/PaymentNotificationControllerTest.kt` (modificar/novo)
- `application/payments_notification/application/UpdateNotificationPaymentMethodProvider.kt` (dependencia)
- `application/payments_notification/entrypoint/rest/request/UpdatePaymentMethodRequest.kt` (dependencia)

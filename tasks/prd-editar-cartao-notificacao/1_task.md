# Tarefa 1.0: Backend — Provider + DTO de atualizacao do cartao da notificacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de aplicacao no backend (controlai) para atualizar o cartao (e o sub-cartao) de uma `PaymentNotification`. Inclui o DTO de request e o provider responsavel por orquestrar carga, validacoes, calculo do `cardLastDigits` e persistencia. O endpoint REST ainda **nao** e exposto nesta tarefa — ela e foco em logica e contratos internos com testes.

<skills>
### Conformidade com Skills Padroes

- **kotlin-springboot** — boas praticas Spring Boot + Kotlin (DI por construtor, services puros, uso correto de `@Transactional`).
- **clean-code** — provider com responsabilidade unica, sem duplicacao, validacoes explicitas, nomes alinhados ao dominio.
</skills>

<requirements>
- Criar `UpdatePaymentMethodRequest` em `application/payments_notification/entrypoint/rest/request/` com validacoes Bean Validation (`@NotNull` em `paymentMethodId`).
- Criar `UpdateNotificationPaymentMethodProvider` em `application/payments_notification/application/` seguindo o padrao "find -> validar -> copy -> save -> retornar" ja usado nos providers vizinhos (`/description`, `/category`, `/purchased-at`).
- Carregar `PaymentNotification` por id; se nao existir, retornar erro mapeavel para 404.
- Recusar atualizacao se `cancelledAt != null` (erro mapeavel para 409).
- Validar que `paymentMethodId` existe; se nao, retornar erro mapeavel para 400.
- Quando `subCardId` for informado, validar que ele pertence ao `paymentMethod` carregado; se nao, retornar erro mapeavel para 400.
- Regra de `cardLastDigits`: se `subCardId` fornecido, sobrescrever com `subCard.lastFourDigits`; se `subCardId == null`, manter o valor original da notificacao.
- Operacao deve ser idempotente: re-enviar o mesmo payload nao gera mudanca alem do save inicial.
- Provider e DTO devem ser **isolados** da camada REST nesta tarefa (controller fica para a Tarefa 2.0).
</requirements>

## Subtarefas

- [x] 1.1 Criar `UpdatePaymentMethodRequest.kt` com campos `paymentMethodId: Long` e `subCardId: Long?` e validacoes.
- [x] 1.2 Criar `UpdateNotificationPaymentMethodProvider.kt` injetando `PaymentNotificationRepository` e `PaymentMethodRepository`.
- [x] 1.3 Implementar metodo `execute(notificationId, paymentMethodId, subCardId)` cobrindo todas as regras descritas em requirements.
- [x] 1.4 Adicionar logging estruturado INFO ao final com `notificationId`, `oldPaymentMethodId`, `newPaymentMethodId`, `subCardChanged`.
- [x] 1.5 Escrever `UpdateNotificationPaymentMethodProviderTest` cobrindo todos os branches.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Arquitetura do Sistema", "Interfaces Principais" (assinatura do provider), "Regras Centrais" e "Arquivos relevantes e dependentes" para detalhes de pacotes e responsabilidades.

## Criterios de Sucesso

- Provider compilando e cobrindo 100% dos branches descritos em requirements.
- Nenhum acesso a `installments` no codigo do provider (relatorios usam join via FK conforme techspec).
- Provider sem dependencia direta de `HttpServletRequest`, ResponseEntity ou anotacoes web.

## Testes da Tarefa

- [ ] Testes de unidade — `UpdateNotificationPaymentMethodProviderTest` com mocks dos dois repositorios:
  - sucesso sem subCardId (preserva `cardLastDigits`)
  - sucesso com subCardId valido (sobrescreve `cardLastDigits` com `lastFourDigits` do sub-card)
  - idempotencia: mesmo payload duas vezes nao altera estado alem do primeiro save
  - notificacao inexistente -> erro de "not found"
  - notificacao cancelada -> erro de "conflict"
  - paymentMethodId inexistente -> erro de "bad request"
  - subCardId nao pertence ao paymentMethod -> erro de "bad request"
- [ ] Testes de integracao — diferidos para a Tarefa 2.0 (onde o controller existe).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/payments_notification/entrypoint/rest/request/UpdatePaymentMethodRequest.kt` (novo)
- `application/payments_notification/application/UpdateNotificationPaymentMethodProvider.kt` (novo)
- `application/payments_notification/application/UpdateNotificationPaymentMethodProviderTest.kt` (novo)
- `application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` (leitura)
- `application/payment_methods/.../PaymentMethodRepository.kt` (leitura)

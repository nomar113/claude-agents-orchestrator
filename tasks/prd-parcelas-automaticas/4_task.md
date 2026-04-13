# Tarefa 4.0: Backend — Integrar geracao de parcelas no createManualNotification

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Modificar o endpoint `POST /payments/notifications/manual` para que, quando `numberOfInstallments > 1`, as parcelas sejam geradas automaticamente via `CreateInstallmentsProvider`. A operacao deve ser atomica (transacional).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Modificar `PaymentNotificationController.createManualNotification()` para injetar e invocar `CreateInstallmentsProvider` quando `numberOfInstallments > 1`
- O `payment_notification.amount` armazena o valor da parcela individual (nao o total)
- A criacao do pai + parcelas deve ser atomica (`@Transactional`)
- Adicionar campo `installments: List<InstallmentResponse>` ao `PaymentNotificationResponse` (lista vazia quando nao ha parcelas)
- Manter retrocompatibilidade: requests com `numberOfInstallments = 1` continuam funcionando como antes (sem criar registros em installments)
</requirements>

## Subtarefas

- [ ] 4.1 Adicionar `@Transactional` e injecao de `CreateInstallmentsProvider` no controller
- [ ] 4.2 Invocar provider quando `numberOfInstallments > 1` apos salvar o pai
- [ ] 4.3 Adicionar campo `installments` ao `PaymentNotificationResponse`
- [ ] 4.4 Testes de integracao

## Detalhes de Implementacao

Consultar secao "Endpoints de API" da `techspec.md` para detalhes do POST modificado.

Fluxo:
1. Salvar `payment_notification` pai (como hoje)
2. Se `numberOfInstallments > 1`, chamar `createInstallmentsProvider.execute(savedId, numberOfInstallments, amount, purchasedAt)`
3. Retornar response com lista de parcelas

## Criterios de Sucesso

- POST com `numberOfInstallments: 10` cria 1 pai + 10 parcelas
- POST com `numberOfInstallments: 1` cria apenas o pai (sem parcelas)
- Se a criacao de parcelas falhar, o pai tambem deve ser revertido
- Testes existentes continuam passando

## Testes da Tarefa

- [ ] Testes de integracao: POST com `numberOfInstallments: 5` — verifica 5 registros em `installments`
- [ ] Testes de integracao: POST com `numberOfInstallments: 1` — verifica 0 registros em `installments`
- [ ] Testes de integracao: POST com `categoryId` invalido — verifica que nenhum registro foi criado (atomicidade)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `PaymentNotificationController.kt` (modificar)
- `PaymentNotificationResponse.kt` (modificar)
- `CreateInstallmentsProvider.kt` (da tarefa 3)
- `ManualPaymentNotificationRequest.kt` (referencia)

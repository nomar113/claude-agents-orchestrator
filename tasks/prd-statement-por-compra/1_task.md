# Tarefa 1.0: Generalizar a criacao de statement para compras novas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Hoje `SavePaymentNotificationProvider` so cria registros em `installments` quando `numberOfInstallments > 1`. Esta tarefa remove essa restricao: toda compra salva a partir de agora (SMS/banco e cadastro manual), independentemente do meio de pagamento, passa a gerar pelo menos 1 statement (linha em `installments`) e a garantir o planejamento do mes correspondente via `EnsureFutureBudgetGateway`. `CreateInstallmentsProvider` ja produz o resultado correto para `totalInstallments = 1` (nenhuma mudanca de calculo e necessaria ali).

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot`: seguir o padrao hexagonal ja em uso (gateway/provider) sem introduzir novos componentes.
</skills>

<requirements>
- PRD 1.1, 1.2, 1.3 (toda compra gera statement no registro, sem acao adicional do usuario).
- PRD 2.1, 2.2, 2.3 (regra de associacao ao mes/ciclo ja implementada em `BudgetPeriodCalculator`/`CreateInstallmentsProvider`; esta tarefa so precisa deixar de pular compras nao parceladas).
- PRD 2.4 (planejamento futuro criado automaticamente via `EnsureFutureBudgetGateway`, ja usado hoje para parceladas).
- Ver Tech Spec, secao "SavePaymentNotificationProvider" em Visao Geral dos Componentes e "Ordem de Construcao" item 1.
</requirements>

## Subtarefas

- [x] 1.1 Remover o guard `if (saved.numberOfInstallments > 1)` em `SavePaymentNotificationProvider.execute`, chamando `createInstallments` para toda compra salva.
- [x] 1.2 Confirmar que `createInstallments` funciona sem alteracao para `numberOfInstallments = 1` (delega a `CreateInstallmentsProvider.execute` com `totalInstallments = notification.numberOfInstallments`).
- [x] 1.3 Validar que o `ensureFutureBudgetGateway` continua sendo chamado para o(s) `YearMonth` resultante(s), inclusive no caso de 1 statement so.
- [x] 1.4 Escrever/ajustar testes unitarios e de integracao cobrindo compra a vista, Pix e dinheiro.

## Detalhes de Implementacao

Ver Tech Spec, secao "Design de Implementacao" e componente `SavePaymentNotificationProvider` em "Visao Geral dos Componentes". Nao ha mudanca de schema nem de contrato de API nesta tarefa.

## Criterios de Sucesso

- Toda nova `PaymentNotification` salva (independente de `numberOfInstallments`) gera exatamente 1 ou N linhas em `installments`, cuja soma bate com `amount` total da compra (PRD 1.3).
- Uma compra a vista/Pix/dinheiro feita perto do fechamento de um cartao de credito cai no ciclo de fatura correto (mesma logica ja validada para a 1a parcela de compras parceladas).
- Uma compra Pix/dinheiro cai sempre no mes calendario da compra.
- Planejamentos futuros necessarios sao criados automaticamente, sem excecao por meio de pagamento.

## Testes da Tarefa

- [x] Testes de unidade: `SavePaymentNotificationProviderTest` cobrindo `numberOfInstallments = 1` para CREDIT_CARD (antes/depois do fechamento), PIX e CASH.
- [x] Testes de integracao: `SavePaymentNotificationProviderIT` — compra a vista via fluxo simulado de SMS e via cadastro manual gera 1 statement automaticamente; compra Pix/dinheiro idem.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/payments_notification/application/SavePaymentNotificationProvider.kt`
- `src/test/kotlin/.../payments_notification/application/SavePaymentNotificationProviderTest.kt` (ou equivalente existente)
- `src/test/kotlin/.../payments_notification/SavePaymentNotificationProviderIT.kt` (ou equivalente existente)

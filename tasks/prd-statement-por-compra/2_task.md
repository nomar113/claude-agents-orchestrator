# Tarefa 2.0: Generalizar e gatear a rotina de backfill (InstallmentReconciliationRunner)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

`InstallmentReconciliationRunner` hoje roda em todo boot da aplicacao, mas so processa compras com `numberOfInstallments > 1`. Esta tarefa generaliza a query para cobrir toda `payment_notifications` nao cancelada/deletada (a vista, Pix, dinheiro e parceladas) e muda a forma de ativacao: em vez de rodar automaticamente em todo boot, passa a ser condicionada por uma property (`app.reconciliation.installments.run-full-backfill`), decisao ja validada com o usuario para nao colocar o backfill completo no caminho critico de toda subida futura da aplicacao. Esta tarefa entrega o mecanismo pronto e testado; a execucao real contra o historico de producao e a Tarefa 3.0.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot`: `InstallmentReconciliationRunner` continua como `ApplicationRunner` de infraestrutura de boot, sem gateway/usecase proprio (mesma justificativa da tech spec anterior).
</skills>

<requirements>
- PRD 5.1 (toda compra existente, inclusive ja paga/em meses passados, recebe seu(s) statement(s)).
- PRD 5.2 (a migracao nao altera valor total nem meio de pagamento da compra original).
- Ver Tech Spec, secao "InstallmentReconciliationRunner" em Visao Geral dos Componentes, bloco de codigo em "Interfaces Principais", e "Decisoes Principais" (gate por property em vez de Flyway Java).
</requirements>

## Subtarefas

- [x] 2.1 Generalizar `PaymentNotificationRepository`: substituir `findByGroupIdAndNumberOfInstallmentsGreaterThanAndCancelledAtIsNull`/`findDistinctGroupIdsWithInstallmentPurchases` por equivalentes sem filtro de `numberOfInstallments`.
- [x] 2.2 Ajustar `InstallmentReconciliationRunner.reconcileGroup` para processar toda notificacao nao cancelada/deletada do grupo.
- [x] 2.3 Adicionar `@ConditionalOnProperty(name = ["app.reconciliation.installments.run-full-backfill"], havingValue = "true")` na classe, com o valor default ausente/false em `application.yml`/`application.properties`.
- [x] 2.4 Confirmar que a logica de idempotencia existente (nao duplica statement ja existente, recalcula `due_date` quando necessario) continua valendo para compras a vista/Pix/dinheiro.
- [x] 2.5 Escrever/ajustar testes de integracao confirmando que, com a property desligada (default), nenhum backfill roda no boot normal.

## Detalhes de Implementacao

Ver Tech Spec, secao "Design de Implementacao" (interface do `InstallmentReconciliationRunner` gated) e "Dados". Sem alteracao de schema — a tabela `installments` ja suporta `installment_number = 1, total_installments = 1`.

## Criterios de Sucesso

- Rodar a aplicacao com a property ligada, contra uma base com compras parceladas e nao parceladas (com e sem statement previo), resulta em 100% das compras nao canceladas/deletadas com pelo menos 1 statement.
- Rodar a rotina duas vezes seguidas sobre a mesma massa produz resultado identico na segunda execucao (idempotencia).
- Com a property desligada (comportamento default), o boot normal da aplicacao nao executa nenhum backfill.

## Testes da Tarefa

- [x] Testes de unidade: cobertura da nova query generalizada do repositorio (se aplicavel via teste de repositorio).
- [x] Testes de integracao: `InstallmentReconciliationRunnerIT` estendido — roda o backfill completo duas vezes (parceladas + a vista + Pix + dinheiro, com e sem statement pre-existente) e confirma idempotencia; caso adicional confirmando que, com a property ausente/false, nada e criado.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/installments/application/InstallmentReconciliationRunner.kt`
- `application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt`
- `src/main/resources/application.yml` (ou `application.properties`)
- `src/test/kotlin/.../installments/InstallmentReconciliationRunnerIT.kt`

# Review: Task 1.0 - Generalizar a criacao de statement para compras novas

**Revisor**: AI Code Reviewer
**Data**: 2026-08-15
**Arquivo da task**: 1_task.md
**Status**: MUDANCAS SOLICITADAS

## Resumo

A mudanca funcional pedida pela Tarefa 1.0 esta correta e bem testada: o guard `if (saved.numberOfInstallments > 1)` foi removido de `SavePaymentNotificationProvider.execute`, `createInstallments(saved)` passa a ser chamado incondicionalmente, e `SavePaymentNotificationProviderTest` cobre exatamente os casos exigidos (dinheiro, Pix, cartao a vista antes/depois do fechamento, fallback sem `closingDay`). Os quatro arquivos de teste de integracao que dependiam do comportamento antigo (0 installments para compra unica) foram corrigidos de forma consistente, incluindo o ajuste de `@BeforeEach`/cleanup para remover `installments`/`budget_payment_periods`/`budget_incomes`/`budget_items`/`budgets` antes de `payment_notifications`/`payment_methods`, respeitando as FKs agora sempre exercitadas. Rodei a suite completa (`./gradlew test`) de forma independente: **513 testes, 0 falhas, 0 erros**, confirmando o numero reportado.

O problema critico desta revisao nao esta na logica da Tarefa 1.0 em si, e sim no estado do working tree onde ela foi implementada: `git status`/`git diff` no repositorio `controlai` mostram **15 arquivos alterados**, mas o resumo de entrega e o escopo da Tarefa 1.0 cobrem apenas 5 deles (`SavePaymentNotificationProvider.kt` + 4 arquivos de teste). Os outros 10 arquivos — incluindo uma migration nova (`V36__drop_current_installment_number.sql`), remocao de um endpoint REST (`PATCH /notifications/{id}/installment-number`), remocao do campo `currentInstallmentNumber` em `PaymentNotification`/`ManualPaymentNotificationRequest`/`PaymentNotificationQueueMessage`, uma nova entidade de projecao (`PaymentNotificationWithInstallmentProjection`) e a reescrita de `PaymentNotificationPeriodQueryProvider` para popular `installmentAmount`/`installmentNumberForMonth` — nao pertencem a Tarefa 1.0 nem a nenhuma das Tarefas 2.0-9.0 documentadas em `tasks.md`/`techspec.md` (a remocao do endpoint/campo nao consta em lugar nenhum do planejamento). Pior: parte desse codigo antecipado (a leitura de `installmentAmount` via `PaymentNotificationPeriodQueryProvider`, ja fiada ao endpoint `GET /payments/notifications` em producao) viola diretamente a ordem de construcao que a propria Tech Spec exige ("Simplificacao do SQL so depois do backfill" — Secao "Ordem de Construcao", item 3), porque `InstallmentReconciliationRunner` (Tarefa 2.0) ainda nao foi generalizado: ele continua filtrando `numberOfInstallments > 1`, entao nenhuma compra historica a vista/Pix/dinheiro tem `installments` ainda. Se esse working tree for commitado como esta, toda compra antiga desse tipo passara a expor `installmentAmount: null`/`installmentNumberForMonth: null` na listagem principal do app antes da migracao de backfill rodar — exatamente o risco que a Tech Spec descreve na secao "Riscos Conhecidos".

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/payments_notification/application/SavePaymentNotificationProvider.kt` | OK | 0 |
| `src/test/.../application/SavePaymentNotificationProviderTest.kt` | OK | 0 |
| `src/test/.../payments_notification/PaymentNotificationControllerTest.kt` | OK | 0 |
| `src/test/.../installments/InstallmentCreationIntegrationTest.kt` | OK | 0 |
| `src/test/.../payments_notification/PaymentNotificationCategoryIntegrationTest.kt` | OK | 0 |
| `src/test/.../purchases/PurchaseCategoryIntegrationTest.kt` | OK | 0 |
| `application/budget/application/BudgetPeriodSqlSupport.kt` | Fora de escopo | 1 (critico, ver abaixo) |
| `application/payments_notification/application/PaymentNotificationPeriodQueryProvider.kt` | Fora de escopo | 1 (critico, ver abaixo) |
| `.../entrypoint/database/model/PaymentNotification.kt` | Fora de escopo | 1 (critico, ver abaixo) |
| `.../entrypoint/queue/PaymentNotificationQueueListener.kt` | Fora de escopo | ver acima |
| `.../entrypoint/queue/model/PaymentNotificationQueueMessage.kt` | Fora de escopo | ver acima |
| `.../entrypoint/rest/PaymentNotificationController.kt` | Fora de escopo | ver acima |
| `.../entrypoint/rest/request/ManualPaymentNotificationRequest.kt` | Fora de escopo | ver acima |
| `.../entrypoint/rest/request/UpdateCurrentInstallmentNumberRequest.kt` (deletado) | Fora de escopo | ver acima |
| `.../entrypoint/rest/response/PaymentNotificationResponse.kt` | Fora de escopo | ver acima |
| `.../entrypoint/database/model/PaymentNotificationWithInstallmentProjection.kt` (novo) | Fora de escopo | ver acima |
| `src/main/resources/db/migration/V36__drop_current_installment_number.sql` (novo) | Fora de escopo | 1 (critico, ver abaixo) |
| `src/test/.../PaymentNotificationControllerIT.kt` (novo) | Fora de escopo | ver acima |
| `src/test/.../PaymentNotificationResponseMappingTest.kt` (novo) | Nao revisado em detalhe (fora de escopo) | ver acima |

## Problemas Encontrados

### Problemas Criticos

1. **Working tree contamina o commit da Tarefa 1.0 com trabalho nao planejado e fora de ordem, incluindo uma migration destrutiva e regressao potencial em producao.**
   - Arquivos: `application/budget/application/BudgetPeriodSqlSupport.kt`, `application/payments_notification/application/PaymentNotificationPeriodQueryProvider.kt`, `.../database/model/PaymentNotificationWithInstallmentProjection.kt` (novo), `.../rest/response/PaymentNotificationResponse.kt`, `src/main/resources/db/migration/V36__drop_current_installment_number.sql` (novo).
   - `PaymentNotificationPeriodQueryProvider.findByBudgetPeriods` (usado por `GET /payments/notifications`, endpoint ja em producao) foi reescrito para popular `installmentAmount`/`installmentNumberForMonth` via `LEFT JOIN installments`. Isso so e seguro depois que `InstallmentReconciliationRunner` (Tarefa 2.0) tiver rodado o backfill para compras historicas nao parceladas — o que **ainda nao aconteceu**: confirmei que `InstallmentReconciliationRunner.reconcileGroup` continua chamando `findByGroupIdAndNumberOfInstallmentsGreaterThanAndCancelledAtIsNull(groupId, 1)`, ou seja, so historicamente parceladas. Toda compra a vista/Pix/dinheiro anterior a este deploy nao tem `installments`, entao a query vai retornar `installmentAmount = null` para elas ja em producao, exatamente o cenario que a Tech Spec pede para evitar ("Simplificacao do SQL so depois do backfill" — Ordem de Construcao, item 3; "Riscos Conhecidos" — janela entre os passos 1 e 3).
   - A migration `V36__drop_current_installment_number.sql` remove a coluna `current_installment_number` de `payment_notifications` em producao. Essa coluna, o campo `currentInstallmentNumber` e o endpoint `PATCH /notifications/{id}/installment-number` que a expunha nao aparecem em nenhum lugar do PRD, da Tech Spec ou de `tasks.md` (nem nas Tarefas 2.0-9.0) — e portanto nao foi objeto de nenhuma Tech Spec/decisao registrada, nao tem migration de rollback documentada, e uma migration de `DROP COLUMN` e irreversivel sem backup.
   - Nenhum desses 10 arquivos foi mencionado no resumo de entrega da Tarefa 1.0 fornecido para esta revisao. Isso sugere que o working tree usado para implementar a Tarefa 1.0 ja continha alteracoes nao commitadas de trabalho futuro (possivelmente comecado e abandonado a meio, dado que `InstallmentReconciliationRunner` — pre-requisito logico dessas mudancas — nao foi tocado).
   - **Correcao sugerida**: antes de qualquer commit, separar (`git add` seletivo ou `git stash`/branch dedicado) exatamente os arquivos da Tarefa 1.0 (`SavePaymentNotificationProvider.kt` + os 4 testes). As demais alteracoes devem ou (a) ser descartadas se forem trabalho obsoleto/abandonado, ou (b) ser formalizadas como uma tarefa propria — com a decisao de remover `currentInstallmentNumber`/o endpoint documentada na Tech Spec — e so entao aplicadas **depois** que a Tarefa 2.0 (backfill) estiver concluida em producao, conforme a propria ordem de construcao da Tech Spec exige.

### Problemas Major

Nenhum problema major encontrado no escopo da Tarefa 1.0 propriamente dita.

### Problemas Minor

1. **Comentario da nova migration referencia tarefas ainda nao concluidas como se fossem fato consumado.**
   - Arquivo: `src/main/resources/db/migration/V36__drop_current_installment_number.sql`
   - O comentario diz `"Every installment purchase now generates its N individual installment rows (Tasks 1.0-5.0)..."`, mas as Tarefas 2.0-5.0 ainda estao `[ ]` em `tasks.md`. Isso reforca a leitura de que a migration foi escrita antecipando um estado que ainda nao existe no codebase. Mesmo que essa migration seja formalizada como tarefa propria no futuro, o comentario precisa refletir o estado real na hora do commit.

2. **`PaymentNotificationControllerTest.kt` testa um endpoint ja removido, mas essa remocao nao e assunto da Tarefa 1.0.**
   - Arquivo: `src/test/.../PaymentNotificationControllerTest.kt`, teste `PATCH installment-number returns 404 since the legacy endpoint was removed`.
   - O teste em si esta correto dado que o endpoint foi removido no working tree, mas por depender de uma mudanca fora do escopo desta tarefa (ver Problema Critico 1), ele deveria ser commitado junto com a mudanca que remove o endpoint, nao misturado ao commit da Tarefa 1.0.

## Destaques Positivos

- `SavePaymentNotificationProvider.execute` continua enxuto (< 50 linhas), com nomes claros, sem magic numbers e sem aninhamento excessivo; a mudanca em si e minima e cirurgica (`-3 +1` linhas), exatamente como a Tech Spec descreveu ("remove o guard... sem alteracao de logica em `CreateInstallmentsProvider`").
- `SavePaymentNotificationProviderTest.kt` cobre com precisao os quatro cenarios exigidos pelos Criterios de Sucesso da tarefa: parcelamento normal (regressao), dinheiro, Pix, cartao a vista respeitando o ciclo de fechamento (antes/depois do dia 10) e fallback sem `closingDay` — inclusive validando `due_date` e criacao de `budgets` futuros, nao so a contagem de `installments`.
- Os ajustes de `@BeforeEach` em `PaymentNotificationCategoryIntegrationTest.kt` e `PurchaseCategoryIntegrationTest.kt` vem acompanhados de comentarios explicando exatamente por que a ordem de `DELETE` mudou ("Every payment_notifications row now gets an installment (Task 1.0) and a budget via EnsureFutureBudgetProvider, so both must be purged before the FK-scoped deletes below") — facilita a manutencao futura desse padrao de cleanup.
- Investiguei os demais ~20 arquivos de teste que fazem `DELETE FROM payment_notifications` sem limpar `installments` antes (busca solicitada). Nenhum deles quebra hoje porque todos inserem `payment_notifications` via SQL direto (`jdbcTemplate.update("INSERT INTO ...")`) ou via `repository.save()`, nunca passando por `SavePaymentNotificationProvider`/`createInstallments` — logo nunca geram `installments` de fato. E um padrao latente-fragil (uma futura mudanca que passe a usar o fluxo real quebraria esses cleanups por FK), mas nao e uma regressao ativa introduzida por esta tarefa; nao bloqueia a aprovacao da Tarefa 1.0.
- Rodei a suite completa de forma independente (nao apenas confiei no relato): `./gradlew test` = 513 testes, 0 falhas, 0 erros, validado via XML de `build/test-results/test/*.xml`, nao so pela saida do console.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (naming, funcoes, tamanho) | OK (arquivos do escopo da Tarefa 1.0) |
| Kotlin/Spring Boot (hexagonal gateway/provider) | OK — nenhum componente novo introduzido, guard removido sem tocar `CreateInstallmentsProvider` |
| Escopo da tarefa / higiene de commit | Critico — working tree mistura Tarefa 1.0 com ~10 arquivos de trabalho futuro nao documentado |
| Testes | OK — cobertura pedida pela tarefa presente e validada (513/513 passando) |

## Recomendacoes

1. **Bloqueante**: antes de comitar, isolar exatamente os arquivos da Tarefa 1.0 (`SavePaymentNotificationProvider.kt`, `SavePaymentNotificationProviderTest.kt`, `PaymentNotificationControllerTest.kt`, `InstallmentCreationIntegrationTest.kt`, `PaymentNotificationCategoryIntegrationTest.kt`, `PurchaseCategoryIntegrationTest.kt`) e commitar so esses.
2. **Bloqueante**: decidir o destino dos outros 10 arquivos (migration V36, remocao do endpoint `installment-number`, `PaymentNotificationWithInstallmentProjection`, reescrita de `PaymentNotificationPeriodQueryProvider`, etc.) — descartar se for lixo de sessao anterior, ou formalizar como tarefa propria (com decisao registrada na Tech Spec) a ser aplicada somente depois que a Tarefa 2.0 (backfill/reconciliation generalizado) estiver concluida em producao, evitando o `installmentAmount: null` para compras historicas.
3. Ao seguir para a Tarefa 2.0, usar este achado como checklist: so generalizar `InstallmentReconciliationRunner` primeiro, confirmar via log que o backfill completou, e so depois liberar qualquer leitura agregada que dependa de `installments` existir para 100% do historico (a propria Tech Spec ja documenta essa ordem — vale so segui-la à risca).
4. Nao bloqueante: ao reintroduzir a remocao de `currentInstallmentNumber`/endpoint como tarefa formal, confirmar novamente ausencia de uso no frontend (ja verifiquei agora e nao ha `currentInstallmentNumber`/`installment-number` em `controlai-frontend/src`, mas vale reconfirmar no momento do commit real, caso o codigo mude ate la).

## Veredito

A implementacao da Tarefa 1.0 em si — a remocao do guard em `SavePaymentNotificationProvider` e os testes que a acompanham — esta correta, completa e bem coberta; se o escopo fosse avaliado isoladamente (por exemplo, via `git diff` filtrado so nesses arquivos), o veredito seria APROVADO. Porem a revisao e do estado real do repositorio, e o working tree atual mistura essa mudanca com aproximadamente 10 arquivos de trabalho nao relacionado e fora de sequencia — incluindo uma migration destrutiva e um caminho de leitura em producao (`GET /payments/notifications`) que pode expor `installmentAmount: null` para compras historicas antes do backfill da Tarefa 2.0 rodar, violando a ordem de construcao explicita da propria Tech Spec. **Mudancas solicitadas**: separar o commit da Tarefa 1.0 do restante antes de prosseguir; o restante do trabalho precisa ser formalizado como tarefa e sequenciado corretamente antes de ser aplicado.

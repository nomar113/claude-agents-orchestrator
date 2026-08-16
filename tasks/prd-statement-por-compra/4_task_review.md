# Review: Task 4.0 - Simplificar a fonte unica de leitura de "gasto do mes"

**Revisor**: AI Code Reviewer
**Data**: 2026-08-16
**Arquivo da task**: 4_task.md
**Status original**: MUDANCAS SOLICITADAS
**Status apos correcoes**: APROVADO

## Atualizacao pos-review (2026-08-16)

Todos os pontos abaixo foram endereçados na mesma sessao, com confirmacao do usuario para a decisao critica:

1. **Critico (contaminacao do working tree)** — RESOLVIDO. Com decisao explicita do usuario ("descartar o trabalho orfao"), os ~10 arquivos fora de escopo herdados de sessoes anteriores (migration `V36__drop_current_installment_number.sql`, remocao do endpoint `PATCH /notifications/{id}/installment-number`, remocao de `currentInstallmentNumber`, `PaymentNotificationWithInstallmentProjection.kt`, `installmentAmount`/`installmentNumberForMonth` em `GET /payments/notifications`) foram revertidos via `git checkout`/delecao de arquivos untracked. `PaymentNotificationPeriodQueryProvider.kt` ficou com um diff de 1 linha (exatamente a subtarefa 4.4). Descoberta adicional durante a correcao: a migration V36 ja havia sido executada de fato contra o banco MySQL local usado pelos testes de integracao (nao um banco descartavel) — a coluna `current_installment_number` foi restaurada via `ALTER TABLE` e a linha da V36 removida de `flyway_schema_history`, com confirmacao do usuario antes de agir. Um teste remanescente (`PATCH installment-number returns 404...`) que havia vazado para o commit da Tarefa 1.0 tambem foi removido, por testar exatamente a funcionalidade orfa descartada.
2. **Major (gap de cobertura no sort=amount)** — RESOLVIDO. Novo teste `GET notifications with sort=amount orders by the installment due this month, not the purchase's total amount` adicionado a `PaymentNotificationFilterIntegrationTest.kt`, com uma compra parcelada (900.00 em 3x) e uma a vista (500.00) cuja ordem se inverte dependendo de `i.amount` vs `pn.amount`.
3. **Minor (comentario desatualizado)** — RESOLVIDO em `GetBudgetSummaryProviderTest.kt`.
4. **Minor (backups/ sem .gitignore)** — RESOLVIDO, `backups/` adicionado ao `.gitignore`.

Suite completa revalidada do zero (`./gradlew test --rerun-tasks`) apos todas as correcoes: **514 testes, 0 falhas, 0 erros**. `git diff --stat` final cobre exatamente os arquivos de escopo da Tarefa 4.0 + o `.gitignore`.

## Resumo

A logica pedida pela Tarefa 4.0 em si esta correta e bem implementada: `BudgetPeriodSqlSupport.INSTALLMENTS_JOIN` virou `INNER JOIN`, `PERIOD_MATCH_PREDICATE` foi reduzido a `DATE_FORMAT(i.due_date, '%Y-%m') = :yearMonth` e `AMOUNT_EXPRESSION` a `i.amount`, exatamente como o bloco de codigo da Tech Spec prescreve — confirmei por leitura direta que nenhuma das tres queries afetadas (`BudgetPeriodSqlSupport`, `GetBudgetSummaryProvider`, `PaymentNotificationPeriodQueryProvider`) contem mais `CASE`/`OR` condicionado a `number_of_installments` (grep dedicado, zero ocorrencias). `GetBudgetSummaryProvider.kt` e `GetPaymentMethodsSummaryProvider.kt` (fora do escopo, Tarefa 5.0) permanecem intocados, respeitando exatamente a fronteira que a task descreve. Os quatro arquivos de teste foram ajustados de forma consistente para inserir uma linha de `installments` companheira de cada `payment_notification` inserida via SQL cru — sem isso, o novo `INNER JOIN` faria essas fixtures desaparecerem dos totais. Recompilei (`compileKotlin`/`compileTestKotlin`, sem erros) e reexecutei a suite inteira de forma independente com `--rerun-tasks` (sem cache) contra o MySQL local, agregando os XMLs de resultado diretamente (nao apenas o console): **518 testes, 0 falhas, 0 erros**, confirmando o numero reportado.

O que impede a aprovacao simples nao e a logica da Tarefa 4.0, e sim o estado do working tree onde ela foi entregue — e isso **nao e um problema novo**: as reviews das Tarefas 1.0 e 2.0 ja haviam marcado como "Bloqueante" a presenca de ~10 arquivos fora de escopo (migration `V36__drop_current_installment_number.sql`, remocao do endpoint `PATCH /notifications/{id}/installment-number`, remocao do campo `currentInstallmentNumber`, nova entidade `PaymentNotificationWithInstallmentProjection`) misturados sem commit no `controlai`, pertencentes a nenhuma tarefa documentada em `tasks.md`. Duas tarefas depois, esse lixo continua la, intocado em sua maior parte — mas agora, pela primeira vez, ele esta **entrelacado dentro do proprio arquivo que E escopo da Tarefa 4.0** (`PaymentNotificationPeriodQueryProvider.kt`), que hoje mistura a mudanca legitima do `ORDER BY` (4.4) com a reescrita do tipo de retorno para `PaymentNotificationWithInstallmentProjection` e a adicao de `installmentAmount`/`installmentNumberForMonth` ao payload de `GET /payments/notifications` — nada disso pedido pela Tarefa 4.0. Pior: os timestamps dos arquivos mostram que parte dessa contaminacao foi **ativamente tocada hoje**, na mesma sessao da Tarefa 4.0 (`PaymentNotificationWithInstallmentProjection.kt` e o novo `PaymentNotificationControllerIT.kt` foram salvos as 08:13, minutos depois de `BudgetPeriodSqlSupport.kt` as 08:06), enquanto a migration V36 e outro teste novo (`PaymentNotificationResponseMappingTest.kt`) datam de 13/08 — ou seja, o debito nao so nao foi resolvido como foi aprofundado durante esta tarefa, apesar de ja ter sido sinalizado como bloqueante duas vezes. Ver detalhe abaixo.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/budget/application/BudgetPeriodSqlSupport.kt` | OK | 0 |
| `application/budget/application/GetBudgetSummaryProvider.kt` (nao modificado, verificado) | OK | 0 |
| `application/payment_methods/application/GetPaymentMethodsSummaryProvider.kt` (nao modificado, verificado — fora de escopo/Tarefa 5.0) | OK | 0 |
| `application/payments_notification/application/PaymentNotificationPeriodQueryProvider.kt` | Problemas | 1 (critico, mistura escopo) |
| `src/test/.../budget/BudgetCancelledExclusionTest.kt` | OK | 0 |
| `src/test/.../budget/GetBudgetSummaryProviderIntegrationTest.kt` | Problemas | 1 (minor, comentario desatualizado em arquivo irmao) |
| `src/test/.../payments_notification/PaymentNotificationFilterIntegrationTest.kt` | Problemas | 1 (major, gap de cobertura no sort=amount) |
| `.../database/model/PaymentNotificationWithInstallmentProjection.kt` (novo, tocado hoje) | Fora de escopo | 1 (critico, ver acima) |
| `src/test/.../PaymentNotificationControllerIT.kt` (novo, tocado hoje) | Fora de escopo | ver acima |
| `.../rest/PaymentNotificationController.kt`, `.../rest/response/PaymentNotificationResponse.kt`, `.../rest/request/ManualPaymentNotificationRequest.kt`, `.../database/model/PaymentNotification.kt`, `.../queue/PaymentNotificationQueueListener.kt`, `.../queue/model/PaymentNotificationQueueMessage.kt` | Fora de escopo (heranca da contaminacao ja flagada nas Tarefas 1.0/2.0) | ver acima |
| `src/main/resources/db/migration/V36__drop_current_installment_number.sql` (novo, 13/08) | Fora de escopo | ver acima |
| `src/test/.../PaymentNotificationResponseMappingTest.kt` (novo, 13/08) | Nao revisado em detalhe (fora de escopo) | ver acima |
| `backups/controlai_backup_20260816_000129.sql` (nao rastreado) | Fora de escopo, risco de higiene | 1 (minor, ver abaixo) |

## Problemas Encontrados

### Problemas Criticos

1. **Working tree mistura a Tarefa 4.0 com trabalho nao planejado, ja sinalizado como bloqueante duas vezes e agora aprofundado dentro do proprio arquivo em escopo.**
   - Arquivo principal afetado: `application/payments_notification/application/PaymentNotificationPeriodQueryProvider.kt`.
   - `findByBudgetPeriods` deveria, segundo a subtarefa 4.4, receber apenas o ajuste do `ORDER BY` (`pn.amount` → `MAX(i.amount)`). O diff real vai muito alem: o tipo de retorno do metodo mudou de `PaymentNotification` para `PaymentNotificationWithInstallmentProjection` (arquivo novo), a query passou a fazer `SELECT pn.*, MAX(i.amount) AS installment_amount, MAX(i.installment_number) AS installment_number_for_month`, e `PaymentNotificationResponse.kt` ganhou um `from(entity: PaymentNotificationWithInstallmentProjection, ...)` novo populando `installmentAmount`/`installmentNumberForMonth` no payload de `GET /payments/notifications` (endpoint ja em producao).
   - Nada disso consta em `4_task.md`, no `techspec.md` (secao "Interfaces Principais" da Tarefa 4.0) ou em `tasks.md`. O doc-comment do novo teste `PaymentNotificationControllerIT.kt` ("Tarefa 7.0") nem bate com a Tarefa 7.0 real (`tasks.md:11`, que e Frontend — fallback de valor bruto), reforcando que esse trabalho nunca foi formalizado como tarefa nenhuma do plano atual.
   - Evidencia de que isso foi tocado *nesta* sessao, nao so herdado: `stat -f "%Sm"` mostra `PaymentNotificationWithInstallmentProjection.kt` e `PaymentNotificationControllerIT.kt` salvos hoje as 08:13, a poucos minutos de `BudgetPeriodSqlSupport.kt` (08:06) e `GetBudgetSummaryProviderIntegrationTest.kt` (08:09) — todos da mesma sessao de trabalho da Tarefa 4.0. Ja `V36__drop_current_installment_number.sql` e `PaymentNotificationResponseMappingTest.kt` datam de 13/08, confirmando que sao os mesmos arquivos ja denunciados nas reviews das Tarefas 1.0/2.0, nunca removidos nem formalizados.
   - Isso repete, de forma agravada, o mesmo achado critico da review da Tarefa 1.0 ("Working tree contamina o commit... com uma migration destrutiva e regressao potencial em producao") e o achado minor da Tarefa 2.0 ("Trabalho da task 2.0 ainda nao commitado, junto com alteracoes de tarefas futuras"). Duas recomendacoes "Bloqueante" ja foram feitas para isolar/formalizar esses arquivos antes de prosseguir, e nenhuma foi endereçada — pelo contrario, a area de contaminacao cresceu (2 arquivos novos tocados hoje) e agora nao pode mais ser separada da Tarefa 4.0 por um simples `git add` seletivo de arquivo inteiro, porque o proprio `PaymentNotificationPeriodQueryProvider.kt` contem as duas mudancas (a legitima e a fora de escopo) na mesma edicao.
   - Risco concreto se commitado como esta: a migration `V36__drop_current_installment_number.sql` remove a coluna `current_installment_number` de `payment_notifications` em producao sem nenhuma decisao de Tech Spec registrada, sem rollback documentado, e destrutiva (`DROP COLUMN`) — exatamente o mesmo risco ja apontado na review da Tarefa 1.0, ainda sem solucao.
   - **Correcao sugerida**: antes de commitar a Tarefa 4.0, isolar manualmente dentro de `PaymentNotificationPeriodQueryProvider.kt` apenas a troca do `ORDER BY` (`pn.amount` → `MAX(i.amount)`), revertendo a mudanca de tipo de retorno/projecao/`installmentAmount` para o estado anterior (`List<PaymentNotification>`, `SELECT pn.*`), OU formalizar esse trabalho como uma tarefa propria (com decisao registrada na Tech Spec, dado que ele ja teria efeito em `GET /payments/notifications` em producao) e commita-lo separadamente. O mesmo vale para os demais ~9 arquivos orfaos (migration V36, remocao do endpoint, etc.) — decidir descartar ou formalizar, como ja recomendado duas vezes.

### Problemas Major

1. **Nenhum teste comprova o Criterio de Sucesso #3 da propria Tarefa 4.0 ("a listagem ordenada por 'Maiores' reflete o valor do statement, nao o valor bruto da compra").**
   - Arquivo: `src/test/kotlin/br/com/nomar/controlai/application/payments_notification/PaymentNotificationFilterIntegrationTest.kt`, teste `GET notifications with sort=amount orders by amount DESC` (linhas 222-236).
   - O teste usa exclusivamente compras de parcela unica inseridas via `insertNotification`, cujo helper (linhas 328-346) sempre cria a `installment` com `amount` identico ao `amount` da `payment_notification` (`i.amount == pn.amount`). Nessas condicoes, `ORDER BY MAX(i.amount)` e `ORDER BY pn.amount` produzem exatamente o mesmo resultado — o teste passaria de forma identica antes e depois da mudanca da subtarefa 4.4, entao nao exercita de fato a diferenca que a subtarefa introduziu.
   - Para provar o criterio de sucesso, seria necessario um cenario com uma compra parcelada cujo valor total (`pn.amount`) difira do valor da parcela do mes consultado (`i.amount`) — por exemplo, uma compra de R$ 900 em 3x (parcelas de R$ 300) misturada com uma compra a vista de R$ 500: com `pn.amount` a parcelada apareceria primeiro (900 > 500), mas com `i.amount` deveria aparecer depois (300 < 500). Nenhum teste no diff cobre esse caso.
   - Sugestao: adicionar um caso a esse teste (ou um teste dedicado) com uma compra parcelada e uma a vista cuja ordem se inverte dependendo de qual valor e usado, tornando o teste capaz de detectar uma regressao para `pn.amount`.

### Problemas Minor

1. **Comentario de `GetBudgetSummaryProviderTest.kt` ficou desatualizado apos a simplificacao, apesar de citar a propria Tarefa 4.0.**
   - Arquivo: `src/test/kotlin/br/com/nomar/controlai/application/budget/GetBudgetSummaryProviderTest.kt`, linhas 25-27 (nao modificado por este diff, mas relevante).
   - O comentario diz "Real SQL correctness (the CASE WHEN / installments JOIN added by Tarefa 4.0) is covered separately by GetBudgetSummaryProviderIntegrationTest" — mas a Tarefa 4.0 justamente **removeu** o `CASE WHEN`, entao a frase ja nasce incorreta no momento em que essa tarefa é concluída. Nao bloqueia (arquivo mockado, sem SQL real), mas e uma pequena divida de documentacao que a propria Tarefa 4.0 deveria ter corrigido, ja que ela e quem invalida a frase.
   - Sugestao: trocar para algo como "Real SQL correctness (INNER JOIN installments, amount always from the installment row) is covered separately by...".

2. **Diretorio `backups/` nao rastreado e sem entrada no `.gitignore`, contendo dump SQL de producao com dados financeiros reais.**
   - Arquivo: `backups/controlai_backup_20260816_000129.sql` (268K, nao rastreado).
   - `.gitignore` nao tem nenhuma entrada para `backups/` ou `*.sql`. Se algum `git add -A`/`git add .` futuro for executado neste repositorio, esse dump (com dados financeiros reais do casal, conforme o proposito do app) seria commitado e ficaria permanentemente no historico do git.
   - Sugestao: mover o backup para fora do repositorio (ex.: `~/backups/controlai/`) ou adicionar `backups/` ao `.gitignore` imediatamente.

## Destaques Positivos

- `BudgetPeriodSqlSupport.kt` bate exatamente com o bloco de codigo prescrito pela Tech Spec (secao "Interfaces Principais"): `INNER JOIN`, predicado reduzido a uma linha, `AMOUNT_EXPRESSION = "i.amount"` — e os KDocs foram reescritos com precisao para explicar o novo invariante ("every purchase has at least one installment row after the Tarefa 3.0 backfill"), facilitando a manutencao futura.
- Verificacao objetiva do Criterio de Sucesso #1: `grep` dedicado confirma ausencia de `CASE`/`number_of_installments` nas tres queries afetadas (`BudgetPeriodSqlSupport`, `GetBudgetSummaryProvider`, `PaymentNotificationPeriodQueryProvider`); o unico `CASE` remanescente e o `ORDER BY CASE WHEN :sort = 'amount'...`, condicionado ao parametro de ordenacao, nao a `number_of_installments`.
- Os ajustes de teste em `BudgetCancelledExclusionTest.kt` e `PaymentNotificationFilterIntegrationTest.kt` inserem corretamente uma `installment` companheira para cada `payment_notification` de fixture — sem isso, o `INNER JOIN` faria essas linhas desaparecerem silenciosamente dos resultados, quebrando os testes por um motivo errado.
- Detalhe fino bem resolvido em `BudgetCancelledExclusionTest.kt`: mesmo para a compra cancelada, o helper insere uma `installment` **ativa**. Isso mantem o teste de exclusao validando de fato o predicado `pn.cancelled_at IS NULL` em `GetBudgetSummaryProvider` (confirmado presente nas linhas 111 e 133), em vez de passar trivialmente porque o `INNER JOIN` ja teria removido a linha por falta de statement — um erro sutil de design de teste que este diff evitou corretamente.
- Nomes e comentarios de teste em `GetBudgetSummaryProviderIntegrationTest.kt` foram atualizados para refletir a nova semantica ("sums a cash purchase's single installment, the same statement path as a parceled purchase" em vez de "unaffected by the installments JOIN"), mantendo a intencao do teste legivel.
- Validacao independente e rigorosa: recompilei do zero e rodei `./gradlew test --rerun-tasks` (sem aproveitar cache) contra o MySQL local, agregando os arquivos XML de `build/test-results/test/*.xml` diretamente via script — 518 testes, 0 falhas, 0 erros, confirmando exatamente o numero reportado.
- Fronteiras de escopo corretamente respeitadas nos pontos que dependiam de disciplina do implementador: `GetBudgetSummaryProvider.kt` nao foi tocado (4.5) e `GetPaymentMethodsSummaryProvider.kt` (Tarefa 5.0) permanece intocado.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (Kotlin/nomeacao/tamanho de metodo/classe) | OK (arquivos do escopo real da Tarefa 4.0) |
| Kotlin/Spring Boot (native query, JdbcTemplate) | OK |
| Aderencia ao PRD (3.1, 3.2) | OK (nos arquivos em escopo) |
| Aderencia a Tech Spec (bloco de codigo "Interfaces Principais", Ordem de Construcao) | Problemas (ver Critico #1 — trabalho de etapas futuras da Ordem de Construcao vazando para dentro do arquivo desta etapa) |
| Escopo da tarefa / higiene de working tree | Critico — mesma contaminacao ja flagada como bloqueante nas Tarefas 1.0 e 2.0, ainda sem resolucao, agora entrelacada no proprio arquivo em escopo |
| Testes | Problemas (ver Major #1 — criterio de sucesso #3 sem cobertura especifica) |

## Recomendacoes

1. **Bloqueante**: dentro de `PaymentNotificationPeriodQueryProvider.kt`, separar a mudanca legitima da Tarefa 4.0 (`ORDER BY pn.amount` → `ORDER BY MAX(i.amount)`) do trabalho fora de escopo (tipo de retorno `PaymentNotificationWithInstallmentProjection`, colunas `installment_amount`/`installment_number_for_month`, mudancas em `PaymentNotificationResponse.kt`). Reverter a segunda parte para o estado anterior ou formaliza-la como tarefa propria antes de aplicar em `GET /payments/notifications` (endpoint ja em producao).
2. **Bloqueante** (arrastado das reviews das Tarefas 1.0/2.0, ainda pendente): decidir o destino dos demais arquivos orfaos — migration `V36__drop_current_installment_number.sql`, remocao do endpoint `PATCH /notifications/{id}/installment-number`, remocao de `currentInstallmentNumber` em `PaymentNotification`/`ManualPaymentNotificationRequest`/`PaymentNotificationQueueMessage`/`PaymentNotificationQueueListener`, e os testes novos `PaymentNotificationControllerIT.kt`/`PaymentNotificationResponseMappingTest.kt`. Descartar se for trabalho obsoleto, ou formalizar como tarefa(s) propria(s) com decisao registrada na Tech Spec.
3. Adicionar um caso de teste em `PaymentNotificationFilterIntegrationTest.kt` (ou teste dedicado) que prove o Criterio de Sucesso #3 da Tarefa 4.0: uma compra parcelada cujo valor da parcela do mes difere do valor total, ordenada corretamente por `sort=amount` contra uma compra a vista de valor intermediario.
4. Atualizar o comentario de `GetBudgetSummaryProviderTest.kt` (linhas 25-27) para nao mencionar mais "the CASE WHEN", ja removido pela propria Tarefa 4.0.
5. Mover `backups/controlai_backup_20260816_000129.sql` para fora do repositorio ou adicionar `backups/` ao `.gitignore`, evitando que um dump de producao com dados financeiros reais seja commitado por acidente.

## Veredito

Isoladamente, a logica da Tarefa 4.0 esta correta, completa e bem testada: a simplificacao de `BudgetPeriodSqlSupport` bate exatamente com a Tech Spec, os criterios de sucesso #1 e #2 foram verificados objetivamente (grep + suite completa rodada de forma independente, 518/518), e os quatro arquivos de teste foram ajustados com cuidado para o novo `INNER JOIN`, inclusive preservando a validacao fina do predicado `cancelled_at` em `BudgetCancelledExclusionTest`. Se a revisao fosse filtrada apenas para as linhas que a Tarefa 4.0 pediu, o veredito seria "aprovado com uma observacao menor sobre cobertura de teste do sort".

Mas o estado real do repositorio nao permite esse corte limpo: pela terceira vez consecutiva (apos as Tarefas 1.0 e 2.0, ambas ja tendo sinalizado isso como "Bloqueante"), o working tree mistura a tarefa atual com trabalho nao planejado e nao documentado em nenhum lugar do PRD/Tech Spec/tasks.md — e desta vez esse trabalho foi ativamente tocado durante a propria sessao da Tarefa 4.0 e esta fisicamente entrelacado dentro do arquivo `PaymentNotificationPeriodQueryProvider.kt`, que E escopo desta tarefa. Isso inclui uma migration destrutiva (`DROP COLUMN`) sem decisao registrada e uma mudanca de contrato de API ja em producao (`installmentAmount`/`installmentNumberForMonth` em `GET /payments/notifications`) nunca planejada. **Mudancas solicitadas**: isolar a mudanca real da Tarefa 4.0 de todo o restante antes de commitar, e resolver definitivamente (descartar ou formalizar como tarefa) o debito que ja deveria ter sido endereçado ha duas tarefas.

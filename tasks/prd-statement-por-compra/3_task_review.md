# Review: Task 3.0 - Executar a migracao one-off de dados existentes

**Revisor**: AI Code Reviewer
**Data**: 2026-08-16
**Arquivo da task**: 3_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

Esta e uma tarefa operacional/de verificacao (sem mudanca de logica de negocio), e foi executada corretamente na sua essencia: os pre-requisitos (Tarefas 1.0/2.0) foram confirmados como ja implementados e testados em `main` (verifiquei diretamente `InstallmentReconciliationRunner.kt` — gate por `@ConditionalOnProperty` presente, e `application.properties:19` com o default `RUN_FULL_INSTALLMENT_BACKFILL:false` correto), os commits das tres tarefas (`a9e305a`, `cbefd93`, `83d514c`) estao publicados em `origin/main` (`HEAD` == `origin/main`, confirmado via `git rev-parse`), a migracao foi executada em producao com o log de conclusao esperado (383 statements criados, 3 recalculados), a property foi desligada e o reboot seguinte confirmado sem reprocessamento, e `tasks.md`/`3_task.md` foram atualizados corretamente.

O diff de codigo (`83d514c`) e minimo e aditivo — apenas 34 linhas, todas no arquivo de teste `InstallmentReconciliationRunnerIT.kt`, nenhuma mudanca de producao — exatamente como a tarefa descreve. Recompilei e reexecutei a suite isoladamente com `--rerun-tasks` (nao aproveitando cache) contra o MySQL local: **7 testes, 0 falhas**, confirmando de forma independente o que foi reportado.

O unico ponto que impede o "APROVADO" simples e uma lacuna de definicao no novo teste `no active payment notification should be left without a statement after reconciliation` (linhas 303-314): ele confirma a existencia de *qualquer* linha em `installments`, mas nao exige que essa linha esteja ativa (`cancelled_at IS NULL`), o que diverge da definicao de "possui statement" usada em todo o resto do codebase (`BudgetPeriodSqlSupport.INSTALLMENTS_JOIN`, linha 13, e o `INNER JOIN` planejado para a Tarefa 4.0 no Tech Spec) — ver detalhe abaixo. Nao ha evidencia de que isso tenha causado um falso-negativo na migracao real (os numeros batem, 0 divergencias reportadas), mas a garantia oferecida pelo teste e mais fraca do que o nome dele promete.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/test/kotlin/br/com/nomar/controlai/application/installments/InstallmentReconciliationRunnerIT.kt` | Problemas | 1 (major) |
| `application/installments/application/InstallmentReconciliationRunner.kt` (nao modificado, verificado) | OK | 0 |
| `src/main/resources/application.properties` (nao modificado, verificado) | OK | 0 |
| `tasks/prd-statement-por-compra/tasks.md` / `3_task.md` | OK | 0 |
| Processo de deploy/migracao em producao (relatado) | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

1. **Teste de "sem orfaos" nao filtra installments cancelados, divergindo da definicao de "statement" usada no resto do codebase**
   - Arquivo: `src/test/kotlin/br/com/nomar/controlai/application/installments/InstallmentReconciliationRunnerIT.kt`, linhas 303-314 (`no active payment notification should be left without a statement after reconciliation`).
   - A query usa `LEFT JOIN installments i ON i.parent_id = pn.id` **sem** `AND i.cancelled_at IS NULL`, contando como "tem statement" qualquer `payment_notification` com pelo menos uma linha em `installments`, mesmo que essa linha esteja cancelada.
   - Isso diverge da definicao usada em todo o resto do sistema: `BudgetPeriodSqlSupport.kt:13` define `INSTALLMENTS_JOIN = "LEFT JOIN installments i ON i.parent_id = pn.id AND i.cancelled_at IS NULL"`, e o Tech Spec (secao "Interfaces Principais") especifica que o `INNER JOIN` simplificado da Tarefa 4.0 tambem filtra `AND i.cancelled_at IS NULL`. O proprio teste seguinte no mesmo arquivo (`sum of statements per active purchase...`, linha 317-334) ja filtra corretamente `WHERE cancelled_at IS NULL` na soma — ou seja, ha uma inconsistencia entre os dois testes novos quanto ao que conta como statement "ativo".
   - Cenario concreto onde isso importa: `InstallmentController.kt` (linhas 81-95, endpoint `DELETE /installments/future`, funcionalidade pre-existente e fora do escopo desta tarefa) permite cancelar as parcelas futuras de uma compra sem cancelar a `payment_notification` em si. Se todas as parcelas de uma compra ativa forem canceladas dessa forma antes da migracao rodar, essa compra passa no teste/consulta de "sem orfaos" (existe uma linha em `installments`, ainda que cancelada), mas efetivamente nao tem nenhum statement ativo contribuindo para nenhum mes — o que a Tarefa 4.0 vai tratar como "sem statement" quando o `INNER JOIN ... AND i.cancelled_at IS NULL` entrar em vigor.
   - Como o proposito explicito desta subtarefa (3.2) e servir de pre-condicao para a simplificacao da Tarefa 4.0 (ver Tech Spec, "Ordem de Construcao" item 3), a consulta de verificacao deveria usar exatamente a mesma definicao de "tem statement" que a Tarefa 4.0 vai usar — senao a garantia de "0 orfaos" nao cobre esse caso de borda.
   - Sugestao: adicionar `AND i.cancelled_at IS NULL` ao `LEFT JOIN` do teste (e, se possivel, revalidar a consulta equivalente contra producao com esse filtro corrigido antes de iniciar a Tarefa 4.0, ja que a consulta original rodada em producao tinha a mesma lacuna):
     ```kotlin
     val orphanCount = jdbcTemplate.queryForObject(
         """SELECT COUNT(*)
            FROM payment_notifications pn
            LEFT JOIN installments i ON i.parent_id = pn.id AND i.cancelled_at IS NULL
            WHERE pn.cancelled_at IS NULL AND pn.deleted_at IS NULL AND i.id IS NULL""",
         Int::class.java,
     )
     ```

### Problemas Minor

1. **Arquivo de teste ja excede o limite de 300 linhas por classe, e esta tarefa aumentou a distancia**
   - Arquivo: `InstallmentReconciliationRunnerIT.kt` (335 linhas apos esta tarefa; ja estava em 301 linhas antes dela, herdado da Tarefa 2.0). E, disparado, o maior arquivo de teste de integracao do projeto (o segundo maior tem 92 linhas).
   - Nao bloqueia — o crescimento desta tarefa foi de apenas 34 linhas e segue o padrao ja estabelecido no arquivo — mas vale considerar extrair o setup de dados (`setUp()`, ~140 linhas) para um builder/fixture compartilhado se o arquivo continuar crescendo em tarefas futuras.

2. **Tolerancia `0.01` como literal na query SQL do teste de soma**
   - Arquivo: mesma classe, linha 330 (`ABS(pn.amount - i.sum_installments) > 0.01`).
   - Numero magico dentro de uma string SQL; aceitavel neste contexto (espelha provavelmente a consulta manual rodada em producao), mas se esse padrao de comparacao com tolerancia se repetir em outros testes de reconciliacao, vale extrair para uma constante nomeada (ex.: `ROUNDING_TOLERANCE`).

## Destaques Positivos

- Conversao de verificacoes manuais de producao em testes automatizados permanentes: em vez de deixar as consultas SQL ad-hoc como um artefato descartavel de uma execucao unica, elas foram encapsuladas como testes de regressao (`InstallmentReconciliationRunnerIT`), que continuam protegendo o codebase mesmo depois que a migracao one-off ja foi concluida — exatamente o que a tarefa sugeria ("se implementada como teste automatizado").
- Diff cirurgico e sem scope creep: apenas o arquivo de teste foi tocado, nenhuma mudanca de logica de producao, consistente com a natureza operacional da tarefa 3.0 declarada no proprio `3_task.md`.
- Recomendacao da review da Tarefa 2.0 (cobertura de `deleted_at`) foi endereçada: o teste `should not create installments for a soft-deleted purchase` e o caso `deletedParentId` no `setUp()` ja estao presentes (introduzidos no commit `cbefd93`, task 2.0), fechando a lacuna apontada anteriormente antes desta migracao rodar contra dados reais.
- Disciplina de sequenciamento respeitada: a ordem prescrita pelo Tech Spec ("Ordem de Construcao" 1→2→3) foi seguida rigorosamente — o backfill (Tarefa 3.0) so rodou depois de 1.0/2.0 confirmados, e a simplificacao do `BudgetPeriodSqlSupport` (Tarefa 4.0) ainda nao foi iniciada, evitando exatamente o risco que o Tech Spec descreve ("zerar totais de compras historicas ainda sem statement").
- Numeros da migracao batem com o esperado e foram verificados por multiplos angulos (orfaos, contagem de compras, soma total, meio de pagamento nulo) antes e depois de dois restarts, com evidencia de idempotencia da property (segundo boot sem reprocessamento).
- Historico de commits limpo, um commit por tarefa, mensagem descritiva incluindo os numeros da execucao real em producao — boa rastreabilidade.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (Kotlin/nomeacao/tamanho de metodo/classe) | Problemas (ver Minor #1) |
| Kotlin/Spring Boot (JUnit5, `@SpringBootTest`, `JdbcTemplate`) | OK |
| Aderencia ao PRD (5.1, 5.2, 5.3) | OK |
| Aderencia a Tech Spec (Ordem de Construcao, Dependencias Tecnicas, Monitoramento) | Problemas (ver Major #1) |
| Testes | Problemas (ver Major #1) |

## Recomendacoes

1. (Antes de iniciar a Tarefa 4.0) Corrigir o `LEFT JOIN` do teste `no active payment notification should be left without a statement after reconciliation` para incluir `AND i.cancelled_at IS NULL`, alinhando-o com `BudgetPeriodSqlSupport.INSTALLMENTS_JOIN` e com o `INNER JOIN` planejado pela Tarefa 4.0.
2. (Antes de iniciar a Tarefa 4.0) Rerodar em producao a consulta de verificacao com esse filtro corrigido, para descartar definitivamente o cenario de compra ativa com todas as parcelas canceladas via `DELETE /installments/future` — hoje esse cenario nao foi verificado pela consulta original.
3. (Opcional) Se o arquivo de teste continuar crescendo em tarefas futuras, considerar extrair o `setUp()` para um fixture/builder compartilhado, dado que ja e o maior arquivo de teste do projeto por larga margem.
4. (Fora do escopo de codigo, mas relevante ao processo) O incidente de seguranca encontrado durante a inspecao de producao (porta MySQL 3306 exposta publicamente, com banco `RECOVER_YOUR_DATA` ja plantado por bot de extorsao) foi corretamente mitigado (backup + bind em `127.0.0.1`), mas merece tratamento proprio como incidente: confirmar que nenhum outro dado foi exfiltrado alem do banco de extorsao, considerar rotacionar credenciais do MySQL exposto, e revisar se outras portas/servicos da VPS estao com exposicao publica desnecessaria.

## Veredito

A Tarefa 3.0 cumpriu seus criterios de sucesso: a migracao foi executada em producao com coordenacao manual correta (property ligada → deploy → confirmacao via log → property desligada → confirmacao de nao-reprocessamento), sem alterar valor ou meio de pagamento de nenhuma compra (verificado por multiplas consultas antes/depois), e as verificacoes da subtarefa 3.2/3.3 foram corretamente convertidas em testes automatizados permanentes, que executei de forma independente e confirmei passando (7/7). Nao ha problemas criticos nem qualquer indicio de que a migracao real tenha deixado dados inconsistentes. A unica pendencia e uma lacuna de definicao no novo teste de "sem orfaos" (nao filtra `cancelled_at` em `installments`), que enfraquece a garantia que esse teste promete fornecer como pre-condicao da Tarefa 4.0 — recomendo corrigi-la e revalidar contra producao antes de iniciar a Tarefa 4.0, mas isso nao invalida o trabalho ja feito nem bloqueia o merge desta tarefa. Aprovado com observacoes.

# Tarefa 6.0: Mecanismo anti-regressao no backend (ArchUnit)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Esta tarefa entrega o mecanismo de verificacao automatizada exigido pelo PRD (Funcionalidade 4): um teste ArchUnit que barra qualquer classe fora de uma allowlist explicita de acessar o campo `PaymentNotification.amount` para fins de agregacao mensal. Deve ser feita por ultimo entre as tarefas de backend, quando o codigo ja esta em conformidade (Tarefas 1-5 concluidas), para nao quebrar o build no meio da migracao.

<skills>
### Conformidade com Skills Padroes

- Nenhuma skill do projeto cobre ArchUnit especificamente; seguir a convencao de testes ja usada em `src/test/kotlin` (JUnit5).
</skills>

<requirements>
- PRD 4.1 (mecanismo automatizado, executado como parte do processo de desenvolvimento, capaz de detectar leitura do valor bruto para "gasto do mes").
- PRD 4.2 (cobre no minimo todo endpoint/tela hoje listados no requisito 3.1, e qualquer ponto futuro equivalente).
- Ver Tech Spec, secao "Decisoes Principais" ("ArchUnit no backend + script grep no frontend") e "Riscos Conhecidos" ("Allowlist do ArchUnit ficar desatualizada").
</requirements>

## Subtarefas

- [ ] 6.1 Adicionar a dependencia `com.tngtech.archunit:archunit-junit5` (test scope) em `build.gradle.kts`.
- [ ] 6.2 Criar `PaymentNotificationAmountAccessTest` definindo a regra `noClasses()...accessClassesThat()`/`noFields()` barrando acesso ao campo `amount` de `PaymentNotification` fora de uma allowlist.
- [ ] 6.3 Definir e documentar (comentario no proprio teste) a allowlist inicial: criacao do statement (`CreateInstallmentsProvider`/`SavePaymentNotificationProvider`), exibicao do valor bruto na tela de detalhe da propria compra (`AssociatedPaymentResponse`/`PurchaseInvoiceDetailResponse`), e qualquer outro ponto legitimo identificado durante a auditoria da Funcionalidade 3.3.
- [ ] 6.4 Auditar o codebase (grep por `.amount` em classes que tocam `PaymentNotification`) e confirmar que, apos as Tarefas 1-5, nenhum acesso fora da allowlist permanece — corrigir se algo for encontrado.
- [ ] 6.5 Rodar o teste e confirmar que ele falha propositalmente se um acesso fora da allowlist for reintroduzido (teste negativo manual, nao commitado).

## Detalhes de Implementacao

Ver Tech Spec, secao "Dependencias Tecnicas" (nova dependencia Gradle) e "Arquivos relevantes e dependentes" (`src/test/kotlin/.../architecture/PaymentNotificationAmountAccessTest.kt`).

## Criterios de Sucesso

- O build (`./gradlew test`) falha se qualquer classe fora da allowlist acessar `PaymentNotification.amount`.
- A allowlist esta documentada no proprio arquivo de teste, com justificativa por item.
- Nenhuma classe de agregacao mensal (`GetBudgetSummaryProvider`, `GetPaymentMethodsSummaryProvider`, `PaymentNotificationPeriodQueryProvider`, `BudgetPeriodSqlSupport`) esta na allowlist.

## Testes da Tarefa

- [ ] Teste de unidade/arquitetura: `PaymentNotificationAmountAccessTest` rodando como parte da suite padrao (`./gradlew test`).
- [ ] Verificacao manual: introduzir temporariamente um acesso indevido em uma classe de teste e confirmar que o ArchUnit falha (revertido antes do commit final).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `build.gradle.kts`
- `src/test/kotlin/br/com/nomar/controlai/architecture/PaymentNotificationAmountAccessTest.kt` (novo)
- `application/payments_notification/entrypoint/database/model/PaymentNotification.kt`

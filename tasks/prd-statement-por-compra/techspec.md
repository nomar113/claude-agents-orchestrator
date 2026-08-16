# Tech Spec: Statement por Compra — Fonte Única de Verdade para Gasto do Mês

## Resumo Executivo

O backend já implementa, para compras parceladas, exatamente o conceito que o PRD chama de "statement": a tabela `installments` (parcela com valor, `due_date` resolvido pelo ciclo de fatura do cartão via `BudgetPeriodCalculator`, e status próprio via `cancelled_at`), criada em `SavePaymentNotificationProvider` e mantida por `InstallmentReconciliationRunner`. O que falta é puramente a generalização: hoje esse caminho só é acionado quando `number_of_installments > 1`; compras à vista, Pix e dinheiro (`number_of_installments == 1`) nunca ganham uma linha em `installments` e todo agregado mensal (`GetBudgetSummaryProvider`, `GetPaymentMethodsSummaryProvider`, `PaymentNotificationPeriodQueryProvider`) mantém um `CASE`/`OR` que decide entre `installments.amount` e `payment_notifications.amount` conforme esse número. A mudança central é remover o guard `if (numberOfInstallments > 1)`, gerar 1 statement por compra à vista/Pix/dinheiro (o mesmo `CreateInstallmentsProvider.execute` já produz o resultado certo para `totalInstallments = 1`, sem alteração de schema), rodar uma migração one-off que faz o mesmo para o histórico já cadastrado, e só então eliminar o `CASE`/`OR` das três leituras agregadas — que passam a fazer `INNER JOIN installments` sem branch. O nome interno `installment`/`installments` é mantido (decisão do usuário): "statement" fica como vocabulário de PRD/produto, não como rename de entidade.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **`CreateInstallmentsProvider`** (existente, sem mudança de lógica) — já calcula corretamente `due_date`/valor para `totalInstallments = 1` reaproveitando `BudgetPeriodCalculator.resolveInstallmentDueDate`, que já aplica a regra do PRD 2.1–2.3 (ciclo do cartão quando `CREDIT_CARD` com `closingDay`, calendário para `PIX`/`CASH`/cartão sem `closingDay`).
- **`SavePaymentNotificationProvider`** (modificado) — remove o guard `numberOfInstallments > 1`; toda compra salva (SMS e manual) passa a gerar seu(s) statement(s) e a garantir os planejamentos futuros necessários via `EnsureFutureBudgetGateway`, sem distinção de meio de pagamento.
- **`BudgetPeriodSqlSupport`** (modificado) — `INSTALLMENTS_JOIN` vira `INNER JOIN` (toda `payment_notifications` tem statement após a migração); `PERIOD_MATCH_PREDICATE` perde o `OR`/`CASE` por `number_of_installments`, comparando só `i.due_date`; `AMOUNT_EXPRESSION` vira simplesmente `i.amount`. Única fonte de verdade compartilhada por `GetBudgetSummaryProvider` e `PaymentNotificationPeriodQueryProvider`.
- **`GetPaymentMethodsSummaryProvider`** (modificado, corrige bug real) — hoje soma `SUM(pn.amount)` filtrando só por `purchased_at` dentro do período; passa a usar o mesmo `INNER JOIN installments` + predicate de `BudgetPeriodSqlSupport`, corrigindo o resumo por meio de pagamento para compras parceladas (hoje já mostra valor errado em produção).
- **`PaymentNotificationPeriodQueryProvider`** (modificado) — `ORDER BY ... pn.amount DESC` do sort `"amount"` passa a usar `MAX(i.amount)`, consistente com o valor exibido na listagem.
- **`InstallmentReconciliationRunner`** (modificado) — passa a considerar toda `payment_notifications` não cancelada/deletada (não só `number_of_installments > 1`); execução deixa de ser automática em todo boot e passa a ser condicionada por uma property (`app.reconciliation.installments.run-full-backfill`), decisão do usuário para não colocar o backfill completo no caminho crítico de todo boot.
- **`ArchUnitTest`** (novo, backend) — regra que barra acesso a `PaymentNotification.amount` fora de uma allowlist explícita (criação de statement, exibição do valor bruto na tela de detalhe da própria compra).
- **Script `check-raw-amount-usage`** (novo, frontend) — varre `src/` por padrões proibidos (`.amount` fora de uma allowlist de arquivos) e roda como parte do `npm run build`/CI.
- **Frontend `Tab1.tsx`, `PurchaseList.tsx`, `CategoryDetailSheet.tsx`, `purchaseService.ts`** (modificados) — removem o fallback `installmentAmount ?? amount` (o campo passa a vir sempre preenchido) e corrigem o bug do card "Total Filtrado" em `Tab1.tsx`, que hoje soma `n.amount` bruto.

## Design de Implementação

### Interfaces Principais

```kotlin
// BudgetPeriodSqlSupport — simplificação pós-migração
const val INSTALLMENTS_JOIN = "INNER JOIN installments i ON i.parent_id = pn.id AND i.cancelled_at IS NULL"
val PERIOD_MATCH_PREDICATE = "DATE_FORMAT(i.due_date, '%Y-%m') = :yearMonth"
const val AMOUNT_EXPRESSION = "i.amount"

// InstallmentReconciliationRunner — gate por property, não mais todo boot
@Component
@ConditionalOnProperty(name = ["app.reconciliation.installments.run-full-backfill"], havingValue = "true")
class InstallmentReconciliationRunner(...) : ApplicationRunner
```

### Modelos de Dados

- Sem alteração de schema. `installments` já suporta `installment_number = 1, total_installments = 1` para compras à vista/Pix/dinheiro — a migração one-off apenas insere linhas usando o `CreateInstallmentsProvider` já existente.
- `PaymentNotificationRepository`: `findByGroupIdAndNumberOfInstallmentsGreaterThanAndCancelledAtIsNull` e `findDistinctGroupIdsWithInstallmentPurchases` generalizam para `findByGroupIdAndCancelledAtIsNull`/`findDistinctGroupIds` (sem filtro por `number_of_installments`).
- `PaymentNotificationResponse.installmentAmount`/`installmentNumberForMonth` (backend) e `PaymentNotification.installmentAmount`/`installmentNumberForMonth` (frontend, `purchaseService.ts`) deixam de ser nulos na prática após a migração; o tipo TypeScript é simplificado de `number | null` para `number` como parte da limpeza da Funcionalidade 3.2 (elimina a necessidade do `??`).

### Endpoints de API

- Nenhum endpoint novo. `GET /payments/notifications` e `GET /budget/{month}/summary` mantêm o mesmo contrato; `installmentAmount`/`installmentNumberForMonth` passam a vir sempre populados em vez de nulos para compras não parceladas.
- Migração one-off: sem endpoint HTTP — ativada via property de ambiente (`app.reconciliation.installments.run-full-backfill=true`) num único deploy/restart controlado, revertida a `false` depois de confirmada pelos logs.

## Abordagem de Testes

### Testes Unidade
- `CreateInstallmentsProviderTest`: caso `totalInstallments = 1` (compra à vista/Pix/dinheiro) confirmando `due_date` igual ao já coberto para a 1ª parcela de uma compra parcelada.
- `SavePaymentNotificationProviderTest`: compra com `numberOfInstallments = 1` também dispara `createInstallments`/`ensureFutureBudgetGateway`.
- `BudgetPeriodSqlSupportTest` (ou equivalente): garante que o SQL gerado não tem mais `CASE`/`OR` condicionado a `number_of_installments`.
- Teste ArchUnit dedicado, cobrindo a allowlist de acesso a `PaymentNotification.amount`.

### Testes de Integração
- `SavePaymentNotificationProviderIT`: compra à vista via SQS e via manual gera 1 `installment`; compra Pix/dinheiro idem.
- `GetPaymentMethodsSummaryProviderIT`: total por meio de pagamento bate com a soma da listagem para compra parcelada cruzando meses (reproduz e corrige o bug atual).
- `InstallmentReconciliationRunnerIT`: roda o backfill completo duas vezes sobre a mesma massa (parceladas + à vista + Pix + dinheiro, com e sem statement pré-existente) e confirma idempotência; roda com a property desligada e confirma que nada é criado (não impacta boot normal).

### Testes de E2E
Cypress (convenção já usada no projeto, ver `techspec.md` de `prd-compras-parceladas-fechamento-fatura`). Cenário: registrar uma compra à vista no Pix, conferir que o card "Total Filtrado" da tela Início bate exatamente com a soma dos itens listados logo abaixo (regressão do bug relatado no PRD); registrar uma compra parcelada e confirmar consistência entre listagem, resumo por categoria e resumo por meio de pagamento no mesmo mês.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. `SavePaymentNotificationProvider` remove o guard `numberOfInstallments > 1` — toda compra nova (a partir de agora) já gera statement. Sem isso, a migração one-off ficaria correndo atrás de compras novas para sempre.
2. `InstallmentReconciliationRunner` generalizado (query sem filtro de `number_of_installments`) + gate por property; roda uma vez em ambiente controlado para popular o histórico. Só depois disso 100% das `payment_notifications` tem pelo menos 1 statement.
3. `BudgetPeriodSqlSupport` simplificado (`INNER JOIN`, sem `CASE`/`OR`) — depende do passo 2 estar concluído, senão compras históricas ainda sem statement somem dos totais.
4. `GetPaymentMethodsSummaryProvider` reescrito para usar `BudgetPeriodSqlSupport`; `PaymentNotificationPeriodQueryProvider` ajusta o `ORDER BY`.
5. Frontend: remove fallback `?? amount` em `Tab1.tsx` (corrige "Total Filtrado"), `CategoryDetailSheet.tsx`, `PurchaseList.tsx`; tipo `installmentAmount`/`installmentNumberForMonth` vira não-nulo.
6. Mecanismo anti-regressão por último (ArchUnit + script frontend), quando o código já está em conformidade — evita quebrar o build no meio da migração.

### Dependências Técnicas

- Nova dependência Gradle: `com.tngtech.archunit:archunit-junit5` (test scope).
- A migração one-off deve ser executada uma única vez em produção antes do passo 3 subir; requer coordenação manual de deploy (subir com a property ligada, confirmar via log `"Installment reconciliation for group..."`, redeploy com a property desligada).

## Monitoramento e Observabilidade

- `InstallmentReconciliationRunner` mantém o log INFO por grupo (criados/recalculados) já existente, único sinal de conclusão da migração one-off — sem endpoint de status dedicado.
- Sem métricas Prometheus/Grafana novas, seguindo o padrão atual do projeto (log via `LoggerFactory`).

## Considerações Técnicas

### Decisões Principais

- **Manter o nome `installment` internamente** em vez de renomear para `Statement`: o comportamento já existe e está testado sob esse nome; um rename de ~15 arquivos + tipos/testes de frontend é blast radius desproporcional para um projeto pessoal, sem ganho funcional — "statement" permanece vocabulário de PRD.
- **Migração one-off gated por property, não Flyway Java**: a lógica de backfill depende de `payment_methods.closing_day` por `group_id` e do `BudgetPeriodCalculator` via injeção de dependência — inviável em uma migração Flyway Java pura sem contexto Spring. Reaproveitar `InstallmentReconciliationRunner` como `ApplicationRunner` gated por property preserva acesso a beans e a idempotência já testada, sem deixar esse custo no boot de toda subida futura (decisão do usuário, dado que agora processa todo o histórico, não só parceladas).
- **ArchUnit no backend + script grep no frontend** para a Funcionalidade 4: ArchUnit permite expressar a regra semanticamente (`getAccessesToSelf()` no campo `amount`) em vez de casar texto; o frontend não tem equivalente, então um script de varredura por padrão textual cobre o caso mínimo (decisão do usuário).
- **Simplificação do SQL só depois do backfill**: fazer o `INNER JOIN` sem esperar o backfill completo zeraria os totais de compras históricas ainda sem statement — por isso a ordem de construção é rígida nesse ponto.

### Riscos Conhecidos

- **Janela entre os passos 1 e 3**: entre generalizar a criação de statements para compras novas e concluir o backfill/simplificação do SQL, o `CASE`/`OR` antigo continua no lugar — sem risco de regressão, mas os dois caminhos coexistem temporariamente.
- **Volume da migração one-off**: mesmo processando 100% do histórico (não só parceladas), a escala é a mesma já aceita na tech spec anterior (uso pessoal/familiar, poucas centenas de registros) — sem necessidade de paginação ou processamento em lote.
- **Allowlist do ArchUnit ficar desatualizada**: se um novo ponto legítimo de leitura de `amount` bruto for adicionado (ex.: nova tela de detalhe da compra) sem entrar na allowlist, o build quebra — comportamento desejado (força revisão manual), mas exige manter a allowlist documentada no próprio teste.

### Conformidade com Skills Padrão

- **`kotlin-springboot`**: mudanças seguem o padrão hexagonal já em uso; nenhum componente novo foge do padrão gateway/provider já estabelecido pela feature anterior.
- **`vercel-react-best-practices`**: mudanças no frontend são simplificação de tipos e remoção de fallback condicional em componentes de exibição já existentes, sem novo estado/fetch.

### Arquivos relevantes e dependentes

**Backend (`controlai`)**
- `application/payments_notification/application/SavePaymentNotificationProvider.kt` — remove guard de `numberOfInstallments`
- `application/installments/application/InstallmentReconciliationRunner.kt` — generaliza query + gate por property
- `application/installments/entrypoint/database/repository/InstallmentRepository.kt`, `payments_notification/.../PaymentNotificationRepository.kt` — queries generalizadas
- `application/budget/application/BudgetPeriodSqlSupport.kt` — simplificação do JOIN/predicate/amount
- `application/budget/application/GetBudgetSummaryProvider.kt` — sem mudança de lógica própria, só se beneficia do support simplificado
- `application/payment_methods/application/GetPaymentMethodsSummaryProvider.kt` — reescrito para usar `BudgetPeriodSqlSupport`
- `application/payments_notification/application/PaymentNotificationPeriodQueryProvider.kt` — `ORDER BY` ajustado
- novo: `src/test/kotlin/.../architecture/PaymentNotificationAmountAccessTest.kt` (ArchUnit)
- `build.gradle.kts` — adiciona `archunit-junit5`

**Frontend (`controlai-frontend`)**
- `src/pages/Tab1.tsx` — corrige `filteredTotal` (bug do "Total Filtrado")
- `src/components/CategoryDetailSheet.tsx`, `src/components/PurchaseList.tsx` — remove fallback `?? amount`
- `src/services/purchaseService.ts` — `installmentAmount`/`installmentNumberForMonth` viram não-nulos
- novo: `scripts/check-raw-amount-usage.mjs` (ou similar) + wiring em `package.json`/CI

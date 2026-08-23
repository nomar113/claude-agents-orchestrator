# Review: Task 2.0 - Backend — Padronização de tipos de data nas entidades JPA + migration

**Revisor**: AI Code Reviewer
**Data**: 2026-08-23
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

A Tarefa 2.0 unifica os tipos de campo de data das entidades JPA do `controlai` conforme a tabela "Modelos de Dados" da techspec: `Instant` para todo timestamp de evento de negócio e `LocalDate` (sem alteração) para datas de calendário puras. As 9 entidades/campos listados nas subtarefas 2.1–2.9 foram migrados corretamente, a migration Flyway `V36__standardize_purchase_invoices_date_column.sql` foi criada na sequência correta e os 3 requisitos de teste da tarefa (serialização Jackson, independência de timezone via suíte parametrizada, migration sem perda de dados) estão cobertos por testes novos e específicos.

O raio de alteração necessário para manter o projeto compilando (repositórios, DTOs de response, conversores, use cases, controllers) foi propagado de forma ampla e, na imensa maioria dos pontos, correta e consistente com a decisão de design deliberada: pontos de fronteira que ainda recebem valores "naive" (SMS, request manual, fila SQS) foram mantidos com a mesma semântica atual via `.atZone(ZoneOffset.UTC).toInstant()` (bug preservado, correção adiada para a Tarefa 3.0/4.0), enquanto o único campo que já carregava offset real e correto (`PurchaseInvoiceModel.date`/`PurchaseInvoice.date`, vindo do producer de NFC-e) foi convertido preservando a corretude, inclusive corrigindo dois pontos de leitura (`AssociatedInvoiceResponse`, `InvoiceSuggestionResponse`) que hoje passam a usar `America/Sao_Paulo` explicitamente em vez de descartar o offset silenciosamente.

Compilação (`./gradlew compileKotlin compileTestKotlin`) passa limpa. A suíte completa (`./gradlew test`) roda 535 testes com apenas 2 falhas, confirmadas nesta revisão (via `git stash` + reexecução isolada e inspeção do XML de resultado) como pré-existentes e não relacionadas a esta tarefa (`PaymentNotificationControllerTest` e `UpdateNotificationPaymentMethodProviderTest`, ambas falhando por `cardLastDigits` nulo, assunto alheio a datas).

Foi identificado um problema MAJOR real, não coberto por nenhum teste: a combinação de um `Instant` ainda "naive-preservado" (`PaymentNotification.purchasedAt`) com um `Instant` já corretamente zonado (`PurchaseInvoiceModel.date`) em subtrações diretas de tempo (`SuggestionResponse.from` e a ordenação SQL de `findByTotalAndNotAssociated`) produz um desvio sistemático de ~3h (o offset de Brasília) no cálculo de proximidade usado pela funcionalidade de sugestões de associação nota↔fatura. Isso se autocorrige quando a Tarefa 3.0 corrigir o parser, mas fica sem documentação nem teste que sinalize essa limitação temporária — recomendo tratar antes de considerar o item fechado.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/auth/entrypoint/database/model/ApiKeyModel.kt` | OK | 0 |
| `application/auth/entrypoint/database/model/PasswordResetTokenModel.kt` | OK | 0 |
| `application/auth/entrypoint/database/model/RefreshTokenModel.kt` | OK | 0 |
| `application/auth/application/ApiKeyProvider.kt` | OK | 0 |
| `application/auth/entrypoint/rest/response/AuthResponses.kt` | OK | 0 |
| `domain/auth/entity/ApiKey.kt` | OK | 0 |
| `application/groups/entrypoint/database/model/GroupInviteModel.kt` | OK | 0 |
| `application/groups/entrypoint/rest/GroupInviteController.kt` | OK | 0 |
| `domain/groups/entity/GroupInvite.kt` | OK | 0 |
| `domain/groups/usecase/InviteToGroupUseCase.kt` | OK | 0 |
| `application/installments/entrypoint/database/model/Installment.kt` | OK | 0 |
| `application/installments/application/InstallmentReconciliationService.kt` | OK | 0 |
| `application/installments/entrypoint/rest/InstallmentController.kt` | OK | 0 |
| `application/payments_notification/entrypoint/database/model/PaymentNotification.kt` | OK | 0 |
| `application/payments_notification/application/PaymentNotificationTextParser.kt` | OK | 0 |
| `application/payments_notification/application/SavePaymentNotificationProvider.kt` | OK | 0 |
| `application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` | OK | 0 |
| `application/payments_notification/entrypoint/queue/PaymentNotificationQueueListener.kt` | OK | 0 |
| `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` | OK | 0 |
| `application/payments_notification/entrypoint/rest/response/AssociatedInvoiceResponse.kt` | OK (positivo) | 0 |
| `application/payments_notification/entrypoint/rest/response/InvoiceSuggestionResponse.kt` | OK (positivo) | 0 |
| `application/payments_notification/entrypoint/rest/response/PaymentNotificationResponse.kt` | OK | 0 |
| `application/purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt` | OK | 0 |
| `domain/purchases_invoices/entity/PurchaseInvoice.kt` | OK | 0 |
| `application/purchases_invoices/entrypoint/database/repository/PurchaseInvoiceRepository.kt` | Problema | 1 (major) |
| `application/purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt` | OK | 0 |
| `application/purchases_invoices/entrypoint/rest/response/PurchaseInvoiceDetailResponse.kt` | OK | 0 |
| `application/purchases_invoices/application/SearchNotificationsProvider.kt` | OK | 0 |
| `domain/purchases_invoices/gateway/SearchNotificationsGateway.kt` | OK | 0 |
| `domain/purchases_invoices/usecase/SearchNotificationsUseCase.kt` | OK | 0 |
| `domain/payments_notifications/usecase/FindInvoiceSuggestionsUseCase.kt` | OK | 0 |
| `application/suggestion/entrypoint/rest/response/SuggestionResponse.kt` | Problema | 1 (major) |
| `src/main/resources/db/migration/V36__standardize_purchase_invoices_date_column.sql` | OK | 0 |
| `src/test/.../config/EntityDateSerializationTest.kt` (novo) | OK | 0 |
| `src/test/.../config/EntityTimezoneIndependenceIntegrationTest.kt` (novo) | OK | 0 |
| `src/test/.../config/PurchaseInvoiceDateMigrationIntegrationTest.kt` (novo) | OK | 0 |
| Demais arquivos de teste atualizados mecanicamente (17 arquivos) | OK | 0 |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

**1. `SuggestionResponse.from` e `PurchaseInvoiceRepository.findByTotalAndNotAssociated` comparam diretamente um `Instant` "naive-preservado" com um `Instant` já corretamente zonado, gerando desvio sistemático de ~3h**

- Arquivo: `src/main/kotlin/br/com/nomar/controlai/application/suggestion/entrypoint/rest/response/SuggestionResponse.kt`, linhas 23-24
- Arquivo relacionado: `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/database/repository/PurchaseInvoiceRepository.kt`, linha 31 (query nativa)

```kotlin
// SuggestionResponse.kt
fun from(notification: PaymentNotification, invoiceDate: Instant): SuggestionResponse {
    val deltaMinutes = abs(ChronoUnit.MINUTES.between(notification.purchasedAt, invoiceDate))
    ...
```

`notification.purchasedAt` é populado, hoje, exclusivamente a partir de fronteiras "naive" ainda não corrigidas (`PaymentNotificationTextParser`, `PaymentNotificationController`, `PaymentNotificationQueueListener`) via `.atZone(ZoneOffset.UTC).toInstant()` — ou seja, ele numericamente preserva os dígitos literais do horário de Brasília, só que rotulados como UTC (o bug documentado, deliberadamente adiado para a Tarefa 3.0). Já `invoiceDate` (`PurchaseInvoiceModel.date` / `PurchaseInvoice.date`) é o `Instant` real e correto, convertido a partir do offset verdadeiro (`-03:00`) informado pelo producer de NFC-e.

Antes desta tarefa, a comparação equivalente (`invoiceDate.toLocalDateTime()` vs. `notification.purchasedAt: LocalDateTime`) operava sobre dois valores igualmente "naive" (dígitos de relógio de parede de Brasília dos dois lados), então o delta calculado para um par que realmente representa o mesmo evento ficava próximo de 0 minutos. Com a padronização para `Instant`, um dos lados passou a representar o instante absoluto real (correto) e o outro continua representando o instante absoluto errado (mascarado, ~3h atrás do real) — subtrair os dois via `ChronoUnit.MINUTES.between` ou via `TIMESTAMPDIFF` (SQL nativo em `findByTotalAndNotAssociated`) produz, para o mesmo par que antes dava ~0, um delta de ~180 minutos.

Impacto prático: a funcionalidade de "sugestões de associação" (bater uma notificação de SMS/push com uma fatura de NFC-e já escaneada) passa a exibir `timeDeltaMinutes` incorreto (fixo em ~3h de desvio) e, mais grave, a ordenação `ORDER BY ABS(TIMESTAMPDIFF(MINUTE, pi.date, :purchasedAt))` de `findByTotalAndNotAssociated` pode alterar qual fatura é considerada "mais próxima" quando o desvio de 3h interage com o `ABS()` perto da fronteira entre candidatos.

Nenhum teste cobre esse cenário cruzado: todos os testes existentes (`SuggestionResponseTest`, `FindInvoiceSuggestionsUseCaseTest`, `FindNotificationInvoiceSuggestionsProviderTest`, `PurchaseInvoiceRepositoryTest`) constroem os dois fixtures (`purchasedAt` e `date`/`invoiceDate`) já mutuamente consistentes como `Instant` puro (ex.: `date = purchasedAt.plusSeconds(...)`), nunca simulando a assimetria real entre a fronteira ainda-naive do parser e a fronteira já corrigida do producer de NFC-e — por isso o desvio passa despercebido pela suíte.

**Isso se autocorrige** quando a Tarefa 3.0 corrigir `PaymentNotificationTextParser` para declarar `America/Sao_Paulo` explicitamente (nesse momento `notification.purchasedAt` também passa a representar o instante absoluto real, e a subtração volta a fazer sentido sem mudança de código aqui). Ainda assim, recomendo, antes de fechar esta tarefa:
- Adicionar um comentário explicativo em `SuggestionResponse.from` e em `findByTotalAndNotAssociated` (nos mesmos moldes dos já adicionados em `PaymentNotificationTextParser.kt`/`PaymentNotificationQueueListener.kt`) documentando que o delta calculado está temporariamente incorreto (~3h) até a Tarefa 3.0, para que a limitação não seja esquecida silenciosamente.
- Opcionalmente, um teste de regressão que documente esse comportamento temporário (ou que fique deliberadamente `@Disabled`/anotado para revisão quando a Tarefa 3.0 for concluída).

### Problemas Minor

**1. Ausência de teste dedicado para a desserialização Jackson de `PurchaseInvoice.date` com `@JsonFormat(pattern = "dd/MM/yyyy HH:mm:ssXXX")` sobre `Instant`**

- Arquivo: `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/entity/PurchaseInvoice.kt`, linha 14-15

Este é o ponto de entrada real de dados de fatura via fila SQS (`PurchaseInvoiceQueueListener.objectMapper.readValue(message.body(), PurchaseInvoice::class.java)`), e é o único lugar do diff onde `@JsonFormat` com padrão de offset é aplicado sobre um campo `Instant` — combinação que não é totalmente óbvia (o deserializer de `Instant` do `jackson-datatype-jsr310` precisa extrair o offset do padrão customizado corretamente). Validei manualmente durante esta revisão (teste ad-hoc, removido após a verificação) que a desserialização funciona corretamente — `"15/01/2026 10:00:00-03:00"` produz `Instant.parse("2026-01-15T13:00:00Z")`, como esperado — mas recomendo formalizar esse caso em um teste da suíte (ex. em `EntityDateSerializationTest.kt` ou em um teste específico do parser de invoice), já que é o ponto de maior risco silencioso do diff e hoje depende apenas da suíte de integração de fluxo completo para ser indiretamente exercitado.

**2. `TIMESTAMP` (MySQL) tem alcance limitado a 1970–2038**

- Arquivo: `src/main/resources/db/migration/V36__standardize_purchase_invoices_date_column.sql`

A migration segue exatamente o que a techspec pede (`datetime` → `TIMESTAMP`), então não é um desvio da tarefa. Vale só o registro para consciência futura: ao contrário de `datetime` (sem limite prático), `TIMESTAMP` do MySQL satura em 2038-01-19. Para um app pessoal sem dados históricos anteriores a 1970 nem necessidade de armazenar datas além de 2038, não há ação necessária agora — mantendo como nota de arquitetura.

## Destaques Positivos

- Todas as 9 subtarefas de tipo (2.1–2.9) foram implementadas exatamente conforme a tabela "Modelos de Dados" da techspec, sem exceções e sem campos esquecidos.
- A migration `V36__standardize_purchase_invoices_date_column.sql` está na sequência correta (V35 é a última existente) e traz um comentário explicando por que a conversão `datetime → TIMESTAMP` não desloca os dados existentes (sessão já forçada para UTC desde a Tarefa 1.0).
- Os 3 requisitos de teste da tarefa foram todos atendidos com testes específicos e bem nomeados: `EntityDateSerializationTest` (serialização Jackson por entidade), `EntityTimezoneIndependenceIntegrationTest` (suíte parametrizada `UTC`/`America/Sao_Paulo` via `System.setProperty`, provando que o `Instant` persistido/lido é idêntico independentemente do timezone da JVM) e `PurchaseInvoiceDateMigrationIntegrationTest` (migration aplicada com sucesso + round-trip sem perda de dados).
- A decisão de design de preservar comportamento exato nas fronteiras ainda-naive (`ManualPaymentNotificationRequest.purchasedAt`, `UpdatePurchasedAtRequest.purchasedAt`, mensagem da fila SQS, `PaymentNotificationTextParser`) via `.atZone(ZoneOffset.UTC).toInstant()` foi aplicada de forma consistente em **todos** os pontos de fronteira relevantes — inclusive em um ponto não listado explicitamente no PRD/techspec (`PurchaseInvoiceController.parseDateTimeParam`, parâmetros de query `startDate`/`endDate`), mostrando atenção ao raio de alteração completo, não só aos arquivos citados na tarefa.
- Em contrapartida, nos dois pontos que liam `PurchaseInvoiceModel.date` para extrair apenas a data de calendário (`AssociatedInvoiceResponse.from`, `InvoiceSuggestionResponse.from`), a implementação foi além da preservação de tipo: corrigiu a conversão para usar `ZoneId.of("America/Sao_Paulo")` explicitamente em vez de `.toLocalDate()` "cru" — uma melhoria real de corretude, coerente com a premissa de que esse campo específico já carrega um instante correto.
- Comentários explicativos foram adicionados exatamente nos pontos onde o comportamento "naive preservado" poderia confundir um leitor futuro (`PaymentNotificationTextParser.kt`, `PaymentNotificationQueueListener.kt`), referenciando explicitamente a Tarefa 3.0/4.0 como responsável pela correção definitiva.
- `SavePaymentNotificationProvider` e `InstallmentReconciliationService` aplicam a mesma conversão `.atZone(ZoneOffset.UTC).toLocalDate()` de forma consistente para extrair a data-base do cálculo de parcelas a partir de `purchasedAt`, preservando matematicamente o mesmo resultado que `LocalDateTime.toLocalDate()` produzia antes.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (clean-code) | OK |
| Kotlin/Spring Boot | OK (com observação major documentada acima) |
| JPA/Hibernate | OK |
| Migrations Flyway | OK |
| Testes | OK (requisitos da tarefa cobertos; gap minor em teste de desserialização do producer NFC-e) |

## Recomendações

1. (Major) Antes de fechar a tarefa, documentar via comentário — nos moldes dos já existentes em `PaymentNotificationTextParser.kt`/`PaymentNotificationQueueListener.kt` — que `SuggestionResponse.from` e a ordenação nativa de `PurchaseInvoiceRepository.findByTotalAndNotAssociated` estão temporariamente com desvio de ~3h no cálculo de proximidade entre `notification.purchasedAt` (ainda naive) e `invoice.date` (já correto), e que isso se resolve automaticamente quando a Tarefa 3.0 corrigir o parser.
2. (Minor) Adicionar um teste de desserialização Jackson cobrindo `PurchaseInvoice.date` com o payload real do producer de NFC-e (`@JsonFormat(pattern = "dd/MM/yyyy HH:mm:ssXXX")` sobre `Instant`), já que é o único ponto do diff combinando essas duas características e hoje não tem cobertura direta.
3. (Acompanhamento) Ao implementar a Tarefa 3.0, validar explicitamente (com um teste) que o desvio de ~3h identificado no item 1 desaparece — é um bom sinal de "definition of done" para aquela tarefa.

## Veredito

Aprovado com observações. A padronização de tipos em si está completa, correta e bem testada — todas as subtarefas foram cumpridas, a migration é segura e sequenciada corretamente, a compilação está limpa e a suíte de testes passa (à exceção de 2 falhas pré-existentes e não relacionadas, confirmadas nesta revisão). O ponto que impede um "aprovado" sem ressalvas é o desvio de ~3h introduzido na comparação entre `PaymentNotification.purchasedAt` (ainda naive) e `PurchaseInvoiceModel.date`/`invoice.date` (já corrigido) usada pela funcionalidade de sugestões — não é um blocker para prosseguir para a Tarefa 3.0 (que inclusive resolve o problema como efeito colateral), mas deveria ser documentado agora para não virar uma surpresa em produção enquanto a Tarefa 3.0 não é implantada. Pode seguir para a próxima tarefa após registrar o comentário explicativo recomendado no item 1.

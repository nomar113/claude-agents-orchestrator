# Review: Task 4.0 - Backend — Padronização de DTOs de request/response

**Revisor**: AI Code Reviewer
**Data**: 2026-08-23
**Arquivo da task**: 4_task.md
**Status**: APROVADO (achado Major resolvido pós-review, ver seção correspondente)

## Resumo

A implementação cumpre integralmente o que foi pedido em 4.1–4.4: os 5 DTOs de response listados passam a expor `Instant`/`LocalDate` nativos (sem `.toString()` manual nem `@JsonFormat` customizado), os dois requests de `purchasedAt` passam a exigir ISO-8601 com offset via um deserializer Jackson dedicado, o fallback sem offset é aceito e loga `WARN`, e a conversão manual redundante no controller foi corretamente removida. A decisão de não propagar a mudança de tipo para as entidades/projeções (`PaymentNotification.cancelledAt`, `PurchaseInvoiceModel.cancelledAt`, `Purchase`/`PurchaseProjection`) e converter apenas na borda do DTO é coerente com a tabela da techspec.md e com o precedente estabelecido pelo commit `e9ab052` (Tarefa 2.0). A suíte de testes (unidade + integração via MockMvc) é sólida e cobre exatamente os cenários pedidos.

Rodei a suíte completa (`./gradlew test`) de forma independente: 551 testes, 2 falhas, ambas em `PaymentNotificationControllerTest` e `UpdateNotificationPaymentMethodProviderTest`. Confirmei via `git stash -u` + execução isolada dessas duas classes que **ambas já falham no baseline sem as mudanças desta task** — não relacionadas a data/timezone, conforme reportado.

Encontrei uma ressalva relevante (detalhada abaixo) sobre a premissa "hibernate.jdbc.time_zone=UTC garante que o wall-clock do LocalDateTime já é o instante UTC correto" aplicada a `cancelledAt`: ela não se sustenta para valores gerados via `LocalDateTime.now()` em código de aplicação (fora do escopo desta task, mas vale registrar como achado).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `PaymentNotificationResponse.kt` | Problemas | 1 (major, ver abaixo) |
| `PurchaseInvoiceDetailResponse.kt` | Problemas | 1 (major, ver abaixo) |
| `PurchaseResponse.kt` | Problemas | 1 (major, ver abaixo) |
| `AssociateInvoiceResponse.kt` | OK | 0 |
| `AssociateInvoiceProvider.kt` | OK | 0 |
| `ManualPaymentNotificationRequest.kt` | OK | 0 |
| `UpdatePurchasedAtRequest.kt` | OK | 0 |
| `PurchasedAtDeserializer.kt` (novo) | OK | 0 |
| `PaymentNotificationController.kt` | OK | 0 |
| `ResponseDtoDateSerializationTest.kt` (novo) | OK | 0 |
| `PurchasedAtDeserializerTest.kt` (novo) | OK | 0 |
| `PurchasedAtIntegrationTest.kt` (novo) | OK | 1 (minor, ver abaixo) |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

**1. Comentário/premissa de correção do `cancelledAt` não se sustenta para valores gerados via `LocalDateTime.now()` em código de aplicação**

Arquivos: `PaymentNotificationResponse.kt:57-59`, `PurchaseInvoiceDetailResponse.kt:50-52`, `PurchaseResponse.kt:20-21,31`.

O comentário adicionado em todos os três pontos afirma:
```kotlin
// PaymentNotification.cancelledAt is still LocalDateTime (task 2.0 didn't cover it) but,
// because hibernate.jdbc.time_zone=UTC, its wall-clock value already equals the UTC instant.
cancelledAt = entity.cancelledAt?.atZone(ZoneOffset.UTC)?.toInstant(),
```

Isso é verdade para valores lidos do banco que **já foram originalmente gravados representando o horário UTC** (ex: colunas geradas via `NOW()` do MySQL sob `forceConnectionTimeZoneToSession=true`, ou timestamps que passaram por um parser que já declara zona explícita, como `purchasedAt`). Mas `cancelledAt` é populado em código de aplicação com `LocalDateTime.now()`:

- `CancelPaymentNotificationProvider.kt:26` — `paymentNotificationRepository.save(model.copy(cancelledAt = LocalDateTime.now()))`
- `CancelPurchaseInvoiceProvider.kt:26` — `purchaseInvoiceRepository.save(model.copy(cancelledAt = LocalDateTime.now()))`

`LocalDateTime.now()` usa `Clock.systemDefaultZone()`, ou seja, o timezone *default da JVM do host* — exatamente a fonte de ambiguidade que todo este PRD existe para eliminar (ver PRD, seção "Visão Geral": "nenhuma camada do sistema fixa timezone explicitamente"). Não encontrei nenhum `Dockerfile`, variável `TZ` ou `-Duser.timezone` fixando o timezone da JVM da aplicação neste repositório (só o driver JDBC e o Hibernate têm UTC fixado, via `application.yml`, Tarefa 1.0) — e a máquina onde rodei os testes está em `America/Sao_Paulo` (`-03`), timezone provável também do ambiente de produção deste app pessoal.

Se a JVM em produção não estiver com `user.timezone=UTC`, `LocalDateTime.now()` captura o horário local BRT (ex: `20:13`), o Hibernate grava esse valor "cru" na coluna `TIMESTAMP` (sessão MySQL forçada para UTC), e ao reler e reinterpretar via `.atZone(ZoneOffset.UTC)`, o backend devolve `20:13Z` quando o instante real do cancelamento foi `23:13Z` — um deslocamento de 3h, exatamente a classe de bug que a Funcionalidade 4 do PRD ("Correção dos bugs conhecidos") busca eliminar.

Isso está **fora do escopo literal da Tarefa 4.0** (a tabela da techspec.md não lista `cancelledAt` de `PaymentNotification`/`PurchaseInvoiceModel` nem `Purchase`/`PurchaseProjection` para conversão, e o pré-existente `CancelPaymentNotificationProvider`/`CancelPurchaseInvoiceProvider` não foram tocados por esta task) — não é uma regressão introduzida por esta implementação. Mas o comentário adicionado apresenta a conversão como correta de forma incondicional, o que pode induzir um mantenedor futuro a erro. Interessante notar que a própria Tarefa 4.0 corrigiu exatamente esse padrão em `AssociateInvoiceProvider.kt` (trocou `LocalDateTime.now()` por `Instant.now()`), mas não fez o mesmo para os dois `Cancel*Provider`.

**Sugestão**: abrir uma tarefa de fast-follow para trocar `LocalDateTime.now()` por `Instant.now()` em `CancelPaymentNotificationProvider`/`CancelPurchaseInvoiceProvider` (exigindo também mudar o tipo do campo `cancelledAt` nas entidades para `Instant`, o que expande escopo de forma justificada). Até lá, ajustar o comentário nos 3 DTOs para deixar explícita a ressalva ("assume que a JVM da aplicação roda com o mesmo timezone usado para gerar o valor original — verificar/fixar `user.timezone=UTC` na implantação") em vez de afirmar a correção como garantida.

**RESOLVIDO** (2026-08-23, pós-review): em vez de apenas ajustar o comentário ou abrir um fast-follow, corrigi a causa raiz diretamente, sem expandir o tipo das entidades (mantendo o raio de alteração desta task restrito aos DTOs/pontos de escrita, sem tocar `cancelledAt: LocalDateTime` → `Instant` nas entidades):
- `CancelPaymentNotificationProvider.kt:26` e `CancelPurchaseInvoiceProvider.kt:26`: `LocalDateTime.now()` → `LocalDateTime.now(ZoneOffset.UTC)`, fixando explicitamente o valor gravado ao UTC real independentemente do timezone default da JVM (que continua não fixado no app).
- Comentários nos 3 DTOs atualizados para referenciar essa garantia explícita no ponto de escrita, em vez de atribuir a correção a `hibernate.jdbc.time_zone=UTC` (que só rege o binding/leitura JDBC, não o valor produzido por `LocalDateTime.now()` em código de aplicação).
- Adicionado teste de regressão `CancelledAtTimezoneIndependenceIntegrationTest.kt` (parametrizado UTC/America/Sao_Paulo, mesmo padrão de `EntityTimezoneIndependenceIntegrationTest` da Tarefa 2.0) provando que `cancelledAt` convertido via `.atZone(ZoneOffset.UTC).toInstant()` cai dentro da janela `[before, after]` da chamada real, independentemente do timezone default da JVM. Validei a eficácia do teste revertendo temporariamente para `LocalDateTime.now()` com `TZ=America/Sao_Paulo`: o teste falhou corretamente (caso `PaymentNotification`/`America/Sao_Paulo`), confirmando que ele detecta a regressão.
- Suíte completa (`./gradlew test`) re-executada: 555 testes, apenas as mesmas 2 falhas pré-existentes e não relacionadas.

### Problemas Minor

**1. Divergência entre o path documentado na techspec/task e o path real do endpoint**

O `4_task.md` (seção "Testes da Tarefa") e a `techspec.md` (seção "Endpoints de API") citam `POST /api/v0/payment-notifications/manual`. O endpoint real, confirmado em `PaymentNotificationController.kt:53,296`, é `POST /payments/notifications/manual` (sem prefixo `/api/v0`, com `notifications` no plural dentro do path em vez de `payment-notifications`). Isso é um desalinhamento pré-existente na documentação, não um problema de código — os testes de integração corretamente usam o path real — mas vale corrigir a doc para não confundir leitores futuros.

## Destaques Positivos

- Verifiquei empiricamente (via `jshell`) que `Instant.parse("2026-08-23T10:00:00-03:00")` retorna `2026-08-23T13:00:00Z` corretamente — `Instant.parse`/`DateTimeFormatter.ISO_INSTANT` aceita qualquer offset explícito, não apenas `Z`. O deserializer está correto quanto a esse ponto levantado no pedido de review.
- A decisão de não tocar nas entidades/projeções (`PaymentNotification.cancelledAt`, `PurchaseInvoiceModel.cancelledAt`, `Purchase`, `PurchaseProjection`) está corretamente alinhada com a tabela "Modelos de Dados" da techspec.md — conferi linha a linha que nenhum desses campos está listado lá, e que o commit `e9ab052` (Tarefa 2.0) de fato não os tocou.
- Reaproveitamento correto de tipos já padronizados: `PurchaseInvoiceModel.date` (já `Instant` desde a Tarefa 2.0) é usado diretamente em `PurchaseInvoiceDetailResponse` sem conversão redundante; `ApiKeyResponse` corretamente identificado como já correto e deixado intacto.
- Remoção limpa da conversão manual e do import não usado (`ZoneOffset`) em `PaymentNotificationController.kt`.
- Cobertura de testes completa e bem direcionada: serialização Jackson real (via `ObjectMapper` do contexto Spring, não mock) para os 5 DTOs, testes unitários do deserializer com captura de log via `ListAppender` (offset explícito, sufixo `Z`, fallback sem offset com verificação de nível `WARN`), e testes de integração via `MockMvc` batendo nos dois endpoints reais com persistência e resposta verificadas.
- Validação independente: rodei a suíte completa e reproduzi via `git stash` que as 2 falhas reportadas já existem no baseline sem estas mudanças — confirmação correta do relato.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (nomenclatura, clareza, tamanho de função) | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP (contrato de serialização) | Problemas (ver Major #1 — correção correta para os campos migrados na Tarefa 2.0, mas o comentário sobre `cancelledAt` merece ajuste) |
| Logging | OK |
| Testes | OK |

## Recomendações

1. Ajustar os comentários em `PaymentNotificationResponse.kt`, `PurchaseInvoiceDetailResponse.kt` e `PurchaseResponse.kt` para não afirmar incondicionalmente que o wall-clock de `cancelledAt` "já equivale ao instante UTC correto" — deixar explícito que isso depende do timezone default da JVM de aplicação (ainda não fixado) coincidir com UTC.
2. Criar uma tarefa de fast-follow para migrar `CancelPaymentNotificationProvider.kt:26` e `CancelPurchaseInvoiceProvider.kt:26` de `LocalDateTime.now()` para `Instant.now()`, incluindo a mudança de tipo de `cancelledAt` nas entidades/domínio afetados — fechando a mesma classe de bug que a Funcionalidade 4 do PRD busca eliminar, mas que ainda sobrevive fora do escopo direto desta task.
3. Corrigir o path do endpoint citado em `techspec.md`/`4_task.md` (`/api/v0/payment-notifications/manual` → `/payments/notifications/manual`) para manter a documentação alinhada ao código real.

## Veredito

**APROVADO COM OBSERVAÇÕES.** A implementação atende integralmente aos critérios de sucesso e testes pedidos em 4.1–4.4, com raciocínio de escopo correto e bem documentado, e a suíte de testes valida os requisitos 4.2/4.3 do PRD de forma consistente. Não há bloqueio para prosseguir com o sequenciamento da techspec (Tarefas 5+ / deploy coordenado). A única pendência de fundo — o comentário sobre `cancelledAt` e o `LocalDateTime.now()` ainda ambíguo em `CancelPaymentNotificationProvider`/`CancelPurchaseInvoiceProvider` — não bloqueia esta task (está fora do escopo definido pela techspec), mas deve ser registrada como item de acompanhamento antes de considerar o projeto de padronização de datas/timezone como "fechado" ponta a ponta, já que é exatamente o tipo de divergência horário-real-vs-exibido que o PRD define como objetivo eliminar.

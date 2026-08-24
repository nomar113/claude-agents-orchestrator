# Tech Spec: Padronização de Datas e Timezone (controlai + controlai-frontend)

## Resumo Executivo

O backend padroniza timestamps de evento em `java.time.Instant` (UTC, sem ambiguidade) e datas de calendário em `LocalDate`, com o timezone fixado explicitamente em todas as camadas que hoje dependem do ambiente (JVM, driver JDBC `mysql-connector-j`, Hibernate, Jackson) via `application.yml`. O frontend introduz `dayjs` com os plugins `utc`/`timezone` como ponto único de parsing/formatação, substituindo as implementações duplicadas de `new Date(...)` espalhadas em ~8 componentes, e corrige os dois bugs conhecidos (deslocamento em `ManualEntryPage.tsx` e comparação inconsistente de `dueDate` em `PurchaseDetail.tsx`). Backend e frontend são entregues e implantados juntos, pois a mudança de contrato de serialização da API (remoção de formatos customizados/`.toString()` manual) é uma breaking change aceita.

## Arquitetura do Sistema

### Visão Geral dos Componentes

**Backend (controlai)**
- **Configuração de timezone** (`application.yml`, JDBC URL): novo ponto central que fixa UTC em Jackson, Hibernate e no driver MySQL — elimina dependência do timezone do host.
- **Entidades JPA** (`PaymentNotification`, `Installment`, `PurchaseInvoiceModel`, `GroupInviteModel`, `ApiKeyModel`, `RefreshTokenModel`, `PasswordResetTokenModel`): tipos de campo padronizados (`Instant` para timestamps de evento, `LocalDate` para datas de calendário).
- **`PaymentNotificationTextParser`**: passa a declarar explicitamente que o horário extraído do SMS está em `America/Sao_Paulo` antes de converter para `Instant`.
- **DTOs de Request/Response** (`PaymentNotificationResponse`, `PurchaseResponse`, `PurchaseInvoiceDetailResponse`, `ManualPaymentNotificationRequest`, `UpdatePurchasedAtRequest`, etc.): tipos nativos consistentes, sem `.toString()` manual nem `@JsonFormat` customizado.
- **Migration Flyway**: ajusta a coluna `purchase_invoices.date` (hoje `datetime` naive) para `TIMESTAMP`.

**Frontend (controlai-frontend)**
- **`src/utils/date.ts`** (novo): módulo único com todas as funções de parsing/formatação/comparação de data, usando `dayjs` + plugins `utc`/`timezone`/`localizedFormat` + locale `pt-br`.
- **Componentes consumidores** (`PurchaseList.tsx`, `PurchaseDetail.tsx`, `AssociatePage.tsx`, `SuggestionsPage.tsx`, `CategoryDetailSheet.tsx`, `ManualEntryPage.tsx`, `Tab2.tsx`, `FilterContext.tsx`, `PeriodEditModal.tsx`, `DuplicateMonthModal.tsx`, `MonthSelector.tsx`, `ProfilePage.tsx`): removem lógica própria de data e passam a chamar `src/utils/date.ts`.

**Fluxo de dados**: SMS → `PaymentNotificationTextParser` (declara `America/Sao_Paulo` → converte para `Instant` UTC) → persistência (`TIMESTAMP` UTC) → serialização (`Instant` → ISO-8601 com `Z`) → frontend (`dayjs.utc(iso).tz('America/Sao_Paulo')` → exibição pt-BR). Entrada manual segue o caminho inverso: usuário informa data/hora local → frontend converte para `Instant`/ISO com offset → backend recebe já não-ambíguo.

## Design de Implementação

### Interfaces Principais

```typescript
// src/utils/date.ts — único ponto de lógica de data do frontend
function parseApiInstant(iso: string): Dayjs                     // parseia timestamp ISO da API em America/Sao_Paulo
function formatDateTime(iso: string, fmt?: string): string       // "23 ago, 10:00" (pt-BR)
function formatCalendarDate(dateOnly: string, fmt?: string): string // trata "YYYY-MM-DD" sem conversão de TZ
function isPastDueDate(dateOnly: string): boolean                // compara dueDate vs "hoje" por string de calendário
function toApiInstant(dateStr: string, timeStr: string): string  // monta ISO com offset de America/Sao_Paulo p/ enviar à API
```

```kotlin
// PaymentNotificationTextParser — trecho da mudança de contrato
fun parse(smsText: String): Instant {
    val naive = LocalDateTime.parse(extractedText, formatter)
    return naive.atZone(ZoneId.of("America/Sao_Paulo")).toInstant()
}
```

### Modelos de Dados

| Entidade.campo | Tipo atual | Tipo padronizado | Coluna banco |
|---|---|---|---|
| `PaymentNotification.purchasedAt` | `LocalDateTime` | `Instant` | `TIMESTAMP` (sem mudança) |
| `PurchaseInvoiceModel.date` | `OffsetDateTime` | `Instant` | `datetime` → **migra para `TIMESTAMP`** |
| `Installment.cancelledAt/createdAt/updatedAt` | `LocalDateTime` | `Instant` | `TIMESTAMP` (sem mudança) |
| `Installment.dueDate` | `LocalDate` | `LocalDate` (sem mudança) | `DATE` |
| `GroupInviteModel.expiresAt/createdAt` | `LocalDateTime` | `Instant` | `TIMESTAMP` (sem mudança) |
| `ApiKeyModel.createdAt/revokedAt` | `LocalDateTime` | `Instant` | `TIMESTAMP` (sem mudança) |
| `RefreshTokenModel.createdAt` | `LocalDateTime` | `Instant` (alinha com `expiresAt`/`revokedAt`, já `Instant`) | `TIMESTAMP` (sem mudança) |
| `PasswordResetTokenModel.createdAt` | `LocalDateTime` | `Instant` | `TIMESTAMP` (sem mudança) |
| `BudgetPaymentPeriod(Model).startDate/endDate` | `LocalDate` | `LocalDate` (sem mudança) | `DATE` |

Serialização JSON resultante: todo timestamp de evento vira `Instant`, serializado nativamente pelo `jackson-datatype-jsr310` como ISO-8601 UTC (ex: `"2026-08-23T13:00:00Z"`); toda data de calendário permanece `LocalDate` (ex: `"2026-08-23"`).

### Endpoints de API

Nenhum endpoint novo. Contrato de payload muda (breaking change coordenada) nos seguintes:
- `POST /payments/notifications/manual` e `PATCH .../purchased-at`: `purchasedAt` passa a exigir string ISO-8601 com offset/zona explícita (ex: `2026-08-23T10:00:00-03:00`), deserializado para `Instant`.
- Responses que hoje têm `cancelledAt: String` (via `.toString()`) e `PurchaseInvoiceDetailResponse.date` (com `@JsonFormat` customizado) passam a serializar como `Instant` nativo (ISO-8601 `Z`).

### Configuração central de timezone

`application.yml`:
```yaml
spring:
  datasource:
    url: ${DB_URL:jdbc:mysql://localhost:3306/controlai?connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true}
  jackson:
    time-zone: UTC
  jpa:
    properties:
      hibernate.jdbc.time_zone: UTC
```
`forceConnectionTimeZoneToSession=true` força a variável de sessão `time_zone` do MySQL para UTC a cada conexão, independentemente do timezone padrão configurado no container — não é necessária alteração no `docker-compose.yml`/imagem MySQL.

## Pontos de Integração

- **Driver `mysql-connector-j`** (já presente em `build.gradle.kts`): apenas parâmetros de URL, sem upgrade de versão necessário.
- **Fila SQS de `payments-notifications`**: nenhuma mudança de contrato da mensagem; apenas o parser interno passa a declarar zona explicitamente antes de persistir.
- Nenhuma integração externa nova.

## Abordagem de Testes

### Testes de Unidade
- Backend: testes de serialização Jackson para `Instant`/`LocalDate` nos DTOs afetados; teste de `PaymentNotificationTextParser` verificando conversão correta SMS→`Instant`.
- Backend (independência de ambiente): suíte parametrizada executando o mesmo teste de persistência/leitura com `System.setProperty("user.timezone", ...)` alternando entre `UTC` e `America/Sao_Paulo`, validando que o `Instant` lido é idêntico ao gravado em ambos os casos.
- Frontend (Vitest): `src/utils/date.ts` — casos de borda para `parseApiInstant`/`formatDateTime` (meia-noite, troca de mês/ano) e `isPastDueDate` (parcela vencendo exatamente "hoje" perto de 00:00 em `America/Sao_Paulo`).

### Testes de Integração
- Backend: teste contra MySQL real (Testcontainers/docker-compose de teste já usado no projeto) validando que `connectionTimeZone=UTC` está de fato aplicado — grava um `Instant` conhecido, reinicia a sessão, relê e compara.

### Testes de E2E
- Playwright cobrindo: (1) criação de compra manual informando data/hora específica → valor exibido no detalhe da compra deve ser idêntico ao informado; (2) parcela com `dueDate` igual à data atual, exercitada perto da virada de dia, classificada corretamente como vencida/não vencida.

## Sequenciamento de Desenvolvimento

### Ordem de Construção
1. **Backend — configuração central de timezone** (`application.yml`, JDBC URL): base para tudo o resto, sem quebrar nada isoladamente.
2. **Backend — padronização de tipos nas entidades** (`Instant`/`LocalDate` conforme tabela acima).
3. **Backend — migration Flyway** para `purchase_invoices.date` (`datetime` → `TIMESTAMP`).
4. **Backend — correção do `PaymentNotificationTextParser`** (declarar `America/Sao_Paulo` explicitamente).
5. **Backend — padronização de DTOs** (remoção de `.toString()`/`@JsonFormat` customizado; requests aceitando ISO com offset).
6. **Backend — testes** (unidade multi-timezone + integração).
7. **Frontend — `src/utils/date.ts`** com `dayjs`/plugins como base isolada, testável antes de tocar nos componentes.
8. **Frontend — migração dos componentes consumidores** para o util único (inclui a correção dos dois bugs conhecidos como parte da migração, não como patches isolados).
9. **Frontend — testes** (unidade do util + E2E Playwright).
10. **Deploy coordenado** backend+frontend (contrato de API muda junto).

### Dependências Técnicas
- Nenhuma infraestrutura nova requerida.
- Nova dependência de frontend: `dayjs` (+ `dayjs/plugin/utc`, `dayjs/plugin/timezone`, `dayjs/locale/pt-br`).
- Migration Flyway deve rodar antes do deploy do backend com os novos tipos de entidade (ordem já garantida pelo pipeline Flyway existente).

## Monitoramento e Observabilidade

O projeto não possui Prometheus/Grafana configurado atualmente — observabilidade permanece via logs SLF4J já usados (`logging.level` em `application.yml`). Adicionar log em nível `WARN` no `PaymentNotificationTextParser` caso o texto do SMS não case com o formato de data/hora esperado, e log em nível `WARN` em qualquer endpoint que receba `purchasedAt` sem offset/zona explícita (fallback de compatibilidade), para detectar clientes desatualizados após o deploy.

## Considerações Técnicas

### Decisões Principais
- **`Instant` em vez de `OffsetDateTime`/`LocalDateTime` para timestamps de evento**: representa um instante absoluto sem ambiguidade, é o tipo recomendado pela documentação Java/Spring para esse caso de uso, e simplifica a serialização (sempre UTC/`Z`, sem depender de configuração de locale do cliente). `OffsetDateTime` foi descartado por preservar um offset que, no caso deste app, não carrega informação útil (o app é fixo em `America/Sao_Paulo`).
- **`connectionTimeZone=UTC` + `forceConnectionTimeZoneToSession=true`** em vez do parâmetro legado `serverTimezone`: é a forma recomendada atual pelo driver `mysql-connector-j` e evita depender do timezone configurado no container MySQL.
- **`dayjs` em vez de `date-fns`/nativo puro** no frontend: os plugins oficiais `utc`+`timezone` cobrem exatamente o padrão necessário (API vem em UTC, exibição em `America/Sao_Paulo`) com API mais simples que `date-fns-tz` e footprint menor que `moment`.
- **Brasil não observa horário de verão desde 2019** — a conversão UTC ↔ `America/Sao_Paulo` é um offset fixo (`-03:00`), sem necessidade de lógica de transição sazonal. Fica registrado como premissa: se o Brasil reintroduzir DST, o timezone IANA (`America/Sao_Paulo`) já absorve a mudança automaticamente sem alteração de código, desde que o sistema operacional/biblioteca de timezone esteja atualizado.

### Riscos Conhecidos
- **Migration de `purchase_invoices.date`** (`datetime`→`TIMESTAMP`) é uma alteração de schema em produção; mitigação: rodar em janela de baixo uso (app pessoal) e validar em ambiente local com dump de produção antes.
- **Clientes desatualizados** enviando `purchasedAt` sem offset após o deploy do backend (ex: app mobile não atualizado imediatamente nas lojas): mitigação via log `WARN` de fallback (ver Observabilidade); como o app é de uso pessoal com poucos dispositivos, o risco de janela de incompatibilidade é baixo mas deve ser comunicado no deploy.
- **Locale `pt-br` do dayjs** precisa ser importado explicitamente (`import 'dayjs/locale/pt-br'`) — se esquecido, formatação cai para inglês silenciosamente; mitigação: cobrir com teste de unidade que verifica o texto de saída em português.

### Conformidade com Skills Padrões
- **`clean-code`** (controlai-frontend): a consolidação de toda lógica de data duplicada em `src/utils/date.ts` está diretamente alinhada ao princípio de eliminar duplicação e centralizar responsabilidade única.
- **`vercel-react-best-practices`** (controlai-frontend): nenhuma mudança de padrão de data fetching é introduzida; a migração dos componentes deve preservar os padrões de memoização/effects já existentes nos arquivos tocados.
- **`ionic-design`** (controlai-frontend): uso de `IonDatetime` em `PeriodEditModal.tsx`/`DuplicateMonthModal.tsx` não muda de componente, apenas o tratamento do valor retornado passa a usar `src/utils/date.ts`.
- **controlai (backend)**: não há skills de projeto configuradas em `.claude/skills`; a padronização segue as convenções já estabelecidas no código (Flyway para migrations, estrutura de pacotes por domínio).

### Arquivos relevantes e dependentes

**Backend**
- `application.yml` (raiz do repositorio `controlai`, nao `src/main/resources` — Spring Boot carrega `file:./application.yml` com precedencia sobre o classpath)
- `.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `.../installments/entrypoint/database/model/Installment.kt`
- `.../purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt`
- `.../domain/purchases_invoices/entity/PurchaseInvoice.kt`
- `.../groups/entrypoint/database/model/GroupInviteModel.kt`
- `.../auth/entrypoint/database/model/ApiKeyModel.kt`
- `.../auth/entrypoint/database/model/RefreshTokenModel.kt`
- `.../auth/entrypoint/database/model/PasswordResetTokenModel.kt`
- `.../payments_notification/.../PaymentNotificationTextParser.kt`
- DTOs: `PaymentNotificationResponse`, `PurchaseResponse`, `PurchaseInvoiceDetailResponse`, `AssociateInvoiceResponse`, `ApiKeyResponse`, `ManualPaymentNotificationRequest`, `UpdatePurchasedAtRequest`
- `src/main/resources/db/migration/V<next>__standardize_purchase_invoices_date_column.sql`

**Frontend**
- `src/utils/date.ts` (novo)
- `src/pages/ManualEntryPage.tsx`
- `src/pages/PurchaseDetail.tsx`
- `src/pages/AssociatePage.tsx`
- `src/pages/SuggestionsPage.tsx`
- `src/pages/Tab2.tsx`
- `src/pages/ProfilePage.tsx`
- `src/context/FilterContext.tsx`
- `src/components/PurchaseList.tsx`
- `src/components/CategoryDetailSheet.tsx`
- `src/components/PeriodEditModal.tsx`
- `src/components/DuplicateMonthModal.tsx`
- `src/components/MonthSelector.tsx`
- `src/services/purchaseService.ts`, `src/types/installment.ts` (tipos `string` mantidos, sem mudança estrutural)
- `package.json` (nova dependência `dayjs`)

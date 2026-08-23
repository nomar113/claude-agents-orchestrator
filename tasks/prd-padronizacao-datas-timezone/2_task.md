# Tarefa 2.0: Backend — Padronizacao de tipos de data nas entidades JPA + migration

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Unificar os tipos de campo de data em todas as entidades JPA do backend: `Instant` para todo timestamp de evento de negocio (compra, cancelamento, criacao/atualizacao, expiracao de token) e `LocalDate` para toda data de calendario pura (vencimento de parcela, periodo de orcamento). Inclui a migration Flyway que ajusta a coluna `purchase_invoices.date` de `datetime` (naive) para `TIMESTAMP`.

**Depende da Tarefa 1.0** (configuracao central de UTC deve estar em vigor antes de padronizar os tipos, para que o `Instant` persistido/lido seja sempre consistente).

<skills>
### Conformidade com Skills Padroes

- `clean-code`: elimina a mistura atual de `LocalDateTime`/`OffsetDateTime`/`Instant` para o mesmo conceito, com um unico tipo por categoria semantica.
</skills>

<requirements>
- Deve existir exatamente um tipo de dado por categoria semantica (timestamp de evento vs. data de calendario) usado consistentemente em todas as entidades do backend (PRD requisito 1).
- Um timestamp de evento persistido deve representar o mesmo instante no tempo independentemente do timezone do host (PRD requisito 3).
- Migration deve ser aplicavel sem exigir indisponibilidade do sistema em producao (PRD, Restricoes Tecnicas de Alto Nivel).
</requirements>

## Subtarefas

- [x] 2.1 `PaymentNotification.purchasedAt`: `LocalDateTime` → `Instant`.
- [x] 2.2 `PurchaseInvoiceModel.date` (e `PurchaseInvoice.date` no dominio): `OffsetDateTime` → `Instant`.
- [x] 2.3 `Installment.cancelledAt/createdAt/updatedAt`: `LocalDateTime` → `Instant`; `Installment.dueDate` permanece `LocalDate` (sem mudanca).
- [x] 2.4 `GroupInviteModel.expiresAt/createdAt`: `LocalDateTime` → `Instant`.
- [x] 2.5 `ApiKeyModel.createdAt/revokedAt`: `LocalDateTime` → `Instant`.
- [x] 2.6 `RefreshTokenModel.createdAt`: `LocalDateTime` → `Instant` (alinha com `expiresAt`/`revokedAt`, ja `Instant`).
- [x] 2.7 `PasswordResetTokenModel.createdAt`: `LocalDateTime` → `Instant`.
- [x] 2.8 `BudgetPaymentPeriod(Model).startDate/endDate`: confirmar que permanecem `LocalDate` (sem mudanca de tipo, apenas validacao de consistencia).
- [x] 2.9 Criar migration Flyway `V<next>__standardize_purchase_invoices_date_column.sql` alterando `purchase_invoices.date` de `datetime` para `TIMESTAMP`.
- [x] 2.10 Escrever testes de unidade e integracao (ver secao de Testes).

## Detalhes de Implementacao

Ver tabela "Modelos de Dados" na `techspec.md` para o mapeamento completo tipo atual → tipo padronizado → coluna banco, e a secao "Riscos Conhecidos" quanto a mitigacao da migration em producao (janela de baixo uso, validacao local com dump de producao).

## Criterios de Sucesso

- Todas as entidades listadas usam `Instant` para timestamp de evento e `LocalDate` para data de calendario, sem excecoes.
- A migration roda com sucesso em ambiente local com dump de producao antes de ser aplicada em producao.
- Nenhuma perda de dados na conversao de `purchase_invoices.date`.

## Testes da Tarefa

- [x] Testes de unidade: serializacao Jackson para `Instant`/`LocalDate` nas entidades afetadas.
- [x] Testes de unidade (independencia de ambiente): suite parametrizada executando o mesmo teste de persistencia/leitura com `System.setProperty("user.timezone", ...)` alternando entre `UTC` e `America/Sao_Paulo`, validando que o `Instant` lido e identico ao gravado em ambos os casos (conforme techspec.md).
- [x] Testes de integracao: migration Flyway aplicada em banco de teste (Testcontainers) sem erro e com dados existentes preservados.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `.../payments_notification/entrypoint/database/model/PaymentNotification.kt`
- `.../installments/entrypoint/database/model/Installment.kt`
- `.../purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt`
- `.../domain/purchases_invoices/entity/PurchaseInvoice.kt`
- `.../groups/entrypoint/database/model/GroupInviteModel.kt`
- `.../auth/entrypoint/database/model/ApiKeyModel.kt`
- `.../auth/entrypoint/database/model/RefreshTokenModel.kt`
- `.../auth/entrypoint/database/model/PasswordResetTokenModel.kt`
- `src/main/resources/db/migration/V<next>__standardize_purchase_invoices_date_column.sql`

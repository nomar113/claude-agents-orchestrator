# Tarefa 4.0: Migracao Flyway — adicionar category_id FK nas tabelas de compras

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar migracao Flyway que adiciona a coluna `category_id` (FK para `categories`) nas tabelas `payment_notifications` e `purchase_invoices`. Coluna nullable para retrocompatibilidade com dados existentes.

<skills>
### Conformidade com Skills Padroes

- **`kotlin-springboot`**: Padroes de migracao Flyway.
</skills>

<requirements>
- Adicionar `category_id BIGINT NULL DEFAULT NULL` em `payment_notifications`
- Adicionar `category_id BIGINT NULL DEFAULT NULL` em `purchase_invoices`
- FK constraints referenciando `categories(id)` em ambas
- Coluna nullable (dados existentes nao tem categoria vinculada)
- Manter campo `category` (VARCHAR) em `payment_notifications` para retrocompatibilidade
</requirements>

## Subtarefas

- [ ] 4.1 Criar arquivo de migracao SQL com ALTER TABLE para ambas as tabelas
- [ ] 4.2 Executar `./gradlew build` para validar que a migracao roda sem erros
- [ ] 4.3 Escrever teste de integracao da migracao

## Detalhes de Implementacao

Consultar a secao **Modelos de Dados > Alteracoes em tabelas existentes** da `techspec.md` para o SQL exato.

## Criterios de Sucesso

- Migracao executa sem erros
- Ambas as tabelas possuem coluna `category_id` nullable com FK valida
- Campo `category` (texto) em `payment_notifications` permanece inalterado
- Dados existentes nao sao afetados (category_id = NULL)

## Testes da Tarefa

- [ ] Teste de integracao: validar que `category_id` existe em `payment_notifications`
- [ ] Teste de integracao: validar que `category_id` existe em `purchase_invoices`
- [ ] Teste de integracao: inserir registro com `category_id` referenciando categoria valida

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/resources/db/migration/V9__add_manual_origin_and_category.sql` — Referencia de ALTER TABLE
- `controlai/src/main/kotlin/.../application/payments_notification/entrypoint/database/model/PaymentNotification.kt` — Modelo que sera atualizado na task 5
- `controlai/src/main/kotlin/.../application/purchases_invoices/entrypoint/database/model/` — Modelo de purchase_invoices

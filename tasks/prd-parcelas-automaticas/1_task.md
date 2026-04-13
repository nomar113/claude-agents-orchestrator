# Tarefa 1.0: Migracao Flyway V15 — criar tabela installments

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a migracao Flyway V15 que cria a tabela `installments` no MySQL. Esta tabela armazena cada parcela individual de uma compra parcelada, com FK para `payment_notifications`.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Criar arquivo `V15__create_installments_table.sql` em `src/main/resources/db/migration/`
- Tabela deve conter: id, parent_id (FK), installment_number, total_installments, amount, due_date, cancelled_at, created_at, updated_at
- UNIQUE KEY em (parent_id, installment_number) para prevenir duplicatas
- FK `parent_id` referenciando `payment_notifications(id)`
- `cancelled_at` nullable para suportar soft delete de parcelas canceladas
</requirements>

## Subtarefas

- [ ] 1.1 Criar arquivo de migracao `V15__create_installments_table.sql`
- [ ] 1.2 Verificar que a migracao roda sem erros no H2 (testes) e MySQL (local)

## Detalhes de Implementacao

Consultar a secao "Modelos de Dados" da `techspec.md` para o DDL completo da tabela `installments`.

## Criterios de Sucesso

- Migracao aplica sem erros no H2 (modo MySQL) nos testes
- Tabela criada com todas as colunas, FK e UNIQUE KEY conforme a tech spec
- Build do backend passa sem erros

## Testes da Tarefa

- [ ] Testes de integracao: verificar que o contexto Spring sobe sem erros com a nova migracao (testes existentes continuam passando)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/V15__create_installments_table.sql` (novo)
- `src/main/resources/db/migration/V14__add_category_id_to_purchases.sql` (referencia — ultima migracao)

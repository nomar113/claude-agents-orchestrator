# Tarefa 1.0: Migrations Flyway — tabelas holders, payment_methods, sub_cards

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar as migrations Flyway para as novas tabelas do bounded context de meios de pagamento e alterar a tabela `payment_notifications` para incluir as FKs de vinculacao. Esta e a base de dados sobre a qual todo o restante sera construido.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar migration V5 para tabela `holders`
- Criar migration V6 para tabela `payment_methods` com soft delete (deleted_at)
- Criar migration V7 para tabela `sub_cards` com soft delete (deleted_at)
- Criar migration V8 para adicionar colunas `payment_method_id` e `sub_card_id` em `payment_notifications` (ambas nullable, FKs)
- Todas as tabelas devem usar `utf8mb4_unicode_ci`, `ENGINE=InnoDB`
- ENUMs MySQL para campos de tipo conforme definido na techspec.md
- Campos `created_at` e `updated_at` com defaults automaticos
- Indices nas FKs de `payment_notifications` para performance
</requirements>

## Subtarefas

- [ ] 1.1 Criar migration `V5__create_holders_table.sql`
- [ ] 1.2 Criar migration `V6__create_payment_methods_table.sql`
- [ ] 1.3 Criar migration `V7__create_sub_cards_table.sql`
- [ ] 1.4 Criar migration `V8__add_payment_method_fks_to_payment_notifications.sql`
- [ ] 1.5 Testes de integracao validando execucao das migrations

## Detalhes de Implementacao

Consultar a secao **Modelos de Dados** da `techspec.md` para a definicao completa de colunas, tipos e restricoes de cada tabela.

Seguir o padrao das migrations existentes (V1 a V4) em `/src/main/resources/db/migration/`.

## Criterios de Sucesso

- Todas as 4 migrations executam sem erro no MySQL e no H2 (testes)
- Tabelas criadas com todas as colunas, tipos, FKs e indices conforme techspec
- FKs em `payment_notifications` sao nullable (retrocompatibilidade)
- `flyway:migrate` executa com sucesso na aplicacao

## Testes da Tarefa

- [ ] Teste de integracao: aplicacao sobe com H2 e todas as migrations executam
- [ ] Teste de integracao: inserir registro em cada tabela nova e validar constraints
- [ ] Teste de integracao: validar que FKs nullable em payment_notifications aceitam NULL

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/resources/db/migration/V5__create_holders_table.sql` (novo)
- `controlai/src/main/resources/db/migration/V6__create_payment_methods_table.sql` (novo)
- `controlai/src/main/resources/db/migration/V7__create_sub_cards_table.sql` (novo)
- `controlai/src/main/resources/db/migration/V8__add_payment_method_fks_to_payment_notifications.sql` (novo)
- `controlai/src/main/resources/db/migration/V1__create_payment_notifications_table.sql` (referencia de padrao)

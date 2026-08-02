# Tarefa 1.0: Migration — cancelled_at

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar migration Flyway adicionando a coluna `cancelled_at TIMESTAMP NULL DEFAULT NULL` nas tabelas `payment_notifications` e `purchase_invoices`.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de migrations Flyway existente no projeto.
</skills>

<requirements>
- Adicionar coluna `cancelled_at TIMESTAMP NULL DEFAULT NULL` em `payment_notifications`
- Adicionar coluna `cancelled_at TIMESTAMP NULL DEFAULT NULL` em `purchase_invoices`
- A migration deve ser non-breaking (coluna nullable, sem default obrigatorio)
- Seguir nomenclatura sequencial do projeto (verificar ultimo numero de migration)
</requirements>

## Subtarefas

- [ ] 1.1 Verificar o numero da proxima migration disponivel no diretorio `src/main/resources/db/migration/`
- [ ] 1.2 Criar arquivo de migration com ALTER TABLE para ambas as tabelas
- [ ] 1.3 Executar migration localmente e verificar sucesso

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Modelos de Dados > Migration V18"

A migration deve conter dois ALTER TABLE simples. Colunas nullable nao causam lock em MySQL.

## Criterios de Sucesso

- Migration executa sem erros no banco local
- Ambas as tabelas possuem a coluna `cancelled_at` apos execucao
- Dados existentes nao sao afetados (coluna null para todos)
- `flyway_schema_history` registra a migration com sucesso

## Testes da Tarefa

- [ ] Testes de integracao: verificar que a migration executa com sucesso no contexto Spring Boot (`@SpringBootTest`)
- [ ] Verificar via query SQL que a coluna existe e aceita NULL

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/` (diretorio de migrations)
- `src/main/resources/db/migration/V12__add_deleted_at_to_purchase_invoices_and_payment_notifications.sql` (referencia de padrao)

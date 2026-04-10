# Tarefa 1.0: Migracao Flyway — tabela categories + seed data

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a migracao Flyway que define a tabela `categories` com suporte a soft delete e insere as 15 categorias pre-populadas. Esta e a fundacao para todas as demais tarefas.

<skills>
### Conformidade com Skills Padroes

- **`kotlin-springboot`**: Seguir padroes de migracao Flyway do projeto.
- **`clean-code`**: SQL limpo, nomes claros.
</skills>

<requirements>
- Tabela `categories` com campos: id (BIGINT PK AUTO_INCREMENT), name (VARCHAR 50, NOT NULL, UNIQUE), deleted_at, created_at, updated_at
- Soft delete via `deleted_at TIMESTAMP NULL`
- Collation `utf8mb4_unicode_ci` (case-insensitive por padrao)
- Seed data com 15 categorias: Gastos Gerais, Mercado, Veiculos, Pets, Moradia, Remedios, Medicos, Transporte, Viagens, Assinaturas, Lazer, Educacao, Vestuario, Beleza, Presentes
- Seguir padrao de nomenclatura existente: `V{N}__descricao.sql`
</requirements>

## Subtarefas

- [ ] 1.1 Identificar o proximo numero de versao Flyway disponivel (verificar migrations existentes)
- [ ] 1.2 Criar arquivo SQL com CREATE TABLE categories + INSERT seed data
- [ ] 1.3 Executar `./gradlew build` para validar que a migracao roda sem erros
- [ ] 1.4 Escrever teste de integracao da migracao

## Detalhes de Implementacao

Consultar a secao **Modelos de Dados > Tabela `categories`** e **Seed data** da `techspec.md` para o SQL exato.

Referencia de schema existente: `V6__create_payment_methods_table.sql`.

## Criterios de Sucesso

- Migracao executa sem erros no build
- Tabela `categories` criada com todos os campos corretos
- 15 categorias inseridas apos a migracao
- Teste de integracao valida que seed data esta presente

## Testes da Tarefa

- [ ] Teste de integracao: validar que a tabela existe e contem 15 registros apos migracao (referencia: `MigrationIntegrationTest.kt`)
- [ ] Teste de integracao: validar que constraint UNIQUE impede nomes duplicados

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/resources/db/migration/V6__create_payment_methods_table.sql` — Referencia de schema
- `controlai/src/main/resources/db/migration/V9__add_manual_origin_and_category.sql` — Ultima migracao relevante
- `controlai/src/test/kotlin/.../application/payment_methods/MigrationIntegrationTest.kt` — Referencia de teste

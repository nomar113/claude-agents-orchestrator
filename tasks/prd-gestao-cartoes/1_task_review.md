# Review: Task 1.0 - Migrations Flyway (holders, payment_methods, sub_cards)

**Revisor**: AI Code Reviewer
**Data**: 2026-03-30
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task implementou as 4 migrations Flyway (V5 a V8) para as tabelas `holders`, `payment_methods`, `sub_cards` e a alteracao em `payment_notifications`, acompanhadas de um teste de integracao abrangente com 12 cenarios. A qualidade geral e boa: as migrations estao corretas, seguem o padrao do projeto e todas executam com sucesso tanto em H2 (testes) quanto na estrutura esperada para MySQL. A decisao de usar VARCHAR no lugar de ENUM MySQL foi acertada para compatibilidade com H2 e extensibilidade futura, conforme recomendacao da propria techspec. Ha apenas observacoes menores que nao bloqueiam a aprovacao.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/main/resources/db/migration/V5__create_holders_table.sql` | OK | 0 |
| `src/main/resources/db/migration/V6__create_payment_methods_table.sql` | OK | 0 |
| `src/main/resources/db/migration/V7__create_sub_cards_table.sql` | OK | 0 |
| `src/main/resources/db/migration/V8__add_payment_method_fks_to_payment_notifications.sql` | OK | 0 |
| `src/test/kotlin/.../MigrationIntegrationTest.kt` | Problemas | 2 |
| `src/test/resources/application.properties` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**M1. Inconsistencia no padrao de `IF NOT EXISTS` na V8**
- **Arquivo**: `V8__add_payment_method_fks_to_payment_notifications.sql`
- **Descricao**: As migrations V5, V6 e V7 usam `CREATE TABLE IF NOT EXISTS`, o que e uma boa pratica defensiva. Porem, a V8 usa `ALTER TABLE` sem protecao equivalente. Se essa migration falhar no meio (ex: coluna ja existe), nao sera possivel re-executa-la. Isso e aceitavel para Flyway (que controla versoes), mas vale registrar a diferenca de padrao.
- **Impacto**: Baixo. O Flyway gerencia o estado das migrations, entao na pratica isso nao causa problema.
- **Sugestao**: Manter como esta. A nota e apenas para consciencia do time.

**M2. Cleanup no teste pode falhar em cenarios de erro**
- **Arquivo**: `MigrationIntegrationTest.kt`, linhas 19-25
- **Descricao**: O metodo `cleanUp()` executa DELETEs em ordem especifica para respeitar FKs, o que e correto. Porem, o `DELETE FROM payment_notifications WHERE card_last_digits IN ('9999', '8888')` no final pode ser desnecessario se as linhas 21-22 ja limparam ou nao criaram esses registros. Alem disso, se um teste anterior falhar no meio de uma insercao, a ordem de cleanup pode deixar dados orfaos em cenarios de borda.
- **Sugestao**: Considerar usar `@Transactional` com rollback automatico nos testes ao inves de cleanup manual. Isso garantiria isolamento perfeito entre testes sem depender de ordem de DELETE.

**M3. Acesso a colunas do result set via nome uppercase (H2)**
- **Arquivo**: `MigrationIntegrationTest.kt`, linhas 67-68, 95-96, etc.
- **Descricao**: O teste acessa colunas do `queryForMap` usando nomes em uppercase (ex: `holder["ID"]`, `holder["NAME"]`). Isso funciona no H2 com `DATABASE_TO_LOWER=TRUE`, mas e uma particularidade do H2 que retorna chaves do Map em uppercase. O codigo esta correto para o ambiente de teste, mas seria fragil se migrado para outro banco de testes.
- **Impacto**: Muito baixo. Os testes de migration sao especificos para validar DDL e rodam apenas em H2.
- **Sugestao**: Manter como esta. Documentar essa particularidade e suficiente.

## Destaques Positivos

1. **Decisao VARCHAR vs ENUM**: Excelente decisao usar `VARCHAR(20)` e `VARCHAR(30)` para campos de tipo ao inves de `ENUM` MySQL. Isso garante compatibilidade com H2, facilita extensao futura (adicionar novos tipos sem `ALTER TABLE`), e esta alinhado com a recomendacao da techspec sobre ENUMs serem dificeis de alterar.

2. **Cobertura de testes abrangente**: O `MigrationIntegrationTest` cobre 12 cenarios que validam: existencia das tabelas, insercao e recuperacao de dados, constraint UNIQUE, FK entre tabelas, nullable FKs para retrocompatibilidade, soft delete via `deleted_at`, e sub-cartoes com wallet platform. Isso excede os 3 cenarios minimos listados na task.

3. **Indices nas FKs de payment_notifications**: A V8 cria indices explicitamente para `payment_method_id` e `sub_card_id`, conforme recomendado na techspec para performance do endpoint de summary. Boa atencao a requisitos nao-funcionais.

4. **Consistencia com migrations existentes**: As novas migrations seguem o padrao de `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`, consistente com V2, V3 e V4. A V1 nao tinha essas especificacoes, mas as novas estao no padrao mais recente do projeto.

5. **Retrocompatibilidade**: As FKs em `payment_notifications` sao nullable (`DEFAULT NULL`), garantindo que despesas existentes continuem funcionando sem quebra.

6. **Configuracao de testes**: O `application.properties` de teste esta bem configurado com H2 em `MODE=MYSQL`, `DATABASE_TO_LOWER=TRUE`, Flyway habilitado e servicos externos (SQS) desabilitados.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| SQL/Flyway | OK |
| Testes | OK |
| Techspec | OK |
| Retrocompatibilidade | OK |

## Recomendacoes

1. **Considerar `@Transactional` nos testes**: Para garantir isolamento perfeito entre testes sem depender de cleanup manual via `@BeforeEach`. Isso simplificaria o `MigrationIntegrationTest` e eliminaria riscos de dados residuais.

2. **Validar tipos aceitos na camada de aplicacao**: Como os campos `type`, `wallet_platform` e outros agora sao VARCHAR (nao ENUM), a validacao dos valores aceitos devera ser feita na camada de dominio/aplicacao nas proximas tasks. Isso nao e escopo desta task, mas e importante ter em mente.

3. **Considerar CHECK constraint para closing_day**: A techspec menciona que `closing_day` deve estar entre 1 e 31. Um `CHECK (closing_day BETWEEN 1 AND 31)` na migration garantiria integridade no nivel de banco. Porem, o H2 em MODE=MYSQL pode ter limitacoes com CHECK constraints, entao essa validacao pode ficar apenas na camada de aplicacao.

## Veredito

Task aprovada com observacoes menores. As 4 migrations estao corretas, seguem os padroes do projeto, e os testes de integracao cobrem os cenarios necessarios com margem. A decisao de usar VARCHAR ao inves de ENUM foi bem fundamentada. As observacoes levantadas sao melhorias opcionais que nao bloqueiam o progresso para a proxima task.

**Proximos passos**: Seguir para a Task 2.0 (Domain layer - entidades de dominio, gateways e use cases), onde a validacao dos valores aceitos para os campos VARCHAR devera ser implementada.

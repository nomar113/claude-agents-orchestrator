# Tarefa 2.0: Backend — Tenancy: group_id, backfill e isolamento de dados

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Tornar todos os dados do sistema pertencentes a um grupo: adicionar `group_id` nas tabelas raiz, migrar os dados legados para o grupo "Família" (usuario Ramon), e filtrar todas as queries por `RequestContext.groupId`. E a mudanca mais invasiva da feature (toca todos os gateways) — por isso vem cedo. Ao final, dois usuarios em grupos distintos tem dados completamente isolados.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — filtros explicitos de `group_id` nos gateways (decisao da techspec: sem Hibernate `@Filter` global).
- `clean-code` — manter queries visiveis e testaveis.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-4.1: todos os dados (cartoes, compras, faturas, categorias, orcamentos, notificacoes) pertencem a um grupo e so podem ser lidos/alterados por quem tem acesso.
- RF-4.5 (parcial): dados existentes migrados para a conta do Ramon (grupo "Família") sem perda.
- Metrica do PRD: 0 endpoints de dados acessiveis sem token valido (teste automatizado parametrizado).
- Erros: recurso de outro grupo responde 404 (nao vazar existencia).
</requirements>

## Subtarefas

- [ ] 2.1 Migracao 1: `ADD COLUMN group_id BIGINT NULL` nas tabelas raiz — `holders`, `payment_methods`, `categories`, `budgets`, `payment_notifications`, `purchase_invoices`, `installments` (filhas herdam via FK, sem coluna propria).
- [ ] 2.2 Migracao 2 (backfill): criar grupo "Família", usuario Ramon (`ramonmesquita113@gmail.com`, sem senha) e `UPDATE ... SET group_id = 1`.
- [ ] 2.3 Migracao 3: `MODIFY group_id NOT NULL` + FKs + indices compostos; uniques globais viram compostos (`(group_id, name)` em categories, `(group_id, reference_month)` em budgets) — ver techspec.md.
- [ ] 2.4 Atualizar todos os gateways/repositories de dados para filtrar por `group_id` vindo do `RequestContext` (leitura e escrita).
- [ ] 2.5 Seed das 15 categorias padrao ao criar grupo novo (copia por grupo).
- [ ] 2.6 Acesso a recurso de outro grupo retorna 404.
- [ ] 2.7 Teste parametrizado de seguranca varrendo o mapping do MVC: todo endpoint de dados retorna 401 sem token.
- [ ] 2.8 Testes de isolamento entre grupos (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Modelos de Dados" (migracao em 3 passos), "Consideracoes Tecnicas" (grupo como dono; filtro explicito nos gateways) e "Abordagem de Testes".

## Criterios de Sucesso

- Migracoes Flyway rodam sobre dump com dados legados sem perda (backfill completo, nenhuma linha com `group_id` nulo).
- Usuario de um grupo nao le nem escreve dados de outro grupo (404).
- Matriz de seguranca: 100% dos endpoints de dados retornam 401 sem token.
- Novo grupo nasce com as 15 categorias padrao.
- `typecheck`/`build`/`lint`/`test` passando no backend.

## Testes da Tarefa

- [ ] Unidade: seed de categorias na criacao de grupo; usecases existentes com filtro de grupo.
- [ ] Integracao: dois usuarios/grupos seedados — A nao le/escreve dados de B (404); teste parametrizado 401 sem token em todos os endpoints; migracao Flyway sobre dump legado verifica backfill sem perda.
- [ ] Testes E2E: nao aplicavel nesta tarefa (cobertos na Tarefa 9.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai/src/main/resources/db/migration/` (3 novas migracoes)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../application/*/entrypoint/database/` (todos os gateways de dados)
- `/Volumes/SSD480GB/projects/controlai/src/main/kotlin/.../domain/` (usecases que criam grupo/seed)

Nota de verificacao: testes do backend exigem Docker MySQL rodando.

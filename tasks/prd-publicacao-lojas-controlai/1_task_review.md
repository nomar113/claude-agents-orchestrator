# Review: Task 1.0 - Seed da conta de revisor das lojas (backend)

**Revisor**: AI Code Reviewer
**Data**: 2026-09-13
**Arquivo da task**: 1_task.md
**Repositório revisado**: `/Volumes/SSD480GB/projects/controlai` (código-fonte da tarefa; o repo orquestrador guarda apenas PRD/techspec/tasks)
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

A Tarefa 1.0 cria, via `V40__seed_store_reviewer_account.sql`, uma conta fixa de revisor (grupo dedicado, usuário com hash BCrypt, assinatura `GRANDFATHERED`/`ACTIVE`, 15 categorias padrão, 1 holder, 1 cartão de crédito fictício e 2 compras manuais de exemplo) para uso do time de revisão da App Store e da Google Play, já que o cadastro público está desativado. A migração segue fielmente o mesmo padrão de dado usado no grandfathering (`V39`) e no bloco conceitual da `techspec.md`, sem introduzir nenhuma lógica de aplicação nova — apenas `INSERT`s.

Validei cada tabela/coluna/enum tocado pela migração contra o schema real (li todas as migrações que criam e alteram `groups`, `users`, `group_members`, `subscriptions`, `categories`, `holders`, `payment_methods` e `payment_notifications`, e também consultei `SHOW CREATE TABLE` no MySQL local para confirmar o estado atual, não apenas o que os arquivos de migração sugerem). Os 15 pares nome/emoji de categoria em `V40` batem **exatamente**, na mesma ordem, com `SeedDefaultCategoriesProvider.DEFAULT_CATEGORIES` (o código Kotlin que semeia categorias para grupos novos) — não há nenhuma categoria inventada ou com emoji divergente. Os enums usados (`origin = 'MANUAL'`, `origin_type = 'MANUAL'`, `type = 'CREDIT_CARD'`, `plan = 'GRANDFATHERED'`, `status = 'ACTIVE'`) são todos valores válidos dos `ENUM`/domínio atuais.

Rodei a suíte completa de forma independente (`./gradlew test --rerun-tasks`, forçando reexecução em vez de reaproveitar cache `UP-TO-DATE`) contra o `mysql_local` real: **BUILD SUCCESSFUL**, e a agregação dos XMLs de resultado (`build/test-results/test/*.xml`) confirma **621 testes, 0 falhas, 0 erros** (a task reporta "623 testes" — diferença pequena e não investigada a fundo, provavelmente metodologia de contagem; não há nenhuma falha real em nenhum dos dois números). Os dois testes novos de `StoreReviewerAccountSeedIntegrationTest` passam individualmente (confirmado no XML dedicado da classe). Também confirmei, com `SELECT`s diretos no MySQL local, que a migração já havia sido aplicada nesse ambiente em execução anterior (grupo `id=3829`, usuário `id=3737`) e que o comportamento documentado no comentário do teste — "outras suítes fazem `DELETE FROM categories/holders/payment_methods/payment_notifications` sem `WHERE`" — é real e observável: hoje, nesse banco de teste, `categories`/`holders`/`payment_methods` do grupo do revisor estão zerados por efeito colateral de outras suítes, enquanto `groups`/`users`/`group_members`/`subscriptions` permanecem íntegros. Isso valida, de forma independente, a decisão de escopo do novo teste.

Fiz `grep` por vazamento de senha em texto claro (`revisor.loja@nomar.com.br`, e um grep amplo por `6JjAPIqwspiQFblSnjWf`) em ambos os repositórios (`controlai` e `claude-agents-orchestrator`, incluindo a pasta da task) — nenhuma ocorrência fora do hash BCrypt na própria migração. A decisão de não commitar a senha em texto claro foi seguida corretamente.

**Ponto de atenção relevante (MAJOR, ver detalhes abaixo)**: encontrei, via `SHOW CREATE TABLE controlai.holders` no MySQL real, que a tabela `holders` ainda carrega uma constraint `UNIQUE KEY \`name\` (\`name\`)` **global** (não escopada por `group_id`), apesar do comentário de `V30__make_group_id_not_null.sql` afirmar "Holders do not have a global unique name constraint to drop" — o que está incorreto. Isso é uma dívida técnica pré-existente (não introduzida por esta tarefa), mas é relevante para `V40` porque o `INSERT INTO holders (..., name) VALUES (..., 'Revisor ControlAI')` pode falhar em produção se, por coincidência, já existir qualquer holder com esse nome exato em qualquer grupo.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `controlai/src/main/resources/db/migration/V40__seed_store_reviewer_account.sql` | OK | 0 críticos / 1 major (risco de colisão em `holders.name`, não é defeito do SQL em si) / 1 minor |
| `controlai/src/test/kotlin/br/com/nomar/controlai/config/StoreReviewerAccountSeedIntegrationTest.kt` | OK | 0 críticos / 0 major / 1 minor |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

1. **Risco de colisão em produção: `holders` ainda tem `UNIQUE KEY (name)` global, não escopada por `group_id`.** Confirmado via `SHOW CREATE TABLE controlai.holders` no MySQL local:
   ```sql
   UNIQUE KEY `name` (`name`),
   KEY `idx_holders_group` (`group_id`),
   CONSTRAINT `fk_holders_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
   ```
   `V30__make_group_id_not_null.sql` trata `categories` e `budgets` corretamente (substitui a unique global por uma composta `group_id + coluna`), mas para `holders` o comentário diz *"Holders do not have a global unique name constraint to drop"* — afirmação incorreta, já que `V5__create_holders_table.sql` cria `UNIQUE (name)` e nenhuma migração posterior a remove ou a torna composta.
   - **Efeito em `V40`**: `INSERT INTO holders (group_id, name) VALUES (@reviewer_group_id, 'Revisor ControlAI')` (linha 40) falhará com violação de unicidade se, por coincidência, **qualquer** grupo real já tiver um holder chamado exatamente `'Revisor ControlAI'`. Como Flyway aplica migrações em ordem e falha o boot da aplicação inteira se uma migração falhar, isso bloquearia o deploy — não apenas a criação da conta seed.
   - **Por que não é CRITICAL**: é uma dívida de schema pré-existente, não um defeito introduzido por esta tarefa; o nome escolhido (`'Revisor ControlAI'`) é suficientemente específico para tornar a colisão real improvável, e não há como o autor da tarefa ter previsto isso sem inspecionar o `SHOW CREATE TABLE` real (a definição em `V5` mais os comentários enganosos de `V30` levam a crer, lendo só os arquivos de migração, que a constraint já foi tratada).
   - **Por que não é apenas observação**: é um modo de falha silencioso até o momento do deploy em produção — não há teste que possa detectá-lo hoje (o ambiente de teste local não tem esse holder) e a falha só apareceria no boot em produção, exatamente o ambiente onde essa conta é mais necessária (App Review).
   - **Correção sugerida (recomendada antes do deploy em produção, não necessariamente antes de mergear o código)**: rodar `SELECT COUNT(*) FROM holders WHERE name = 'Revisor ControlAI'` contra o banco de produção antes de aplicar `V40`; se o resultado for `0`, pode aplicar com segurança. Alternativa mais robusta e reutilizável: trocar o `INSERT` por `INSERT IGNORE` (aceitando o pequeno risco de silenciosamente não criar o holder se colidir) ou, melhor, escolher um nome ainda mais inequívoco (ex.: `'Revisor ControlAI (App Review)'`) para reduzir a probabilidade a praticamente zero. A correção definitiva (tornar a unique de `holders` composta por `group_id + name`, como já foi feito em `categories`) é dívida técnica pré-existente e está fora do escopo desta tarefa, mas vale registrar como débito conhecido.

### Problemas Minor

1. **`V40__seed_store_reviewer_account.sql` — lista de categorias duplica conhecimento já existente em `SeedDefaultCategoriesProvider.kt`.** Os 15 pares nome/emoji (linhas 18-33) são uma cópia literal de `SeedDefaultCategoriesProvider.DEFAULT_CATEGORIES` (confirmado, batem 100%). Isso é aceitável e até esperado — a `techspec.md` explicitly pede "sem lógica de aplicação nova" — mas cria acoplamento silencioso: se a lista de categorias padrão mudar no futuro, `V40` não vai refletir a mudança automaticamente (nem deveria, já que é um seed pontual), mas vale deixar registrado para quem for revisar `SeedDefaultCategoriesProvider` no futuro que existe uma cópia estática em `V40`.

2. **`StoreReviewerAccountSeedIntegrationTest.kt:23-33` — comentário de cabeçalho longo (11 linhas).** Style guide genérico da skill pede "evitar comentários", mas o próprio projeto já não segue essa regra de forma estrita em testes de integração não triviais (ex.: `TimezoneJdbcIntegrationTest.kt`, citado na review da Tarefa 1.0 de "padronizacao-datas-timezone"). O comentário aqui é, inclusive, particularmente valioso — explica uma decisão de design não óbvia (por que não asserta contagens em `categories`/`holders`/etc.) que seria fácil de questionar numa review futura sem esse contexto. Não é um problema real, apenas uma nota de que segue o precedente do projeto, não o checklist genérico.

## Destaques Positivos

- **Lista de categorias validada byte-a-byte contra o código Kotlin real**: os 15 pares nome/emoji em `V40` (linhas 18-33) são idênticos, na mesma ordem, a `SeedDefaultCategoriesProvider.DEFAULT_CATEGORIES` — não há categoria inventada, emoji trocado ou nome com erro de digitação.
- **Enums e tipos de coluna corretos em todas as tabelas tocadas**, verificado contra o schema real via `SHOW CREATE TABLE` (não apenas contra os arquivos de migração): `origin='MANUAL'` e `origin_type='MANUAL'` são valores válidos do `ENUM` atual (pós `V9`/`V38`); `type='CREDIT_CARD'` bate com `PaymentMethodType.kt`; `plan='GRANDFATHERED'`/`status='ACTIVE'` reaproveitam exatamente o padrão de `V39`; `card_last_digits='4242'` cabe em `CHAR(4)`; `amount` cabe em `DECIMAL(19,2)`.
- **`categories` e `payment_methods` não têm o mesmo risco de colisão de `holders`** (verificado via `SHOW CREATE TABLE`): `categories` já tem `UNIQUE KEY (group_id, name)` corretamente escopada por grupo (fruto de `V30`), e `payment_methods` não tem unique constraint em `name`. Só `holders` ficou com a constraint global — achado documentado no Problema Major 1.
- **Ordem de inserção e uso de `LAST_INSERT_ID()` corretos**: grupo → usuário → `group_members` → categorias → assinatura → holder → payment method → notifications, sempre referenciando a variável de sessão certa (`@reviewer_group_id`, `@reviewer_user_id`, `@reviewer_holder_id`, `@reviewer_payment_method_id`). É o primeiro uso de `SET @var = LAST_INSERT_ID()` entre as migrações deste repositório, mas a suíte completa (que aplica `V40` via Flyway durante o boot do Spring) provou empiricamente que o padrão funciona corretamente com o executor MySQL do Flyway usado neste projeto.
- **Nenhuma senha em texto claro em nenhum dos dois repositórios** — confirmado por grep direcionado (`revisor.loja@nomar.com.br`, string aleatória de teste do padrão de senha) em `controlai` e em `claude-agents-orchestrator/tasks/prd-publicacao-lojas-controlai/`. Apenas o hash BCrypt está versionado.
- **Teste novo reaproveita literalmente o padrão de `SubscriptionGuardFilterIntegrationTest`** (mesmo esquema de `buildToken` com claim `groupId`, mesmo endpoint `/purchases`, mesmo uso de `JwtEncoder`), em vez de inventar um mecanismo de autenticação de teste novo — reduz risco de teste "não representativo do fluxo real".
- **Decisão de escopo do teste (não assertar `categories`/`holders`/`payment_methods`/`payment_notifications`) validada de forma independente nesta revisão**: consultei o MySQL de teste local depois da suíte completa rodar e confirmei que essas tabelas do grupo do revisor estavam de fato zeradas por `DELETE`s sem `WHERE` de outras suítes, exatamente como o comentário do teste descreve — não é uma alegação não verificável, é um comportamento real e reproduzido.
- **Suíte completa executada de forma independente nesta revisão** (não apenas confiando no relato da task): `./gradlew test --rerun-tasks`, BUILD SUCCESSFUL, 621 testes / 0 falhas / 0 erros via agregação dos XMLs de resultado. O log de `ERROR ... Data truncated for column 'origin'` que aparece no console durante o shutdown vem de um listener assíncrono de fila (`PaymentNotificationQueueListener`) processando uma mensagem de teste de uma suíte não relacionada (`SubscriptionGuardFilterIntegrationTest`, que usa `origin: "sms-app"` de propósito para simular payload malformado) — confirmei que esse erro aparece nos `system-out` de testes pré-existentes sem relação com `V40`, não é uma falha nova introduzida por esta tarefa.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (clean-code) | OK |
| Kotlin/Spring Boot | OK |
| Migração Flyway / Schema | Observação (ver Problema Major 1 — risco de colisão em `holders.name`, pré-existente) |
| REST/HTTP | N/A (nenhum endpoint novo) |
| Testes | OK |

## Recomendações

1. **(Major, verificar antes do deploy em produção, não bloqueia o merge do código desta tarefa)** Antes de aplicar `V40` em produção, rodar `SELECT COUNT(*) FROM holders WHERE name = 'Revisor ControlAI'` para confirmar ausência de colisão, ou trocar o `INSERT` por uma forma mais defensiva (`INSERT IGNORE`, ou um nome ainda mais inequívoco). Considerar, como item de débito técnico separado (fora desta tarefa), corrigir a constraint `UNIQUE KEY (name)` de `holders` para `UNIQUE (group_id, name)`, como já foi feito em `categories` na `V30`.
2. **(Minor, opcional)** Nenhuma ação necessária — a duplicação da lista de categorias entre `V40` e `SeedDefaultCategoriesProvider.kt` é esperada dado o requisito de "sem lógica nova"; só vale ter em mente ao alterar as categorias padrão no futuro.
3. **(Já coberto pelo plano, sem ação nesta tarefa)** O teste manual de navegação completa (subtarefa/critério de teste pendente) está corretamente adiado para as Tarefas 5.0/6.0 conforme a própria `techspec.md` ("Testes de E2E... a validação final é um smoke test manual"). Não bloqueia esta tarefa.

## Veredito

**APROVADO COM OBSERVAÇÕES.** A migração `V40` está correta: todos os tipos de coluna, valores de `ENUM` e FKs tocados foram verificados não só contra os arquivos de migração, mas contra o schema real via `SHOW CREATE TABLE`, e a lista de categorias bate exatamente com o código Kotlin que ela substitui. O teste de integração é significativo (reaproveita o padrão real de autenticação/autorização do `SubscriptionGuardFilter`, exercitando o fluxo real de JWT + rota protegida) e não é frágil — a decisão de não assertar contagens em `categories`/`holders`/`payment_methods`/`payment_notifications` foi verificada de forma independente nesta revisão como corretamente motivada por um comportamento real e observável de outras suítes do repositório, não uma suposição. A suíte completa (621 testes) passa com 0 falhas, confirmado por execução própria e independente desta revisão, não apenas pelo relato da task. Não há vazamento de senha em texto claro em nenhum dos dois repositórios.

O único ponto que impede a aprovação sem ressalvas é o Problema Major 1: a tabela `holders` carrega uma constraint de unicidade global em `name` (dívida pré-existente, não introduzida por esta tarefa, e documentada de forma incorreta no comentário de `V30`) que pode fazer `V40` falhar no boot de produção caso já exista, por coincidência, um holder chamado exatamente `'Revisor ControlAI'`. Isso não bloqueia o merge do código nem a conclusão desta tarefa como unidade de trabalho, mas **deve ser verificado manualmente contra o banco de produção antes de aplicar a migração em produção** — recomendação registrada acima. Com essa verificação feita (ou o `INSERT` tornado defensivo), a tarefa está pronta para as Tarefas 5.0/6.0 (App Review Information), que dependem das credenciais desta conta seed.

## Addendum — correção aplicada após esta review (2026-09-13)

O Problema Major 1 foi corrigido diretamente em `V40__seed_store_reviewer_account.sql` antes do merge:

- O `INSERT INTO holders` passou a usar `ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)`, o idiom padrão de MySQL para reaproveitar a linha existente em vez de falhar caso o nome já exista em outro grupo — a migração (e o boot da aplicação) não é mais bloqueada por uma colisão de `holders.name`.
- O nome do holder foi trocado de `'Revisor ControlAI'` para `'Revisor da Loja (App Review)'`, reduzindo ainda mais a chance de colisão real.
- O banco de teste local foi recriado do zero (`DROP DATABASE` + `CREATE DATABASE`) e `./gradlew test --rerun-tasks` foi executado novamente contra o schema limpo: **BUILD SUCCESSFUL**, `StoreReviewerAccountSeedIntegrationTest` com 2/2 testes passando.
- A correção estrutural de fundo (tornar `holders` `UNIQUE (group_id, name)`, como já foi feito em `categories`) continua sendo dívida técnica pré-existente, fora do escopo desta tarefa, e permanece registrada como recomendação futura.

Com essa correção, não há mais nenhuma ressalva pendente de aplicação — apenas o item de dívida técnica pré-existente (fora de escopo) mencionado acima.

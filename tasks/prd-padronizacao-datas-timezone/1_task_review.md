# Review: Task 1.0 - Backend — Configuração central de timezone UTC

**Revisor**: AI Code Reviewer
**Data**: 2026-08-23
**Arquivo da task**: 1_task.md
**Repositório revisado**: `/Volumes/SSD480GB/projects/controlai` (código-fonte da tarefa; o repo orquestrador guarda apenas PRD/techspec/tasks)
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

A Tarefa 1.0 fixa explicitamente UTC em Jackson (`spring.jackson.time-zone`), Hibernate (`spring.jpa.properties.hibernate.jdbc.time_zone`) e no driver JDBC (`connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true` na URL do datasource), exatamente como especificado no bloco YAML da seção "Configuração central de timezone" da `techspec.md`. As três subtarefas de configuração (1.1-1.3) foram implementadas literalmente conforme o spec, e as subtarefas de teste (1.4-1.5) foram cobertas com uma suíte de unidade e uma suíte de integração contra MySQL real.

**Ponto de atenção relevante**: a mudança foi aplicada em `application.yml`, na raiz do repositório `controlai` — não em `src/main/resources/application.yml`, caminho citado tanto em "Arquivos relevantes" de `1_task.md` quanto de `techspec.md`. Verifiquei isso de forma independente: não existe `application.yml` em `src/main/resources` (só `application.properties`, com chaves não relacionadas a datasource/jackson/jpa), e o arquivo na raiz já continha `spring.datasource.url`, `spring.flyway.*`, `aws.sqs.*` etc. *antes* desta tarefa — ou seja, é uma convenção pré-existente do projeto (Spring Boot carrega `file:./application.yml` com prioridade sobre `classpath:/application.yml`), não uma decisão isolada de quem implementou. O arquivo correto foi editado. A imprecisão está apenas na documentação da task/techspec, que deveria referenciar o caminho real — ver Recomendações.

**Risco de produção (avaliação solicitada explicitamente)**: a URL JDBC de produção é injetada via variável de ambiente `DB_URL`, externa ao repositório (confirmei: não há `Dockerfile`, workflow de CI/CD ou arquivo de deploy no repo `controlai` que referencie `DB_URL`). O novo valor com `connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true` está apenas no *default* do placeholder `${DB_URL:jdbc:mysql://...}`. Se o `DB_URL` de produção já estiver setado como uma URL completa sem esses parâmetros (cenário plausível e, por sinal, o que encontrei — fora do diff revisado — num run config local do IDE apontando para um host remoto sem os novos parâmetros), o default é totalmente ignorado e a aplicação em produção continua sem a correção, silenciosamente, sem log ou erro de startup. Isso é diretamente relevante para o critério de sucesso 1.4 ("vale tanto para local quanto para produção") e para a frase da própria task "esta é a base de toda a padronização: nenhuma outra tarefa de backend deve iniciar antes desta configuração estar em vigor" — se não estiver em vigor em produção, as Tarefas 2.0-4.0 (que dependem de 1.0) herdam uma falsa sensação de que a base está pronta. Classifico isso como **MAJOR** (não CRITICAL, porque não há defeito de código: o código entregue, testado e revisado está correto e correto localmente) — mas é um MAJOR que **deve ser resolvido/verificado operacionalmente antes de considerar o PRD como um todo concluído**, não apenas anotado. Detalhes e mitigação sugerida na seção de Problemas Major.

Validação independente feita nesta revisão: rodei os dois novos test classes (`./gradlew test --tests TimezoneConfigurationTest --tests TimezoneJdbcIntegrationTest`) — todos passam. Reproduzi também as 2 falhas pré-existentes (`PaymentNotificationControllerTest.PATCH payment-method returns 200...` e `UpdateNotificationPaymentMethodProviderTest.should update payment method without subCard...`) e confirmei via `git stash`/`git stash pop` que ambas falham igualmente sem a mudança desta tarefa aplicada — são de fato pré-existentes e não relacionadas a timezone (ambas verificam `cardLastDigits`/`subCardId` de meio de pagamento, não datas).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application.yml` | OK | 0 críticos / 1 major (risco de produção, não é defeito do arquivo em si) / 0 minor |
| `src/test/kotlin/br/com/nomar/controlai/config/TimezoneConfigurationTest.kt` | OK | 0 críticos / 0 major / 1 minor |
| `src/test/kotlin/br/com/nomar/controlai/config/TimezoneJdbcIntegrationTest.kt` | OK | 0 críticos / 0 major / 1 minor |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

1. **Risco operacional: default de `DB_URL` com os novos parâmetros de timezone pode nunca chegar a produção.** `application.yml`, linha 3: `url: ${DB_URL:jdbc:mysql://localhost:3306/controlai?connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true}`. Como `DB_URL` é gerenciado fora do repositório (variável de ambiente/secret), nada no código, nos testes ou no pipeline garante que o valor de produção inclua `connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true`. Se o `DB_URL` de produção já for uma string completa (o padrão mais comum para strings de conexão de banco gerenciadas fora do repo), o default do YAML é simplesmente substituído e a aplicação em produção volta a depender do timezone do host MySQL, exatamente o problema que esta tarefa deveria eliminar — e o requisito 3 do PRD ("um timestamp de evento persistido deve representar o mesmo instante no tempo independentemente do timezone do host") ficaria não atendido em produção mesmo com o código "correto".
   - **Por que não é CRITICAL**: o código, a configuração e os testes entregues nesta tarefa estão corretos e verificados; o gap é de responsabilidade operacional (atualizar um secret fora do repo), não um bug introduzido pela implementação.
   - **Por que não pode ser apenas "observação"**: é um modo de falha silencioso — não há log, erro de boot ou teste (nem poderia haver, já que o valor real de produção não é acessível a partir do repositório) que denuncie o problema; o sintoma só reaparece como os bugs de deslocamento de horário que esta tarefa pretende eliminar, e só em produção.
   - **Correção sugerida (recomendada, fora do escopo estritamente obrigatório da Tarefa 1.0, mas de alto custo-benefício)**: adicionar um log de verificação no boot, seguindo o mesmo padrão de observabilidade já usado no projeto e já previsto na techspec para o parser de SMS (seção "Monitoramento e Observabilidade" da techspec.md prevê logs `WARN` para detectar configuração inesperada em produção). Exemplo:
     ```kotlin
     @Component
     class TimezoneStartupCheck(
         private val jdbcTemplate: JdbcTemplate,
     ) {
         private val logger = LoggerFactory.getLogger(TimezoneStartupCheck::class.java)

         @EventListener(ApplicationReadyEvent::class)
         fun logSessionTimeZone() {
             val sessionTimeZone = jdbcTemplate.queryForObject(
                 "SELECT @@session.time_zone", String::class.java,
             )
             if (sessionTimeZone != "+00:00") {
                 logger.warn(
                     "MySQL session time_zone is '{}', expected '+00:00' — DB_URL is likely " +
                         "missing connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true",
                     sessionTimeZone,
                 )
             }
         }
     }
     ```
     Isso transforma uma falha silenciosa em algo observável nos logs de produção logo no primeiro boot, sem exigir mudança de infraestrutura. Alternativa mais simples: apenas confirmar manualmente com o Ramon, antes de avançar para a Tarefa 2.0, que o `DB_URL` de produção já contém (ou será atualizado para conter) esses parâmetros — e registrar essa confirmação em algum lugar rastreável (ex: nota na própria `tasks.md` ou `techspec.md`).

### Problemas Minor

1. **`TimezoneJdbcIntegrationTest.kt:30` — nome da tabela de teste usa abreviação (`tz_probe`).** O padrão de código pede nomes sem abreviações. Como é uma tabela efêmera (criada e destruída dentro do próprio teste, nunca chega ao schema versionado por Flyway), o impacto é mínimo, mas `timezone_probe` seria mais aderente ao padrão sem custo adicional.

2. **`TimezoneConfigurationTest.kt:26-29` — o teste de Hibernate verifica apenas a presença da property no `Environment`, não seu efeito real.** `hibernate jdbc time zone is fixed to UTC via configuration` confirma que `spring.jpa.properties.hibernate.jdbc.time_zone=UTC` está no `Environment`, mas isso testa a configuração declarada, não o comportamento do Hibernate ao ler/escrever timestamps. Não é um problema por si só — o efeito real é coberto (indiretamente, mas de forma sólida) pelo teste de round-trip em `TimezoneJdbcIntegrationTest` — mas vale deixar registrado que o nome do teste ("is fixed to UTC via configuration") é mais preciso do que "is applied", que seria a leitura mais natural do requisito 1.4 da task.

## Destaques Positivos

- O trecho de `application.yml` bate literalmente com o bloco YAML de "Configuração central de timezone" da `techspec.md` — mesma chave, mesmos parâmetros de URL, mesma ordem.
- Uso de `connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true` em vez do parâmetro legado `serverTimezone`, exatamente a decisão registrada em "Considerações Técnicas" da techspec, com a justificativa correta (força a sessão a cada conexão, independentemente do timezone do container).
- Nenhuma mudança em `docker-compose.yml`/imagem MySQL, conforme exigido pelos requisitos da task — confirmado por `git diff` (nenhum arquivo de infraestrutura tocado).
- `TimezoneJdbcIntegrationTest` valida o comportamento real via `SELECT @@session.time_zone`, não apenas a configuração declarada — é a forma mais direta possível de provar que `forceConnectionTimeZoneToSession` está de fato surtindo efeito na conexão usada pela aplicação, e evita a armadilha de um teste que só confirma "a property existe" sem confirmar "o MySQL obedeceu".
- O teste parametrizado (`@ValueSource(strings = ["UTC", "America/Sao_Paulo"])`) que varia `TimeZone.setDefault(...)` e usa `try/finally` para restaurar o timezone original é uma boa prática — evita vazar estado global para outros testes da suíte caso a asserção falhe no meio.
- A tabela de teste é criada e destruída dentro do próprio teste (`@BeforeEach`/`@AfterEach`), evitando qualquer mudança em Flyway apenas para uma tabela descartável — decisão pragmática e correta para este caso.
- Convenção de nomes de teste (strings entre backticks em inglês) é idêntica à usada no restante do projeto (ex: `BudgetMigrationIntegrationTest`, `PaymentNotificationCategoryIntegrationTest`).
- Validação cruzada e independente nesta revisão: rodei a suíte completa das 2 falhas pré-existentes com e sem a mudança (via `git stash`) e confirmei que são idênticas em ambos os casos — a alegação de "pré-existentes, não relacionadas" está correta.
- Nenhuma mudança de comportamento observável fora do escopo — `git diff` confirma que só `application.yml` (config) e os dois novos arquivos de teste foram tocados, exatamente como o critério de sucesso da task exige ("nenhuma mudança de comportamento observável ainda nesta tarefa").

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (clean-code) | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP | N/A (nenhum endpoint tocado) |
| Logging/Observabilidade | Observação (ver Problema Major 1 — recomenda-se log de verificação no boot) |
| Testes | OK |

Nota sobre o checklist genérico de `code-standards.md` ("sem linhas em branco dentro de métodos", "sem comentários"): o projeto `controlai` não segue essas duas regras de forma real — arquivos de teste já existentes (ex: `BudgetMigrationIntegrationTest.kt`) usam linhas em branco livremente dentro dos métodos, e `InstallmentReconciliationRunnerGateIT.kt` já usa comentário de cabeçalho KDoc para documentar um teste de integração não-trivial. Os dois novos arquivos desta tarefa seguem exatamente esse padrão real do projeto (inclusive o comentário de cabeçalho em `TimezoneJdbcIntegrationTest.kt`, que segue o mesmo precedente), portanto não foram tratados como violação — o CLAUDE.md do projeto e a convenção real do código têm precedência sobre o checklist genérico da skill.

## Recomendações

1. **(Major, requer ação antes de fechar o PRD, não necessariamente antes de mergear este código)** Confirmar explicitamente — com Ramon ou verificando o valor real de `DB_URL` em produção — que a URL de produção já inclui `connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true`, ou providenciar essa atualização como parte do deploy desta tarefa. Considerar adicionar o log de verificação no boot sugerido no Problema Major 1, que torna esse risco observável em vez de silencioso, e serve também para as Tarefas 2.0-4.0, que assumem esta base como já "em vigor".
2. **(Minor, opcional)** Renomear a tabela de teste `tz_probe` para `timezone_probe` em `TimezoneJdbcIntegrationTest.kt`, alinhando com a regra de "sem abreviações".
3. **(Documentação, fora do código)** Atualizar `1_task.md` e a tabela "Arquivos relevantes" de `techspec.md` para referenciar `application.yml` (raiz do projeto) em vez de `src/main/resources/application.yml` — o caminho documentado está desatualizado/incorreto em relação à estrutura real do projeto `controlai`.

## Veredito

**APROVADO COM OBSERVAÇÕES.** A implementação da Tarefa 1.0 está correta e completa dentro do que o código pode garantir: `application.yml` reproduz fielmente o trecho da techspec, a URL JDBC usa a abordagem recomendada (`connectionTimeZone`/`forceConnectionTimeZoneToSession`), e a suíte de testes (2 classes, 5 testes) verifica tanto a configuração declarada quanto — de forma mais importante — o comportamento real do MySQL sob a nova configuração, incluindo independência do timezone default da JVM. As 2 falhas pré-existentes na suíte completa foram verificadas de forma independente nesta revisão e confirmadas como não relacionadas a esta mudança.

Nenhum problema crítico ou major de código bloqueia o avanço para a Tarefa 2.0. O único ponto que merece tratamento antes de considerar esta base "em vigor" em produção — condição que a própria task declara como pré-requisito para todas as tarefas seguintes — é o risco descrito no Problema Major 1: o default de `DB_URL` no `application.yml` só se aplica se a variável de ambiente de produção não estiver setada explicitamente sem esses parâmetros. Recomenda-se resolver isso (confirmação manual ou log de verificação no boot) antes de tratar o PRD como "corrigido em produção", ainda que isso não precise bloquear o merge do código desta tarefa nem o início da Tarefa 2.0 em paralelo.

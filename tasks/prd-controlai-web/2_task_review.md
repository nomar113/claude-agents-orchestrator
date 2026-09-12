# Review: Task 2.0 - Liberar CORS no backend para o(s) domínio(s) da web

**Revisor**: AI Code Reviewer
**Data**: 2026-09-11
**Arquivo da task**: 2_task.md
**Status**: APROVADO

## Resumo

A tarefa exigia liberar CORS no backend `controlai` para o(s) domínio(s) do ControlAI Web, **sem alterar código Kotlin** — apenas configuração de ambiente — e cobrir o comportamento com um teste de integração. A implementação cumpre exatamente esse escopo: `CorsConfig.kt`/`SecurityConfig.kt`/`application.yml` permanecem intocados (confirmado via `git diff` do commit da tarefa e leitura direta dos arquivos), a variável `CORS_ALLOWED_ORIGIN_PATTERNS` foi aplicada em produção com três origens explícitas (domínio customizado, domínio Vercel de produção e um padrão wildcard restrito a previews de um projeto específico — sem uso de `*` global), e foi adicionado `CorsConfigIntegrationTest.kt`, um teste de integração novo com 3 casos cobrindo origem permitida (domínio customizado), origem permitida via wildcard (preview Vercel) e origem bloqueada.

Verificações independentes realizadas nesta review (não apenas leitura do relato da task):
- Rodei `./gradlew test --tests "...CorsConfigIntegrationTest"` localmente (MySQL/LocalStack já de pé via `docker-compose`): **3/3 testes passando**.
- Rodei a suíte completa `./gradlew test`: **BUILD SUCCESSFUL, 618 testes, 0 falhas, 0 erros** — sem regressões.
- Confirmei via `git diff HEAD~1 HEAD --stat` que o único arquivo alterado no commit da tarefa é o teste novo (64 linhas adicionadas, nenhuma removida) — nenhuma classe de configuração tocada.
- Validei via `curl` direto contra `https://api.opencod3.com.br/health`: preflight da origem `https://controlai.opencod3.com.br` retorna `200` com `access-control-allow-origin` e `access-control-allow-credentials: true`; preflight de origem não listada retorna `403` com corpo `Invalid CORS request` — reproduzindo de forma independente o que o `2_task.md` relata.

Qualidade geral do teste é alta e segue fielmente as convenções já estabelecidas no diretório (`SubscriptionGuardFilterIntegrationTest.kt`): `@SpringBootTest` + `@AutoConfigureMockMvc`, nomes de teste em linguagem natural entre backticks, comentário de classe explicando o objetivo e a restrição de não tocar nas classes de config. Não há necessidade de mudanças antes de mergear/considerar a tarefa concluída.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `controlai/src/test/kotlin/br/com/nomar/controlai/config/CorsConfigIntegrationTest.kt` (novo) | OK | 0 |
| `controlai/src/main/kotlin/br/com/nomar/controlai/config/CorsConfig.kt` (verificado, não alterado) | OK | 0 |
| `controlai/src/main/kotlin/br/com/nomar/controlai/config/SecurityConfig.kt` (verificado, não alterado) | OK | 0 |
| `controlai/application.yml` (verificado, não alterado) | OK | 0 |
| `tasks/prd-controlai-web/2_task.md` (documentação da task) | OK | 0 |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **Cobertura não testa explicitamente a segunda origem exata de produção** (`CorsConfigIntegrationTest.kt`, arquivo inteiro). A propriedade de teste inclui três origens: `https://controlai.opencod3.com.br` (exata, testada no teste 1), `https://controlai-web-sepia.vercel.app` (exata, **não testada diretamente**) e o padrão wildcard de preview (testado no teste 2). Como as duas origens exatas usam o mesmo mecanismo de comparação simples de string na lista `allowedOriginPatterns`, o risco de regressão não coberto é baixo — e essa origem específica já foi validada via `curl` em produção conforme documentado no `2_task.md`. Ainda assim, para fechar 100% a matriz de origens configuradas, seria mais robusto adicionar um quarto `@Test` cobrindo `https://controlai-web-sepia.vercel.app` explicitamente, evitando depender apenas de validação manual/curl para essa origem específica.
   - Sugestão (não bloqueante):
     ```kotlin
     @Test
     fun `preflight from the production Vercel origin is accepted`() {
         mockMvc.perform(
             options("/health")
                 .header(HttpHeaders.ORIGIN, "https://controlai-web-sepia.vercel.app")
                 .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "GET"),
         )
             .andExpect(status().isOk)
             .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "https://controlai-web-sepia.vercel.app"))
     }
     ```

## Destaques Positivos

- **Escopo respeitado à risca**: nenhuma linha de `CorsConfig.kt`/`SecurityConfig.kt`/`application.yml` foi tocada, exatamente como a tarefa exigia. Confirmado por leitura direta dos arquivos e por `git diff` do commit, não apenas pelo relato da task.
- **Teste de integração ponta a ponta real**, não um teste unitário isolado: usa `@SpringBootTest` + `MockMvc` contra a rota real `/health`, exercitando o pipeline completo (`WebMvcConfigurer` do `CorsConfig` + `SecurityConfig.cors(Customizer.withDefaults())`), o que dá confiança real de que o comportamento em produção corresponde ao testado.
- **Uso correto de `properties` no `@SpringBootTest`** para sobrepor `app.cors.allowed-origin-patterns` com os valores reais de produção, evitando qualquer necessidade de alterar `application.yml` ou usar `@ActiveProfiles` adicional — técnica idiomática do Spring Boot para testar comportamento orientado a configuração sem tocar em código de produção.
- **Asserção negativa forte**: o teste de origem bloqueada não verifica apenas o status `403`, mas também `header().doesNotExist(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN)` — evita falso positivo em que o status estaria correto mas o header ainda vazasse.
- **Teste do wildcard é o mais valioso dos três**: comprova especificamente que `allowedOriginPatterns` (e não `allowedOrigins`) está em uso, o que é o único jeito de suportar `*` no meio do domínio combinado com `allowCredentials(true)`. Isso funciona como uma rede de segurança contra uma futura refatoração acidental que trocasse `allowedOriginPatterns` por `allowedOrigins` no `CorsConfig.kt`.
- **Aderência total às convenções do diretório**: nome de classe terminando em `IntegrationTest`, nomes de teste em linguagem natural com backticks, comentário de classe de duas linhas explicando o propósito — mesmo padrão de `SubscriptionGuardFilterIntegrationTest.kt`.
- **Configuração de produção segue o requisito de não afrouxar além do necessário**: três origens/padrões explícitos, nenhum uso de `*` global, e o padrão wildcard é escopado ao projeto Vercel específico (`ramon-mesquitas-projects`), não a todo o domínio `vercel.app`.
- **Validação ponta a ponta real em produção** (curl + browser automation) documentada no `2_task.md` e reproduzida de forma independente nesta review com o mesmo resultado.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código (nomenclatura, tamanho, clareza) | OK |
| Kotlin/Spring Boot (`kotlin-springboot`, Gateway/Provider, config via `@Value`) | OK |
| CLAUDE.md do repo `controlai` (arquitetura hexagonal, convenções de teste) | OK |
| Testes | OK |
| Configuração de infraestrutura (CORS em produção) | OK |

## Recomendações

1. (Opcional, não bloqueante) Adicionar um quarto caso de teste cobrindo explicitamente a origem exata `https://controlai-web-sepia.vercel.app`, para não depender apenas de validação manual/curl nessa origem específica de produção.
2. Nenhuma outra ação necessária para esta tarefa.

## Veredito

**APROVADO.** A implementação cumpre integralmente os critérios de sucesso da Tarefa 2.0: nenhuma classe Kotlin de configuração foi modificada, a variável `CORS_ALLOWED_ORIGIN_PATTERNS` foi aplicada em produção de forma restritiva (sem `*` global), e o teste de integração novo cobre adequadamente origem permitida (exata e wildcard) vs. origem negada, seguindo os padrões de teste já estabelecidos no repositório. Suíte completa (618 testes) passa sem regressões, e o comportamento em produção foi validado de forma independente por esta review via `curl`, reproduzindo os mesmos resultados relatados no `2_task.md`. A única observação é uma sugestão de cobertura extra (Minor, não bloqueante). A tarefa pode ser considerada concluída; nenhuma correção é exigida antes de seguir para a próxima etapa do PRD "ControlAI Web".

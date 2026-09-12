# Tarefa 2.0: Liberar CORS no backend para o(s) domínio(s) da web

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Configurar o backend (`controlai`) para aceitar requisições cross-origin vindas do(s) domínio(s) do ControlAI Web (obtidos na Tarefa 1.0), usando a variável de ambiente já existente `CORS_ALLOWED_ORIGIN_PATTERNS`. Nenhuma alteração de código é necessária em `CorsConfig.kt`/`SecurityConfig.kt` — apenas configuração de ambiente — mas a tarefa inclui um teste de integração comprovando o comportamento.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — aplica-se por manter `SecurityConfig`/`CorsConfig` inalterados, seguindo o padrão de configuração via `@Value` já usado no projeto.
</skills>

<requirements>
- Tech Spec `Pontos de Integração`: incluir o(s) domínio(s) de produção/preview do ControlAI Web em `CORS_ALLOWED_ORIGIN_PATTERNS`, sem deploy de código.
- Tech Spec `Arquitetura do Sistema`: `SecurityConfig`/`CorsConfig` permanecem sem alteração de código.
- Não afrouxar o padrão de origem além do necessário (não usar `*` em produção quando já há domínio(s) conhecidos).
</requirements>

## Subtarefas

- [x] 2.1 Definir o(s) valor(es) finais de `CORS_ALLOWED_ORIGIN_PATTERNS` para o ambiente de produção do backend, incluindo o(s) domínio(s) obtidos na Tarefa 1.0.
- [x] 2.2 Aplicar a configuração no ambiente de produção/staging do backend (variável de ambiente, sem alteração de código-fonte).
- [x] 2.3 Escrever um teste de integração para `CorsConfig`/`SecurityConfig` cobrindo: requisição preflight de uma origem permitida (sucesso) e de uma origem não listada (bloqueada).
- [x] 2.4 Validar manualmente, a partir da URL pública da Tarefa 1.0, que o login funciona sem erro de CORS no console do navegador.

## Configuração aplicada em produção

- **Valor de `CORS_ALLOWED_ORIGIN_PATTERNS`**: `https://controlai.opencod3.com.br,https://controlai-web-sepia.vercel.app,https://controlai-*-ramon-mesquitas-projects.vercel.app`
- **Onde foi aplicado**: `export` adicionado em `/root/script.sh` no servidor `root@31.97.83.47` (script de deploy que reinicia o backend via `nohup java -jar`), junto aos demais `export` de ambiente já existentes (`DB_URL`, `JWT_SECRET`, etc.). Nenhum código Kotlin foi alterado.
- **Deploy executado**: script rodado para aplicar a variável; backend reiniciado com sucesso (`git fetch` + `./gradlew bootJar` + restart), `GET /health` voltou a responder `200` após ~45s de boot.
- **Validação via `curl` (preflight `OPTIONS /health` contra `https://api.opencod3.com.br`)**:
  - Origem `https://controlai.opencod3.com.br` → `200`, com `access-control-allow-origin` e `access-control-allow-credentials: true`.
  - Origem `https://controlai-web-sepia.vercel.app` → `200`, com `access-control-allow-origin` correspondente.
  - Origem não listada (`https://attacker.example.com`) → `403 Forbidden`, corpo `Invalid CORS request`, sem header `access-control-allow-origin`.
- **Validação manual no navegador** (`https://controlai.opencod3.com.br`, via Claude in Chrome): `POST /auth/refresh` → `200` e `GET /me` → `402` (bloqueio por assinatura, regra de negócio já existente e não relacionada a CORS); nenhum erro de CORS no console do navegador nem nas network requests.

## Detalhes de Implementação

Ver Tech Spec `Pontos de Integração` e `Arquitetura do Sistema > Visão Geral dos Componentes` (item "Backend `SecurityConfig`/`CorsConfig`"). Referenciar `src/main/kotlin/br/com/nomar/controlai/config/CorsConfig.kt` e `application.yml` (chave `app.cors.allowed-origin-patterns`).

## Critérios de Sucesso

- Requisições originadas do(s) domínio(s) do ControlAI Web são aceitas pelo backend (CORS + credentials).
- Origens não listadas continuam sendo bloqueadas.
- Nenhuma classe Kotlin de configuração foi modificada — só variável de ambiente.

## Testes da Tarefa

- [x] Testes de unidade: não aplicável (sem lógica nova).
- [x] Teste de integração cobrindo origem permitida vs. origem negada (preflight `OPTIONS` + resposta com/sem `Access-Control-Allow-Origin`). Ver `CorsConfigIntegrationTest.kt` (3 testes, 100% passando).
- [x] Teste manual ponta a ponta: login via URL pública da web sem erro de CORS.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/br/com/nomar/controlai/config/CorsConfig.kt` (referência, sem alteração)
- `controlai/application.yml`
- `controlai/src/test/kotlin/br/com/nomar/controlai/config/CorsConfigIntegrationTest.kt` (novo)
- Depende de: domínio(s) obtidos na Tarefa 1.0

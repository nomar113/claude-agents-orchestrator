# Review: Task 1.0 - Provisionar hospedagem web e pipeline de build

**Revisor**: AI Code Reviewer
**Data**: 2026-09-10
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Tarefa 1.0 provisionou a hospedagem web do `controlai-frontend` na Vercel (projeto `ramon-mesquitas-projects/controlai-web`, conectado ao repo `nomar113/controlai-frontend`, auto-deploy em `main`), publicando o `dist/` gerado por `npm run build` (`tsc && vite build`, sem `cap copy`/`trapeze`). O commit `4d9868e` adiciona apenas `vercel.json` (build command, output directory, rewrite catch-all para SPA) e duas linhas em `.gitignore` (`.vercel`, `.env*`) — nenhum arquivo de página ou lógica de negócio foi tocado, confirmado via `git show --stat HEAD`.

Validei de forma independente, via navegador (Chrome, sessão já autenticada do usuário):
- `https://controlai-web-sepia.vercel.app` carrega a SPA e resolve a rota `/tab1` com dados reais da API (orçamento, compras), sem erros de console — confirma ausência de bloqueio de CORS na origem de produção.
- Navegação direta (hard load, não client-side) para `https://controlai-web-sepia.vercel.app/tab2` renderizou a aplicação (título "Ionic App"), em vez de uma página 404 da Vercel — confirma empiricamente que o rewrite catch-all do `vercel.json` funciona para deep links, exatamente o problema que ele foi criado para resolver.
- `npx tsc --noEmit` no estado atual do repositório não acusa erros.

O escopo desta tarefa é essencialmente infraestrutura/configuração (não há lógica de aplicação nova), então a maior parte do checklist de `code-standards.md` (nomenclatura de funções, aninhamento, etc.) não se aplica; a avaliação abaixo foca em corretude da configuração, aderência ao PRD/tech spec e disciplina de escopo/commit.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `controlai-frontend/vercel.json` (novo) | OK | 0 |
| `controlai-frontend/.gitignore` | OK | 1 (minor, redundância) |
| `controlai-frontend/vite.config.ts` | OK (sem alteração, corretamente) | 0 |
| `controlai-frontend/package.json` | OK (sem alteração, corretamente) | 0 |
| `tasks/prd-controlai-web/1_task.md` | OK | 0 |
| `tasks/prd-controlai-web/tasks.md` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`controlai-frontend/.gitignore` — regra redundante.** A linha adicionada `.env*` (linha 35) já cobre `.env.local`, `.env.development.local`, `.env.test.local` e `.env.production.local`, que permanecem listadas individualmente logo acima (linhas 17-20). Não é um bug — apenas ruído deixado pelo `vercel link` — mas vale um commit de limpeza futuro removendo as quatro linhas específicas já cobertas pelo glob. Sem risco: nenhum arquivo `.env*` está hoje versionado (`git ls-files | grep env` vazio).

2. **Adição de `VITE_GOOGLE_WEB_CLIENT_ID` não documentada na tech spec/subtarefas antes do fato.** A tech spec (`Pontos de Integração`) e a subtarefa 1.3 citam explicitamente apenas `VITE_API_BASE_URL`. A necessidade da segunda env var só apareceu ao validar o login com Google em produção (subtarefa 1.4). A decisão de adicioná-la foi correta e dentro do escopo (ver análise abaixo), mas recomendo um ajuste retroativo curto na tech spec (seção `Pontos de Integração`) citando `VITE_GOOGLE_WEB_CLIENT_ID` como env var obrigatória de hospedagem, para que uma futura configuração (ex.: ambiente de disaster-recovery, ou eventual migração para Netlify cogitada na tech spec) não precise redescobrir isso por tentativa e erro.

3. **Padrão coringa de preview ainda não testado contra o backend.** A recomendação `https://controlai-*-ramon-mesquitas-projects.vercel.app` documentada em "Domínios obtidos" é compatível com o mecanismo de `CorsConfiguration.setAllowedOriginPatterns` do Spring (que usa `*` como wildcard simples), mas isso ainda não foi exercitado contra o backend real. Recomendo que a Tarefa 2.0 valide explicitamente uma chamada de um deployment de preview real contra a API antes de considerar o padrão coringa fechado, em vez de assumir que a sintaxe funciona sem teste.

## Destaques Positivos

- **Disciplina de commit/escopo exemplar**: o commit `4d9868e` contém exclusivamente `vercel.json` e `.gitignore`, apesar de o repositório ter, no momento, diversas mudanças não relacionadas em andamento (`e2e/helpers/apiMocks.ts`, `src/App.tsx`, `src/components/BudgetPeriodCard.tsx`, etc., confirmadas via `git status` como não commitadas). Isso evitou contaminar o histórico da Tarefa 1.0 com trabalho de outras tarefas.
- **`vercel.json` correto e mínimo**: usa exatamente o padrão recomendado pela própria Vercel para SPA com roteamento client-side (`IonReactRouter`/browser history) — rewrite catch-all para `index.html`, sem sobre-configuração. Validado empiricamente nesta review (deep link direto não gerou 404).
- **Verificação real de conectividade Git→Vercel**: em vez de apenas confiar no status "already connected" da CLI, a evidência foi fortalecida por um deploy automático real disparado por push — é o tipo de validação que efetivamente comprova o requisito da subtarefa 1.2, não apenas uma configuração declarada.
- **Zero mudança de lógica de negócio**: confirmado tanto pelo diff do commit quanto pela ausência de qualquer arquivo de `src/pages`/`src/components`/`src/services` na lista de arquivos alterados.
- **Reuso correto do vite.config.ts/package.json existentes**: a subtarefa 1.1 foi tratada corretamente como "nenhuma mudança necessária" em vez de forçar uma alteração cosmética só para "mostrar trabalho" — `npm run build` já era `tsc && vite build` puro, isolado de `appflow:build`.
- **Suíte de testes unitários sem regressão** (594 testes / 54 arquivos, conforme reportado) é consistente com a natureza do diff (nenhum arquivo de código-fonte tocado).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (não aplicável — nenhum código de aplicação foi escrito nesta tarefa) |
| TypeScript/Node.js | OK (`npx tsc --noEmit` sem erros no estado atual do repositório) |
| REST/HTTP | OK (nenhum endpoint novo; consumo dos endpoints existentes validado em produção) |
| Logging | N/A |
| React | N/A (nenhum componente novo/alterado) |
| Testes | OK (suíte existente reportada 100% passando; não foi possível re-executar a suíte completa nesta review isoladamente do estado da árvore de trabalho, que contém alterações não relacionadas de outras tarefas em andamento — risco residual baixo dado que o diff da Tarefa 1.0 é restrito a config) |

## Recomendacoes

1. (Minor, não bloqueante) Limpar a redundância em `.gitignore` (`.env*` vs. entradas específicas) em um commit de housekeeping futuro.
2. (Minor, não bloqueante) Adicionar `VITE_GOOGLE_WEB_CLIENT_ID` à seção `Pontos de Integração` da tech spec, retroativamente, como env var obrigatória de hospedagem.
3. (Para a Tarefa 2.0) Validar contra o backend real que o padrão coringa de origem de preview (`https://controlai-*-ramon-mesquitas-projects.vercel.app`) é de fato aceito por `CORS_ALLOWED_ORIGIN_PATTERNS`, com uma chamada real de um deployment de preview, antes de fechar a tarefa de CORS.

## Veredito

**Aprovado com observações.** Nenhum problema crítico ou major foi encontrado; a implementação atende a todos os critérios de sucesso da Tarefa 1.0 (hospedagem pública via HTTPS, login funcional sem erro de CORS bloqueado, nenhuma página/lógica de negócio alterada), com evidência verificada de forma independente nesta review (deploy real, deep link funcionando, diff do commit restrito à configuração). As observações Minor listadas não bloqueiam a Tarefa 2.0 nem exigem retrabalho imediato — são ajustes de documentação/limpeza. A Tarefa 2.0 (CORS) pode prosseguir.

### Pendências fora do repositório (ação do usuário, não deste review)

- Confirmado como já feito pelo usuário durante esta tarefa: adicionar `https://controlai-web-sepia.vercel.app` em "Authorized JavaScript origins" do OAuth Client ID Web no Google Cloud Console. Nenhuma ação adicional pendente aqui.
- Ainda pendente para o futuro (não bloqueia a Tarefa 1.0, mas é pré-requisito da Tarefa 2.0): liberar o(s) domínio(s) documentados em "Domínios obtidos" (`1_task.md`) em `CORS_ALLOWED_ORIGIN_PATTERNS` no ambiente do backend — está fora do escopo desta tarefa e corretamente adiado para a Tarefa 2.0.
- Se e quando URLs de preview adicionais (ex.: de outros branches/PRs) precisarem de acesso ao Google Login, será necessário adicioná-las manualmente em "Authorized JavaScript origins" no Google Cloud Console também — o Google não aceita wildcard nessa configuração (diferente do CORS do backend), então cada preview usado para testar login com Google exigirá esse passo manual.

# Tarefa 1.0: Provisionar hospedagem web e pipeline de build

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Criar o alvo de build "web" do `controlai-frontend` (mesmo repositório do app mobile, sem etapas de Capacitor) e provisionar um projeto Vercel ou Netlify apontando para ele, publicando o `dist/` gerado por `npm run build`. Ao final desta tarefa, o app deve estar acessível por uma URL pública e permitir login/navegação básica contra a API já existente (mesmo sem o shell de navegação desktop, que vem na Tarefa 3.0).

<skills>
### Conformidade com Skills Padrões

- `ionic-design` — aplica-se por reaproveitar o mesmo bundle Ionic React sem alterações de componentes nesta tarefa.
- `clean-code` — aplica-se a qualquer ajuste de configuração de build (scripts, variáveis de ambiente).
</skills>

<requirements>
- Tech Spec `Arquitetura do Sistema`: o build web reaproveita 100% do código-fonte hoje usado pelo mobile; não duplicar o projeto.
- Tech Spec `Pontos de Integração`: variável `VITE_API_BASE_URL` deve apontar para a API de produção (`api.opencod3.com.br`) no ambiente de produção do site, e para o ambiente correto em cada preview.
- Tech Spec `Decisões Principais`: hospedagem Vercel ou Netlify, consistente com a direção já considerada para a landing page comercial.
- Não alterar nenhuma página ou lógica de negócio nesta tarefa — o escopo é exclusivamente infraestrutura de build/deploy.
</requirements>

## Subtarefas

- [x] 1.1 Confirmar/ajustar `vite.config.ts` e `package.json` do `controlai-frontend` para garantir que `npm run build` produza um `dist/` funcional como site puro (sem depender de `cap copy`/`trapeze`, que ficam restritos ao script `appflow:build` já existente para os builds nativos).
- [x] 1.2 Criar o projeto na plataforma escolhida (Vercel ou Netlify), conectado ao repositório `controlai-frontend`, com comando de build `npm run build` e diretório de publicação `dist`.
- [x] 1.3 Configurar a variável de ambiente `VITE_API_BASE_URL` no projeto de hospedagem (produção e preview, se aplicável).
- [x] 1.4 Validar manualmente que a URL pública gerada carrega a tela de login e completa um login de teste contra a API.
- [x] 1.5 Documentar o(s) domínio(s) obtidos (produção e preview) — necessários para a Tarefa 2.0 (CORS).

## Domínios obtidos (para a Tarefa 2.0 — CORS)

- **Plataforma**: Vercel, projeto `ramon-mesquitas-projects/controlai-web`, conectado ao repositório `nomar113/controlai-frontend` (auto-deploy a cada push em `main`).
- **Produção (Vercel)**: `https://controlai-web-sepia.vercel.app`
- **Produção (domínio customizado)**: `https://controlai.opencod3.com.br` — nginx no servidor `root@31.97.83.47` (`/etc/nginx/sites-available/controlai.opencod3.com.br`) faz proxy reverso de `/` para `https://controlai-web-sepia.vercel.app` (SSL/DNS já existentes no domínio, reaproveitados; sem domínio customizado configurado na Vercel). A landing page comercial, que antes ocupava a raiz do domínio, foi movida para `https://controlai.opencod3.com.br/landing-page/` (arquivos estáticos originais em `/var/www/controlai`, servidos via `alias`, sem alteração de conteúdo pois já usava apenas caminhos relativos). Backup do config anterior em `controlai.opencod3.com.br.bak-20260910233156` no servidor.
- **Preview**: URL única por deployment, padrão `https://controlai-<hash>-ramon-mesquitas-projects.vercel.app` (gerada por deployment/branch/PR). Para a Tarefa 2.0, recomenda-se liberar em `CORS_ALLOWED_ORIGIN_PATTERNS` um padrão que cubra `https://controlai-web-sepia.vercel.app` (produção), `https://controlai.opencod3.com.br` (domínio customizado) e um padrão coringa para os previews, ex.: `https://controlai-*-ramon-mesquitas-projects.vercel.app`.
- **Env vars configuradas na Vercel (Production + Preview)**: `VITE_API_BASE_URL=https://api.opencod3.com.br`, `VITE_GOOGLE_WEB_CLIENT_ID` (necessária para o botão "Entrar com Google", que usa Google Identity Services no navegador e valida a origem).
- **Pendência fora do repositório**: resolvida. Ambas as origens — `https://controlai-web-sepia.vercel.app` e `https://controlai.opencod3.com.br` — foram adicionadas em "Authorized JavaScript origins" do OAuth Client ID Web no Google Cloud Console (feito manualmente pelo usuário durante esta tarefa). Login com Google validado em produção nos dois domínios.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (item "Pipeline de deploy") e `Pontos de Integração`.

## Critérios de Sucesso

- Build web publicado e acessível publicamente via HTTPS.
- Login funcional na URL pública contra a API real, sem erros de CORS bloqueados (ou com erro de CORS documentado como esperado até a Tarefa 2.0, caso a origem ainda não esteja liberada).
- Nenhum arquivo de página/lógica de negócio foi alterado nesta tarefa.

## Testes da Tarefa

- [x] Build local (`npm run build`) executa sem erros e gera `dist/` válido.
- [x] Teste manual: acessar a URL pública, realizar login e navegar até o dashboard.
- [x] Testes de integração: nenhum teste automatizado novo é necessário nesta tarefa (infraestrutura); suíte existente (`npm run test.unit`) deve continuar passando sem regressão. (594 testes, 54 arquivos, 100% passando)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/vite.config.ts`
- `controlai-frontend/package.json`
- Configuração externa do projeto Vercel/Netlify (fora do repositório)

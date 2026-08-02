# Tarefa 9.0: E2E Playwright + Migracao/cutover de producao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Fechar a feature: suite E2E Playwright cobrindo os fluxos criticos na web, roteiro de validacao manual no iOS (biometria, Google), e o cutover de producao — backup, deploy com backfill, atualizacao do Atalho do iPhone com a API key, definicao de senha do Ramon e convite a esposa. Ao final, a API esta 100% protegida em producao e o casal acessa os mesmos dados com contas separadas.

<skills>
### Conformidade com Skills Padroes

- `clean-code` — testes E2E legiveis e independentes entre si.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- Metricas do PRD: 0 endpoints de dados sem token; login pelos dois metodos em iOS e web; casal acessando os mesmos dados com duas contas.
- RF-4.5: dados existentes migrados para a conta do Ramon e acessiveis a esposa via compartilhamento, sem perda.
- Continuidade: migracao sem perda de dados nem downtime prolongado; backup do MySQL antes do backfill.
- Automacao do iPhone: Atalho atualizado com `X-Api-Key` ANTES do lockdown do endpoint (sem janela sem captura).
</requirements>

## Subtarefas

- [ ] 9.1 Suite Playwright (web): registro → login → dados vazios; login Ramon → dados legados visiveis; convite entre duas contas → mesmo dado visivel nas duas; logout → redirect `/login`; deep-link em rota protegida sem sessao → `/login`.
- [ ] 9.2 Roteiro de validacao manual iOS (para o QA): Face ID (sucesso/cancelamento/fallback), Google Sign-In no device, reinstalacao do app.
- [ ] 9.3 Checklist de producao: backup MySQL; envs `JWT_SECRET`, `GOOGLE_CLIENT_IDS`, `RESEND_API_KEY`, `APP_WEB_URL`.
- [ ] 9.4 Cutover sequenciado: deploy com migracoes/backfill → Ramon define senha via "esqueci minha senha" (ou entra com Google) → criar API key → atualizar Atalho do iPhone com `X-Api-Key` → validar captura de notificacao → lockdown completo confirmado.
- [ ] 9.5 Convite a esposa: criacao da conta dela, aceite do convite, verificacao dos dados compartilhados em ambas as contas.
- [ ] 9.6 Verificacao pos-deploy: matriz 401 contra producao, metricas `auth.*` no Actuator, mensagens SQS antigas processadas com fallback.

## Detalhes de Implementacao

Ver techspec.md, secoes "Testes de E2E", "Sequenciamento de Desenvolvimento" (etapa 9), "Dependencias Tecnicas" e "Riscos Conhecidos" (automacao do iPhone; backfill).

## Criterios de Sucesso

- Suite Playwright verde e integrada ao fluxo de build do frontend.
- Producao: nenhum endpoint de dados responde sem token; automacao do iPhone segue capturando notificacoes; Ramon e esposa veem os mesmos dados com logins proprios.
- Nenhuma perda de dados verificada pos-migracao (contagens antes/depois).

## Testes da Tarefa

- [ ] Testes E2E Playwright: os 5 fluxos da subtarefa 9.1.
- [ ] Integracao: matriz 401 re-executada como smoke test pos-deploy.
- [ ] Manual: roteiro iOS (biometria, Google, Atalho com API key).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai-frontend/` (suite Playwright, config de E2E)
- `/Volumes/SSD480GB/projects/controlai/src/main/resources/db/migration/` (migracoes ja criadas nas tarefas 1–3, 7, 8)
- Atalho do iPhone (automacao `POST /payments/notification`) — atualizacao manual pelo usuario

Nota de verificacao: E2E local exige backend local com Docker MySQL; dev do frontend aponta para API de producao por padrao.

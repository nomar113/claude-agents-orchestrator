# Tarefa 10.0: Testes E2E Playwright — fluxo crítico desktop

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Criar a suíte Playwright do fluxo crítico do ControlAI Web em viewport desktop, cobrindo login, dashboard, cartões, fatura, registro manual de compra e orçamento — validando de ponta a ponta o que foi construído nas Tarefas 3.0 a 9.0. Usa a configuração Playwright já existente (`playwright.config.ts`, projeto `chromium`/Desktop Chrome).

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — não aplicável diretamente (é teste E2E), mas os seletores devem respeitar os componentes Ionic reais renderizados.
</skills>

<requirements>
- Tech Spec `Abordagem de Testes > Testes de E2E`: fluxo login → dashboard (Tab1) → cartões → fatura → registrar compra manual → orçamento, em viewport desktop, usando o projeto `chromium`/`Desktop Chrome` já configurado.
- Rodar contra o build web local (`webServer` já configurado em `playwright.config.ts`, `http://localhost:5173`) ou contra o ambiente de preview da Tarefa 1.0.
</requirements>

## Subtarefas

- [ ] 10.1 Criar o diretório `e2e/` (referenciado por `testDir` em `playwright.config.ts`) com o primeiro spec: login com credenciais de teste.
- [ ] 10.2 Adicionar passos cobrindo navegação até o dashboard e verificação de dados carregados.
- [ ] 10.3 Adicionar passos cobrindo navegação até cartões e visualização de fatura (detalhe por compra e por período de fechamento).
- [ ] 10.4 Adicionar passos cobrindo registro de uma compra manual via `/manual-entry` a partir do botão "Novo".
- [ ] 10.5 Adicionar passos cobrindo navegação até orçamento e verificação de que a nova compra impacta o resumo do período.
- [ ] 10.6 Rodar a suíte localmente (`npm run test.e2e.pw`) e garantir que passa de forma estável (sem flakiness).

## Detalhes de Implementação

Ver Tech Spec `Abordagem de Testes > Testes de E2E`.

## Critérios de Sucesso

- Suíte Playwright cobre o fluxo crítico completo em viewport desktop e passa de forma consistente.
- Falhas de asserção apontam claramente qual etapa do fluxo quebrou.

## Testes da Tarefa

- [ ] Testes E2E (esta é a própria entrega da tarefa): `npm run test.e2e.pw` passando localmente.
- [ ] Execução da suíte pelo menos 3 vezes seguidas sem flakiness antes de considerar a tarefa concluída.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/playwright.config.ts`
- `controlai-frontend/e2e/critical-flow-desktop.spec.ts` (novo)
- Depende de: Tarefas 3.0 a 9.0 (funcionalidades e telas cobertas pelo fluxo)

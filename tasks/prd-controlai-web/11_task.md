# Tarefa 11.0: Testes E2E Playwright — fluxo crítico em navegador mobile

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Adicionar um segundo projeto Playwright simulando um navegador mobile (ex.: `devices['iPhone 13']`), reaproveitando o mesmo spec de fluxo crítico da Tarefa 10.0, já que o suporte a navegador mobile também é requisito confirmado para o ControlAI Web.

<skills>
### Conformidade com Skills Padroes

- Nenhuma skill de padrão de código específica; segue a mesma convenção Playwright já usada na Tarefa 10.0.
</skills>

<requirements>
- Tech Spec `Abordagem de Testes > Testes de E2E`: "Adicionar um segundo projeto Playwright com viewport mobile ... cobrindo o mesmo fluxo crítico, dado que o suporte a navegador mobile também é requisito".
- Reaproveitar o mesmo spec de teste da Tarefa 10.0 sempre que possível, evitando duplicação de lógica de teste (usar `test.describe`/parametrização por projeto, não copiar o arquivo).
</requirements>

## Subtarefas

- [ ] 11.1 Adicionar um novo `projects` em `playwright.config.ts` usando `devices['iPhone 13']` (ou dispositivo equivalente).
- [ ] 11.2 Confirmar que o spec de fluxo crítico da Tarefa 10.0 roda sob esse novo projeto sem duplicação de código (mesmo arquivo, dois projetos).
- [ ] 11.3 Ajustar seletores/asserções do spec, se necessário, para funcionar tanto em viewport desktop quanto mobile (ex.: elementos que só aparecem via sidebar em desktop vs. tab bar em mobile).
- [ ] 11.4 Rodar a suíte completa (`npm run test.e2e.pw`) cobrindo os dois projetos (`chromium` desktop + mobile) e garantir estabilidade.

## Detalhes de Implementação

Ver Tech Spec `Abordagem de Testes > Testes de E2E`.

## Critérios de Sucesso

- O mesmo fluxo crítico passa tanto em viewport desktop quanto em viewport mobile, sem duplicação de arquivos de teste.
- Diferenças de shell de navegação (sidebar vs. tab bar) são tratadas corretamente pelos seletores do teste.

## Testes da Tarefa

- [ ] Testes E2E (esta é a própria entrega da tarefa): `npm run test.e2e.pw` passando para os dois projetos configurados.
- [ ] Execução da suíte pelo menos 3 vezes seguidas sem flakiness em ambos os projetos antes de considerar a tarefa concluída.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/playwright.config.ts`
- `controlai-frontend/e2e/critical-flow-desktop.spec.ts` (reaproveitado, possivelmente renomeado para refletir uso em ambos os projetos)
- Depende de: Tarefa 10.0
